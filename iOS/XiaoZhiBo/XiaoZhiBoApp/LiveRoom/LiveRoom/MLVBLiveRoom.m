//
//  MLVBLiveRoom.m
//  TXLiteAVDemo
//
//  Created by lijie on 2017/10/30.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "MLVBLiveRoom.h"
#import "TXLiveSDKTypeDef.h"
#import "TXLivePush.h"
#import "TXLivePlayer.h"
#import "AFNetworking.h"
#import "IMMsgManager.h"
#import "RoomUtil.h"
#import <pthread.h>

@interface MLVBProxy : NSProxy {
    MLVBLiveRoom *_object;
}
- (instancetype)initWithInstance:(MLVBLiveRoom *)cloud;
- (void)destroy;
@end

// 业务服务器API
#define ServerAddr                      @"https://liveroom.qcloud.com/weapp/live_room"

#define kHttpServerAddr_GetRoomList     @"get_room_list"
#define kHttpServerAddr_GetAudienceList @"get_audiences"
#define kHttpServerAddr_GetAnchorUrl    @"get_anchor_url"
#define kHttpServerAddr_GetAnchors      @"get_anchors"
#define kHttpServerAddr_CreateRoom      @"create_room"
#define kHttpServerAddr_AddAnchor       @"add_anchor"
#define kHttpServerAddr_DeleteAnchor    @"delete_anchor"
#define kHttpServerAddr_AddAudience     @"add_audience"
#define kHttpServerAddr_DeleteAudience  @"delete_audience"
#define kHttpServerAddr_AnchorHeartBeat @"anchor_heartbeat"
#define kHttpServerAddr_Logout          @"logout"
#define kHttpServerAddr_MergeStream     @"merge_stream"
#define kHttpServerAddr_SetCustomField  @"set_custom_field"
#define kHttpServerAddr_GetCustomInfo  @"get_custom_Info"

static NSString * const RespCodeKey = @"code";

typedef NS_ENUM(int, RoomRole) {
    RoomRoleCreator = 1,
    RoomRoleMinor   = 2,
    RoomRoleMember  = 3
};

typedef NS_ENUM(NSUInteger, StreamMixMode) {
    StreamMixModeJoinAnchor,
    StreamMixModePK
};

/// 连麦请求超时等待时间
static const NSTimeInterval JoinAnchorRequestTimeout = 10;
/// PK请求超时等待时间
static const NSTimeInterval PKRequestTimeout = 10;

@interface MLVBLiveRoom() <TXLivePushListener, IRoomLivePlayListener, IMMsgManagerDelegate> {
    TXLivePush              *_livePusher;
    NSMutableDictionary<NSString *, RoomLivePlayerWrapper*> *_playerWrapperDic; // [userID, RoomLivePlayerWrapper]
    NSArray<MLVBRoomInfo *>     *_roomList;      // 保存最近一次拉回的房间列表，这里仅仅使用里面的房间混流地址和创建者信息
    NSMutableArray<MLVBAudienceInfo *> *_audienceList;  // 保存最近一次拉回的房间观众列表
    AFHTTPSessionManager    *_httpSession;
    NSString                *_serverDomain;   // 保存业务服务器域名
    NSMutableDictionary     *_apiAddr;        // 保存业务服务器相关的rest api
    
    MLVBLoginInfo           *_currentUser;
    NSString                *_pushUrl;
    NSString                *_accUrl;
    
    dispatch_source_t       _heartBeatTimer;
    dispatch_queue_t        _queue;
    
    RoomRole                _roomRole;        // 房间角色，创建者(大主播):1  小主播:2  普通观众:3
    BOOL                    _created;         // 标记是否已经创建过房间
    int                     _videoQuality;    // 保存当前推流的视频质量
    int                     _renderMode;
    BOOL                    _inBackground;
    StreamMixMode           _mixMode;
}
@property (nonatomic, strong) MLVBAnchorInfo *pkAnchor;
@property (atomic, strong) IMMsgManager      * msgMgr;
/// getAnchors 会返回一个code, 作为etag, 心跳时变了就返回pusher列表
@property (nonatomic, strong) NSNumber *roomStatusCode;
@property (nonatomic, copy) void(^createRoomCompletion)(int errCode, NSString *reason);
@property (nonatomic, copy) void(^joinAnchorCompletion)(int errCode, NSString *reason);
@property (nonatomic, copy) void(^requestAnchorCompletion)(int errCode, NSString *reason);

@property (nonatomic, copy) IRequestPKCompletionHandler requestPKCompletion;

/// 注意这个RoomInfo里面的anchorInfoArray不包含自己
@property (nonatomic, strong) MLVBRoomInfo *roomInfo;
@property (nonatomic, copy) NSString *roomCreatorPlayerURL;
@end

static MLVBProxy *sharedInstance = nil;
static pthread_mutex_t sharedInstanceLock;

@implementation MLVBLiveRoom
+ (void)load {
    pthread_mutex_init(&sharedInstanceLock, NULL);
}

+ (instancetype)sharedInstance {
    if (sharedInstance == nil) {
        pthread_mutex_lock(&sharedInstanceLock);
        if (sharedInstance == nil) {
            MLVBLiveRoom *liveRoom = [[MLVBLiveRoom alloc] initInternal];
            sharedInstance = [[MLVBProxy alloc] initWithInstance:liveRoom];
            NSLog(@"sharedInstance<%p> is created", sharedInstance);
        }
        pthread_mutex_unlock(&sharedInstanceLock);
    }
    return (MLVBLiveRoom*)sharedInstance;
}

+ (void)destorySharedInstance {
    pthread_mutex_lock(&sharedInstanceLock);
    if (sharedInstance) {
        [sharedInstance destroy];
        NSLog(@"sharedInstance<%p> is destroyed", sharedInstance);
        sharedInstance = nil;
    }
    pthread_mutex_unlock(&sharedInstanceLock);
}

