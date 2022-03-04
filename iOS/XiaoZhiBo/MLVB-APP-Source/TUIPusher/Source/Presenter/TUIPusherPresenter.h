//
//  TUIPusherPresenter.h
//  Alamofire
//
//  Created by gg on 2021/9/13.
//

#import <Foundation/Foundation.h>
#import "TUIPusherStreamService.h"
#import "TUIPusherSignalingService.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TUIPusherViewDelegate;
@class TUIPusherView;

@protocol TUIPusherPresenterDelegate <NSObject>

- (void)onStreamServiceError:(V2TXLiveCode)code msg:(NSString *)msg;

- (void)onSignalingError:(NSString *)cmd code:(int)code message:(NSString *)msg;

- (void)onReceivePKInvite:(NSString *)inviter cmd:(NSString *)cmd streamId:(NSString *)streamId;
- (void)onAcceptPKInvite:(NSString *)cmd streamId:(NSString *)streamId;
- (void)onRejectPKInvite:(NSString *)cmd reason:(int)reason;
- (void)onCancelPK:(NSString *)cmd;
- (void)onStopPK:(NSString *)cmd;
- (void)onTimeoutPK;

- (void)onReceiveLinkMicInvite:(NSString *)inviter cmd:(NSString *)cmd streamId:(NSString *)streamId;
- (void)onStartLinkMic:(NSString *)cmd streamId:(NSString *)streamId;
- (void)onCancelLinkMic:(NSString *)cmd;
- (void)onStopLinkMic:(NSString *)cmd;
- (void)onTimeoutLinkMic;
@end

@interface TUIPusherPresenter : NSObject

@property (nonatomic, copy, null_resettable) NSString *pushUrl;
@property (nonatomic, weak) id <TUIPusherPresenterDelegate> delegate;
@property (nonatomic, weak) id <TUIPusherViewDelegate> pusherViewDelegate;
@property (nonatomic, weak) TUIPusherView *pusherView;
@property (nonatomic, copy) NSString *remoteStreamId;

@property (nonatomic, assign) BOOL isFrontCamera;
@property (nonatomic, assign) BOOL isMirror;

@property (nonatomic, readonly) NSString *currentUserId;

@property (nonatomic, readonly, nullable) V2TXLivePusher *pusher;

@property (nonatomic, readonly) BOOL isInPK;
@property (nonatomic, readonly) BOOL isInLinkMic;

- (instancetype)initWithPusherView:(TUIPusherView *)pusherView;

- (BOOL)checkPushUrl:(NSString *)url;

- (BOOL)checkLoginStatus;

- (BOOL)start:(NSString *)url view:(UIView *)view;

- (void)stop;

- (BOOL)startPush:(NSString *)url;

- (void)stopPush;

/// 打开本地摄像头。
/// @note startVirtualCamera，startCamera，startScreenCapture，同一 Pusher 实例下，仅有一个能上行，三者为覆盖关系。例如先调用 startCamera，后调用 startVirtualCamera。此时表现为暂停摄像头推流，开启图片推流
/// @param frontCamera 是否为前置摄像头
///         - YES 【默认值】: 切换到前置摄像头
///         - NO: 切换到后置摄像头
- (void)startCamera:(BOOL)frontCamera;

/// 关闭摄像头
- (void)closeCamera;

/// 开启图片推流。
/// @note startVirtualCamera，startCamera，startScreenCapture，同一 Pusher 实例下，仅有一个能上行，三者为覆盖关系。例如先调用 startCamera，后调用 startVirtualCamera。此时表现为暂停摄像头推流，开启图片推流
/// @param image UIImage图片
- (void)startVirtualCamera:(UIImage *)image;

/// 关闭图片推流
- (void)stopVirtualCamera;

- (void)switchCamera:(BOOL)isFrontCamera;

- (void)setMirror:(BOOL)isMirror;

- (void)setVideoResolution:(VideoResolution)resolution;

- (BOOL)sendPKRequest:(NSString *)userID;
- (void)cancelPKRequest;
- (void)acceptPK;
- (void)rejectPK;
- (BOOL)startPKWithUser:(NSString *)remoteUserId atView:(UIView *)view;
- (void)sendStopPK;
- (void)stopPK;

- (void)acceptLinkMic;
- (void)rejectLinkMic;
- (BOOL)startLinkMicWithUser:(NSString *)remoteUserId atView:(UIView *)view;
- (void)sendStopLinkMic;
- (void)stopLinkMic;
@end

NS_ASSUME_NONNULL_END
