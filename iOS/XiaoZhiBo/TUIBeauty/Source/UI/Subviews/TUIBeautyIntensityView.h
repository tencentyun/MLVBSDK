//
//  TUIBeautyIntensityView.h
//  TUIBeauty
//
//  Created by gg on 2021/9/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIBeautyIntensityView : UIView

@property (nonatomic, copy) void (^onSliderValueChanged) (float value);

- (void)setSliderValue:(float)value;

- (void)setSliderMinValue:(float)minValue maxValue:(float)maxValue;

@end

NS_ASSUME_NONNULL_END
