//
//  TUIPusherSignalingService.m
//  Alamofire
//
//  Created by gg on 2021/9/8.
//

#import "TUIPusherSignalingService.h"
#import <ImSDK_Plus/ImSDK_Plus.h>
#import "TUIPusherSignalingHelper.h"
#import "TUIPusherHeader.h"
#import <TUICore/TUILogin.h>

@interface TUIPusherSignalingService () <V2TIMSignalingListener>

@property (nonatomic, weak) id <TUIPusherSignalingServiceDelegate> delegate;

@property (nonatomic, copy) NSString *currentPKInviteId;
@property (nonatomic, copy) NSString *currentPKStreamId;
@property (nonatomic, copy) NSString *currentPKRequestUserId;

@property (nonatomic, copy) NSString *currentLinkMicInviteId;
@property (nonatomic, copy) NSString *currentLinkMicUserId;
@end

@implementation TUIPusherSignalingService

- (instancetype)init {
    if (self = [super init]) {
        [[V2TIMManager sharedInstance] addSignalingListener:self];
    }
    return self;
}

- (void)setDelegate:(id<TUIPusherSignalingServiceDelegate>)delegate {
    _delegate = delegate;
}

- (BOOL)checkLoginStatus {
    V2TIMLoginStatus res = [[V2TIMManager sharedInstance] getLoginStatus];
    return res == V2TIM_STATUS_LOGINED;
}

#pragma mark - PK
- (BOOL)requestPK:(NSString *)userId {
    NSDictionary *signaling = [TUIPusherSignalingHelper requestPkSignaling:[TUILogin getUserID]];
    NSString *jsonStr = [self dic2JsonStr:signaling];
    @weakify(self)
    NSString *inviteId = [[V2TIMManager sharedInstance] invite:userId data:jsonStr onlineUserOnly:YES offlinePushInfo:nil timeout:30 succ:^{
        
    } fail:^(int code, NSString *desc) {
        @strongify(self)
        if ([self.delegate respondsToSelector:@selector(onSignalingError:code:message:)]) {
            [self.delegate onSignalingError:PUSHER_SIGNALING_VALUE_DATA_CMD_PK_REQ code:code message:desc];
        }
    }];
    if (inviteId != nil) {
        self.currentPKInviteId = inviteId;
        self.currentPKRequestUserId = userId;
    }
    return inviteId != nil;
}

- (void)cancelPKRequest {
    if (self.currentPKInviteId) {
        NSDictionary *signaling = [TUIPusherSignalingHelper cancelPkSignaling];
        NSString *jsonStr = [self dic2JsonStr:signaling];
        [[V2TIMManager sharedInstance] cancel:self.currentPKInviteId data:jsonStr succ:^{
            
        } fail:^(int code, NSString *desc) {
            
        }];
        if ([self.delegate respondsToSelector:@selector(onCancelPK:)]) {
            [self.delegate onCancelPK:PUSHER_SIGNALING_VALUE_DATA_CMD_PK_CANCEL];
        }
        self.currentPKInviteId = nil;
        self.currentPKRequestUserId = nil;
    }
}

- (void)acceptPK:(NSString *)streamId {
    if (self.currentPKInviteId != nil) {
        NSDictionary *signaling = [TUIPusherSignalingHelper acceptPkSignaling:streamId];
        NSString *jsonStr = [self dic2JsonStr:signaling];
        @weakify(self)
        [[V2TIMManager sharedInstance] accept:self.currentPKInviteId data:jsonStr succ:^{
            
        } fail:^(int code, NSString *desc) {
            @strongify(self)
            if ([self.delegate respondsToSelector:@selector(onSignalingError:code:message:)]) {
                [self.delegate onSignalingError:PUSHER_SIGNALING_VALUE_DATA_CMD_PK_RES code:code message:desc];
            }
        }];
        self.currentPKInviteId = nil;
    }
}

