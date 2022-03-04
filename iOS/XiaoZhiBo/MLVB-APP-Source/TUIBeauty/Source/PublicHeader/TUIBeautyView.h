//
//  TUIBeautyView.h
//  TUIBeauty
//
//  Created by gg on 2021/9/22.
//

#import <UIKit/UIKit.h>
#import "TUIThemeConfig.h"

NS_ASSUME_NONNULL_BEGIN

@class TXBeautyManager;
@interface TUIBeautyView : UIView

@property (nonatomic, strong, null_resettable) TUIThemeConfig *theme;

/// 初始化时需要传入 BeautyManager 对象
/// @param beautyManager 通过 SDK 对象 -getBeautyManager 方法获取
- (instancetype)initWithFrame:(CGRect)frame beautyManager:(TXBeautyManager *)beautyManager;

/// 弹出美颜面板
- (void)show;

/// 关闭美颜面板
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
