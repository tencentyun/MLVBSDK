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

/// 后台错误码
typedef NS_ENUM(NSInteger, RoomServerError) {
    //推流和拉流错误码，请查看 TXLiteAVCode.h
    //IM 错误码，请查看 https://cloud.tencent.com/document/product/269/1671

    /*msg处理错误*/
    ERROR_CODE_INVALID_MSG = 200100,
    ERROR_CODE_INVALID_JSON = 200101,
    /*参数校验错误*/
    ERROR_CODE_INCOMPLETE_PARAM = 201000,
    ERROR_CODE_INCOMPLETE_LOGIN_PARAM = 201001,
    ERROR_CODE_NO_USERID = 201002,
    ERROR_CODE_USERID_NOT_EQUAL = 201003,
    ERROR_CODE_NO_ROOMID = 201004,
    ERROR_CODE_NO_COUNT = 201005,
    ERROR_CODE_NO_MERGE_STREAM_PARAM = 201006,
    ERROR_CODE_OPERATION_EMPTY = 201007,
    ERROR_CODE_UNSUPPORT_OPERATION = 201008,
    ERROR_CODE_SET_FIELD_VALUE_EMPTY = 201009,
    /*鉴权错误*/
    ERROR_CODE_VERIFY = 202000,
    ERROR_CODE_VERIFY_FAILED = 202001,
    ERROR_CODE_CONNECTED_TO_IM_SERVER = 202002,
    ERROR_CODE_INVALID_RSP = 202003,
    ERROR_CODE_LOGOUT = 202004,
    ERROR_CODE_APPID_RELATION = 202005,
    /*房间操作错误*/
    ERROR_CODE_ROOM_MGR = 203000,
    ERROR_CODE_GET_ROOM_ID = 203001,
    ERROR_CODE_CREATE_ROOM = 203002,
    ERROR_CODE_DESTROY_ROOM = 203003,
    ERROR_CODE_GET_ROOM_LIST = 203004,
    ERROR_CODE_UPDATE_ROOM_MEMBER = 203005,
    ERROR_CODE_ENTER_ROOM = 203006,
    ERROR_CODE_ROOM_PUSHER_TOO_MUCH = 203007,
    ERROR_CODE_INVALID_PUSH_URL = 203008,
    ERROR_CODE_ROOM_NAME_TOO_LONG = 203009,
    ERROR_CODE_USER_NOT_IN_ROOM = 203010,

    /*pusher操作错误*/
    ERROR_CODE_PUSHER_MGR = 204000,
    ERROR_CODE_GET_PUSH_URL = 204001,
    ERROR_CODE_GET_PUSHERS = 204002,
    ERROR_CODE_LEAVE_ROOM = 204003,
    ERROR_CODE_GET_PUSH_AND_ACC_URL = 204004,

    /*观众操作错误*/
    ERROR_CODE_AUDIENCE_MGR = 205000,
    ERROR_CODE_AUDIENCE_NUM_FULL = 205001,
    ERROR_CODE_ADD_AUDIENCE = 205002,
    ERROR_CODE_DEL_AUDIENCE = 205003,
    ERROR_CODE_GET_AUDIENCES = 205004,

    /*心跳处理错误*/
    ERROR_CODE_HEARTBEAT = 206000,
    ERROR_CODE_SET_HEARTBEAT = 206001,
    ERROR_CODE_DEL_HEARTBEAT = 206002,
    /*其他错误*/
    ERROR_CODE_OTHER = 207000,
    ERROR_CODE_DB_FAILED = 207001,
    ERROR_CODE_MIX_FAILED = 207002,
    ERROR_CODE_SET_CUSTOM_FIELD = 207003,
    ERROR_CODE_GET_CUSTOM_FIELD = 207004,
    ERROR_CODE_UNSUPPORT_ACTION = 207005,
    ERROR_CODE_UNSUPPORT_ROOM_TYPE = 207006,
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
    ROOM_ERR_INVALID_PARAM        =  -11, // 参数错误
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
