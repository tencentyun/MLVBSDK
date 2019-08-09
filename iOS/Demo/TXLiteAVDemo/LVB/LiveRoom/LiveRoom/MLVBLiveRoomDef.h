//
//  RoomDef.h
//  TXLiteAVDemo
//
//  Created by lijie on 2017/11/21.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

// 用户账号信息
@interface MLVBLoginInfo : NSObject <NSCopying>
@property (nonatomic, assign) int         sdkAppID;
@property (nonatomic, copy)   NSString*   userID;
@property (nonatomic, copy)   NSString*   userName;
@property (nonatomic, copy)   NSString*   userAvatar;
@property (nonatomic, copy)   NSString*   userSig;
@end

// 推流者信息
@interface MLVBAnchorInfo : NSObject
/// 用户 ID
@property (nonatomic, strong) NSString *userID;
/// 用户昵称
@property (nonatomic, strong) NSString *userName;
/// 用户头像地址
@property (nonatomic, strong) NSString *userAvatar;
/// 低时延拉流地址（带防盗链key）
@property (nonatomic, strong) NSString *accelerateURL;
@end

/** 普通观众信息
 *
 * 如果 userInfo 是 JSON 字符串，userName 和 userAvatar 会从 userInfo 中的 "userName"，"userAvatar" 中提取。
 * 如果 MLVBAudienceInfo 从 IM 用户信息中创建，则 userInfo 为空。
 */
@interface MLVBAudienceInfo : NSObject
@property (nonatomic, copy)   NSString*   userID;
@property (nonatomic, copy)   NSString*   userAvatar;
@property (nonatomic, copy)   NSString*   userName;
@property (nonatomic, copy)   NSString*   userInfo;
@end

// 房间信息
@interface MLVBRoomInfo : NSObject
@property (nonatomic, copy) NSString*   roomID;
@property (nonatomic, copy) NSString*   roomInfo;
@property (nonatomic, copy) NSString*   roomCreator;   // 房间创建者的userID
@property (nonatomic, copy) NSString*   mixedPlayURL;  // 房间混流播放地址
@property (nonatomic, copy) NSString*   custom;
@property (nonatomic, strong) MLVBAnchorInfo* anchor;    // 大主播
@property (nonatomic, strong) NSArray<MLVBAnchorInfo*>* anchorInfoArray; ///< 小主播列表
@property (nonatomic, strong) NSNumber *audienceCount;
@property (nonatomic, strong) NSMutableArray<MLVBAudienceInfo*>* audienceInfoArray;
@end


// 视频分辨率比例
typedef NS_ENUM(NSInteger, RoomVideoRatio) {
    ROOM_VIDEO_RATIO_9_16    =   1,  // 视频分辨率为9:16
    ROOM_VIDEO_RATIO_3_4     =   2,  // 视频分辨率为3:4
    ROOM_VIDEO_RATIO_1_1     =   3,  // 视频分辨率为1:1
};

// 错误码列表
typedef NS_ENUM(NSInteger, RoomErrCode) {
    ROOM_SUCCESS                  =   0, // 成功
    ROOM_ERR_REQUEST_TIMEOUT      =  -1, // 请求超时
    ROOM_ERR_IM_LOGIN             =  -2, // IM登录失败
    ROOM_ERR_CREATE_ROOM          =  -3, // 创建房间失败
    ROOM_ERR_ENTER_ROOM           =  -4, // 加入房间失败
    ROOM_ERR_INVALID_LICENSE      =  -5, // License校验失败
    ROOM_ERR_CANCELED             =  -6, // 用户取消（如退房）
    ROOM_ERR_INSTANCE_RELEASED    =  -7, // 异步操作返回时 MLVBLiveRoom 已经被释放
    ROOM_ERR_USER_REJECTED        =  -8, // 请求被对方拒绝
    ROOM_ERR_IM_FORCE_OFFLINE     =  -9, // IM被强制下线（如多端登录）
    ROOM_ERR_PUSH_DISCONNECT      =  -10, // 推流连接断开
};

/// 自定义字段设置操作
typedef NS_ENUM(NSInteger, MLVBCustomFieldOp) {
    MLVBCustomFieldOpSet, ///< 设置值
    MLVBCustomFieldOpInc, ///< 加计数
    MLVBCustomFieldOpDec  ///< 减计数
};

/**
 主播发起PK请求的回调
 @param errCode 0表示成功，1表示拒绝，-1表示超时
 @param errMsg  消息说明
 @param streamUrl 若errCode为0，则streamUrl表示对方主播的播放流地址
 */
typedef void (^IRequestPKCompletionHandler)(int errCode, NSString *errMsg, NSString *streamUrl);

/**
 获取房间列表的回调
 @param roomInfoArray 请求的房间列表信息
 */
typedef void (^IGetRoomListCompletionHandler)(int errCode, NSString *errMsg, NSArray<MLVBRoomInfo *> *roomInfoArray);

/**
 播放开始的回调
 */
typedef void (^IPlayBegin)(void);

/**
 播放过程中发生错误时的回调
 */
typedef void (^IPlayError)(int errCode, NSString *errMsg);