- (instancetype)initInternal {
    if (self = [super init]) {
        _serverDomain = ServerAddr;
        [self initLivePusher];
        _playerWrapperDic = [[NSMutableDictionary alloc] init];
        _delegateQueue = dispatch_get_main_queue();
        _roomInfo = [[MLVBRoomInfo alloc] init];
        _audienceList = [[NSMutableArray alloc] init];
        _httpSession = [AFHTTPSessionManager manager];
        [_httpSession setRequestSerializer:[AFJSONRequestSerializer serializer]];
        [_httpSession setResponseSerializer:[AFJSONResponseSerializer serializer]];
        [_httpSession.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        _httpSession.requestSerializer.timeoutInterval = 5.0;
        [_httpSession.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        _httpSession.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/xml", @"text/plain", nil];
        
        _queue = dispatch_queue_create("LiveRoomQueue", DISPATCH_QUEUE_SERIAL);
        [_httpSession setCompletionQueue:_queue];
        
        _created = NO;
        _inBackground = NO;
        _renderMode = -1;
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(willResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [center addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)initLivePusher {
    if (_livePusher == nil) {
        TXLivePushConfig *config = [[TXLivePushConfig alloc] init];
        config.pauseImg = [UIImage imageNamed:@"pause_publish.jpg"];
        config.pauseFps = 15;
        config.pauseTime = 300;
        
        _videoQuality = VIDEO_QUALITY_HIGH_DEFINITION;
        _livePusher = [[TXLivePush alloc] initWithConfig:config];
        _livePusher.delegate = self;
        [_livePusher setVideoQuality:_videoQuality adjustBitrate:NO adjustResolution:NO];
        [_livePusher setLogViewMargin:UIEdgeInsetsMake(120, 10, 60, 10)];
        config.videoEncodeGop = 2;
        [_livePusher setConfig:config];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_httpSession invalidateSessionCancelingTasks:NO];
    [self stopHeartBeat];
}

#pragma mark -
- (void)releaseLivePusher {
    if (_livePusher) {
        _livePusher.delegate = nil;
        _livePusher = nil;
    }
}

- (void)asyncRun:(void(^)(MLVBLiveRoom *self))block {
    __weak __typeof(self) wself = self;
    dispatch_async(_queue, ^{
        __strong __typeof(wself) self = wself;
        if (self) {
            block(self);
        }
    });
}

#pragma mark - API Generator
- (NSString *)getApiAddr:(NSString *)api userID:(NSString*)userID token:(NSString*)token {
    return [NSString stringWithFormat:@"%@/%@?userID=%@&token=%@", _serverDomain, api, userID, token];
}

// 保存所有server API
- (void)initApiAddr:(NSString*)userID token:(NSString*)token {
    _apiAddr = [[NSMutableDictionary alloc] init];
    NSArray *apiList = @[
                          kHttpServerAddr_GetRoomList
                         ,kHttpServerAddr_GetAudienceList
                         ,kHttpServerAddr_GetAnchorUrl
                         ,kHttpServerAddr_GetAnchors
                         ,kHttpServerAddr_CreateRoom
                         ,kHttpServerAddr_AddAnchor
                         ,kHttpServerAddr_DeleteAnchor
                         ,kHttpServerAddr_AnchorHeartBeat
                         ,kHttpServerAddr_AddAudience
                         ,kHttpServerAddr_DeleteAudience
                         ,kHttpServerAddr_MergeStream
                         ,kHttpServerAddr_GetCustomInfo
                         ,kHttpServerAddr_SetCustomField
                         ,kHttpServerAddr_Logout];
    
    for (NSString *api in apiList) {
        _apiAddr[api] = [self getApiAddr:api userID:userID token:token];
    }
}

#pragma mark - SDK 基础函数
/**
 1. Room登录
 2. IM初始化及登录
 */
- (void)loginWithInfo:(MLVBLoginInfo *)loginInfo completion:(void(^)(int, NSString*))completion {
    __weak __typeof(self) weakSelf = self;
    [self login:loginInfo.sdkAppID userID:loginInfo.userID userSig:loginInfo.userSig completion:^(int errCode, NSString *errMsg, NSString *userID, NSString *token, NSNumber *timestamp) {
        __strong __typeof(weakSelf) self = weakSelf;
        if (self == nil) return;
        if (errCode == ROOM_SUCCESS) {
            [self initApiAddr: loginInfo.userID token:token];
            
            // 初始化userInfo
            self->_currentUser = [loginInfo copy];
            // 初始化 RoomMsgMgr 并登录
            self-> _msgMgr = [[IMMsgManager alloc] initWithConfig:loginInfo];
            [self->_msgMgr setDelegate:self];
            
            [self sendDebugMsg:[NSString stringWithFormat:@"初始化IMSDK: appID[%d] userID[%@] timestamp[%@]", loginInfo.sdkAppID, loginInfo.userID, timestamp]];
            
            [self->_msgMgr loginWithCompletion:^(int errCode, NSString *errMsg) {
                [weakSelf asyncRun:^(MLVBLiveRoom *self){
                    [self sendDebugMsg:[NSString stringWithFormat:@"IM登录返回: errCode[%d] errMsg[%@]", errCode, errMsg]];
                    if (completion) {
                        if (errCode == 0) {
                            [self setSelfProfile:loginInfo.userName avatarURL:loginInfo.userAvatar completion:nil];
                            completion(0, @"登录成功");
                        } else if (errCode != 0) {
                            completion(ROOM_ERR_IM_LOGIN, @"登录失败");
                        }
                    }
                }];
            }];
            self->_msgMgr.loginServerTime = [timestamp unsignedLongLongValue];
        } else {
            [weakSelf sendDebugMsg:[NSString stringWithFormat:@"初始化LiveRoom失败: errorCode[%d] errorMsg[%@]", errCode, errMsg]];
            completion(errCode, errMsg);
        }
    }];
}

/**
 Room退出
 */
-(void)logout {
    [self asyncRun:^(MLVBLiveRoom *self) {
        if (self->_apiAddr == nil) {
            return;
        }
        [self stopHeartBeat];
        __weak __typeof(self) weakSelf = self;
        [self exitRoom:^(int errCode, NSString *errMsg) {
            __strong __typeof(weakSelf) self = weakSelf;
            if (!self) return;
            // Room退出
            [self requestWithName:kHttpServerAddr_Logout params:nil completion:^(MLVBLiveRoom *self, int errCode, NSString *errMsg, NSDictionary *responseObject) {
                NSLog(@"MLVBLiveRoom logout with code: %d, msg: %@", errCode, errMsg);
            }];
            
            self->_currentUser = nil;
            self->_created = NO;
            self->_msgMgr.delegate = nil;
            [self->_msgMgr logout:nil];
            self->_msgMgr = nil;
            self->_apiAddr = nil;
            [self releaseLivePusher];
            [self->_playerWrapperDic removeAllObjects];
            self->_roomList = nil;
        }];
    }];
}

-(void)setSelfProfile:(NSString *)userName avatarURL:(NSString*)avatarURL completion:(void(^)(int code, NSString *msg))completion
{
    __weak __typeof(self) wself = self;
    [_msgMgr setSelfProfile:userName avatarURL:avatarURL completion:^(int code, NSString *msg) {
        if (code == 0) {
            __strong __typeof(wself) self = wself;
            if (self) {
                self->_currentUser.userName = userName;
                self->_currentUser.userAvatar = avatarURL;
            }
        }
    }];
}

#pragma mark - 被踢
- (void)onForceOffline {
    [self.delegate onError:ROOM_ERR_IM_FORCE_OFFLINE errMsg:@"IM 被强制下线" extraInfo:nil];
}

#pragma mark - 前后台切换
- (void)willResignActive:(NSNotification *)notification {
    [_livePusher pausePush];
    _inBackground = YES;
}

- (void)didBecomeActive:(NSNotification *)notification {
    [_livePusher resumePush];
    
    [self asyncRun:^(MLVBLiveRoom *self) {
        [self->_playerWrapperDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, RoomLivePlayerWrapper * _Nonnull wrapper, BOOL * _Nonnull stop) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [wrapper.player resume];
            });
        }];
    }];
    
    _inBackground = NO;
    
    if (_livePusher && [_livePusher isPublishing]) {
        [self updateAnchorList];
    }
}

#pragma mark - 房间相关接口函数
- (void)getRoomList:(int)index count:(int)count completion:(IGetRoomListCompletionHandler)completion {
    [self asyncRun:^(MLVBLiveRoom *self) {
        NSDictionary *params = @{@"cnt": @(count), @"index": @(index)};
        [self sendDebugMsg:[NSString stringWithFormat:@"发起获取房间列表请求: index[%d] cnt[%d]", index, count]];
        [self requestWithName:kHttpServerAddr_GetRoomList params:params completion:^(MLVBLiveRoom *self, int errCode, NSString *errMsg, NSDictionary *responseObject) {
            NSArray<MLVBRoomInfo *> *roomList = [self parseRoomListFromResponse:responseObject];
            if (self) {
                self->_roomList = roomList;
            }
            if (completion) {
                if (errCode == 0) {
                    completion(errCode, errMsg, roomList);
                } else {
                    completion(errCode, [NSString stringWithFormat:@"%@[%d]", errMsg, errCode], nil);
                }
            }
        }];
    }];
}

- (void)onGroupMemberEnter:(NSString *)group user:(MLVBAudienceInfo *)audienceInfo {
    [self asyncRun:^(MLVBLiveRoom *self) {
        [self->_audienceList addObject:audienceInfo];
        dispatch_async(self.delegateQueue, ^{
            if ([self.delegate respondsToSelector:@selector(onAudienceEnter:)]) {
                [self.delegate onAudienceEnter:audienceInfo];
            }
        });
    }];
}

- (void)onGroupMemberLeave:(NSString *)group user:(MLVBAudienceInfo *)audienceInfo {
    [self asyncRun:^(MLVBLiveRoom *self) {
        [self->_audienceList removeObject:audienceInfo];
        dispatch_async(self.delegateQueue, ^{
            if ([self.delegate respondsToSelector:@selector(onAudienceExit:)]) {
                [self.delegate onAudienceExit:audienceInfo];
            }
        });
    }];
}

- (void)getAudienceList:(NSString *)roomID completion:(void(^)(int errCode, NSString *errMsg, NSArray<MLVBAudienceInfo *> *audienceInfoArray))completion {
    [self asyncRun:^(MLVBLiveRoom *self) {
        if (self->_audienceList.count == 0) {
            [self->_msgMgr getGroupMemberList:roomID completion:^(int code, NSString *msg, NSArray<MLVBAudienceInfo *> *members) {
                if (code != 0) {
                    completion(code, msg, nil);
                } else {
                    [self asyncRun:^(MLVBLiveRoom *self) {
                        [self->_audienceList setArray:members];
                    }];
                    completion(0, nil, members);
                }
            }];
        } else {
            completion(0, 0, [self->_audienceList copy]);
        }
    }];
}

/**
 大主播
 1. 在应用层调用startLocalPreview
 2. 请求kHttpServerAddr_GetAnchorUrl,获取推流地址
 3. 开始推流
 4. 在收到推流成功的事件后请求kHttpServerAddr_CreateRoom，获取roomID
 5. 加入IM Group (groupID就是第4步请求到的roomID)
 */
- (void)createRoom:(NSString *)roomID roomInfo:(NSString *)roomName completion:(void(^)(int errCode, NSString *errMsg))completion {
    [self asyncRun:^(MLVBLiveRoom *self) {
        self->_roomRole = RoomRoleCreator;  // 房间角色为创建者
        MLVBRoomInfo *roomInfo = [[MLVBRoomInfo alloc] init];
        roomInfo.roomID = roomID;
        roomInfo.roomInfo = roomName;
        roomInfo.roomCreator = self->_currentUser.userID;
        self.roomInfo = roomInfo;
        self.createRoomCompletion = completion;
        [self getUrlAndPushing:completion];
        // onPushBegin 后创建IM房间并回调
    }];
}

- (RoomLivePlayerWrapper *)playerWrapperForUserID:(NSString *)userID {
    RoomLivePlayerWrapper *playerWrapper = self->_playerWrapperDic[userID];
    if (!playerWrapper) {
        playerWrapper = [[RoomLivePlayerWrapper alloc] init];
        playerWrapper.userID = userID;
        playerWrapper.delegate = self;
        [playerWrapper.player setRenderMode:RENDER_MODE_FILL_EDGE];
        
        self->_playerWrapperDic[userID] = playerWrapper;
    }
    return playerWrapper;
}

/**
 观众
 1. 加入IM Group
 2. 播放房间的混流播放地址
 */
- (void)enterRoom:(NSString *)roomID view:(UIView *)view completion:(void(^)(int errCode, NSString *errMsg))completion {
    __weak __typeof(self) weakSelf = self;
    
    [self asyncRun:^(MLVBLiveRoom *self){
        self->_roomRole = RoomRoleMember;  // 房间角色为普通观众
        self.roomInfo = [[MLVBRoomInfo alloc] init];
        self.roomInfo.roomID = roomID;
        
        NSString *groupID = roomID;
        
        [self->_msgMgr enterRoom:groupID completion:^(int errCode, NSString *errMsg) {
            [weakSelf asyncRun:^(MLVBLiveRoom *self) {
                [self sendDebugMsg:[NSString stringWithFormat:@"加入IMGroup完成: errCode[%d] errMsg[%@]", errCode, errMsg]];
                if (errCode == 0) {
                    
                    // 找到当前房间
                    MLVBRoomInfo *roomInfo = nil;
                    for (MLVBRoomInfo *info in self->_roomList) {
                        if ([info.roomID isEqualToString:roomID]) {
                            roomInfo = info;
                            break;
                        }
                    }
                    
                    if (roomInfo == nil) {
                        self.roomInfo = nil;
                        if (completion) {
                            NSString *message = [NSString stringWithFormat:@"进房失败\n获取房间信息失败"];
                            completion(ROOM_ERR_ENTER_ROOM, message);
                        }
                        return;
                    }
                    
                    
                    // 保存大主播ID和房间混流地址
                    self.roomInfo = roomInfo;
                    
                    // 播放房间混流地址，注意这里是按直播模式播放
                    RoomLivePlayerWrapper *playerWrapper = [self playerWrapperForUserID:self.roomInfo.roomCreator];
                    playerWrapper.playErrorBlock = ^(int event, NSString *msg) {
                        dispatch_async(self.delegateQueue, ^{
                            [self.delegate onError:event errMsg:@"播放地址无效或者当前没有数据" extraInfo:nil];
                        });
                    };
                    TXLivePlayer *player = playerWrapper.player;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        TXLivePlayConfig *playConfig = [[TXLivePlayConfig alloc] init];
                        playConfig.bAutoAdjustCacheTime = YES;
                        playConfig.minAutoAdjustCacheTime = 2.0f;
                        playConfig.maxAutoAdjustCacheTime = 2.0f;
                        [player setupVideoWidget:CGRectZero containView:view insertIndex:0];
                        [player setConfig:playConfig];
                        [player stopPlay];
                        [player startPlay:self.roomInfo.mixedPlayURL type:[self getPlayType:self.roomInfo.mixedPlayURL]];
                        [player setLogViewMargin:UIEdgeInsetsMake(120, 10, 60, 10)];
                    });
                    
                    // 作为普通观众，调用CGI：add_audience
                    NSError *parseError = nil;
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"userName":self->_currentUser.userName, @"userAvatar":self->_currentUser.userAvatar} options:NSJSONWritingPrettyPrinted error:&parseError];
                    NSString *userInfo = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                    [self doAddAudience:roomID userID:self->_currentUser.userID userInfo:userInfo completion:^(int errCode, NSString *errMsg) {
                        
                    }];
                    
                    if (completion) {
                        completion(errCode, errMsg);
                    }
                }
                else {
                    if (completion) {
                        NSString *message = [NSString stringWithFormat:@"进房失败\nIM:%@", errMsg];
                        completion(ROOM_ERR_ENTER_ROOM, message);
                    }
                }
                
            }];
        }];
    }];
}

/**
 1. stopLocalPreview
 2. 调用stopPush
 3. 退出IM房间
 4. 结束播放所有的流
 5. 请求 kHttpServerAddr_DeleteAnchor
 
 如果是普通观众，则只需要调用第3、4步
 */
