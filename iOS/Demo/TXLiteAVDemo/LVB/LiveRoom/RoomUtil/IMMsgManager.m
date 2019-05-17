//
//  IMMsgManager.m
//  TXLiteAVDemo
//
//  Created by lijie on 2017/11/1.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "IMMsgManager.h"
#import "ImSDK/ImSDK.h"
#import <mach/mach_time.h>

#define CMD_PUSHER_CHANGE      @"notifyPusherChange"
#define CMD_CUSTOM_TEXT_MSG    @"CustomTextMsg"
#define CMD_CUSTOM_CMD_MSG     @"CustomCmdMsg"
#define CMD_LINK_MIC           @"linkmic"
#define CMD_PK                 @"pk"

#define ErrMsg(x) [@"[IM] " stringByAppendingString:x]

@interface IMMsgManager() <TIMMessageListener, TIMGroupEventListener, TIMUserStatusListener> {
    MLVBLoginInfo     *_config;
    dispatch_queue_t     _queue;
    
    NSString             *_groupID;           // 群ID
    TIMConversation      *_groupConversation;  // 群会话上下文
}

@property (nonatomic, assign) BOOL     isOwner;  // 是否是群主
@property (nonatomic, copy) NSString   *ownerGroupID;

@end

@implementation IMMsgManager
- (instancetype)initWithConfig:(MLVBLoginInfo *)config {
    if (self = [super init]) {
        _config = config;
        _queue = dispatch_queue_create("RoomMsgMgrQueue", DISPATCH_QUEUE_SERIAL);
        
        TIMSdkConfig *sdkConfig = [[TIMSdkConfig alloc] init];
        sdkConfig.sdkAppId = config.sdkAppID;
        sdkConfig.logLevel = TIM_LOG_NONE;
        TIMUserConfig *config = [[TIMUserConfig alloc] init];
        config.userStatusListener = self;
        [[TIMManager sharedInstance] setUserConfig:config];
        [[TIMManager sharedInstance] initSdk:sdkConfig];
        [[TIMManager sharedInstance] addMessageListener:self];
        _groupID = @"0";
        _isOwner = NO;
    }
    return self;
}

- (void)dealloc {
    [[TIMManager sharedInstance] removeMessageListener:self];
}

- (void)asyncRun:(void(^)(void))block {
    dispatch_async(_queue, ^{
        block();
    });
}

- (void)syncRun:(void(^)(void))block {
    dispatch_sync(_queue, ^{
        block();
    });
}

- (void)switchGroup:(NSString *)groupID {
    _groupID = groupID;
    _groupConversation = [[TIMManager sharedInstance] getConversation:TIM_GROUP receiver:groupID];
}

#pragma mark - Time
double getSystemUptime(void)
{
    enum { NANOSECONDS_IN_MS = 1000 * 1000 };
    static double multiply = 0;
    if (multiply == 0)
    {
        mach_timebase_info_data_t s_timebase_info;
        kern_return_t result = mach_timebase_info(&s_timebase_info);
        assert(result == noErr);
        // multiply to get value in the nano seconds
        multiply = (double)s_timebase_info.numer / (double)s_timebase_info.denom;
        // multiply to get value in the microseconds
        multiply /= NANOSECONDS_IN_MS;
    }
    return mach_absolute_time() * multiply;
}

- (void)setLoginServerTime:(uint64_t)loginServerTime {
    _loginServerTime = loginServerTime;
    _loginUptime = getSystemUptime();
    NSLog(@"[IM] setLoginServerTime: %llu, %llu", _loginServerTime, _loginUptime);
}

- (uint64_t)currentTimestamp {
    uint64_t elapse = getSystemUptime() - _loginUptime;
    return _loginServerTime + elapse;
}

- (BOOL)isExpired:(uint64_t)timestamp {
    uint64_t current = [self currentTimestamp];
    NSLog(@"current: %llu, timestamp: %llu", current, timestamp);
    uint64_t diff;
    if (current > timestamp) {
        diff = current - timestamp;
    } else {
        diff = timestamp - current;
    }
    return diff > 10000;
}

