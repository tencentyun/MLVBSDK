//
//  UIViewController+AlertViewController.h
//  MLVB-API-Example-OC
//
//  Created by adams on 2021/4/15.
//  Copyright (c) 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (AlertViewController)
- (void)showAlertViewController:(nullable NSString *)title message:(nullable NSString *)message
 handler:(void (^ __nullable)(UIAlertAction *action))handler;

- (void)requestPhotoAuthorization:(void(^)(void))handler;

@end

NS_ASSUME_NONNULL_END