- (void)rejectPKWithReason:(TUIPusherRejectReason)reason {
    if (self.currentPKInviteId != nil) {
        NSDictionary *signaling = [TUIPusherSignalingHelper rejectPkSignaling:(int)reason];
        NSString *jsonStr = [self dic2JsonStr:signaling];
        @weakify(self)
        [[V2TIMManager sharedInstance] reject:self.currentPKInviteId data:jsonStr succ:^{
            
        } fail:^(int code, NSString *desc) {
            @strongify(self)
            if ([self.delegate respondsToSelector:@selector(onSignalingError:code:message:)]) {
                [self.delegate onSignalingError:PUSHER_SIGNALING_VALUE_DATA_CMD_PK_RES code:code message:desc];
            }
        }];
        self.currentPKInviteId = nil;
        self.currentPKRequestUserId = nil;
    }
}

- (void)stopPK {
    if (self.currentPKRequestUserId != nil) {
        NSDictionary *signaling = [TUIPusherSignalingHelper stopPkReqSignaling];
        NSString *jsonStr = [self dic2JsonStr:signaling];
        @weakify(self)
        [[V2TIMManager sharedInstance] invite:self.currentPKRequestUserId data:jsonStr onlineUserOnly:YES offlinePushInfo:nil timeout:30 succ:^{
            @strongify(self)
            self.currentPKRequestUserId = nil;
            if ([self.delegate respondsToSelector:@selector(onStopPK:)]) {
                [self.delegate onStopPK:PUSHER_SIGNALING_VALUE_DATA_CMD_PK_STOP_REQ];
            }
        } fail:^(int code, NSString *desc) {
            @strongify(self)
            if ([self.delegate respondsToSelector:@selector(onSignalingError:code:message:)]) {
                [self.delegate onSignalingError:PUSHER_SIGNALING_VALUE_DATA_CMD_PK_STOP_REQ code:code message:desc];
            }
        }];
    }
}

#pragma mark - Link Mic

- (void)acceptLinkMic:(NSString *)streamId {
    if (self.currentLinkMicInviteId != nil) {
        NSDictionary *signaling = [TUIPusherSignalingHelper acceptLinkMicSignaling:streamId];
        NSString *jsonStr = [self dic2JsonStr:signaling];
        [[V2TIMManager sharedInstance] accept:self.currentLinkMicInviteId data:jsonStr succ:^{
            
        } fail:^(int code, NSString *desc) {
            
        }];
        self.currentLinkMicInviteId = nil;
    }
}

- (void)rejectLinkMic:(TUIPusherRejectReason)reason {
    if (self.currentLinkMicInviteId != nil) {
        NSDictionary *signaling = [TUIPusherSignalingHelper rejectLinkMicSignaling:(int)reason];
        NSString *jsonStr = [self dic2JsonStr:signaling];
        [[V2TIMManager sharedInstance] reject:self.currentLinkMicInviteId data:jsonStr succ:^{
            
        } fail:^(int code, NSString *desc) {
            
        }];
        self.currentLinkMicInviteId = nil;
    }
}

- (void)stopLinkMic {
    if (self.currentLinkMicUserId != nil) {
        NSDictionary *signaling = [TUIPusherSignalingHelper stopLinkMicReqSignaling];
        NSString *jsonStr = [self dic2JsonStr:signaling];
        [[V2TIMManager sharedInstance] invite:self.currentLinkMicUserId data:jsonStr onlineUserOnly:YES offlinePushInfo:nil timeout:30 succ:^{
            
        } fail:^(int code, NSString *desc) {
            
        }];
        if ([self.delegate respondsToSelector:@selector(onStopLinkMic:)]) {
            [self.delegate onStopLinkMic:PUSHER_PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_STOP_REQ];
        }
        self.currentLinkMicUserId = nil;
    }
}

- (NSString *)dic2JsonStr:(NSDictionary *)dic {
    NSError *err = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&err];
    if (err) {
        return @"";
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSDictionary *)jsonStr2Dic:(NSString *)str {
    if (!str) {
        return @{};
    }
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (err) {
        return @{};
    }
    return res;
}