#pragma mark -
- (void)loginWithCompletion:(void(^)(int errCode, NSString *errMsg))completion {
    [self asyncRun:^{
        TIMLoginParam *param = [[TIMLoginParam alloc] init];
        param.identifier = self->_config.userID;
        param.userSig    = self->_config.userSig;
        param.appidAt3rd = [NSString stringWithFormat:@"%d", self->_config.sdkAppID];
        [[TIMManager sharedInstance] login:param succ:^{
            if (completion) {
                completion(0, nil);
            }
        } fail:^(int code, NSString *msg) {
            if (completion) {
                completion(code, ErrMsg(msg));
            }
        }];
    }];
}

- (void)logout:(void(^)(int errCode, NSString *errMsg))completion {
    [self asyncRun:^{
        [[TIMManager sharedInstance] logout:^{
            if (completion) {
                completion(0, nil);
            }
        } fail:^(int code, NSString *msg) {
            if (completion) {
                completion(code, ErrMsg(msg));
            }
        }];
    }];
}

- (void)enterRoom:(NSString *)groupID completion:(void(^)(int errCode, NSString *errMsg))completion {
    [self asyncRun:^{
        __weak __typeof(self) weakSelf = self;
        [[TIMGroupManager sharedInstance] joinGroup:groupID msg:nil succ:^{
            //切换群会话的上下文环境
            [weakSelf switchGroup:groupID];
            
            if (completion) {
                completion(0, nil);
            }
            
        } fail:^(int code, NSString *msg) {
            if (completion) {
                completion(code, ErrMsg(msg));
            }
        }];
    }];
}

- (void)quitGroup:(NSString *)groupID completion:(void(^)(int errCode, NSString *errMsg))completion {
    [self asyncRun:^{
        // 如果是群主，那么就解散该群，如果不是群主，那就退出该群
        if (self->_isOwner && [self->_ownerGroupID isEqualToString:groupID]) {
            [[TIMGroupManager sharedInstance] deleteGroup:groupID succ:^{
                if (completion) {
                    completion(0, nil);
                }
            } fail:^(int code, NSString *msg) {
                if (completion) {
                    completion(code, ErrMsg(msg));
                }
            }];
            
        } else {
            [[TIMGroupManager sharedInstance] quitGroup:groupID succ:^{
                if (completion) {
                    completion(0, nil);
                }
            } fail:^(int code, NSString *msg) {
                if (completion) {
                    completion(code, ErrMsg(msg));
                }
            }];
        }
    }];
}

- (void)sendNotifyMessage {
    TIMCustomElem *elem = [[TIMCustomElem alloc] init];
    NSDictionary *data = @{@"cmd": CMD_PUSHER_CHANGE};
    [elem setData:[self dictionary2JsonData:data]];
    
    TIMMessage *msg = [[TIMMessage alloc] init];
    [msg addElem:elem];
    
    if (_groupConversation) {
        [_groupConversation sendMessage:msg succ:^{
            NSLog(@"sendCustomMessage success");
        } fail:^(int code, NSString *msg) {
            NSLog(@"sendCustomMessage failed, data[%@]", data);
        }];
    }
}

// CustomElem{"cmd":"CustomCmdMsg", "data":{"userName":"xxx", "userAvatar":"xxx", "cmd":"xx", msg:"xx"}}
- (void)sendRoomCustomMsg:(NSString *)cmd msg:(NSString *)msg completion:(void (^)(int errCode, NSString *errMsg))completion {
    [self asyncRun:^{
        TIMCustomElem *elem = [[TIMCustomElem alloc] init];
        NSDictionary *data = @{@"cmd": cmd, @"msg": msg == nil ? @"" : msg};
        NSDictionary *customMsg = @{@"userName":self->_config.userName, @"userAvatar":self->_config.userAvatar, @"cmd": CMD_CUSTOM_CMD_MSG, @"data": data};
        [elem setData:[self dictionary2JsonData:customMsg]];
        
        TIMMessage *msg = [[TIMMessage alloc] init];
        [msg addElem:elem];
        
        if (self->_groupConversation) {
            [self->_groupConversation sendMessage:msg succ:^{
                NSLog(@"sendCustomMessage success");
                if (completion) completion(0, nil);
            } fail:^(int code, NSString *msg) {
                NSLog(@"sendCustomMessage failed, data[%@]", data);
                if (completion) completion(code, msg);
            }];
        }
    }];
}

