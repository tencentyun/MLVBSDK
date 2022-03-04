//
//  TUIPusherView+Private.h
//  Pods
//
//  Created by gg on 2021/9/9.
//
#import "TUIPusherView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIPusherView (Private)

/// 如果需要自定义开始按钮，请调用此接口实现
/// @param startBtn 创建的自定义按钮
- (void)resetStartButton:(__kindof UIView *)startBtn;

/** 请自行实现原有的接口
 - (void)start;
 @property (nonatomic, readonly) BOOL isInCountdown;
 @property (nonatomic,  copy ) void (^willDismiss) (void);
 */
/// 如果需要自定义倒计时界面，请调用此接口实现
/// @param countdownView 创建的自定义页面
- (void)resetCountdownView:(__kindof UIView *)countdownView;

@end

NS_ASSUME_NONNULL_END
