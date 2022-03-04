//
//  TUIPlayerPresenter.h
//  TUIPlayer
//
//  Created by gg on 2021/9/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TUIPlayerPresenterDelegate <NSObject>

- (void)onReceiveLinkMicInvite:(NSString *)inviter cmd:(NSString *)cmd streamId:(NSString *)streamId;

- (void)onAcceptLinkMicInvite:(NSString *)cmd streamId:(NSString *)streamId;
- (void)onRejectLinkMicInvite:(NSString *)cmd reason:(int)reason;

- (void)onStartLinkMic:(NSString *)cmd streamId:(NSString *)streamId;
- (void)onStopLinkMic:(NSString *)cmd;
- (void)onLinkMicInviteTimeout;

- (void)onRemoteStopPush;

@end

@interface TUIPlayerPresenter : NSObject

@property (nonatomic, weak) id <TUIPlayerPresenterDelegate> delegate;

- (NSInteger)startPlay:(NSString *)url atView:(UIView *)view;

- (void)stopPlay;

/// 暂停视频流。
- (void)pauseVideo;

/// 恢复视频流。
- (void)resumeVideo;

/// 暂停音频流。
- (void)pauseAudio;

/// 恢复音频流
- (void)resumeAudio;

- (BOOL)sendLinkMicRequest:(NSString *)userId;

- (void)cancelLinkMicRequest;

- (void)sendStopLinkMic;

- (void)startLinkMicWithUser:(NSString *)remoteUserId atView:(UIView *)view complete:(void (^) (BOOL success))complete;

- (void)stopLinkMic;

@end

NS_ASSUME_NONNULL_END