- (BOOL)validateSignalingHeader:(NSDictionary *)dic {
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    if ([dic.allKeys containsObject:PUSHER_SIGNALING_KEY_VERSION]) {
        int version = [dic[PUSHER_SIGNALING_KEY_VERSION] intValue];
        if (version < PUSHER_SIGNALING_VALUE_VERSION) {
            return NO;
        }
    }
    else {
        return NO;
    }
    if ([dic.allKeys containsObject:PUSHER_SIGNALING_KEY_BUSINESSID]) {
        NSString *businessId = dic[PUSHER_SIGNALING_KEY_BUSINESSID];
        if (![businessId isEqualToString:PUSHER_SIGNALING_VALUE_BUSINESSID] && ![businessId isEqualToString:PUSHER_PLAYER_SIGNALING_VALUE_BUSINESSID]) {
            return NO;
        }
    }
    else {
        return NO;
    }
    return YES;
}

#pragma mark - V2TIMSignalingListener
/// 收到邀请的回调
-(void)onReceiveNewInvitation:(NSString *)inviteID inviter:(NSString *)inviter groupID:(NSString *)groupID inviteeList:(NSArray<NSString *> *)inviteeList data:(NSString *)data {
    LOGD("【Pusher】recv invitaion: [%@] %@", inviter, data);
    NSDictionary *dic = [self jsonStr2Dic:data];
    if (![self validateSignalingHeader:dic]) {
        return;
    }
    if (![dic.allKeys containsObject:PUSHER_SIGNALING_KEY_DATA]) {
        return;
    }
    NSDictionary *dataDic = dic[PUSHER_SIGNALING_KEY_DATA];
    if (![dataDic.allKeys containsObject:PUSHER_SIGNALING_KEY_DATA_CMD]) {
        return;
    }
    NSString *cmd = dataDic[PUSHER_SIGNALING_KEY_DATA_CMD];
    NSString *streamId = dataDic[PUSHER_SIGNALING_KEY_DATA_STREAMID];
    if ([cmd isEqualToString:PUSHER_SIGNALING_VALUE_DATA_CMD_PK_STOP_REQ]) {
        // stop PK
        if ([self.delegate respondsToSelector:@selector(onStopPK:)]) {
            [self.delegate onStopPK:cmd];
        }
        self.currentPKRequestUserId = nil;
        
        NSDictionary *signaling = [TUIPusherSignalingHelper stopPkResSignaling];
        NSString *jsonStr = [self dic2JsonStr:signaling];
        [[V2TIMManager sharedInstance] accept:inviteID data:jsonStr succ:nil fail:nil];
    }
    else if ([cmd isEqualToString:PUSHER_SIGNALING_VALUE_DATA_CMD_PK_REQ]) {
        // request PK
        if (self.currentPKInviteId && [self.currentPKInviteId isKindOfClass:[NSString class]] && self.currentPKInviteId.length > 0) {
            // 如果当前正在处理其它用户的PK申请, 将新的申请拒绝掉， 避免PK混乱
            NSDictionary *signaling = [TUIPusherSignalingHelper rejectPkSignaling:(int)TUIPusherRejectReasonBusy];
            NSString *jsonStr = [self dic2JsonStr:signaling];
            [[V2TIMManager sharedInstance] reject:inviteID data:jsonStr succ:^{
                
            } fail:^(int code, NSString *desc) {
                
            }];
            return;
        }
        self.currentPKInviteId = inviteID;
        self.currentPKRequestUserId = inviter;
        if ([self.delegate respondsToSelector:@selector(onReceivePKInvite:cmd:streamId:)]) {
            [self.delegate onReceivePKInvite:inviter cmd:cmd streamId:streamId];
        }
    }
    else if ([cmd isEqualToString:PUSHER_PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_REQ]) {
        // request Link Mic
        if (self.currentLinkMicInviteId && [self.currentLinkMicInviteId isKindOfClass:[NSString class]] && self.currentLinkMicInviteId.length > 0) {
            // 如果当前正在处理其它用户的连麦申请, 将新的连麦申请拒绝掉， 避免连麦混乱
            NSDictionary *signaling = [TUIPusherSignalingHelper rejectLinkMicSignaling:(int)TUIPusherRejectReasonBusy];
            NSString *jsonStr = [self dic2JsonStr:signaling];
            [[V2TIMManager sharedInstance] reject:inviteID data:jsonStr succ:^{
                
            } fail:^(int code, NSString *desc) {
                
            }];
            return;
        }
        self.currentLinkMicInviteId = inviteID;
        self.currentLinkMicUserId = inviter;
        if ([self.delegate respondsToSelector:@selector(onReceiveLinkMicInvite:cmd:streamId:)]) {
            [self.delegate onReceiveLinkMicInvite:inviter cmd:cmd streamId:streamId];
        }
    }
    else if ([cmd isEqualToString:PUSHER_PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_START_REQ]) {
        // start Link mic
        if ([self.delegate respondsToSelector:@selector(onStartLinkMic:streamId:)]) {
            [self.delegate onStartLinkMic:cmd streamId:streamId];
        }
        
        NSDictionary *signaling = [TUIPusherSignalingHelper startLinkMicResSignaling];
        NSString *jsonStr = [self dic2JsonStr:signaling];
        [[V2TIMManager sharedInstance] accept:inviteID data:jsonStr succ:nil fail:nil];
    }
    else if ([cmd isEqualToString:PUSHER_PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_STOP_REQ]) {
        // stop Link mic
        if ([self.delegate respondsToSelector:@selector(onStopLinkMic:)]) {
            [self.delegate onStopLinkMic:cmd];
        }
        self.currentLinkMicUserId = nil;
        
        NSDictionary *signaling = [TUIPusherSignalingHelper stopLinkMicResSignaling];
        NSString *jsonStr = [self dic2JsonStr:signaling];
        [[V2TIMManager sharedInstance] accept:inviteID data:jsonStr succ:nil fail:nil];
    }
}

