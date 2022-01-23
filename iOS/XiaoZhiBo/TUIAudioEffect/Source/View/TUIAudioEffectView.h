//
//  TUIAudioEffect.h
//  TUIAudioEffect
//
//  Created by jack on 2021/9/27.
//

#import <UIKit/UIKit.h>

@class TXAudioEffectManager;
@class TUILiveThemeConfig;

NS_ASSUME_NONNULL_BEGIN

@interface TUIAudioEffectView : UIView

/// 主题样式
@property(nonatomic, strong, null_resettable)TUILiveThemeConfig *theme;

/// TUIAudioEffectView构造器
/// @param frame 视图布局尺寸，推荐设备全尺寸。
/// @param audioEffectManager TXAudioEffectManager 的接口包装
- (instancetype)initWithFrame:(CGRect)frame audioEffectManager:(TXAudioEffectManager *)audioEffectManager;

/// 展示音效控制视图，此方法调用前需确保已添加到父视图
- (void)show;

/// 音效控制视图消失
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