- (void)exitRoom:(void(^)(int errCode, NSString *errMsg))completion {
    __weak __typeof(self) weakSelf = self;
    [self asyncRun:^(MLVBLiveRoom *self){
        // 上层存在没有获取到roomID也调用exitRoom的情况
        if (!self.roomInfo.roomID) {
            return;
        }
        
        [self->_livePusher stopPush];
        if (self->_requestAnchorCompletion) {
            self->_requestAnchorCompletion(ROOM_ERR_CANCELED, @"Exit Room");
            self->_requestAnchorCompletion = nil;
        }
        if (self->_requestPKCompletion) {
            self->_requestPKCompletion(ROOM_ERR_CANCELED, @"Exit Room", nil);
            self->_requestPKCompletion = nil;
        }
        if (self.joinAnchorCompletion) {
            self.joinAnchorCompletion(ROOM_ERR_CANCELED, @"Exit Room");
            self.joinAnchorCompletion = nil;
        }
        if (self.createRoomCompletion) {
            self.createRoomCompletion(ROOM_ERR_CANCELED, @"Exit Room");
            self.createRoomCompletion = nil;
        }
        
        NSString *groupID = self.roomInfo.roomID;
        IMMsgManager *IMManager = self->_msgMgr;
        
        if (self->_roomRole == RoomRoleCreator) {
            // 解散IM群组
            [IMManager deleteGroupWithID:groupID completion:nil];
        } else {
            [self notifyAnchorChange];
            // 退出IM群组
            [IMManager quitGroup:groupID completion:^(int errCode, NSString *errMsg) {
                [weakSelf sendDebugMsg:[NSString stringWithFormat:@"离开IM Group完成: errCode[%d] errMsg[%@]", errCode, errMsg]];
            }];
        }
        
        // 作为连麦者退出房间（不区分大、小主播、普通观众）
        [self doDeleteAnchorWithRoomID:self.roomInfo.roomID userID:self->_currentUser.userID completion:completion];
        
        // 作为普通观众退出 (不区分大、小主播）
        [self doDeleteAudience:self.roomInfo.roomID userID:self->_currentUser.userID completion:nil];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 关闭本地采集和预览
            [self stopLocalPreview];
            
            // 关闭所有播放器
            [self->_playerWrapperDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, RoomLivePlayerWrapper * _Nonnull obj, BOOL * _Nonnull stop) {
                TXLivePlayer *player = obj.player;
                [player stopPlay];
            }];
            
            [self->_playerWrapperDic removeAllObjects];
        });
        
        // 停止心跳
        [self stopHeartBeat];
        
        // 清掉房间信息
        self.roomInfo = nil;
        self.roomCreatorPlayerURL = nil;
        self.pkAnchor = nil;
        self.roomStatusCode = nil;
        self.roomCreatorPlayerURL = nil;
        [self->_audienceList removeAllObjects];
        // 清除标记
        self->_created = NO;
        self->_renderMode = -1;
    }];
}

- (void)setCustomInfo:(MLVBCustomFieldOp)op key:(NSString *)key value:(NSString *)value completion:(void(^)(int errCode, NSString *errMsg))completion
{
    NSString *operation = nil;;
    switch(op) {
        case MLVBCustomFieldOpSet:
            operation = @"set";
            break;
        case MLVBCustomFieldOpInc:
            operation = @"inc";
            break;
        case MLVBCustomFieldOpDec:
            operation = @"dec";
            break;
        default:
            NSAssert(NO, @"invalid operation");
            break;
    }
    NSAssert(key != nil, @"key is nil");
    
    [self asyncRun:^(MLVBLiveRoom *self) {
        if (self.roomInfo.roomID == nil) {
            completion(-1, @"未进入房间");
            return;
        }
        
        NSDictionary *params = @{@"roomID": self.roomInfo.roomID, @"operation": operation, @"fieldName": key, @"value": value};
        [self requestWithName:kHttpServerAddr_SetCustomField params:params completion:^(MLVBLiveRoom *self, int errCode, NSString *errMsg, NSDictionary *responseObject) {
            if (completion) {
                completion(errCode, errMsg);
            }
        }];
    }];
}

- (void)getCustomInfo:(void(^)(int errCode, NSString *errMsg, NSString *custom))completion
{
    [self asyncRun:^(MLVBLiveRoom *self) {
        if (self.roomInfo.roomID == nil) {
            completion(-1, @"未进入房间", nil);
            return;
        }
        NSDictionary *params = @{@"roomID": self.roomInfo.roomID,};
        [self requestWithName:kHttpServerAddr_GetCustomInfo params:params completion:^(MLVBLiveRoom *self, int errCode, NSString *errMsg, NSDictionary *responseObject) {
            if (completion) {
                if (errCode == 0) {
                    NSString *custom = responseObject[@"custom"];
                    completion(errCode, errMsg, custom);
                } else {
                    completion(errCode, errMsg, nil);
                }
            }
        }];
    }];
}

#pragma mark - 房间相关接口函数
/**
 小主播发起连麦请求
 */
- (void)requestJoinAnchor:(NSString *)reason completion:(void(^)(int errCode, NSString *errMsg))completion {
    [self asyncRun:^(MLVBLiveRoom *self) {
        self.requestAnchorCompletion = completion;
        [self->_msgMgr sendJoinAnchorRequest:self.roomInfo.roomCreator roomID:self.roomInfo.roomID];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleRequestJoinAnchorTimeOut:) object:self];
            [self performSelector:@selector(handleRequestJoinAnchorTimeOut:) withObject:self afterDelay:JoinAnchorRequestTimeout];
        });
    }];
}

/**
 大主播响应连麦请求
 */
- (void)responseJoinAnchor:(NSString *)userID agree:(BOOL)agree reason:(NSString *)reason {
    [self asyncRun:^(MLVBLiveRoom *self) {
        [self->_msgMgr sendJoinAnchorResponseWithUID:userID roomID:self.roomInfo.roomID result:agree reason:reason];
    }];
}

/**
 小主播在请求加入连麦成功后调用
 1. 在应用层调用startLocalPreview
 2. 结束播放房间的混流地址(mixedPlayURL)，改为播放大主播的直播流地址
 3. 请求kHttpServerAddr_GetAnchors，获取房间里所有pusher的信息
 4. 通过onGetAnchors将房间里所有主播信息回调给上层播放
 5. 请求kHttpServerAddr_GetAnchorUrl,获取推流地址
 6. 开始推流
 7. 在收到推流成功的事件后请求kHttpServerAddr_AddAnchor，把自己加入房间成员列表
 */
- (void)joinAnchor:(void(^)(int errCode, NSString *errMsg))completion {
    [self asyncRun:^(MLVBLiveRoom *self) {
        // 房间角色为小主播
        self->_roomRole = RoomRoleMinor;
        
        // 设置视频质量为小主播(连麦模式)
        if (self->_videoQuality != VIDEO_QUALITY_LINKMIC_SUB_PUBLISHER) {
            self->_videoQuality = VIDEO_QUALITY_LINKMIC_SUB_PUBLISHER;
            [self->_livePusher setVideoQuality:self->_videoQuality adjustBitrate:NO adjustResolution:NO];
            [self->_livePusher setLogViewMargin:UIEdgeInsetsMake(2, 2, 2, 2)];
        }
        
        
        // 获取主播加速流地址
        __weak __typeof(self) weakSelf = self;
        [self _updateAnchorList:^(int errCode, NSString *errMsg, NSArray<MLVBAnchorInfo *> *anchorList) {
            __strong __typeof(weakSelf) self = weakSelf;
            if (errCode != 0) {
                dispatch_async(self.delegateQueue, ^{
                    [self.delegate onError:errCode errMsg:errMsg extraInfo:nil];
                });
            } else {
                // 复用房间直播播放器来播放大主播的直播流地址
                RoomLivePlayerWrapper *wrapper = self->_playerWrapperDic[self.roomInfo.roomCreator];
                TXLivePlayer *player = wrapper.player;
                NSAssert(player, @"nil player");
                if (player) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [player stopPlay];
                        NSAssert(self.roomCreatorPlayerURL, @"empty acc url");
                        // 播放大主播的直播流地址，注意type是 PLAY_TYPE_LIVE_RTMP_ACC
                        [player startPlay:self.roomCreatorPlayerURL type:PLAY_TYPE_LIVE_RTMP_ACC];
                    });
                }
                
                dispatch_async(self.delegateQueue, ^{
                    [self handleUpdatedAnchorList:anchorList];
                });
                
                self.joinAnchorCompletion = completion;
                // 获取推流地址并推流
                [self getUrlAndPushing:^(int errCode, NSString *errMsg) {
                    // errCode = 0 则等待推流成功后回调
                    if (errCode != 0) {
                        self.joinAnchorCompletion = nil; // 失败直接调用completion，无需保存
                        self->_roomRole = RoomRoleMember;
                        completion(errCode, errMsg);
                    }
                }];
            }
        }];
    }];
}

/**
 小主播退出连麦
 1. 应用层调用stopLocalPreview，结束本地预览和停止推流
 2. 结束播放所有的流(playUrl)
 3. 播放房间的混流地址(mixedPlayURL),这里使用大主播的view来播放视频
 4. 请求 kHttpServerAddr_DeleteAnchor，将自己从房间成员列表里删除
 */
- (void)quitJoinAnchor:(void(^)(int errCode, NSString *errMsg))completion {
    [self asyncRun:^(MLVBLiveRoom *self) {
        self->_roomRole = RoomRoleMember;  // 房间角色变为普通观众
        
        RoomLivePlayerWrapper *playerForCreator = self->_playerWrapperDic[self.roomInfo.roomCreator];
        
        // 关闭所有播放器
        [self _stopAndRemoveAllPlayerIncludeCreator:NO];
        
        // 用大主播的播放器来播放混流地址，这样可以复用之前的view
        TXLivePlayer *bigPlayer = playerForCreator.player; // 获取大主播的player
        playerForCreator.userID = self.roomInfo.roomCreator;
        playerForCreator.delegate = self;
        
        if (self->_roomRole != RoomRoleMinor && [bigPlayer isPlaying]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                TXLivePlayConfig *playConfig = [[TXLivePlayConfig alloc] init];
                playConfig.bAutoAdjustCacheTime = YES;
                playConfig.minAutoAdjustCacheTime = 2.0f;
                playConfig.maxAutoAdjustCacheTime = 2.0f;
                [bigPlayer setConfig:playConfig];
                [bigPlayer stopPlay];
                [bigPlayer startPlay:self.roomInfo.mixedPlayURL type:[self getPlayType:self.roomInfo.mixedPlayURL]];
                if (self->_inBackground == YES) {
                    [bigPlayer pause];
                }
            });
        }
        
        // 请求 kHttpServerAddr_DeleteAnchor
        [self doDeleteAnchorWithRoomID:self.roomInfo.roomID
                                userID:self->_currentUser.userID
                            completion:nil];
        
        // 停止心跳
        [self stopHeartBeat];
        
    }];
}

/**
 大主播踢掉小主播
 */
- (void)kickoutJoinAnchor:(NSString *)userID {
    // 发送踢掉消息
    [_msgMgr sendJoinAnchorKickout:userID roomID:self.roomInfo.roomID];
}

#pragma mark - 主播跨房间 PK
/**
 主播PK: 发起PK请求
 请求带上自己的userID, userName, userAvatar, streamUrl
 */
- (void)requestRoomPK:(NSString *)userID completion:(IRequestPKCompletionHandler)completion {
    [self asyncRun:^(MLVBLiveRoom *self) {
        NSString *accelerateURL = self->_accUrl;
        self->_requestPKCompletion = completion;
        [self->_msgMgr sendPKRequest:userID roomID:self.roomInfo.roomID withAccelerateURL:accelerateURL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleRequestPKTimeout:) object:nil];
            [self performSelector:@selector(handleRequestPKTimeout:) withObject:nil afterDelay:PKRequestTimeout];
        });
    }];
}

/**
 主播PK: 拒绝PK请求
 */
- (void)responseRoomPK:(MLVBAnchorInfo *)anchor agree:(BOOL)agree reason:(NSString *)reason {
    [self asyncRun:^(MLVBLiveRoom *self) {
        if (agree) {
            self->_mixMode = StreamMixModePK;
            self.pkAnchor = anchor;
            [self->_msgMgr acceptPKRequest:anchor.userID roomID:self.roomInfo.roomID withAccelerateURL:self->_accUrl];
        } else {
            [self->_msgMgr rejectPKRequest:anchor.userID roomID:self.roomInfo.roomID reason:reason];
        }
    }];
}

/**
 主播PK: 发送结束PK的请求
 */
- (void)quitRoomPK:(void(^)(int errCode, NSString *errMsg))completion {
    [self asyncRun:^(MLVBLiveRoom *self) {
        if (self.pkAnchor == nil) {
            if (completion) {
                completion(ROOM_ERR_CANCELED, @"没有正在进行的PK");
            }
            return;
        }
        [self->_msgMgr sendPKFinishRequest:self.pkAnchor.userID roomID:self.roomInfo.roomID completion:^(int errCode, NSString *errMsg) {
            if (errCode == 0) {
                self.pkAnchor = nil;
            }
            if (completion) {
                completion(errCode, errMsg);
            }
        }];
    }];
}

