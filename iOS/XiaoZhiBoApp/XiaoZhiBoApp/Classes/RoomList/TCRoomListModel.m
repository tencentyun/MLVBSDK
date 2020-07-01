/**
 * Module: TCRoomListModel
 *
 * Function: 房间列表管理
 */

#import "TCRoomListModel.h"
#import "TCUtil.h"

@implementation TCUserInfo

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_nickname forKey:@"nickname" ];
    [coder encodeObject:_headpic forKey:@"headpic" ];
    [coder encodeObject:_frontcover forKey:@"frontcover" ];
    [coder encodeObject:_location forKey:@"location" ];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.nickname = [coder decodeObjectForKey:@"nickname" ];
        self.headpic = [coder decodeObjectForKey:@"headpic" ];
        self.frontcover = [coder decodeObjectForKey:@"frontcover" ];
        self.location = [coder decodeObjectForKey:@"location" ];
    }
    return self;
}

@end

@implementation TCRoomInfo

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_userid forKey:@"userid" ];
    [coder encodeObject:_groupid forKey:@"groupid" ];
    [coder encodeObject:@(_type) forKey:@"type" ];
    [coder encodeObject:@(_viewercount) forKey:@"viewercount" ];
    [coder encodeObject:@(_likecount) forKey:@"likecount" ];
    [coder encodeObject:_title forKey:@"title" ];
    [coder encodeObject:_playurl forKey:@"playurl" ];
    [coder encodeObject:_fileid forKey:@"fileid" ];
    [coder encodeObject:_userinfo forKey:@"userinfo" ];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.userid = [coder decodeObjectForKey:@"userid" ];
        self.groupid = [coder decodeObjectForKey:@"groupid" ];
        self.type = [[coder decodeObjectForKey:@"type" ] intValue];
        self.viewercount = [[coder decodeObjectForKey:@"viewercount" ] intValue];
        self.likecount = [[coder decodeObjectForKey:@"likecount" ] intValue];
        self.title = [coder decodeObjectForKey:@"title" ];
        self.playurl = [coder decodeObjectForKey:@"playurl" ];
        self.fileid = [coder decodeObjectForKey:@"fileid" ];
        self.userinfo = [coder decodeObjectForKey:@"userinfo" ];
    }
    return self;
}

@end


// -----------------------------------------------------------------------------

#import <AFNetworking.h>
#import <MJExtension/MJExtension.h>

#define pageSize 20
#define userDefaultsKey @"TCRoomListMgr"


#define QUOTE(...) @#__VA_ARGS__
//*
NSString *json = QUOTE(
                       {
                           "returnValue": 0,
                           "returnMsg": "return successfully!",
                           "returnData": {
                               "all_count": 1,
                               "pusherlist": [
                                              {
                                                  "userid" : "aaaa",
                                                  "groupid" : "bbbb",
                                                  "timestamp" : 1874483992,
                                                  "type" : 1,
                                                  "viewercount" : 1888,
                                                  "likecount" : 888,
                                                  "title" : "Testest",
                                                  "playurl" : "rtmp://live.hkstv.hk.lxdns.com/live/hks",
                                                  "userinfo" : {
                                                      "nickname": "Testest",
                                                      "userid" : "aaaa",
                                                      "groupid" : "bbbb",
                                                      "headpic" : "http://wx.qlogo.cn/mmopen/xxLzNxqMsxnlE4O0LjLaxTkiapbRU1HpVNPPvZPWb4MTicy1G1hJtEic0VGLbMFUrVA5ILoAnjQ2enNTSMYIe2hrQFkfRRfBccQ/132",
                                                      "frontcover" : "http://wx.qlogo.cn/mmopen/xxLzNxqMsxnlE4O0LjLaxTkiapbRU1HpVNPPvZPWb4MTicy1G1hJtEic0VGLbMFUrVA5ILoAnjQ2enNTSMYIe2hrQFkfRRfBccQ/0",
                                                      "location" : "深圳"
                                                  }
                                              }
                                              ]
                           }
                       }
                       );

