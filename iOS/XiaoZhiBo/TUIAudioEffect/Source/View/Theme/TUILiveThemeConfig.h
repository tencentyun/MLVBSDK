//
//  TUILiveThemeConfig.h
//  TUIAudioEffect
//
//  Created by jack on 2021/9/27.
//  音效视图UI样式配置

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUILiveThemeConfig : UIView

// 背景色，默认为白色
@property (nonatomic, strong) UIColor *backgroundColor;

// 主题色，Switch开关、选择状态的色值
@property(nonatomic, strong) UIColor *themeColor;
// 选中高亮色
@property(nonatomic, strong) UIColor *tintColor;
// 文本颜色
@property(nonatomic, strong) UIColor *textColor;
// 占位符颜色
@property(nonatomic, strong) UIColor *textPlaceholderColor;

// 标题字体
@property(nonatomic, strong) UIFont *titleFont;
// 默认字体
@property(nonatomic, strong) UIFont *normalFont;

+ (instancetype)defaultConfig;

@end

NS_ASSUME_NONNULL_END
