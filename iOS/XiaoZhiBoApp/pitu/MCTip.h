//
//  MCTip.h
//  PituMotionDemo
//
//  Created by ricocheng on 6/24/16.
//  Copyright © 2016 Pitu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    MCTipsContent,
    MCTipsNoFace,
    MCTipsSwipUpDown,
} MCTipsType;

@interface MCTip : NSObject

+ (void)showText:(NSString *)text withFaceIcon:(BOOL)withFaceIcon inView:(UIView *)parentView;
+ (void)hideText;
+ (void)showText:(NSString *)text inView:(UIView *)parentView afterDelay:(NSTimeInterval)delay;
+ (void)showText:(NSString *)text
          inView:(UIView *)parentView
         atPoint:(CGPoint)point
        withType:(MCTipsType)type
          showBG:(BOOL)showBG
      afterDelay:(NSTimeInterval)delay;
+ (void)showLoadingText:(NSString *)text inView:(UIView *)parentView;
+ (void)stopLoadingText;

@end