//*/
NSString *const kTCRoomListNewDataAvailable = @"kTCLiveListNewDataAvailable";
NSString *const kTCRoomListSvrError = @"kTCLiveListSvrError";
NSString *const kTCRoomListUpdated = @"kTCLiveListUpdated";

@interface TCRoomListMgr()

@property (strong) NSMutableArray        *allLivesArray;
@property int                   totalCount;
@property int                   currentPage;
@property BOOL                  isLoading;
@property BOOL                  isVideoTypeChange;
@property VideoType             videoType;
@property (strong) AFHTTPSessionManager  *httpSession;
@property (strong) NSMutableArray        *liveArray;
@property (nonatomic, copy)   NSString*  userId;
@property (nonatomic, strong) NSNumber*        expired;
@property (nonatomic, strong) NSString*        token;

@end

@implementation TCRoomListMgr

- (instancetype)init {
    self = [super init];
    if (self) {
        _allLivesArray = [NSMutableArray new];
        _liveArray = [NSMutableArray new];
        _totalCount = 0;
        _isLoading = NO;
        _httpSession = [AFHTTPSessionManager manager];
        
#ifdef NDEBUG
        _httpSession.requestSerializer.timeoutInterval = 5.f;
#endif
        [_httpSession setRequestSerializer:[AFJSONRequestSerializer serializer]];
        [_httpSession setResponseSerializer:[AFJSONResponseSerializer serializer]];
        _httpSession.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/xml", @"text/plain", nil];
        
    }
    return self;
}

+ (instancetype)sharedMgr {
    static TCRoomListMgr *mgr;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (mgr == nil) {
            mgr = [TCRoomListMgr new];
        }
    });
    return mgr;
}

- (void)setUserId:(NSString *)userId expires:(NSNumber *)expires token:(NSString *)token {
    self.userId = userId;
    self.expired = expires;
    self.token = token;
}

- (void)queryVideoList:(VideoType)videoType getType:(GetType)getType {
    _isLoading = YES;
    
    if (getType == GetType_Up || _videoType != videoType) {
        _currentPage = 0;
        [self cleanAllLives];
        _videoType = videoType;
    }
    
    [_httpSession.operationQueue cancelAllOperations];
    
    [self loadNextLives:videoType];
}

- (void)queryLiveVideoList:(VideoType)type {
    __weak typeof(self) weakSelf = self;

    _isLoading = YES;
    [self.liveRoom getRoomList:0 count:_currentPage * 20 completion:^(int errCode, NSString *errMsg, NSArray<MLVBRoomInfo *> *roomInfoArray) {
        if (errCode == 0) {
            NSMutableArray* pusherArray = [NSMutableArray new];
            for (MLVBRoomInfo* roomInfo in roomInfoArray) {
                TCRoomInfo* liveInfo = [TCRoomInfo new];
                liveInfo.userinfo = [TCUserInfo new];
                liveInfo.userid = roomInfo.roomCreator;
                liveInfo.groupid = roomInfo.roomID;
                liveInfo.type = TCRoomListItemType_Live;
                liveInfo.playurl = roomInfo.mixedPlayURL;
                if(roomInfo.audienceCount && [roomInfo.audienceCount isKindOfClass:[NSNumber class]]){
                     liveInfo.viewercount = [roomInfo.audienceCount intValue];
                }
                NSString *roomInfoMsg = roomInfo.roomInfo;
                if(roomInfoMsg){
                    NSDictionary *dic = [TCUtil jsonData2Dictionary:roomInfoMsg];
                    if(dic){
                        liveInfo.title = dic[@"title"];
                        liveInfo.userinfo.frontcover = dic[@"frontcover"];
                        liveInfo.userinfo.location = dic[@"location"];
                    } else {
                        liveInfo.title = roomInfoMsg;
                    }
                }
                NSDictionary *customInfo = [TCUtil jsonData2Dictionary:roomInfo.custom];
                if (customInfo) {
                    liveInfo.likecount = [customInfo[@"praise"] intValue];
                }

                MLVBAnchorInfo* anchorInfo = roomInfo.anchor;
                liveInfo.userinfo.nickname = (anchorInfo.userName == nil ? anchorInfo.userID : anchorInfo.userName);
                liveInfo.userinfo.headpic = (anchorInfo.userAvatar == nil ? @"" : anchorInfo.userAvatar);
                if (liveInfo.playurl.length < 1) {
                    liveInfo.playurl = anchorInfo.accelerateURL;
                }
                
                [pusherArray addObject:liveInfo];
            }
            
            if (![pusherArray isEqualToArray:weakSelf.liveArray]) {
                @synchronized (weakSelf) {
                    [weakSelf.allLivesArray removeObjectsInArray:weakSelf.liveArray];
                    weakSelf.liveArray = pusherArray;
                    [weakSelf.allLivesArray addObjectsFromArray:weakSelf.liveArray];
                }
            }
            weakSelf.isLoading = NO;
            [weakSelf dumpLivesToArchive:type];
            [weakSelf postDataAvaliableNotify];
        }
        else {
            weakSelf.isLoading = NO;
            NSLog(@"finish loading");
            [[NSNotificationCenter defaultCenter] postNotificationName:kTCRoomListSvrError object:[NSError errorWithDomain:@"LiveVideoList" code:errCode userInfo:@{@"errCode":@(errCode), @"description": errMsg}]];
        }
    }];
}