/// 被邀请者接受邀请
-(void)onInviteeAccepted:(NSString *)inviteID invitee:(NSString *)invitee data:(NSString *)data {
    LOGD("【Pusher】invite accept: [%@] %@", invitee, data);
    if ([invitee isEqualToString:[TUILogin getUserID]]) {
        return;
    }
    NSDictionary *dic = [self jsonStr2Dic:data];
    if (![self validateSignalingHeader:dic]) {
        return;
    }
    if (![dic.allKeys containsObject:PUSHER_SIGNALING_KEY_DATA]) {
        return;
    }
    NSDictionary *dataDic = dic[PUSHER_SIGNALING_KEY_DATA];
    if (![dataDic.allKeys containsObject:PUSHER_SIGNALING_KEY_DATA_CMD]) {
        return;
    }
    NSString *cmd = dataDic[PUSHER_SIGNALING_KEY_DATA_CMD];
    if ([cmd isEqualToString:PUSHER_SIGNALING_VALUE_DATA_CMD_PK_RES]) {
        self.currentPKInviteId = nil;
        NSString *streamId = dataDic[PUSHER_SIGNALING_KEY_DATA_STREAMID];
        if ([self.delegate respondsToSelector:@selector(onAcceptPKInvite:streamId:)]) {
            [self.delegate onAcceptPKInvite:cmd streamId:streamId];
        }
    }
}

