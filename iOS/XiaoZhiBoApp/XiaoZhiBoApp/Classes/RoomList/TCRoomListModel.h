/**
 * Module: TCRoomListModel
 *
 * Function: 房间列表管理
 */

#import <Foundation/Foundation.h>
#import "MLVBLiveRoom.h"

/**
 *  直播/点播列表的数据层定义以及序列化/反序列化实现
 */

typedef NS_ENUM(NSInteger, TCRoomListItemType) {
    TCRoomListItemType_Live             = 0,
    TCRoomListItemType_Record           = 1,
    TCRoomListItemType_UGC              = 2,
};


/**
 * 用户信息
 */
@interface TCUserInfo : NSObject
@property (nonatomic, strong) NSString *nickname;
@property (nonatomic, strong) NSString *headpic;
@property (nonatomic, strong) NSString *frontcover;
@property (nonatomic, strong) UIImage  *frontcoverImage;
@property (nonatomic, strong) NSString *location;
@end

/**
 * 房间信息
 */
@interface TCRoomInfo : NSObject
@property (nonatomic, strong) NSString    *userid;
@property (nonatomic, strong) NSString    *groupid;
@property (nonatomic, assign) NSInteger   type;
@property (nonatomic, assign) NSInteger   viewercount;         // 当前在线人数
@property (nonatomic, assign) NSInteger   likecount;           // 点赞数
@property (nonatomic, strong) NSString    *title;
@property (nonatomic, strong) NSString    *playurl;
@property (nonatomic, strong) NSString    *hls_play_url;
@property (nonatomic, strong) NSString    *fileid;
@property (nonatomic, strong) TCUserInfo  *userinfo;
@property (nonatomic, assign) NSInteger   timestamp;
@end


extern NSString *const kTCRoomListNewDataAvailable;
extern NSString *const kTCRoomListSvrError;
extern NSString *const kTCRoomListUpdated;

typedef NS_ENUM(NSInteger,VideoType) {
    VideoType_LIVE_Online = 1,        //1:拉取在线直播列表
    VideoType_VOD_SevenDay,           //2:拉取7天内录播列表
    VideoType_LIVE_VOD_SevenDay,      //3:拉取在线直播和7天内录播列表，直播列表在前，录播列表在后
    VideoType_LIVE_All,               //4:拉取所有直播列表
    VideoType_UGC_SevenDay,           //5拉取7天内ugc列表
};

typedef NS_ENUM(NSInteger,GetType) {
    GetType_Up,
    GetType_Down,
};

/**
 *  列表管理的数据层代码，主要负责列表数据的拉取、缓存和更新。目前只支持全量拉取，暂不支持增量拉取。
 *  列表拉取的协议设计成分页模式，调用列表拉取接口后，逻辑层循环从后台拉取列表，直至拉取完成，
 *  为了提升拉取体验，在拉取到第一页数据后，就立即通知界面刷新展示
 */
@interface TCRoomListMgr : NSObject

@property (nonatomic, retain) MLVBLiveRoom* liveRoom;

+ (instancetype)sharedMgr;

- (void)setUserId:(NSString *)userId expires:(NSNumber *)expires token:(NSString *)token;

/**
 *  后台请求列表数据
 */
- (void)queryVideoList:(VideoType)videoType getType:(GetType)getType;

/**
 *  清除所有列表数据，停止当前的请求动作
 */
- (void)cleanAllLives;

/**
 *  读取列表
 *
 *  @param range  列表返回
 *  @param finish 是否已经读到末尾
 *
 *  @return 返回读取到的数据
 *  如果返回数据为空，finish = NO，表示还有数据未读完，可以等待下次通知
 *  kTCLiveListNewDataAvailable 到达后继续调用此接口
 */
- (NSArray *)readRoomList:(NSRange)range finish:(BOOL *)finish;

/**
 * 读取指定id的数据
 */
- (TCRoomInfo *)readRoom:(int)type userId:(NSString *)userId fileId:(NSString *)fileId;

/**
 *  从本地文件加载列表数据
 */
- (void)loadLivesFromArchive:(VideoType)videoType;

/**
 *  更新在线人数和点赞数量，由于后台的视频的在线人数和点赞数量一直在变化，所以需要在用户点击播放按钮后，调用TCPlayer中的GetUserInfo接口
 *  查询到最新的数据后，调用此接口更新该视频的在线人数和点赞数量
 */
- (void)update:(NSString *)userId viewerCount:(int)viewerCount likeCount:(int)likeCount;


@end