- (void)sendCCCustomMessage:(NSString *)userID data:(NSData *)data completion:(void(^)(int code, NSString *msg))completion {
    TIMCustomElem *elem = [[TIMCustomElem alloc] init];
    [elem setData:data];
    
    TIMMessage *msg = [[TIMMessage alloc] init];
    [msg addElem:elem];
    
    TIMConversation *conversation = [[TIMManager sharedInstance] getConversation:TIM_C2C receiver:userID];
    if (conversation) {
        [conversation sendMessage:msg succ:^{
            NSLog(@"sendCCCustomMessage success");
            if (completion) {
                completion(0, nil);
            }
        } fail:^(int code, NSString *msg) {
            NSLog(@"sendCCCustomMessage failed, data[%@]", data);
            if (completion) {
                completion(code, ErrMsg(msg));
            }
        }];
    }
}

// 一条消息两个Elem：CustomElem{“cmd”:”CustomTextMsg”, “data”:{nickName:“xx”, headPic:”xx”}} + TextElem
- (void)sendGroupTextMsg:(NSString *)textMsg  completion:(void (^)(int errCode, NSString *errMsg))completion {
    [self asyncRun:^{
        TIMCustomElem *msgHead = [[TIMCustomElem alloc] init];
        NSDictionary *userInfo = @{@"nickName": self->_config.userName, @"headPic": self->_config.userAvatar};
        NSDictionary *headData = @{@"cmd": CMD_CUSTOM_TEXT_MSG, @"data": userInfo};
        msgHead.data = [self dictionary2JsonData:headData];
        
        TIMTextElem *msgBody = [[TIMTextElem alloc] init];
        msgBody.text = textMsg;
        
        TIMMessage *msg = [[TIMMessage alloc] init];
        [msg addElem:msgHead];
        [msg addElem:msgBody];
        
        if (self->_groupConversation) {
            [self->_groupConversation sendMessage:msg succ:^{
                NSLog(@"sendGroupTextMsg success");
                if (completion) completion(0, nil);
            } fail:^(int code, NSString *msg) {
                NSLog(@"sendGroupTextMsg failed, textMsg[%@]", textMsg);
                if (completion) completion(code, msg);
            }];
        }
    }];
}

#pragma mark - Group Management
- (void)createGroupWithID:(NSString *)groupID name:(NSString *)groupName completion:(void(^)(int errCode, NSString *errMsg))completion {
    // TODO: Test if initialization finished
    __weak __typeof(self) wself = self;
    [TIMGroupManager.sharedInstance createGroup:@"AVChatRoom" groupId:groupID groupName:groupName succ:^(NSString *groupId) {
        __strong __typeof(wself) self = wself;
        [self switchGroup:groupId];
        if (completion) {
            completion(0, nil);
        }
    } fail:^(int code, NSString *msg) {
        if (code == 10025) {
            code = 0;
            NSLog(@"群组 %@ 已被使用，并且操作者为群主，可以直接使用", groupID);
            [self switchGroup:groupID];
        }
        completion(code, ErrMsg(msg));
    }];
}

- (void)deleteGroupWithID:(NSString *)groupID completion:(void(^)(int errCode, NSString *errMsg))completion {
    [TIMGroupManager.sharedInstance deleteGroup:groupID succ:^{
        if (completion) {
            completion(0, nil);
        }
    } fail:^(int code, NSString *msg) {
        if (completion) {
            completion(code, ErrMsg(msg));
        }
    }];
}

- (void)getGroupMemberList:(NSString *)groupID completion:(void(^)(int code, NSString *msg, NSArray <MLVBAudienceInfo *>* members))completion
{
    [TIMGroupManager.sharedInstance getGroupMembers:groupID succ:^(NSArray<TIMGroupMemberInfo*> *members) {
        NSMutableArray *userIds = [NSMutableArray arrayWithCapacity:members.count];
        for (TIMGroupMemberInfo *info in members) {
            if (info.role != TIM_GROUP_MEMBER_ROLE_SUPER) {
                [userIds addObject:info.member];
            }
        }
        [TIMFriendshipManager.sharedInstance getUsersProfile:userIds
                                                 forceUpdate:YES
                                                        succ:^(NSArray<TIMUserProfile *> *profiles) {
                                                            NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:members.count];
                                                            for (TIMUserProfile *profile in profiles) {
                                                                MLVBAudienceInfo *info = [[MLVBAudienceInfo alloc] init];
                                                                info.userID = profile.identifier;
                                                                info.userName = profile.nickname;
                                                                info.userAvatar = profile.faceURL;
                                                                [result addObject:info];
                                                            }
                                                            completion(0, nil, result);
                                                        } fail:^(int code, NSString *msg) {
                                                            completion(code, ErrMsg(msg), nil);
                                                        }];
    } fail:^(int code, NSString *msg) {
        completion(code, ErrMsg(msg), nil);
    }];
}
#pragma mark - TIMMessageListener