#pragma mark - 视频相关接口函数
- (void)startLocalPreview:(BOOL)frontCamera view:(UIView *)view {
    [self initLivePusher];
    if (_livePusher.frontCamera != frontCamera) {
        [_livePusher switchCamera];
    }
    [_livePusher startPreview:view];
}

- (void)stopLocalPreview {
    [_livePusher stopPreview];
    [_livePusher stopPush];
    [self releaseLivePusher];
}

// 播放小主播、PK
- (void)startRemoteView:(MLVBAnchorInfo *)anchorInfo view:(UIView *)view onPlayBegin:(IPlayBegin)onPlayBegin onPlayError:(IPlayError)onPlayError playEvent:(IPlayEventBlock)onPlayEvent {
    [self asyncRun:^(MLVBLiveRoom *self) {
        NSString *userID = anchorInfo.userID;
        
        if (self->_roomRole == RoomRoleCreator) {
            NSArray *anchorURLsToMix = nil;
            if (self->_mixMode == StreamMixModePK) {
                // 设置PK推流模式（降低分辨率）
                self->_videoQuality = VIDEO_QUALITY_LINKMIC_MAIN_PUBLISHER;
                [self->_livePusher setVideoQuality:self->_videoQuality adjustBitrate:YES adjustResolution:NO];
                TXLivePushConfig * config = self->_livePusher.config;
                config.videoResolution = VIDEO_RESOLUTION_TYPE_360_640;
                config.enableAutoBitrate = NO;
                config.videoBitratePIN = 800;
                [self->_livePusher setConfig:config];
                
                anchorURLsToMix = @[anchorInfo.accelerateURL];
            } else {
                if ([self->_roomInfo.anchorInfoArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"userID = %@", anchorInfo.userID]].count == 0) {
                    // 如果userID不存在,就通知上层该userID已经离开房间及销毁view
                    NSLog(@"startRemoteView: userID[%@] not exist!!!", userID);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (self->_delegate) {
                            MLVBAnchorInfo *pushInfo = [[MLVBAnchorInfo alloc] init];
                            pushInfo.userID = userID;
                            [self->_delegate onAnchorExit:pushInfo];
                        }
                    });
                    return;
                }
                anchorURLsToMix = [self.roomInfo.anchorInfoArray valueForKey:@"accelerateURL"];
            }
            
            [self requestMergeStreamWithPlayUrlArray:anchorURLsToMix withMode:self->_mixMode];
        }
        
        [self startPlayAcc:anchorInfo inView:view playBegin:onPlayBegin playError:onPlayError playEvent:onPlayEvent];
    }];
}

- (void)stopRemoteView:(MLVBAnchorInfo *)anchor {
    if(anchor == nil) {
        return;
    }
    [self asyncRun:^(MLVBLiveRoom *self) {
        RoomLivePlayerWrapper *playerWrapper = [self->_playerWrapperDic objectForKey:anchor.userID];
        TXLivePlayer *player = playerWrapper.player;
        if (player) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [player stopPlay];
                [player removeVideoWidget];
            });
        }
        if ([self.pkAnchor.userID isEqualToString:anchor.userID]) {
            self.pkAnchor = nil;
        }
        [self->_playerWrapperDic removeObjectForKey:anchor.userID];
        if (self->_roomRole == RoomRoleCreator) {
            NSArray *urls = [[self.roomInfo.anchorInfoArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"userID != %@", anchor.userID]]
                             valueForKey:@"accelerateURL"];
            [self requestMergeStreamWithPlayUrlArray:urls withMode:self->_mixMode];
            
            if (self.roomInfo.anchorInfoArray == 0) {
                // 无连麦或PK，设置推流模式为直播模式(高清）
                self->_videoQuality = VIDEO_QUALITY_HIGH_DEFINITION;
                [self->_livePusher setVideoQuality:self->_videoQuality adjustBitrate:NO adjustResolution:NO];
                TXLivePushConfig * config = self->_livePusher.config;
                config.videoEncodeGop = 2;
                [self->_livePusher setConfig:config];
            }
        }
        self.roomInfo.anchorInfoArray = [self.roomInfo.anchorInfoArray filteredArrayUsingPredicate:
                                         [NSPredicate predicateWithFormat:
                                          @"%@ != %@", NSStringFromSelector(@selector(userID)), anchor.userID]];
    }];
}

#pragma mark - 音频相关接口函数
- (void)muteLocalAudio:(BOOL)mute
{
    [_livePusher setMute:mute];
}

- (void)muteRemoteAudio:(NSString *)userID mute:(BOOL) mute
{
    [self asyncRun:^(MLVBLiveRoom *self) {
        RoomLivePlayerWrapper *wrapper = self->_playerWrapperDic[userID];
        [wrapper.player setMute:mute];
    }];
}

-(void)muteAllRemoteAudio:(BOOL)mute
{
    [self asyncRun:^(MLVBLiveRoom *self) {
        [self->_playerWrapperDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, RoomLivePlayerWrapper * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj.player setMute:mute];
        }];
    }];
}
#pragma mark - 摄像头相关接口函数
- (void)switchCamera {
    [_livePusher switchCamera];
}


- (void)setZoom:(CGFloat)distance {
    [_livePusher setZoom:distance];
}

- (BOOL)enableTorch:(BOOL)enabled {
    return [_livePusher toggleTorch: enabled];
}

- (void)setCameraMuteImage:(UIImage *)pauseImage {
    TXLivePushConfig *config = _livePusher.config;
    if (!config.pauseImg || ![config.pauseImg isEqual:pauseImage]) {
        config.pauseImg = pauseImage;
        [_livePusher setConfig:config];
    }
}
- (void)setFocusPosition:(CGPoint)position {
    [_livePusher setFocusPosition:position];
}

- (void)setMirror:(BOOL)isMirror {
    [_livePusher setMirror:isMirror];
}
#pragma mark - 美颜滤镜相关接口函数
- (void)setBeautyStyle:(TX_Enum_Type_BeautyStyle)beautyStyle beautyLevel:(float)beautyLevel whitenessLevel:(float)whitenessLevel ruddinessLevel:(float)ruddinessLevel {
    [_livePusher setBeautyStyle:beautyStyle beautyLevel:beautyLevel whitenessLevel:whitenessLevel ruddinessLevel:ruddinessLevel];
}

- (void)setFilter:(UIImage *)image {
    [_livePusher setFilter:image];
}

- (void)setEyeScaleLevel:(float)eyeScaleLevel {
    [_livePusher setEyeScaleLevel:eyeScaleLevel];
}

- (void)setFaceScaleLevel:(float)faceScaleLevel {
    [_livePusher setFaceScaleLevel:faceScaleLevel];
}

- (void)setSpecialRatio:(float)specialValue {
    [_livePusher setSpecialRatio:specialValue];
}

- (void)setFaceVLevel:(float)faceVLevel {
    [_livePusher setFaceVLevel:faceVLevel];
}

- (void)setChinLevel:(float)chinLevel {
    [_livePusher setChinLevel:chinLevel];
}

- (void)setFaceShortLevel:(float)faceShortlevel {
    [_livePusher setFaceShortLevel:faceShortlevel];
}

- (void)setNoseSlimLevel:(float)noseSlimLevel {
    [_livePusher setNoseSlimLevel:noseSlimLevel];
}

- (void)setGreenScreenFile:(NSURL *)file {
    [_livePusher setGreenScreenFile:file];
}

- (void)selectMotionTmpl:(NSString *)tmplName inDir:(NSString *)tmplDir;
{
    [_livePusher selectMotionTmpl:tmplName inDir:tmplDir];
}

#pragma mark - 消息发送接口函数
- (void)sendRoomTextMsg:(NSString *)textMsg completion:(void (^)(int errCode, NSString *errMsg))completion {
    [self asyncRun:^(MLVBLiveRoom *self) {
        [self->_msgMgr sendGroupTextMsg:textMsg completion:completion];
    }];
}

- (void)sendRoomCustomMsg:(NSString *)cmd msg:(NSString *)msg completion:(void (^)(int errCode, NSString *errMsg))completion {
    [self asyncRun:^(MLVBLiveRoom *self) {
        [self->_msgMgr sendRoomCustomMsg:cmd msg:msg completion:completion];
    }];
}

#pragma mark - 背景混音相关接口函数
- (BOOL)playBGM:(NSString *)path {
    TXLivePushConfig *config = _livePusher.config;
    config.enableAudioPreview = YES; // 开启耳返
    [_livePusher setConfig:config];
    
    return [_livePusher playBGM:path];
}

- (BOOL)playBGM:(NSString *)path
withBeginNotify:(void (^)(NSInteger errCode))beginNotify
withProgressNotify:(void (^)(NSInteger progressMS, NSInteger durationMS))progressNotify
andCompleteNotify:(void (^)(NSInteger errCode))completeNotify {
    TXLivePushConfig *config = _livePusher.config;
    config.enableAudioPreview = YES; // 开启耳返
    [_livePusher setConfig:config];
    
    return [_livePusher playBGM:path withBeginNotify:beginNotify withProgressNotify:progressNotify andCompleteNotify:completeNotify];
}

- (BOOL)stopBGM {
    TXLivePushConfig *config = _livePusher.config;
    config.enableAudioPreview = NO; // 关闭耳返
    [_livePusher setConfig:config];
    
    return [_livePusher stopBGM];
}

- (BOOL)pauseBGM {
    return [_livePusher pauseBGM];
}

- (BOOL)resumeBGM {
    return [_livePusher resumeBGM];
}

- (int)getMusicDuration:(NSString *)path {
    return [_livePusher getMusicDuration:path];
}

- (BOOL)setMicVolume:(float)volume {
    return [_livePusher setMicVolume:volume];
}

- (BOOL)setBGMVolume:(float)volume {
    return [_livePusher setBGMVolume:volume];
}

- (BOOL)setBGMPitch:(float)pitch {
    return [_livePusher setBGMPitch:pitch];
}

- (BOOL)setBGMPosition:(float)position {
    int duration = [_livePusher getMusicDuration:NULL];
    return [_livePusher setBGMPosition:duration*position];
}

- (BOOL)setReverbType:(TXReverbType)reverbType {
    return [_livePusher setReverbType:reverbType];
}

- (BOOL)setVoiceChangerType:(TXVoiceChangerType)voiceChangerType {
    return [_livePusher setVoiceChangerType:voiceChangerType];
}

#pragma mark -
- (void)notifyAnchorChange {
    //通知房间内其他主播
    [self.msgMgr sendNotifyMessage];
}


typedef void (^ILoginCompletionCallback)(int errCode, NSString *errMsg, NSString *userID, NSString *token, NSNumber *timestamp);

/**
 Room登录
 */