- (void)queryVodList:(VideoType)type {
    NSDictionary* params = @{@"userid": self.userId, @"timestamp":@([[NSDate date] timeIntervalSince1970] * 1000), @"expires":self.expired, @"index":@(0), @"count":@(_currentPage * 20)};
    __weak typeof(self) weakSelf = self;
    
    [TCUtil asyncSendHttpRequest:@"get_vod_list" token:self.token params:params handler:^(int resultCode, NSString *message, NSDictionary *resultDict) {
        if (resultCode == 200) {
            NSArray* vodInfoArray = resultDict[@"list"];
            NSMutableArray* vodArray = [NSMutableArray new];
            for (NSDictionary* roomInfo in vodInfoArray) {
                TCRoomInfo* liveInfo = [TCRoomInfo new];
                liveInfo.userinfo = [TCUserInfo new];
                liveInfo.userid = roomInfo[@"userid"];
                liveInfo.type = TCRoomListItemType_Record;
                liveInfo.title = roomInfo[@"title"];
                liveInfo.playurl = roomInfo[@"play_url"];
                liveInfo.hls_play_url = roomInfo[@"hls_play_url"];
                liveInfo.fileid = roomInfo[@"file_id"];
                liveInfo.viewercount = ((NSNumber*)roomInfo[@"viewercount"]).intValue;
                liveInfo.likecount = ((NSNumber*)roomInfo[@"likecount"]).intValue;
                liveInfo.userinfo.nickname = roomInfo[@"nickname"];
                if (liveInfo.userinfo.nickname.length == 0) {
                    liveInfo.userinfo.nickname = roomInfo[@"userid"];
                }
                liveInfo.userinfo.location = roomInfo[@"location"];
                liveInfo.userinfo.headpic = roomInfo[@"avatar"];
                liveInfo.userinfo.frontcover = roomInfo[@"frontcover"];
                [vodArray addObject:liveInfo];
            }
            
            if (![vodArray isEqualToArray:weakSelf.liveArray]) {
                @synchronized (weakSelf) {
                    
                    [weakSelf.allLivesArray removeObjectsInArray:weakSelf.liveArray];
                    weakSelf.liveArray = vodArray;
                    [weakSelf.allLivesArray addObjectsFromArray:weakSelf.liveArray];
                }
            }
            weakSelf.isLoading = NO;
            [weakSelf dumpLivesToArchive:type];
            [weakSelf postDataAvaliableNotify];
        }
        else {
            weakSelf.isLoading = NO;
            NSLog(@"finish loading");
            [[NSNotificationCenter defaultCenter] postNotificationName:kTCRoomListSvrError object:[NSError errorWithDomain:@"VodVideoList" code:resultCode userInfo:@{@"errCode":@(resultCode), @"description": message}]];
        }
    }];
}

