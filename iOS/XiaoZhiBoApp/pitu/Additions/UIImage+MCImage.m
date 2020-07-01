//
//  UIImage+MCImage.m
//  PituCameraSDK
//
//  Created by billwang on 16/7/4.
//  Copyright © 2016年 Pitu. All rights reserved.
//

#import "UIImage+MCImage.h"

@implementation UIImage (MotionCamera)

+ (UIImage *)MCImageNamed:(NSString *)imgName {
    NSString *imgExt = [imgName pathExtension];
    if (imgExt.length <= 0) {
        imgExt = @"png";
    }
    
    imgName = [imgName stringByDeletingPathExtension];
    NSRange bundleRange = [imgName rangeOfString:@"/"];
    if (bundleRange.length <= 0) {
        imgName = [NSString stringWithFormat:@"Resource/bundle/%@", imgName];
    }
    NSString *imgPath = [[NSBundle mainBundle] pathForResource:imgName ofType:imgExt];
    if (!imgPath) {
        NSRange atRange = [imgName rangeOfString:@"@"];
        if (atRange.length > 0) {
            imgName = [imgName substringToIndex:atRange.location];
        }
        
        NSInteger screenScale = (int)[UIScreen mainScreen].scale;
        for (NSInteger imgScale = screenScale; imgScale > 1; --imgScale) {
            imgPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@@%dx", imgName, (int)imgScale] ofType:imgExt];
            if (imgPath) {
                break;
            }
        }
        if (!imgPath) {
            imgPath = [[NSBundle mainBundle] pathForResource:imgName ofType:imgExt];
        }
    }
    
    UIImage *img = [self imageWithContentsOfFile:imgPath];
    
    return img;
}

@end