-(void)login:(int)sdkAppID userID:(NSString*)userID userSig:(NSString*)userSig completion:(ILoginCompletionCallback)completion {
    if (!(userID && userSig)) {
        NSLog(@"Param is missing");
        return;
    }
    [self asyncRun:^(MLVBLiveRoom *self) {
        __weak __typeof(self) weakSelf = self;
        
        // Room登录
        NSDictionary *params = @{@"sdkAppID": @(sdkAppID).stringValue,
                                 @"userID": userID,
                                 @"userSig": userSig,
                                 @"platform": @"iOS"
                                 };
        NSMutableString *query = [[NSMutableString alloc] init];
        [params enumerateKeysAndObjectsUsingBlock:^(NSString *_Nonnull key, NSString *_Nonnull obj, BOOL * _Nonnull stop) {
            [query appendFormat:@"%@=%@&", key, [obj stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        }];
        [query deleteCharactersInRange:NSMakeRange(query.length-1, 1)];
        NSString * cgiUrl = [NSString stringWithFormat:@"%@/login?%@", self->_serverDomain, query];
        
        [weakSelf sendDebugMsg:[NSString stringWithFormat:@"LiveRoom登录, userID[%@]", userID]];
        
        [self->_httpSession POST:cgiUrl parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            int errCode = [responseObject[RespCodeKey] intValue];
            NSString *errMsg = responseObject[@"message"];
            NSString *userID = responseObject[@"userID"];
            NSString *token  = responseObject[@"token"];
            NSNumber *timestamp = responseObject[@"timestamp"];
            
            weakSelf.roomInfo.roomCreator = userID;
            if (completion) {
                completion(errCode == 0 ? ROOM_SUCCESS : ROOM_ERR_REQUEST_TIMEOUT, [NSString stringWithFormat:@"%@[%d]", errMsg, errCode], userID, token, timestamp);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [weakSelf sendDebugMsg:[NSString stringWithFormat:@"LiveRoom登录失败: error[%@]", [error description]]];
            if (completion) {
                completion(ROOM_ERR_REQUEST_TIMEOUT, @"网络请求超时，请检查网络设置", nil, nil, nil);
            }
        }];
    }];
}

- (void)_stopAndRemoveAllPlayerIncludeCreator:(BOOL)includeCreator {
    [_playerWrapperDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, RoomLivePlayerWrapper * _Nonnull obj, BOOL * _Nonnull stop) {
        BOOL shouldStop = includeCreator || ![key isEqualToString:self.roomInfo.roomCreator];
        if (shouldStop) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [obj.player stopPlay];
            });
        }
    }];
    NSArray *keysToRemove = [[_playerWrapperDic allKeys] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat: @"self != %@", self.roomInfo.roomCreator]];
    [_playerWrapperDic removeObjectsForKeys:keysToRemove];
    self.roomInfo.anchorInfoArray = @[];
}


-(void) handleRequestJoinAnchorTimeOut:(NSObject*)obj {
    if (_requestAnchorCompletion) {
        _requestAnchorCompletion(1, @"主播未处理您的连麦请求");
        _requestAnchorCompletion = nil;
    }
}


- (void)handleRequestPKTimeout:(NSObject *)obj {
    if (_requestPKCompletion) {
        _requestPKCompletion(1, @"主播未处理您的PK请求或者超时", nil);
        _requestPKCompletion = nil;
    }
}

#pragma mark - 心跳

- (void)startHeartBeat {
    // 启动心跳，向业务服务器发送心跳请求
    __weak __typeof(self) weakSelf = self;
    _heartBeatTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_event_handler(_heartBeatTimer, ^{
        __strong __typeof(self) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf sendHeartBeat];
        }
    });
    dispatch_source_set_timer(_heartBeatTimer, dispatch_walltime(NULL, 0), 7 * NSEC_PER_SEC, 0);
    dispatch_resume(_heartBeatTimer);
}

- (void)stopHeartBeat {
    if (_heartBeatTimer) {
        dispatch_cancel(_heartBeatTimer);
        _heartBeatTimer = nil;
    }
}

- (void)sendHeartBeat {
    [self asyncRun:^(MLVBLiveRoom *self) {
        if (self->_currentUser == nil || self.roomInfo.roomID == nil) {
            return;
        }
        
        NSDictionary *params = @{@"roomID": self.roomInfo.roomID,
                                 @"userID": self->_currentUser.userID,
                                 @"roomStatusCode": self.roomStatusCode ?: @0
                                 };
        
        [self requestWithName:kHttpServerAddr_AnchorHeartBeat params:params completion:^(MLVBLiveRoom *self, int errCode, NSString *errMsg, NSDictionary *responseObject) {
            if (errCode == 0) {
                [self onHeartBeatResponse:responseObject];
            }
        }];
    }];
}

- (void)onHeartBeatResponse:(NSDictionary *)responseObject {
    if ([responseObject[RespCodeKey] intValue] == 0 && responseObject[@"roomStatusCode"]) {
        self.roomStatusCode = responseObject[@"roomStatusCode"];
        NSArray<MLVBAnchorInfo *> *anchorList = [self parseAnchorsFromJsonArray:responseObject[@"pushers"]];
        [self handleUpdatedAnchorList:anchorList];
    }
}

#pragma mark -
- (void)startPlayAcc:(MLVBAnchorInfo *)anchor inView:(UIView *)view playBegin:(IPlayBegin)playBegin playError:(IPlayError)playError  playEvent:(IPlayEventBlock)onPlayEvent {
    // 播放加速流地址
    NSString *playUrl = anchor.accelerateURL;
    // 播放加速流地址
    RoomLivePlayerWrapper *playerWrapper = [self playerWrapperForUserID:anchor.userID];
    playerWrapper.playBeginBlock = playBegin;
    __weak __typeof(self) wself = self;
    playerWrapper.playErrorBlock = ^(int errCode, NSString *errMsg) {
        [wself stopRemoteView:anchor];
    };
    playerWrapper.playEventBlock = onPlayEvent;
    TXLivePlayer *player = playerWrapper.player;
    dispatch_async(dispatch_get_main_queue(), ^{
        [player setupVideoWidget:CGRectZero containView:view insertIndex:0];
        [player startPlay:playUrl type:PLAY_TYPE_LIVE_RTMP_ACC];
    });
}

- (void)handleUpdatedAnchorList:(NSArray<MLVBAnchorInfo *> *)updatedAnchorList
{
    NSArray<MLVBAnchorInfo *>* oldAnchorList = _roomInfo.anchorInfoArray;
    
    NSMutableSet *leftAnchorSet = [[NSMutableSet alloc] initWithArray:oldAnchorList];
    NSSet *updatedAnchorSet = [NSSet setWithArray:updatedAnchorList];
    if ([updatedAnchorSet isEqualToSet:leftAnchorSet]) {
        return;
    }
    
    BOOL anchorChanged = NO;
    for (MLVBAnchorInfo *anchorInfo in updatedAnchorList) {
        // 过滤自己
        if ([anchorInfo.userID isEqualToString:_currentUser.userID]) {
            continue;
        }
        
        BOOL isNewMember = ![oldAnchorList containsObject:anchorInfo];
        
        if (isNewMember) {
            dispatch_async(self.delegateQueue, ^{
                [self.delegate onAnchorEnter:anchorInfo];
                [self sendDebugMsg:[NSString stringWithFormat:@"加入房间: userID[%@] userName[%@] playUrl[%@]", anchorInfo.userID, anchorInfo.userName, anchorInfo.accelerateURL]];
            });
            anchorChanged = YES;
            // 有新主播加入，混流时采用连麦配置
            _mixMode = StreamMixModeJoinAnchor;
        }
        [leftAnchorSet filterUsingPredicate:[NSPredicate predicateWithFormat:@"userID != %@", anchorInfo.userID]];
    }
    
    for (MLVBAnchorInfo *anchorInfo in leftAnchorSet) {
        // 关闭播放器
        [self stopRemoteView:anchorInfo];
        dispatch_async(self.delegateQueue, ^{
            [self.delegate onAnchorExit:anchorInfo];
            [self sendDebugMsg:[NSString stringWithFormat:@"离开房间: userID[%@] userName[%@]", anchorInfo.userID, anchorInfo.userName]];
        });
        anchorChanged = YES;
    }
    
    // 更新
    _roomInfo.anchorInfoArray = updatedAnchorList;
    
    if (_roomRole == RoomRoleCreator && anchorChanged) {
        // 当连麦人数发生变化时，大主播需要重新向服务器请求混流
        NSMutableArray *playUrlArray = [[NSMutableArray alloc] init];
        for (MLVBAnchorInfo *anchorInfo in _roomInfo.anchorInfoArray) {
            [playUrlArray addObject:anchorInfo.accelerateURL];
        }
        
        // 当存在其他推流者时，就是连麦模式
        if (_roomInfo.anchorInfoArray.count > 0) {
            // 设置视频质量为大主播(连麦模式)
            if (_videoQuality != VIDEO_QUALITY_LINKMIC_MAIN_PUBLISHER) {
                _videoQuality = VIDEO_QUALITY_LINKMIC_MAIN_PUBLISHER;
                [_livePusher setVideoQuality:_videoQuality adjustBitrate:YES adjustResolution:NO];
            }
        } else {
            // 只有一个主播（自己），恢复正常的直播模式
            // 设置视频质量为高清(直播模式)
            if (_videoQuality != VIDEO_QUALITY_HIGH_DEFINITION) {
                _videoQuality = VIDEO_QUALITY_HIGH_DEFINITION;
                [_livePusher setVideoQuality:_videoQuality adjustBitrate:NO adjustResolution:NO];
                TXLivePushConfig * config = _livePusher.config;
                config.videoEncodeGop = 2;
                [_livePusher setConfig:config];
            }
        }
    }
}

- (void)showVideoDebugLog:(BOOL)isShow {
    [_livePusher showVideoDebugLog:isShow];
    
    [self asyncRun:^(MLVBLiveRoom *self) {
        [self->_playerWrapperDic enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, RoomLivePlayerWrapper * _Nonnull wrapper, BOOL * _Nonnull stop) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [wrapper.player showVideoDebugLog:isShow];
            });
        }];
    }];
}


#pragma mark - TXLivePushListener
-(void) onPushEvent:(int)EvtID withParam:(NSDictionary*)param {
    [self asyncRun:^(MLVBLiveRoom *self) {
        if (EvtID == PUSH_EVT_PUSH_BEGIN) {
            [self onPushBegin];
        } else if (EvtID == PUSH_ERR_NET_DISCONNECT || EvtID == PUSH_ERR_INVALID_ADDRESS) {
            NSString *errMsg = @"推流断开，请检查网络设置";
            if (self.createRoomCompletion) {
                self.createRoomCompletion(ROOM_ERR_CREATE_ROOM, errMsg);
                self.createRoomCompletion = nil;
                
            } else if (self.joinAnchorCompletion) {
                self.joinAnchorCompletion(ROOM_ERR_PUSH_DISCONNECT, errMsg);
            } else {
                dispatch_async(self.delegateQueue, ^{
                    [self.delegate onError:ROOM_ERR_PUSH_DISCONNECT errMsg:errMsg extraInfo:nil];
                });
            }
        } else if (EvtID == PUSH_ERR_OPEN_CAMERA_FAIL) {
            NSString *errMsg = @"获取摄像头权限失败，请前往隐私-相机设置里面打开应用权限";
            if (self.createRoomCompletion) {
                self.createRoomCompletion(ROOM_ERR_CREATE_ROOM, errMsg);
                self.createRoomCompletion = nil;
            } else if (self.joinAnchorCompletion) {
                self.joinAnchorCompletion(ROOM_ERR_ENTER_ROOM, errMsg);
                self.joinAnchorCompletion = nil;
            }
        } else if (EvtID == PUSH_ERR_OPEN_MIC_FAIL) {
            NSString *errMsg = @"获取麦克风权限失败，请前往隐私-麦克风设置里面打开应用权限";
            if (self->_createRoomCompletion) {
                self->_createRoomCompletion(ROOM_ERR_CREATE_ROOM, errMsg);
                self->_createRoomCompletion = nil;
            } else if (self->_joinAnchorCompletion) {
                self->_joinAnchorCompletion(ROOM_ERR_ENTER_ROOM, errMsg);
                self->_joinAnchorCompletion = nil;
            }
        }
    }];
}

/** 退流成功
 *
 * 1. 创建房间
 * 2. 加入推流
 * 3. 创建IM组
 * 4. 启动心跳
 */
