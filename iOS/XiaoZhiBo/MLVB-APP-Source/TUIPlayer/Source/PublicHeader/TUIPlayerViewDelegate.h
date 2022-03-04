//
//  TUIPlayerViewDelegate.h
//  Pods
//
//  Created by gg on 2021/9/14.
//

#ifndef TUIPlayerViewDelegate_h
#define TUIPlayerViewDelegate_h

typedef NS_ENUM(NSInteger, TUIPlayerEvent) {
    TUIPLAYER_EVENT_SUCCESS = 1,
    TUIPLAYER_EVENT_FAILED = -1,
    TUIPLAYER_EVENT_INVALID_LICENSE = -2,
    TUIPLAYER_EVENT_URL_NOTSUPPORT = -3, // 不合法的URL
    
    /// 连麦相关的事件
    TUIPLAYER_EVENT_LINKMIC_START = 10001, // 开始连麦
    TUIPLAYER_EVENT_LINKMIC_STOP = 10002,   // 结束连麦
};

@class TUIPlayerView;

@protocol TUIPlayerViewDelegate <NSObject>

#pragma mark - 播放回调
/// 开始拉流
- (void)onPlayStarted:(TUIPlayerView *)playerView url:(NSString *)url;

/// 结束拉流
- (void)onPlayStoped:(TUIPlayerView *)playerView url:(NSString *)url;

/// 事件发生时调用
- (void)onPlayEvent:(TUIPlayerView *)playerView event:(TUIPlayerEvent)event message:(NSString *)message;

/// 对方拒绝 连麦请求的 回调
/// @param reason  1：对方主动拒绝 2：忙线中(pk 或者 连麦)
- (void)onRejectJoinAnchorResponse:(TUIPlayerView *)playerView reason:(int)reason;
@end

#endif /* TUIPlayerViewDelegate_h */