- (void)onNewMessage:(NSArray*)msgs {
    [self asyncRun:^{
        for (TIMMessage *msg in msgs) {
            TIMConversationType type = msg.getConversation.getType;
            switch (type) {
                case TIM_C2C:
                    [self onRecvC2CMsg:msg];
                    break;
                    
                case TIM_SYSTEM:
                    [self onRecvSystemMsg:msg];
                    break;
                    
                case TIM_GROUP:
                    // 目前只处理当前群消息
                    if ([[msg.getConversation getReceiver] isEqualToString:self->_groupID]) {
                        [self onRecvGroupMsg:msg];
                    }
                    break;
                    
                default:
                    break;
            }
        }
    }];
}

- (void)onRecvC2CMsg:(TIMMessage *)msg {
    for (int idx = 0; idx < [msg elemCount]; ++idx) {
        TIMElem *elem = [msg getElem:idx];
        
        if ([elem isKindOfClass:[TIMCustomElem class]]) {
            TIMCustomElem *customElem = (TIMCustomElem *)elem;
            NSDictionary *dict = [self jsonData2Dictionary:customElem.data];
            
            NSString *cmd = nil;
            id data = nil;
            if (dict) {
                cmd = dict[@"cmd"];
                data = dict[@"data"];
            }
            
            // 连麦相关的消息
            if (cmd && [cmd isEqualToString:CMD_LINK_MIC] && [data isKindOfClass:[NSDictionary class]]) {
                NSString *type = data[@"type"];
                uint64_t timestamp = [data[@"timestamp"] unsignedLongLongValue];
                if ([self isExpired:timestamp]) {
                    return;
                }
                if (type && [type isEqualToString:@"request"]) {
                    NSString *message = data[@"reason"];
                    if (_delegate && [_delegate respondsToSelector:@selector(onRecvJoinAnchorRequest:userID:userName:userAvatar:reason:)]) {
                        [_delegate onRecvJoinAnchorRequest:data[@"roomID"] userID:msg.sender userName:data[@"userName"] userAvatar:data[@"userAvatar"] reason:message];
                    }
                } else if (type && [type isEqualToString:@"response"]) {
                    NSString *resultStr = data[@"result"];
                    NSString *message = data[@"reason"];
                    NSString *roomID = data[@"roomID"];
                    BOOL result = NO;
                    if (resultStr && [resultStr isEqualToString:@"accept"]) {
                        result = YES;
                    }
                    if (_delegate && [_delegate respondsToSelector:@selector(onRecvJoinAnchorResponse:result:message:)]) {
                        [_delegate onRecvJoinAnchorResponse:roomID result:result message:message];
                    }
                    
                } else if (type && [type isEqualToString:@"kickout"]) {
                    NSString *roomID = data[@"roomID"];
                    if (_delegate && [_delegate respondsToSelector:@selector(onRecvJoinAnchorKickout:)]) {
                        [_delegate onRecvJoinAnchorKickout:roomID];
                    }
                }
            }
            // 跨房主播PK相关的消息
            else if (cmd && [cmd isEqualToString:CMD_PK] && [data isKindOfClass:[NSDictionary class]]) {
                NSString *type = data[@"type"];
                uint64_t timestamp = [data[@"timestamp"] unsignedLongLongValue];
                if ([self isExpired:timestamp]) {
                    return;
                }
                
                if (type && [type isEqualToString:@"request"]) {
                    NSString *action = data[@"action"];
                    if (action && [action isEqualToString:@"start"]) {  // 收到PK请求的消息
                        if (_delegate && [_delegate respondsToSelector:@selector(onRequestRoomPK:userID:userName:userAvatar:streamUrl:)]) {
                            [_delegate onRequestRoomPK:data[@"roomID"] userID:msg.sender userName:data[@"userName"] userAvatar:data[@"userAvatar"] streamUrl:data[@"accelerateURL"]];
                        }
                        
                    } else if (action && [action isEqualToString:@"stop"]) { // 收到PK结束的消息
                        if (_delegate && [_delegate respondsToSelector:@selector(onRecvPKFinishRequest:userID:)]) {
                            [_delegate onRecvPKFinishRequest:data[@"roomID"] userID:msg.sender];
                        }
                    }
                    
                } else if (type && [type isEqualToString:@"response"]) {
                    NSString *result = data[@"result"];
                    if (result && [result isEqualToString:@"accept"]) {  // 收到接收PK的消息
                        if (_delegate && [_delegate respondsToSelector:@selector(onRecvPKResponse:userID:result:message:streamUrl:)]) {
                            [_delegate onRecvPKResponse:data[@"roomID"] userID:msg.sender result:YES message:@"" streamUrl:data[@"accelerateURL"]];
                        }
                        
                    } else if (result && [result isEqualToString:@"reject"]) {  // 收到拒绝PK的消息
                        if (_delegate && [_delegate respondsToSelector:@selector(onRecvPKResponse:userID:result:message:streamUrl:)]) {
                            [_delegate onRecvPKResponse:data[@"roomID"] userID:msg.sender result:NO message:data[@"reason"] streamUrl:nil];
                        }
                    }
                }
            }
        }
    }
}