- (void)onPushBegin {
    IMMsgManager *IMManager = self.msgMgr;
    NSString *userID = _currentUser.userID;
    __weak __typeof(self) weakSelf = self;
    
    if (_roomRole == RoomRoleCreator) {  // 创建者
        // rtmp推流过程中每次重连都会下发PUSH_EVT_PUSH_BEGIN，需要加一个BOOL变量来保护下，避免重复请求create_room，
        // 只能在第一次或者调用过exitRoom后才能够请求create_room
        if (_created) {
            return;
        }
        
        //调用CGI：create_room，返回roomID
        [self doCreateRoom:^(int errCode, NSString *errMsg, NSString *roomID) {
            __strong __typeof(weakSelf) self = weakSelf;
            if (self == nil) return;
            
            void (^finish)(int, NSString *) = ^(int code, NSString *msg) {
                if (weakSelf.createRoomCompletion) {
                    weakSelf.createRoomCompletion(code, [NSString stringWithFormat:@"%@[%d]", msg, code]);
                    weakSelf.createRoomCompletion = nil;
                }
            };
            
            if (errCode == 0) {
                self.roomInfo.roomID = roomID;
                self->_created = YES; // 标记已经创建房间
                
                //请求CGI：add_anchor，加入房间
                [self doAddAnchor:roomID completion:^(int errCode, NSString *errMsg) {
                    __strong __typeof(weakSelf) self = weakSelf;
                    if (self == nil) return;
                    if (errCode == 0) {
                        [IMManager createGroupWithID:roomID name:roomID completion:^(int errCode, NSString *errMsg) {
                            [self sendDebugMsg:[NSString stringWithFormat:@"加入IMGroup完成: errCode[%d] errMsg[%@]", errCode, errMsg]];
                            
                            if (errCode == 0 || errCode == 10025) {
                                //群组 ID 已被使用，并且操作者为群主，可以直接使用
                                if (errCode == 10025) {
                                    NSLog(@"群组 %@ 已被使用，并且操作者为群主，可以直接使用", roomID);
                                }
                                self.roomInfo.roomCreator = userID;
                                [self startHeartBeat]; // 启动心跳
                                //启动心跳
                                //mStreamMixturer.setMainVideoStream(pushURL);
                                errCode = 0;
                            } else if (errCode == 10036) {
                                NSLog(@"您当前使用的云通讯账号未开通音视频聊天室功能，创建聊天室数量超过限额，请前往腾讯云官网开通【IM音视频聊天室】 https://buy.cloud.tencent.com/avc");
                            }
                            finish(errCode, errMsg);
                        }];
                    } else {
                        finish(ROOM_ERR_ENTER_ROOM, errMsg);
                    }
                }];
            } else {
                finish(ROOM_ERR_CREATE_ROOM, [NSString stringWithFormat:@"%@[%d]", errMsg, errCode]);
            }
        }];
    } else if (_roomRole == RoomRoleMinor) {  // 小主播
        //请求CGI：add_anchor，加入房间
        [self doAddAnchor:self.roomInfo.roomID completion:^(int errCode, NSString *errMsg) {
            int code = errCode;
            NSString *msg = errMsg;
            if (errCode != 0) {
                code = ROOM_ERR_ENTER_ROOM;
                msg = [NSString stringWithFormat:@"%@[%d]", errMsg, errCode];
            }
            if (weakSelf.joinAnchorCompletion) {
                weakSelf.joinAnchorCompletion(code, msg);
                weakSelf.joinAnchorCompletion = nil;
            }
            if (errCode == 0) {
                [self notifyAnchorChange];
            }
            // 启动心跳
            [weakSelf startHeartBeat];
        }];
    }
}

-(void) onNetStatus:(NSDictionary*)param {
    
}

#pragma mark - HTTP API

- (void)requestWithName:(NSString *)name
                 params:(NSDictionary *)params
             completion:(void(^)(__strong MLVBLiveRoom *self, int code, NSString *message, NSDictionary *responseObject))completion {
    __weak __typeof(self) weakSelf = self;
    NSString *paramDesc = [[params description] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    [self sendDebugMsg:[NSString stringWithFormat:@"开始请求 %@, %@", name, paramDesc]];
    [self->_httpSession POST:_apiAddr[name]
                  parameters:params
                    progress:nil
                     success:
     ^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         __strong __typeof(weakSelf) self = weakSelf;
         int errCode = [responseObject[RespCodeKey] intValue];
         [self sendDebugMsg:[NSString stringWithFormat:@"请求 %@ %@, 返回 %@", name, errCode == 0 ? @"成功" : @"失败", responseObject]];
         if (completion) {
             NSString *errMsg = responseObject[@"message"];
             if (errCode != 0) {
                 completion(self, errCode, [@"[MLVBLiveRoom] " stringByAppendingString:errMsg], responseObject);
             } else {
                 completion(self, errCode, errMsg, responseObject);
             }
         }
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         [weakSelf sendDebugMsg:[NSString stringWithFormat:@"请求 %@ 失败: error[%@]", name, [error description]]];
         if (completion) {
             completion(weakSelf, ROOM_ERR_REQUEST_TIMEOUT, [NSString stringWithFormat: @"[MLVBLiveRoom] 网络请求超时，请检查网络设置, %@", error], nil);
         }
     }];
}

/**
 获取推流地址，并推流
 */
- (void)getUrlAndPushing:(void(^)(int errCode, NSString *errMsg))completion {
    [self asyncRun:^(MLVBLiveRoom *self) {
        // 获取推流地址
        NSDictionary *params = @{@"userID": self->_currentUser.userID};
        [self requestWithName:kHttpServerAddr_GetAnchorUrl params:params completion:^(MLVBLiveRoom *self, int errCode, NSString *errMsg, NSDictionary *responseObject) {
            if (errCode == 0) {
                if (self == nil) {
                    completion(ROOM_ERR_INSTANCE_RELEASED, @"[MLVBLiveRoom] MLVBLiveRoom 已经被销毁");
                    return;
                }
                // 启动推流
                NSString *pushURL = responseObject[@"pushURL"];
                NSString *accURL = responseObject[@"accelerateURL"];
                self->_pushUrl = pushURL;
                self->_accUrl = accURL;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    int result = [self->_livePusher startPush:pushURL];
                    dispatch_async(self->_queue, ^{
                        if (result == 0) {
                            completion(0, nil);
                        } else {
                            completion(result, [NSString stringWithFormat:@"[MLVBLiveRoom] 启动推流失败, %d", result]);
                        }
                    });
                });
            } else {
                if (completion) {
                    completion(errCode, errMsg);
                }
            }
        }];
    }];
}

/**
 * 获取房间内所有主播的信息
 */
- (void)_updateAnchorList:(void (^)(int errCode, NSString *errMsg, NSArray<MLVBAnchorInfo *> *anchorList))completion {
    [self asyncRun:^(MLVBLiveRoom *self) {
        NSDictionary *params = @{@"roomID": self.roomInfo.roomID};
        [self requestWithName:kHttpServerAddr_GetAnchors params:params completion:^(MLVBLiveRoom *self, int errCode, NSString *errMsg, NSDictionary *responseObject) {
            if (errCode == 0) {
                NSArray<MLVBAnchorInfo *> * anchorList = [self parseAnchorsFromJsonArray:responseObject[@"pushers"]];
                self.roomStatusCode = responseObject[@"roomStatusCode"];
                if (completion) {
                    completion(errCode, errMsg, anchorList);
                }
            } else {
                if (completion) {
                    completion(errCode, errMsg, nil);
                }
            }
        }];
    }];
}

- (void)doCreateRoom:(void (^)(int errCode, NSString *errMsg, NSString * roomID))completion {
    [self asyncRun:^(MLVBLiveRoom *self) {
        NSDictionary *params = @{@"userID": self->_currentUser.userID,
                                 @"roomID": self.roomInfo.roomID ?: @"",
                                 @"roomInfo":self.roomInfo.roomInfo};
        [self requestWithName:kHttpServerAddr_CreateRoom params:params completion:^(MLVBLiveRoom *self, int errCode, NSString *errMsg, NSDictionary *responseObject) {
            if (errCode == 0) {
                NSString *roomID = responseObject[@"roomID"];
                self.roomInfo.roomID = roomID;
                self.roomInfo.roomCreator = self->_currentUser.userID;
                if (completion) {
                    completion(errCode, errMsg, roomID);
                }
            } else {
                if (completion) {
                    completion(ROOM_ERR_CREATE_ROOM, [NSString stringWithFormat:@"%@[%d]", errMsg, errCode], nil);
                }
            }
        }];
    }];
}

- (void)doAddAnchor:(NSString*)roomID completion:(void(^)(int errCode, NSString *errMsg))completion {
    [self asyncRun:^(MLVBLiveRoom *self) {
        MLVBLoginInfo *user = self->_currentUser;
        NSDictionary *params = @{@"roomID": roomID, @"userID": user.userID, @"userName": user.userName, @"userAvatar": user.userAvatar, @"pushURL": self->_pushUrl};
        [self requestWithName:kHttpServerAddr_AddAnchor params:params completion:^(MLVBLiveRoom *self, int errCode, NSString *errMsg, NSDictionary *responseObject) {
            if (completion) {
                if (errCode == 0) {
                    completion(errCode, errMsg);
                } else {
                    completion(ROOM_ERR_ENTER_ROOM, [NSString stringWithFormat:@"%@[%d]", errMsg, errCode]);
                }
            }
        }];
    }];
}

- (void)doDeleteAnchorWithRoomID:(NSString *)roomID userID:(NSString *)userID completion:(void(^)(int,NSString*))completion {
    // 作为连麦者退出房间（不区分大、小主播、普通观众）
    [self asyncRun:^(MLVBLiveRoom *self) {
        NSDictionary *params = @{@"roomID": roomID, @"userID": userID};
        [self requestWithName:kHttpServerAddr_DeleteAnchor params:params completion:^(MLVBLiveRoom *self, int errCode, NSString *errMsg, NSDictionary *responseObject) {
            if (errCode == 0) {
                [self notifyAnchorChange];
            }
            if (completion) {
                completion(errCode, errMsg);
            }
        }];
    }];
}

- (void)doAddAudience:(NSString*)roomID userID:(NSString*)userID userInfo:(NSString*)userInfo completion:(void(^)(int errCode, NSString *errMsg))completion {
    [self asyncRun:^(MLVBLiveRoom *self) {
        NSDictionary *params = @{@"roomID": roomID, @"userID": userID, @"userInfo": userInfo};
        [self requestWithName:kHttpServerAddr_AddAudience params:params completion:^(MLVBLiveRoom *self, int errCode, NSString *errMsg, NSDictionary *responseObject) {
            if (completion) {
                if (errCode == 0) {
                    completion(errCode, errMsg);
                } else {
                    completion(ROOM_ERR_ENTER_ROOM, [NSString stringWithFormat:@"%@[%d]", errMsg, errCode]);
                }
            }
        }];
    }];
}

- (void)doDeleteAudience:(NSString*)roomID userID:(NSString*)userID completion:(void(^)(int errCode, NSString *errMsg))completion {
    [self asyncRun:^(MLVBLiveRoom *self) {
        NSDictionary *params = @{@"roomID": roomID, @"userID": userID};
        [self requestWithName:kHttpServerAddr_DeleteAudience params:params completion:^(MLVBLiveRoom *self, int errCode, NSString *errMsg, NSDictionary *responseObject) {
            if (completion) {
                if (errCode == 0) {
                    completion(errCode, errMsg);
                } else {
                    completion(ROOM_ERR_ENTER_ROOM, [NSString stringWithFormat:@"%@[%d]", errMsg, errCode]);
                }
            }
        }];
    }];
}

