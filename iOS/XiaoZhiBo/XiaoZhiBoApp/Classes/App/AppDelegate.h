//
//  AppDelegate.h
//  TCLVBIMDemo
//
//  Created by kuenzhang on 16/7/29.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCBaseAppDelegate.h"

#define hasEnteredXiaoZhiBo @"_hasEnteredXiaoZhiBo_"
#define isFirstInstallApp     @"_isFirstInstallApp_"

@interface AppDelegate : TCBaseAppDelegate

- (void)enterMainUI;
- (void)enterLoginUI;
@end

