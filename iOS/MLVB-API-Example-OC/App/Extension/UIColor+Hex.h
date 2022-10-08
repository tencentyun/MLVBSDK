//
//  UIColor+Hex.h
//  TRTCSimpleDemo-OC
//
//  Created by adams on 2021/4/14.
//  Copyright (c) 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Hex)

+ (UIColor *)hexColor:(NSString *)hexString;

+ (UIColor *)themeGreenColor;

+ (UIColor *)themeGrayColor;

+ (UIColor *)themeBlueColor;

- (UIImage *)trans2Image:(CGSize)imageSize;

@end

NS_ASSUME_NONNULL_END