-(void) sendMergeStreamRequest:(NSDictionary*)mergeParams retryCount:(NSInteger)retryCount
{
    NSLog(@"MergeVideoStream: sendRequest, retryIndex = %d\n%@", (int)retryCount, mergeParams);
    [self asyncRun:^(MLVBLiveRoom *self) {
        [self requestWithName:kHttpServerAddr_MergeStream params:mergeParams completion:^(MLVBLiveRoom *self, int errCode, NSString *errMsg, NSDictionary *responseObject) {
            if (errCode == ROOM_ERR_REQUEST_TIMEOUT) {
                // 因网络原因失败
                [self sendDebugMsg:[NSString stringWithFormat:@"merge_video_stream请求失败: error[%@]", errMsg]];
                return;
            }
            
            int merge_code = [responseObject[@"merge_code"] intValue];
            NSString *merge_msg = responseObject[@"merge_message"];
            NSNumber *timestamp = responseObject[@"timestamp"];
            
            [self sendDebugMsg:[NSString stringWithFormat:@"AppSvr回复merge_video_stream请求: errCode[%d] errMsg[%@] description[code = %d message = %@ timestamp = %@]", errCode, errMsg, merge_code, merge_msg, timestamp]];
            
            if (merge_code != 0) {
                if (retryCount > 0) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
                        [self sendMergeStreamRequest:mergeParams retryCount:retryCount-1];
                    });
                }
            }
        }];
    }];
}

#pragma mark - Response Parser
- (NSArray<MLVBRoomInfo *> *)parseRoomListFromResponse:(NSDictionary *)responseObject {
    NSArray *rooms = responseObject[@"rooms"];
    NSMutableArray *roomInfos = [[NSMutableArray alloc] init];
    for (id room in rooms) {
        MLVBRoomInfo *roomInfo = [[MLVBRoomInfo alloc] init];
        roomInfo.roomID = room[@"roomID"];
        roomInfo.roomInfo = room[@"roomInfo"];
        roomInfo.roomCreator = room[@"roomCreator"];
        roomInfo.mixedPlayURL = room[@"mixedPlayURL"];
        roomInfo.custom = room[@"custom"];
        NSDictionary *anchorDict = [[room[@"pushers"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"userID = %@",  roomInfo.roomCreator]] firstObject];
        MLVBAnchorInfo *anchor = [[MLVBAnchorInfo alloc] init];
        anchor.userID = anchorDict[@"userID"];
        anchor.userName = anchorDict[@"userName"];
        anchor.userAvatar = anchorDict[@"userAvatar"];
        roomInfo.anchor = anchor;
        roomInfo.audienceInfoArray = [self parseAudiencesFromJsonObject:room[@"audiences"]];
        
        [roomInfos addObject:roomInfo];
    }
    return roomInfos;
}

// 1. 找到房主加速流地址保存到 self.roomCreatorPlayerURL
// 2. 返回小主播列表
- (NSArray<MLVBAnchorInfo *> *)parseAnchorsFromJsonArray:(NSArray *)anchorList {
    if (anchorList == nil) {
        return nil;
    }
    
    NSMutableArray *anchorInfoArray = [[NSMutableArray alloc] init];
    for (id anchor in anchorList) {
        MLVBAnchorInfo *anchorInfo = [[MLVBAnchorInfo alloc] init];
        anchorInfo.accelerateURL = anchor[@"accelerateURL"];
        anchorInfo.userID = anchor[@"userID"];
        anchorInfo.userName = anchor[@"userName"];
        anchorInfo.userAvatar = anchor[@"userAvatar"];
        
        // 注意：这里将自己过滤掉 (为了上层使用方便)
        if ([anchorInfo.userID isEqualToString:_currentUser.userID]) {
            continue;
        }
        
        // 注意：这里将大主播过滤掉 (为了上层使用方便)
        // 内部使用时需要过滤，如果是外面调用getRoomList接口时则不能过滤，不然显示在线人数有问题
        if ([anchorInfo.userID isEqualToString:self.roomInfo.roomCreator]) {
            self.roomCreatorPlayerURL = anchorInfo.accelerateURL;
            continue;
        }
        
        [anchorInfoArray addObject:anchorInfo];
    }
    
    return anchorInfoArray;
}

- (NSMutableArray<MLVBAudienceInfo *> *)parseAudiencesFromJsonObject:(NSDictionary *)audiences {
    if (audiences == nil) {
        return nil;
    }
    
    NSMutableArray<MLVBAudienceInfo *> *audienceInfoArray = [[NSMutableArray alloc] init];
    NSArray * array = audiences[@"audiences"];
    if (array != nil && array.count > 0) {
        for (id item in array) {
            MLVBAudienceInfo * audienceInfo = [[MLVBAudienceInfo alloc] init];
            audienceInfo.userID = item[@"userID"];
            audienceInfo.userInfo = item[@"userInfo"];
            
            // 注意：这里将自己过滤掉 (为了上层使用方便)
            if ([audienceInfo.userID isEqualToString:_currentUser.userID]) {
                continue;
            }
            
            [audienceInfoArray addObject:audienceInfo];
        }
    }
    
    return audienceInfoArray;
}

#pragma mark - IRoomLivePlayListener
-(void)onLivePlayNetStatus:(NSString*) userID withParam: (NSDictionary*) param {
    if (self.roomInfo.roomCreator != nil && [self.roomInfo.roomCreator isEqualToString:userID]) {
        if (param) {
            int renderMode = RENDER_MODE_FILL_SCREEN;
            int width  = [(NSNumber*)[param valueForKey:NET_STATUS_VIDEO_WIDTH] intValue];
            int height = [(NSNumber*)[param valueForKey:NET_STATUS_VIDEO_HEIGHT] intValue];
            if (width > 0 && height > 0) {
                //pc上混流后的宽高比为4:5，这种情况下填充模式会把左右的小主播窗口截掉一部分，用适应模式比较合适
                float ratio = (float) height / width;
                if (ratio > 1.3f) {
                    renderMode = RENDER_MODE_FILL_SCREEN;
                }
                else {
                    renderMode = RENDER_MODE_FILL_EDGE;
                }
                if (_renderMode != renderMode) {
                    _renderMode = renderMode;
                    TXLivePlayer * livePlayer = _playerWrapperDic[self.roomInfo.roomCreator].player;
                    if (livePlayer) {
                        [livePlayer setRenderMode:_renderMode];
                    }
                }
            }
        }
    }
}

#pragma mark - RoomMsgListener

- (void)onRecvGroupTextMsg:(NSString *)groupID userID:(NSString *)userID textMsg:(NSString *)textMsg userName:(NSString *)userName userAvatar:(NSString *)userAvatar {
    if (![groupID isEqualToString:self.roomInfo.roomID]) {
        return;
    }
    
    dispatch_async(self.delegateQueue, ^{
        if ([self.delegate respondsToSelector:@selector(onRecvRoomTextMsg:userID:userName:userAvatar:message:)]) {
            [self.delegate onRecvRoomTextMsg:groupID userID:userID userName:userName userAvatar:userAvatar message:textMsg];
        }
    });
}

- (void)onMemberChange:(NSString *)groupID {
    if (![groupID isEqualToString:self.roomInfo.roomID]) {
        return;
    }
    if (_roomRole == RoomRoleMember) { // 普通观众不需要关注这个消息
        return;
    }
    if (_inBackground == YES) { //切后台期间，忽略这个消息
        return;
    }
    [self _updateAnchorList:^(int errCode, NSString *errMsg, NSArray<MLVBAnchorInfo *> *updatedAnchorList) {
        [self handleUpdatedAnchorList:updatedAnchorList];
    }];
}

- (void)onGroupDelete:(NSString *)groupID {
    [self sendDebugMsg:[NSString stringWithFormat:@"房间[%@]被解散", groupID]];
    dispatch_async(self.delegateQueue, ^{
        if ([groupID isEqualToString:self.roomInfo.roomID]) {
            if ([self.delegate respondsToSelector:@selector(onRoomDestroy:)]) {
                [self.delegate onRoomDestroy:groupID];
            }
        }
    });
}

// 接收到小主播的连麦请求
- (void)onRecvJoinAnchorRequest:(NSString *)roomID userID:(NSString *)userID userName:(NSString *)userName userAvatar:(NSString *)userAvatar reason:(NSString *)reason {
    if (![roomID isEqualToString:self.roomInfo.roomID]) {
        return;
    }
    
    [self sendDebugMsg:[NSString stringWithFormat:@"收到小主播[%@-%@]连麦请求", userID, userName]];
    [self asyncRun:^(MLVBLiveRoom *self) {
        dispatch_async(self.delegateQueue, ^{
            if ([self.delegate respondsToSelector:@selector(onRequestJoinAnchor:reason:)]) {
                MLVBAnchorInfo *anchor = [[MLVBAnchorInfo alloc] init];
                anchor.userID = userID;
                anchor.userName = userName;
                anchor.userAvatar = userAvatar;
                [self.delegate onRequestJoinAnchor:anchor reason:reason];
            }
        });
    }];
}

// 接收到大主播的连麦回应， result为YES表示同意连麦，为NO表示拒绝连麦
- (void)onRecvJoinAnchorResponse:(NSString *)roomID result:(BOOL)result message:(NSString *)message {
    if (![roomID isEqualToString:self.roomInfo.roomID]) {
        return;
    }
    
    [self sendDebugMsg:[NSString stringWithFormat:@"收到大主播回应连麦请求:result[%d] message[%@]", result, message]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleRequestJoinAnchorTimeOut:) object:self];
        if (self.requestAnchorCompletion) {
            self.requestAnchorCompletion(result ? 0 : ROOM_ERR_USER_REJECTED, message);
            self.requestAnchorCompletion = nil;
        }
    });
}

// 接收到被大主播的踢出连麦的消息
- (void)onRecvJoinAnchorKickout:(NSString *)roomID {
    if (![roomID isEqualToString:self.roomInfo.roomID]) {
        return;
    }
    
    [self sendDebugMsg:@"收到被大主播踢出连麦的消息"];
    dispatch_async(self.delegateQueue, ^{
        if ([self.delegate respondsToSelector:@selector(onKickoutJoinAnchor)]) {
            [self.delegate onKickoutJoinAnchor];
        }
    });
}

// 接收群自定义消息，cmd为自定义命令字，msg为自定义消息体(这里统一使用json字符串)
- (void)onRecvGroupCustomMsg:(NSString *)groupID userID:(NSString *)userID cmd:(NSString *)cmd msg:(NSString *)msg userName:(NSString *)userName userAvatar:(NSString *)userAvatar {
    if (![groupID isEqualToString:self.roomInfo.roomID]) {
        return;
    }
    
    dispatch_async(self.delegateQueue, ^{
        if ([self.delegate respondsToSelector:@selector(onRecvRoomCustomMsg:userID:userName:userAvatar:cmd:message:)]) {
            [self.delegate onRecvRoomCustomMsg:groupID userID:userID userName:userName userAvatar:userAvatar cmd:cmd message:msg];
        }
    });
}

// 接收到PK请求
- (void)onRequestRoomPK:(NSString *)roomID userID:(NSString *)userID userName:(NSString *)userName userAvatar:(NSString *)userAvatar streamUrl:(NSString *)streamUrl {
    [self sendDebugMsg:[NSString stringWithFormat:@"收到房间[%@]主播[%@]的PK请求", roomID, userID]];
    dispatch_async(self.delegateQueue, ^{
        if ([self.delegate respondsToSelector:@selector(onRequestRoomPK:)]) {
            MLVBAnchorInfo *info = [[MLVBAnchorInfo alloc] init];
            info.userID = userID;
            info.userName = userName;
            info.userAvatar = userAvatar;
            info.accelerateURL = streamUrl;
            [self.delegate onRequestRoomPK:info];
        }
    });
}

