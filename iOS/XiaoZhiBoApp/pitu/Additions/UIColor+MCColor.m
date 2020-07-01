//
//  UIColor+Color.m
//  PituMotionDemo
//
//  Created by ricocheng on 6/21/16.
//  Copyright © 2016 Pitu. All rights reserved.
//

#import "UIColor+MCColor.h"

@implementation UIColor (MotionCamera)

+ (UIColor *)MCNormal {
    return [UIColor colorWithRed:0x36/255.f green:0x39/255.f blue:0x4c/255.f alpha:1.f];
}
+ (UIColor *)MCSelected {
    return [UIColor colorWithRed:0x2d/255.f green:0x8b/255.f blue:0xe6/255.f alpha:1.f];
}
+ (UIColor *)MCLine {
    return [UIColor colorWithRed:0xf6/255.f green:0xf6/255.f blue:0xf6/255.f alpha:1.f];
}
+ (UIColor *)MCWhite {
    return [UIColor colorWithRed:0xf3/255.f green:0xf3/255.f blue:0xf3/255.f alpha:1.f];
}
@end
