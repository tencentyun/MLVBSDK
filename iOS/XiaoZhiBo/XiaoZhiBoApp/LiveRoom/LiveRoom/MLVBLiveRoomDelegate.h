//
//  LiveRoomDelegate.h
//  TXLiteAVDemo
//
//  Created by cui on 2019/4/15.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "MLVBLiveRoomDef.h"

/**
 * MLVBLiveRoom 事件回调
 *
 * 包括房间关闭、Debug 事件信息、出错说明等。
 */
@protocol MLVBLiveRoomDelegate <NSObject>
#pragma mark - 通用事件回调
/// @name 通用事件回调
/// @{
/**
 * 错误回调
 *
 * SDK 不可恢复的错误，一定要监听，并分情况给用户适当的界面提示
 *
 * @param errCode     错误码
 * @param errMsg     错误信息
 * @param extraInfo 额外信息，如错误发生的用户，一般不需要关注，默认是本地错误
 */
- (void)onError:(int)errCode errMsg:(NSString*)errMsg extraInfo:(NSDictionary *)extraInfo;

@optional

/**
 * 警告回调
 *
 * @param warningCode     错误码 TRTCWarningCode
 * @param warningMsg     警告信息
 * @param extraInfo     额外信息，如警告发生的用户，一般不需要关注，默认是本地错误
 */
- (void)onWarning:(int)warningCode warningMsg:(NSString *)warningMsg extraInfo:(NSDictionary *)extraInfo;

/**
 * Log 回调
 *
 * @param log LOG 信息
 */
- (void)onDebugLog:(NSString *)log;

/// @}

#pragma mark - 房间事件回调
/// @name 房间事件回调
/// @{
/**
 * 房间被销毁的回调
 *
 * 主播退房时，房间内的所有用户都会收到此通知
 *
 * @param roomID 房间ID
 */
- (void)onRoomDestroy:(NSString *)roomID;
/// @}


#pragma mark - 主播和观众的进出事件回调
/// @name 主播和观众的进出事件回调
/// @{
/**
 * 收到新主播进房通知
 *
 * 房间内的主播（和连麦中的观众）会收到新主播的进房事件，您可以调用 MLVBLiveRoom#startRemoteView() 显示该主播的视频画面。
 *
 * @param anchorInfo 新进房用户信息
 *
 * @note 直播间里的普通观众不会收到主播加入和推出的通知。
 */
- (void)onAnchorEnter:(MLVBAnchorInfo *)anchorInfo;

/**
 * 收到主播退房通知
 *
 * 房间内的主播（和连麦中的观众）会收到新主播的退房事件，您可以调用 MLVBLiveRoom#stopRemoteView: 关闭该主播的视频画面。
 *
 * @param anchorInfo 退房用户信息
 *
 * @note 直播间里的普通观众不会收到主播加入和推出的通知。
 */
- (void)onAnchorExit:(MLVBAnchorInfo *)anchorInfo;

/**
 * 收到观众进房通知
 *
 * @param audienceInfo 进房观众信息
 */
- (void)onAudienceEnter:(MLVBAudienceInfo *)audienceInfo;

/**
 * 收到观众退房通知
 *
 * @param audienceInfo 退房观众信息
 */
- (void)onAudienceExit:(MLVBAudienceInfo *)audienceInfo;
/// @}

#pragma mark - 主播和观众连麦事件回调
/// @name 主播和观众连麦事件回调
/// @{

/**
 * 主播收到观众连麦请求时的回调
 *
 * @param anchorInfo 观众信息
 * @param reason 连麦原因描述
 */
- (void)onRequestJoinAnchor:(MLVBAnchorInfo *)anchorInfo reason:(NSString *)reason;

/**
 * 连麦观众收到被踢出连麦的通知
 *
 * 连麦观众收到被主播踢除连麦的消息，您需要调用 MLVBLiveRoom#kickoutJoinAnchor: 来退出连麦
 */
- (void)onKickoutJoinAnchor;

/// @}


#pragma mark - 主播 PK 事件回调
/// @name 主播 PK 事件回调
/// @{

/**
 * 收到请求跨房 PK 通知
 *
 * 主播收到其他房间主播的 PK 请求
 * 如果同意 PK ，您需要调用 MLVBLiveRoom#startRemoteView() 接口播放邀约主播的流
 *
 * @param anchorInfo 发起跨房连麦的主播信息
 */
- (void)onRequestRoomPK:(MLVBAnchorInfo *)anchorInfo;

/**
 * 收到断开跨房 PK 通知
 */
- (void)onQuitRoomPK;

/// @}

#pragma mark -  消息事件回调
/// @name  消息事件回调
/// @{

/**
 * 收到文本消息
 *
 * @param roomID        房间ID
 * @param userID        发送者ID
 * @param userName      发送者昵称
 * @param userAvatar    发送者头像
 * @param message       文本消息
 */
- (void)onRecvRoomTextMsg:(NSString *)roomID userID:(NSString *)userID userName:(NSString *)userName userAvatar:(NSString *)userAvatar message:(NSString *)message;

/**
 * 收到自定义消息
 *
 * @param roomID        房间ID
 * @param userID        发送者ID
 * @param userName      发送者昵称
 * @param userAvatar    发送者头像
 * @param cmd           自定义cmd
 * @param message       自定义消息内容
 */
- (void)onRecvRoomCustomMsg:(NSString *)roomID userID:(NSString *)userID userName:(NSString *)userName userAvatar:(NSString *)userAvatar cmd:(NSString *)cmd message:(NSString *)message;


/// @}

@end
