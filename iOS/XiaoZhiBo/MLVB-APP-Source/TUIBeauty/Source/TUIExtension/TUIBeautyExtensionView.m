//
//  TUIBeautyExtensionView.m
//  TUIBeauty
//
//  Created by gg on 2021/9/28.
//

#import "TUIBeautyExtensionView.h"
#import "BeautyLocalized.h"

@implementation TUIBeautyExtensionView

+ (__kindof UIView *)getExtensionView {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"BeautyTouchIcon" inBundle:BeautyBundle() compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    return btn;
}

@end