/// 被邀请者拒绝邀请
-(void)onInviteeRejected:(NSString *)inviteID invitee:(NSString *)invitee data:(NSString *)data {
    LOGD("【Pusher】invite reject: [%@] %@", invitee, data);
    if ([invitee isEqualToString:[TUILogin getUserID]]) {
        return;
    }
    NSDictionary *dic = [self jsonStr2Dic:data];
    if (![self validateSignalingHeader:dic]) {
        return;
    }
    if (![dic.allKeys containsObject:PUSHER_SIGNALING_KEY_DATA]) {
        return;
    }
    NSDictionary *dataDic = dic[PUSHER_SIGNALING_KEY_DATA];
    if (![dataDic.allKeys containsObject:PUSHER_SIGNALING_KEY_DATA_CMD]) {
        return;
    }
    NSString *cmd = dataDic[PUSHER_SIGNALING_KEY_DATA_CMD];
    NSString *reason = nil;
    if ([dataDic.allKeys containsObject:PUSHER_SIGNALING_KEY_DATA_CMD_INFO]) {
        reason = dataDic[PUSHER_SIGNALING_KEY_DATA_CMD_INFO];
        if (reason.length != 1) {
            reason = nil;
        }
        else {
            int value = [reason intValue];
            if (value != TUIPusherRejectReasonNormal && value != TUIPusherRejectReasonBusy) {
                reason = nil;
            }
        }
    }
    if ([cmd isEqualToString:PUSHER_SIGNALING_VALUE_DATA_CMD_PK_RES] && reason != nil) {
        self.currentPKInviteId = nil;
        self.currentPKRequestUserId = nil;
        if ([self.delegate respondsToSelector:@selector(onRejectPKInvite:reason:)]) {
            [self.delegate onRejectPKInvite:cmd reason:[reason intValue]];
        }
    }
}

/// 邀请被取消
-(void)onInvitationCancelled:(NSString *)inviteID inviter:(NSString *)inviter data:(NSString *)data {
    LOGD("【Pusher】invite cancel: [%@] %@", inviter, data);
    NSDictionary *dic = [self jsonStr2Dic:data];
    if (![self validateSignalingHeader:dic]) {
        return;
    }
    if (![dic.allKeys containsObject:PUSHER_SIGNALING_KEY_DATA]) {
        return;
    }
    NSDictionary *dataDic = dic[PUSHER_SIGNALING_KEY_DATA];
    if (![dataDic.allKeys containsObject:PUSHER_SIGNALING_KEY_DATA_CMD]) {
        return;
    }
    NSString *cmd = dataDic[PUSHER_SIGNALING_KEY_DATA_CMD];
    if ([cmd isEqualToString:PUSHER_SIGNALING_VALUE_DATA_CMD_PK_CANCEL]) {
        self.currentPKInviteId = nil;
        self.currentPKRequestUserId = nil;
        if ([self.delegate respondsToSelector:@selector(onCancelPK:)]) {
            [self.delegate onCancelPK:cmd];
        }
    }
    else if ([cmd isEqualToString:PUSHER_PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_CANCEL]) {
        self.currentLinkMicUserId = nil;
        self.currentLinkMicInviteId = nil;
        if ([self.delegate respondsToSelector:@selector(onCancelLinkMic:)]) {
            [self.delegate onCancelLinkMic:cmd];
        }
    }
}

/// 邀请超时
-(void)onInvitationTimeout:(NSString *)inviteID inviteeList:(NSArray<NSString *> *)inviteeList {
    LOGD("【Pusher】invite timeout: [%@] %@", inviteeList);
    if (self.currentPKInviteId != nil && [inviteID isEqualToString:self.currentPKInviteId]) {
        self.currentPKInviteId = nil;
        self.currentPKRequestUserId = nil;
        if ([self.delegate respondsToSelector:@selector(onPKInviteTimeout)]) {
            [self.delegate onPKInviteTimeout];
        }
    }
    else if (self.currentLinkMicInviteId != nil && [inviteID isEqualToString:self.currentLinkMicInviteId]) {
        self.currentLinkMicInviteId = nil;
        self.currentLinkMicUserId = nil;
        if ([self.delegate respondsToSelector:@selector(onLinkMicInviteTimeout)]) {
            [self.delegate onLinkMicInviteTimeout];
        }
    }
}

@end