// 接收到PK请求回应, result为YES表示同意PK，为NO表示拒绝PK，若同意，则streamUrl为对方的播放流地址
- (void)onRecvPKResponse:(NSString *)roomID userID:(NSString *)userID result:(BOOL)result message:(NSString *)message streamUrl:(NSString *)streamUrl {
    [self sendDebugMsg:[NSString stringWithFormat:@"收到房间[%@]主播[%@]回应PK请求:result[%d] message[%@]", roomID, userID, result, message]];
    MLVBAnchorInfo *anchor = [[MLVBAnchorInfo alloc] init];
    anchor.userID = userID;
    anchor.accelerateURL = streamUrl;
    __weak __typeof(self) wself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong __typeof(wself) self = wself;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleRequestPKTimeout:) object:nil];
        [self asyncRun:^(MLVBLiveRoom *self) {
            self->_mixMode = StreamMixModePK;
            self.pkAnchor = anchor;
            dispatch_async(self.delegateQueue, ^{
                if (self->_requestPKCompletion) {
                    if (result) {
                        self.requestPKCompletion(0, message, streamUrl);
                    } else {
                        self.requestPKCompletion(ROOM_ERR_USER_REJECTED, message, nil);
                    }
                    self->_requestPKCompletion = nil;
                }
            });
        }];
        
    });
}

// 接收PK结束消息
- (void)onRecvPKFinishRequest:(NSString *)roomID userID:(NSString *)userID {
    [self sendDebugMsg:[NSString stringWithFormat:@"收到房间[%@]主播[%@]的结束PK消息", roomID, userID]];
    [self asyncRun:^(MLVBLiveRoom *self) {
        self.pkAnchor = nil;
    }];
    dispatch_async(self.delegateQueue, ^{
        if ([self.delegate respondsToSelector:@selector(onQuitRoomPK)]) {
            [self.delegate onQuitRoomPK];
        }
    });
}

- (void)updateAnchorList {
    [self _updateAnchorList:^(int errCode, NSString *errMsg, NSArray<MLVBAnchorInfo *> *updatedAnchorList) {
        [self handleUpdatedAnchorList:updatedAnchorList];
    }];
}

- (void)sendDebugMsg:(NSString *)msg {
    NSLog(@"%@", msg);
    dispatch_async(self.delegateQueue, ^{
        if ([self.delegate respondsToSelector:@selector(onDebugLog:)]) {
            [self.delegate onDebugLog:msg];
        }
    });
}

#pragma mark - 连麦混流

// mode: 1 表示连麦模式   2 表示PK模式， 二者画面布局不同
// playUrlArray 表示待混流的播放地址(自己除外)
// https://cloud.tencent.com/document/product/267/8832
- (void)requestMergeStreamWithPlayUrlArray:(NSArray<NSString *> *)playUrlArray withMode:(StreamMixMode)mode {
    [self requestMergeStream:5 playUrlArray:playUrlArray withMode:mode];
}

- (void)requestMergeStream: (int)retryCount playUrlArray:(NSArray<NSString *> *)playUrlArray withMode:(StreamMixMode)mode {
    NSDictionary *mergeParams = nil;
    if (mode == StreamMixModePK && playUrlArray.count > 0) {
        mergeParams = [self createPKMergeParams:playUrlArray];
    } else {
        mergeParams = [self createJoinAnchorMergeParams:playUrlArray];
    }
    NSDictionary *param = @{@"userID": _currentUser.userID, @"roomID": self.roomInfo.roomID, @"mergeParams": mergeParams};
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        [self sendMergeStreamRequest:param retryCount:retryCount];
    });
}

// 连麦合流参数
- (NSDictionary*)createJoinAnchorMergeParams:(NSArray<NSString *> *)playUrlArray {
    NSString *mainStreamId = [self getStreamIDByStreamUrl:_pushUrl];
    
    NSMutableArray * inputStreamList = [NSMutableArray new];
    
    //大主播
    NSDictionary * mainStream = @{
                                  @"input_stream_id": mainStreamId,
                                  @"layout_params": @{@"image_layer": [NSNumber numberWithInt:1]}
                                  };
    [inputStreamList addObject:mainStream];
    
    NSString * streamInfo = [NSString stringWithFormat:@"mainStream: %@", mainStreamId];
    
    
    int mainStreamWidth = 540;
    int mainStreamHeight = 960;
    int subWidth  = 160;
    int subHeight = 240;
    int offsetHeight = 90;
    if (mainStreamWidth < 540 || mainStreamHeight < 960) {
        subWidth  = 120;
        subHeight = 180;
        offsetHeight = 60;
    }
    int subLocationX = mainStreamWidth - subWidth;
    int subLocationY = mainStreamHeight - subHeight - offsetHeight;
    
    NSMutableArray *subStreamIds = [[NSMutableArray alloc] init];
    for (NSString *playUrl in playUrlArray) {
        [subStreamIds addObject:[self getStreamIDByStreamUrl:playUrl]];
    }
    
    //小主播
    int index = 0;
    for (NSString * item in subStreamIds) {
        NSDictionary * subStream = @{
                                     @"input_stream_id": item,
                                     @"layout_params": @{
                                             @"image_layer": [NSNumber numberWithInt:(index + 2)],
                                             @"image_width": [NSNumber numberWithInt: subWidth],
                                             @"image_height": [NSNumber numberWithInt: subHeight],
                                             @"location_x": [NSNumber numberWithInt:subLocationX],
                                             @"location_y": [NSNumber numberWithInt:(subLocationY - index * subHeight)]
                                             }
                                     };
        ++index;
        [inputStreamList addObject:subStream];
        
        streamInfo = [NSString stringWithFormat:@"%@ subStream%d: %@", streamInfo, index, item];
    }
    
    NSLog(@"MergeVideoStream: %@", streamInfo);
    
    //para
    NSDictionary * para = @{
                            @"app_id": @(_currentUser.sdkAppID) ,
                            @"interface": @"mix_streamv2.start_mix_stream_advanced",
                            @"mix_stream_session_id": mainStreamId,
                            @"output_stream_id": mainStreamId,
                            @"input_stream_list": inputStreamList
                            };
    
    //interface
    NSDictionary * interface = @{
                                 @"interfaceName":@"Mix_StreamV2",
                                 @"para":para
                                 };
    
    
    //mergeParams
    NSDictionary * mergeParams = @{
                                   @"timestamp": [NSNumber numberWithLong: (long)[[NSDate date] timeIntervalSince1970]],
                                   @"eventId": [NSNumber numberWithLong: (long)[[NSDate date] timeIntervalSince1970]],
                                   @"interface": interface
                                   };
    return mergeParams;
}

// PK合流参数
- (NSDictionary*)createPKMergeParams:(NSArray<NSString *> *)playUrlArray {
    NSString *mainStreamId = [self getStreamIDByStreamUrl:_pushUrl];
    NSString *pkStreamId = @"";
    for (NSString *playUrl in playUrlArray) {  // 目前只会有一个主播PK
        pkStreamId = [self getStreamIDByStreamUrl:playUrl];
        break;
    }
    
    NSMutableArray * inputStreamList = [NSMutableArray new];
    
    //画布
    NSDictionary * canvasStream = @{
                                    @"input_stream_id": mainStreamId,
                                    @"layout_params": @{
                                            @"image_layer": @(1),
                                            @"input_type": @(3),
                                            @"image_width": @(720),
                                            @"image_height": @(640)
                                            }
                                    };
    [inputStreamList addObject:canvasStream];
    
    // mainStream
    NSDictionary * mainStream = @{
                                  @"input_stream_id": mainStreamId,
                                  @"layout_params": @{
                                          @"image_layer": @(2),
                                          @"image_width": @(360),
                                          @"image_height": @(640),
                                          @"location_x": @(0),
                                          @"location_y": @(0)
                                          }
                                  };
    [inputStreamList addObject:mainStream];
    
    // pkStream
    NSDictionary * pkStream = @{
                                @"input_stream_id": pkStreamId,
                                @"layout_params": @{
                                        @"image_layer": @(3),
                                        @"image_width": @(360),
                                        @"image_height": @(640),
                                        @"location_x": @(360),
                                        @"location_y": @(0)
                                        }
                                };
    [inputStreamList addObject:pkStream];
    
    
    //para
    NSDictionary * para = @{
                            @"app_id": @(_currentUser.sdkAppID) ,
                            @"interface": @"mix_streamv2.start_mix_stream_advanced",
                            @"mix_stream_session_id": mainStreamId,
                            @"output_stream_id": mainStreamId,
                            @"input_stream_list": inputStreamList
                            };
    
    //interface
    NSDictionary * interface = @{
                                 @"interfaceName":@"Mix_StreamV2",
                                 @"para":para
                                 };
    
    
    //mergeParams
    NSDictionary * mergeParams = @{
                                   @"timestamp": [NSNumber numberWithLong: (long)[[NSDate date] timeIntervalSince1970]],
                                   @"eventId": [NSNumber numberWithLong: (long)[[NSDate date] timeIntervalSince1970]],
                                   @"interface": interface
                                   };
    return mergeParams;
}

- (NSString*) getStreamIDByStreamUrl:(NSString*) strStreamUrl {
    if (strStreamUrl == nil || strStreamUrl.length == 0) {
        return nil;
    }
    
    //推流地址格式：rtmp://8888.livepush.myqcloud.com/path/8888_test_12345_test?txSecret=aaaa&txTime=bbbb
    //拉流地址格式：rtmp://8888.liveplay.myqcloud.com/path/8888_test_12345_test
    //            http://8888.liveplay.myqcloud.com/path/8888_test_12345_test.flv
    //            http://8888.liveplay.myqcloud.com/path/8888_test_12345_test.m3u8
    
    NSString * strSubString = strStreamUrl;
    
    {
        //1 截取第一个 ？之前的子串
        NSString * strFind = @"?";
        NSRange range = [strSubString rangeOfString:strFind];
        if (range.location != NSNotFound) {
            strSubString = [strSubString substringToIndex:range.location];
        }
        if (strSubString == nil || strSubString.length == 0) {
            return nil;
        }
    }
    
    {
        //2 截取最后一个 / 之后的子串
        NSString * strFind = @"/";
        NSRange range = [strSubString rangeOfString:strFind options:NSBackwardsSearch];
        if (range.location != NSNotFound) {
            strSubString = [strSubString substringFromIndex:range.location + range.length];
        }
        if (strSubString == nil || strSubString.length == 0) {
            return nil;
        }
    }
    
    {
        //3 截取第一个 . 之前的子串
        NSString * strFind = @".";
        NSRange range = [strSubString rangeOfString:strFind];
        if (range.location != NSNotFound) {
            strSubString = [strSubString substringToIndex:range.location];
        }
        if (strSubString == nil || strSubString.length == 0) {
            return nil;
        }
    }
    
    return strSubString;
}

-(int)getPlayType:(NSString*)playUrl {
    if ([playUrl hasPrefix:@"rtmp:"]) {
        return  PLAY_TYPE_LIVE_RTMP;
    }
    else if (([playUrl hasPrefix:@"https:"] || [playUrl hasPrefix:@"http:"]) && ([playUrl rangeOfString:@".flv"].length > 0)) {
        return PLAY_TYPE_LIVE_FLV;
    }
    else{
        return PLAY_TYPE_LIVE_FLV;
    }
}
@end

@implementation MLVBProxy
+ (Class)class {
    return [MLVBLiveRoom class];
}

- (instancetype)initWithInstance:(MLVBLiveRoom *)object
{
    _object = object;
    return self;
}
- (void)destroy {
    _object = nil;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [MLVBLiveRoom instanceMethodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    if (_object) {
        [invocation invokeWithTarget:_object];
    } else {
        NSLog(@"Calling method on destroyed TRTCCloud: %p, %s", self, [NSStringFromSelector(invocation.selector) UTF8String]);
    }
}
@end