- (void)onRecvSystemMsg:(TIMMessage *)msg {
    for (int idx = 0; idx < [msg elemCount]; ++idx) {
        TIMElem *elem = [msg getElem:idx];
        
        if ([elem isKindOfClass:[TIMGroupSystemElem class]]) {
            TIMGroupSystemElem *sysElem = (TIMGroupSystemElem *)elem;
            if ([sysElem.group isEqualToString:_groupID]) {
                if (sysElem.type == TIM_GROUP_SYSTEM_DELETE_GROUP_TYPE) {  // 群被解散
                    if (_delegate) {
                        [_delegate onGroupDelete:_groupID];
                    }
                }
                else if (sysElem.type == TIM_GROUP_SYSTEM_CUSTOM_INFO) {  // 用户自定义通知(默认全员接收)
                    NSDictionary *dict = [self jsonData2Dictionary:sysElem.userData];
                    if (dict == nil) {
                        break;
                    }
                    
                    NSString *cmd = dict[@"cmd"];
                    if (cmd == nil) {
                        break;
                    }
                    
                    // 群成员有变化
                    if ([cmd isEqualToString:CMD_PUSHER_CHANGE]) {
                        if (_delegate) {
                            [_delegate onMemberChange:_groupID];
                        }
                    }
                }
            }
        }
    }
}

- (void)onRecvGroupMsg:(TIMMessage *)msg {
    NSString *cmd = nil;
    id data = nil;
    
    for (int idx = 0; idx < [msg elemCount]; ++idx) {
        TIMElem *elem = [msg getElem:idx];
        
        if ([elem isKindOfClass:[TIMCustomElem class]]) {
            TIMCustomElem *customElem = (TIMCustomElem *)elem;
            NSDictionary *dict = [self jsonData2Dictionary:customElem.data];
            if (dict) {
                cmd = dict[@"cmd"];
                data = dict[@"data"];
            }
            
            // 群自定义消息处理
            if (cmd && [cmd isEqualToString:CMD_CUSTOM_CMD_MSG] && [data isKindOfClass:[NSDictionary class]]) {
                if (_delegate && [_delegate respondsToSelector:@selector(onRecvGroupCustomMsg:userID:cmd:msg:userName:userAvatar:)]) {
                    [_delegate onRecvGroupCustomMsg:_groupID userID:msg.sender cmd:data[@"cmd"] msg:data[@"msg"] userName:data[@"userName"] userAvatar:data[@"userAvatar"]];
                }
            } else if ([cmd isEqualToString:CMD_PUSHER_CHANGE]) {
                [_delegate onMemberChange:_groupID];
            }
        } else if ([elem isKindOfClass:[TIMTextElem class]]) {
            TIMTextElem *textElem = (TIMTextElem *)elem;
            NSString *msgText = textElem.text;
            
            // 群文本消息处理
            if ([cmd isEqualToString:CMD_CUSTOM_TEXT_MSG] && [data isKindOfClass:[NSDictionary class]]) {
                NSDictionary *userInfo = (NSDictionary *)data;
                NSString *nickName = nil;
                NSString *headPic = nil;
                if (userInfo) {
                    nickName = userInfo[@"nickName"];
                    headPic = userInfo[@"headPic"];
                }
                
                if (_delegate) {
                    [_delegate onRecvGroupTextMsg:_groupID userID:msg.sender textMsg:msgText userName:nickName userAvatar:headPic];
                }
            } else if ([cmd isEqualToString:CMD_PUSHER_CHANGE]) {
                [_delegate onMemberChange:_groupID];
            }
        } else if ([elem isKindOfClass:[TIMGroupTipsElem class]]) {
            NSLog(@"group tip message received: %@", elem);
            TIMGroupTipsElem *tips = (TIMGroupTipsElem *)elem;
            MLVBAudienceInfo *info = [[MLVBAudienceInfo alloc] init];
            info.userID = tips.opUserInfo.identifier;
            info.userName = tips.opUserInfo.nickname;
            info.userAvatar = tips.opUserInfo.faceURL;
            if (tips.type == TIM_GROUP_TIPS_TYPE_QUIT_GRP) {
                [self.delegate onGroupMemberLeave:_groupID user:info];
            } else if (tips.type == TIM_GROUP_TIPS_TYPE_INVITE) {
                [self.delegate onGroupMemberEnter:_groupID user:info];
            }
        }
    }
}

