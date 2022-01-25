//
//  TUIPusherView.h
//  TUIPusher
//
//  Created by gg on 2021/9/7.
//

#import <UIKit/UIKit.h>
#import "TUIPusherViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    TUIPUSHER_VIDEO_RES_360 = 1, // 360p
    TUIPUSHER_VIDEO_RES_540,     // 540p
    TUIPUSHER_VIDEO_RES_720,     // 720p
    TUIPUSHER_VIDEO_RES_1080,    // 1080p
} TUIPusherVideoResolution;

@interface TUIPusherView : UIView

/// 设置代理对象，抛出的事件在 TUIPusherViewDelegate.h 中定义
- (void)setDelegate:(id <TUIPusherViewDelegate>)delegate;

/// 开始推流
/// @param url 需传入生成好的url
- (BOOL)start:(NSString *)url;

/// 停止推流
- (void)stop;

/// 加载挂件时可能会需要使用（TUIBarrage / TUIGift）
/// @param groupId 创建群组的 group id
- (void)setGroupId:(NSString *)groupId;

/// 发送 PK 请求
/// @param userID 对方的 user id
- (BOOL)sendPKRequest:(NSString *)userID;

/// 取消发送的 PK 请求
- (void)cancelPKRequest;

/// 结束 PK
- (void)stopPK;

/// 结束连麦
- (void)stopJoinAnchor;

/// 设置镜像
/// @param isMirror 是否镜像
- (void)setMirror:(BOOL)isMirror;

/// 切换摄像头
/// @param isFrontCamera 是否前置摄像头
- (void)switchCamera:(BOOL)isFrontCamera;

/// 设置分辨率
/// @param resolution TUIPusherVideoResolution 提供了四种主流的分辨率
- (void)setVideoResolution:(TUIPusherVideoResolution)resolution;

@end

NS_ASSUME_NONNULL_END
