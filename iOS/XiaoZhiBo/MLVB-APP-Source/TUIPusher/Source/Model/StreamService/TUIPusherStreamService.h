//
//  TRTCPusher.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by gg on 2021/9/7.
//

#import <Foundation/Foundation.h>
#import "TUIPusherKit.h"
#import "TUIPusherStreamServiceDelegate.h"

@import ImSDK_Plus;

NS_ASSUME_NONNULL_BEGIN

typedef void(^PusherActionCallback)(void);
typedef void(^ErrorCallback)(int code, NSString *des);

typedef enum : NSUInteger {
    VIDEO_RES_360 = 1,
    VIDEO_RES_540,
    VIDEO_RES_720,
    VIDEO_RES_1080,
} VideoResolution;

@class V2TXLivePusher;

@interface TUIPusherStreamService : NSObject

@property (nonatomic, readonly) V2TXLivePusher *pusher;

- (instancetype)initWithMode:(V2TXLiveMode)mode NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/// 设置TRTCCallingDelegate回调
/// @param delegate 回调实例
- (void)setDelegate:(id<TUIPusherStreamServiceDelegate>)delegate
NS_SWIFT_NAME(setDelegate(delegate:));

///开启远程用户视频渲染
- (void)startRemoteView:(NSString *)userId view:(UIView *)view
NS_SWIFT_NAME(startRemoteView(userId:view:));

///关闭远程用户视频渲染
- (void)stopRemoteView:(NSString *)userId
NS_SWIFT_NAME(stopRemoteView(userId:));

///打开摄像头
- (BOOL)openCamera:(BOOL)frontCamera view:(UIView *)view
NS_SWIFT_NAME(openCamera(frontCamera:view:));

/// 打开本地摄像头。
/// @note startVirtualCamera，startCamera，startScreenCapture，同一 Pusher 实例下，仅有一个能上行，三者为覆盖关系。例如先调用 startCamera，后调用 startVirtualCamera。此时表现为暂停摄像头推流，开启图片推流
/// @param frontCamera 是否为前置摄像头
///         - YES 【默认值】: 切换到前置摄像头
///         - NO: 切换到后置摄像头
- (void)startCamera:(BOOL)frontCamera NS_SWIFT_NAME(startCamera(frontCamera:));

/// 关闭摄像头
- (void)closeCamara NS_SWIFT_NAME(closeCamara());

/// 开启图片推流。
/// @note startVirtualCamera，startCamera，startScreenCapture，同一 Pusher 实例下，仅有一个能上行，三者为覆盖关系。例如先调用 startCamera，后调用 startVirtualCamera。此时表现为暂停摄像头推流，开启图片推流
/// @param image UIImage图片
- (void)startVirtualCamera:(TXImage *)image NS_SWIFT_NAME(startVirtualCamera(image:));

/// 关闭图片推流
- (void)stopVirtualCamera NS_SWIFT_NAME(stopVirtualCamera());

/// 开始推流
- (BOOL)startPush:(NSString *)url
NS_SWIFT_NAME(startPush(url:));

/// 停止推流
- (void)stopPush NS_SWIFT_NAME(stopPush());

- (BOOL)startPK:(NSString *)streamId view:(UIView *)pkView;

- (void)stopPK;

///切换摄像头
- (void)switchCamera:(BOOL)frontCamera NS_SWIFT_NAME(switchCamera(isFront:));

///静音操作
- (void)setMicMute:(BOOL)isMute NS_SWIFT_NAME(setMicMute(isMute:));

///免提操作
- (void)setHandsFree:(BOOL)isHandsFree NS_SWIFT_NAME(setHandsFree(isHandsFree:));

// 设置选项
- (void)setMirror:(BOOL)isMirror;

- (void)setVideoResolution:(VideoResolution)resolution;

- (BOOL)startLinkMic:(NSString *)streamId view:(UIView *)view;

- (void)stopLinkMic;
@end



NS_ASSUME_NONNULL_END