#pragma mark - TIMUserStatusListener
/**
 *  踢下线通知
 */
- (void)onForceOffline
{
    if ([self.delegate respondsToSelector:@selector(onForceOffline)]) {
        [self.delegate onForceOffline];
    }
}

#pragma mark - utils

- (NSData *)dictionary2JsonData:(NSDictionary *)dict {
    if ([NSJSONSerialization isValidJSONObject:dict]) {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
        if (error) {
            NSLog(@"dictionary2JsonData failed: %@", dict);
            return nil;
        }
        return data;
    }
    return nil;
}

- (NSDictionary *)jsonData2Dictionary:(NSData *)jsonData {
    if (jsonData == nil) {
        return nil;
    }
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if (err) {
        NSLog(@"JjsonData2Dictionary failed: %@", jsonData);
        return nil;
    }
    return dic;
}

#pragma mark - 连麦

// 向userID发起连麦请求
// {cmd:"linkmic", data:{type: “request”, roomID:”xxx”, userID:"xxxx", userName:"xxxx", userAvatar:"xxxx"}}
- (void)sendJoinAnchorRequest:(NSString *)userID roomID:(NSString *)roomID {
    [self asyncRun:^{
        NSDictionary *data = @{@"type": @"request",
                               @"roomID":roomID,
                               @"userID":self->_config.userID,
                               @"userName":self->_config.userName,
                               @"userAvatar":self->_config.userAvatar,
                               @"timestamp": @([self currentTimestamp])
                               };
        NSDictionary *msgDic = @{@"cmd": CMD_LINK_MIC, @"data":data};
        
        [self sendCCCustomMessage:userID data:[self dictionary2JsonData:msgDic] completion:nil];
    }];
}

// 向userID发起连麦响应，result为："accept“ or "reject"
// {cmd:"linkmic", data:{type: “response”, roomID:”xxx”, result: "xxxx"，message:"xxxx }}
- (void)sendJoinAnchorResponseWithUID:(NSString *)userID roomID:(NSString*)roomID result:(BOOL)result reason:(NSString *)reason {
    [self asyncRun:^{
        NSString *resultStr = @"reject";
        if (result) {
            resultStr = @"accept";
        }
        NSDictionary *data = @{@"type": @"response", @"roomID":roomID, @"result":resultStr, @"reason":reason ?: @"", @"timestamp": @([self currentTimestamp])};
        NSDictionary *msgDic = @{@"cmd": CMD_LINK_MIC, @"data":data};
        
        [self sendCCCustomMessage:userID data:[self dictionary2JsonData:msgDic] completion:nil];
    }];
}

// 群主向userID发出踢出连麦消息
// {cmd:"linkmic", data:{type: "kickout”, roomID:”xxx”}}
- (void)sendJoinAnchorKickout:(NSString *)userID roomID:(NSString *)roomID {
    [self asyncRun:^{
        NSDictionary *data = @{@"type": @"kickout", @"roomID":roomID, @"timestamp": @([self currentTimestamp])};
        NSDictionary *msgDic = @{@"cmd": CMD_LINK_MIC, @"data":data};
        
        [self sendCCCustomMessage:userID data:[self dictionary2JsonData:msgDic] completion:nil];
    }];
}

