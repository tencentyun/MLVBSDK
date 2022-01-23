//
//  TUIPusherView.h
//  TUIPusher
//
//  Created by gg on 2021/9/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TUIPusherView;

typedef NS_ENUM(NSInteger, TUIPusherEvent) {
    TUIPUSHER_EVENT_UNKNOWN = 0, // 未知错误，详细查询推流错误吗对照表
    TUIPUSHER_EVENT_SUCCESS = 1,
    TUIPUSHER_EVENT_FAILED = -1,
    TUIPUSHER_EVENT_INVALID_LICENSE = -2,
    TUIPUSHER_EVENT_URL_NOTSUPPORT = -3, // 不支持当前URL
    TUIPUSHER_EVENT_NOT_LOGIN = -4, // 用户状态没有登录
};

// 响应回调
typedef void(^Response)(BOOL isAgree);

@protocol TUIPusherViewDelegate <NSObject>

@optional

#pragma mark - 主要流程回调
/// 开始推流后回调
/// @param url 当前推流地址
- (void)onPushStarted:(TUIPusherView *)pusherView url:(NSString *)url;

/// 结束推流后回调
/// @param url 之前推流地址
- (void)onPushStoped:(TUIPusherView *)pusherView url:(NSString *)url;

/// 有异常时从这里抛出
/// @param event 事件类型
/// @param message 信息
- (void)onPushEvent:(TUIPusherView *)pusherView event:(TUIPusherEvent)event message:(NSString *)message;

/// 点击开始按钮回调
/// @param url 当前推流地址
/// @param completion 给 Pusher 回调结果，为 true，则继续推流，为 false，则停止当前操作
- (void)onClickStartPushButton:(TUIPusherView *)pusherView url:(NSString *)url responseCallback:(Response)completion;

#pragma mark - PK 相关

/// 收到 PK 邀请
/// @param userId 对方 user id
/// @param completion 给 Pusher 回调结果，若为 true，则开始 PK 流程，为 false 则停止当前操作
- (void)onReceivePKRequest:(TUIPusherView *)pusherView userId:(NSString *)userId responseCallback:(Response)completion;

/// 对方拒绝 PK请求的 回调
/// @param reason  1：对方主动拒绝 2：忙线中(pk 或者 连麦)
- (void)onRejectPKResponse:(TUIPusherView *)pusherView reason:(int)reason;

/// 对方取消 PK 邀请
- (void)onCancelPKRequest:(TUIPusherView *)pusherView;

/// 开始 PK
- (void)onStartPK:(TUIPusherView *)pusherView;

/// 结束 PK
- (void)onStopPK:(TUIPusherView *)pusherView;

/// PK 请求超时
- (void)onPKTimeout:(TUIPusherView *)pusherView;

#pragma mark - 连麦相关

/// 收到连麦邀请
/// @param userId 对方 user id
/// @param completion 给 Pusher 回调结果，若为 true，则开始连麦流程，为 false 则停止当前操作
- (void)onReceiveJoinAnchorRequest:(TUIPusherView *)pusherView userId:(NSString *)userId responseCallback:(Response)completion;

/// 对方取消连麦邀请
- (void)onCancelJoinAnchorRequest:(TUIPusherView *)pusherView;

/// 开始连麦
- (void)onStartJoinAnchor:(TUIPusherView *)pusherView;

/// 结束连麦
- (void)onStopJoinAnchor:(TUIPusherView *)pusherView;

/// 连麦请求超时
- (void)onJoinAnchorTimeout:(TUIPusherView *)pusherView;
@end

NS_ASSUME_NONNULL_END