- (void)loadNextLives:(VideoType)type {
    if (_currentPage * pageSize > _totalCount) {
        _isLoading = NO;
        [self dumpLivesToArchive:type];
        [self postDataAvaliableNotify];
        return ;
    }
    
    _currentPage++;
    
    if (type == VideoType_LIVE_Online || type == VideoType_LIVE_All) {
        [self queryLiveVideoList:type];
        return;
    }
    
    if (type == VideoType_VOD_SevenDay) {
        [self queryVodList:type];
        return;
    }
}

- (NSArray *)readRoomList:(NSRange)range finish:(BOOL *)finish {
    NSArray *res = nil;
    
    @synchronized (self) {
        if (range.location < _allLivesArray.count) {
            range.length = MIN(range.length, _allLivesArray.count - range.location);
            res = [_allLivesArray subarrayWithRange:range];
        }
    }
    
    if (range.location + range.length >= _totalCount) { // _totalCount = 0表示还没有拉到数据
        *finish = YES;
    } else {
        *finish = NO;
    }
    return res;
}

- (TCRoomInfo*)readRoom:(int)type userId:(NSString*)userId fileId:(NSString*)fileId {
    TCRoomInfo* info = nil;
    if (nil == userId)
        return nil;
    
    @synchronized (self) {
        for (TCRoomInfo* item in _allLivesArray)
        {
            if (0 == type)
            {
                if (type == item.type && [userId isEqualToString:item.userid])
                {
                    info = item;
                    break;
                }
                
                //直播在前，点播在后，所以如果type为直播，一旦遍历到点播，说明没取到数据，直接break
                if (0 != item.type)
                    break;
            }
            else
            {
                if (type == item.type && [userId isEqualToString:item.userid] && [fileId isEqualToString:item.fileid])
                {
                    info = item;
                    break;
                }
            }
        }
    }
    return info;
}

- (void)cleanAllLives {
    @synchronized (self) {
        [_allLivesArray removeAllObjects];
    }
}

- (void)postDataAvaliableNotify {
    [[NSNotificationCenter defaultCenter] postNotificationName:kTCRoomListNewDataAvailable object:nil];
}

#pragma mark - 持久化存储
- (void)loadLivesFromArchive:(VideoType)type {
    NSString *key = [NSString stringWithFormat:@"%@_%ld", userDefaultsKey, type];
    NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
    NSData *savedArray = [currentDefaults objectForKey:key];
    NSArray *oldArray = nil;
    if (savedArray != nil)
    {
        oldArray = [NSKeyedUnarchiver unarchiveObjectWithData:savedArray];
    }
    @synchronized (self) {
        if (oldArray != nil) {
            _allLivesArray = [[NSMutableArray alloc] initWithArray:oldArray];
            _totalCount = (int)_allLivesArray.count;
        } else {
            _allLivesArray = [[NSMutableArray alloc] init];
            _totalCount = 0;
        }
    }

}

- (void)dumpLivesToArchive:(VideoType)type {
    @synchronized (self) {
        if (_allLivesArray.count > 0) {
            NSString *key = [NSString stringWithFormat:@"%@_%ld", userDefaultsKey, type];
            [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:_allLivesArray] forKey:key];
        }
    }
}

- (void)update:(NSString*)userId viewerCount:(int)viewerCount likeCount:(int)likeCount {
    if (nil == userId)
        return;
    @synchronized (self) {
        for (TCRoomInfo* info in _allLivesArray)
        {
            if (info.type == 0)
            {
                if ([userId isEqualToString:info.userid])
                {
                    info.viewercount = viewerCount;
                    info.likecount = likeCount;
                    NSDictionary* dict = @{@"userid" : userId, @"type" : @0};
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kTCRoomListUpdated object:nil userInfo:dict];
                    });
                    return;
                }
            }
            else
            {
                return;
            }
        }
    }
}
@end