// 向userID发起PK请求
// {"cmd":"pk", "data":{"roomID":"XXX", "type":"request", "action":"start", "userID":"XXX", "userName":"XXX", "userAvatar":"XXX", "accelerateURL":"XXX"} }
- (void)sendPKRequest:(NSString *)userID roomID:(NSString *)roomID withAccelerateURL:(NSString *)accelerateURL {
    [self asyncRun:^{
        NSDictionary *data = @{@"roomID":roomID, @"type": @"request", @"action": @"start", @"userID": self->_config.userID,
                               @"userName": self->_config.userName, @"userAvatar": self->_config.userAvatar,
                               @"accelerateURL": accelerateURL, @"timestamp": @([self currentTimestamp])};
        NSDictionary *msgDic = @{@"cmd": CMD_PK, @"data": data};
        
        [self sendCCCustomMessage:userID data:[self dictionary2JsonData:msgDic] completion:nil];
    }];
}

// 请求结束PK
// {"cmd":"pk", "data":{"roomID":"XXX", "type":"request", "action":"stop", "userID":"XXX", "userName":"XXX", "userAvatar":"XXX"} }
- (void)sendPKFinishRequest:(NSString *)userID roomID:(NSString *)roomID completion:(void(^)(int errCode, NSString *errMsg))completion {
    [self asyncRun:^{
        NSDictionary *data = @{@"roomID":roomID, @"type": @"request", @"action": @"stop", @"userID": self->_config.userID,
                               @"userName": self->_config.userName, @"userAvatar": self->_config.userAvatar,
                               @"timestamp": @([self currentTimestamp])};
        NSDictionary *msgDic = @{@"cmd": CMD_PK, @"data": data};
        
        [self sendCCCustomMessage:userID data:[self dictionary2JsonData:msgDic] completion:completion];
    }];
}

// 接收PK
// {"cmd":"pk", "data":{"roomID":"XXX", "type":"response", "result":"accept",  "reason":"" , "accelerateURL":"XXX"} }
- (void)acceptPKRequest:(NSString *)userID roomID:(NSString *)roomID withAccelerateURL:(NSString *)accelerateURL {
    [self asyncRun:^{
        NSDictionary *data = @{@"roomID":roomID, @"type": @"response", @"result": @"accept", @"reason": @"",
                               @"accelerateURL": accelerateURL, @"timestamp": @([self currentTimestamp])};
        NSDictionary *msgDic = @{@"cmd": CMD_PK, @"data": data};
        
        [self sendCCCustomMessage:userID data:[self dictionary2JsonData:msgDic] completion:nil];
    }];
}

// 拒绝PK
// {"cmd":"pk", "data":{"roomID":"XXX",  "type":"response", "result":"reject",  "reason":"" } }
- (void)rejectPKRequest:(NSString *)userID roomID:(NSString *)roomID reason:(NSString *)reason {
    [self asyncRun:^{
        NSDictionary *data = @{@"roomID":roomID, @"type": @"response", @"result": @"reject", @"reason": reason, @"timestamp": @([self currentTimestamp])};
        NSDictionary *msgDic = @{@"cmd": CMD_PK, @"data": data};
        
        [self sendCCCustomMessage:userID data:[self dictionary2JsonData:msgDic] completion:nil];
    }];
}

#pragma mark - 个人信息
-(void)setSelfProfile:(NSString *)userName avatarURL:(NSString*)avatarURL completion:(void(^)(int code, NSString *msg))completion {
    NSDictionary *profile = @{TIMProfileTypeKey_Nick:userName,
                              TIMProfileTypeKey_FaceUrl:avatarURL};
    [[TIMFriendshipManager sharedInstance] modifySelfProfile:profile succ:^{
        NSLog(@"[IM} modifySelfProfile succeed");
        if (completion) {
            completion(0, nil);
        }
    } fail:^(int code, NSString *msg) {
        NSLog(@"[IM} modifySelfProfile failed: %d, %@", code, msg);
        if (completion) {
            completion(code, ErrMsg(msg));
        }
    }];
}

- (void)getProfile:(void(^)(int code, NSString *msg, NSString *nickname, NSString *avatar))completion
{
    if (completion == nil) return;
    [[TIMFriendshipManager sharedInstance] getSelfProfile:^(TIMUserProfile *profile) {
        completion(0, nil, profile.nickname, profile.faceURL);
    } fail:^(int code, NSString *msg) {
        completion(code, msg, nil, nil);
    }];
}
@end
