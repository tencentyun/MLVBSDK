//
//  UMSocialUIManager.h
//  UMSocialSDK
//
//  Created by umeng on 16/8/10.
//  Copyright © 2016年 dongjianxiong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UMSocialShareSelectionView.h"

@interface UMSocialUIManager (Private)

+ (void)showShareMenuViewInView:(UIView *)view sharePlatformSelectionBlock:(UMSocialSharePlatformSelectionBlock)sharePlatformSelectionBlock;


+ (void)showShareMenuViewInWindowWithPlatformSelectionBlock:(UMSocialSharePlatformSelectionBlock)sharePlatformSelectionBlock;


+ (void)dismissShareMenuView;

@end
