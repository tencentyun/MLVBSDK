//
//  TCBaseAppDelegate.m
//  TCLVBIMDemo
//
//  Created by annidyfeng on 16/7/29.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "TCBaseAppDelegate.h"
#import "TCNavigationController.h"

@implementation TCBaseAppDelegate

+ (instancetype)sharedAppDelegate
{
    return (TCBaseAppDelegate*)[UIApplication sharedApplication].delegate;
}

// 配置App中的控件的默认属性
- (void)configAppearance
{
    UIColor *blueColor = [UIColor colorWithRed:51/255.0 green:139/255.0 blue:255/255.0 alpha:1.0];
    [[UINavigationBar appearance] setBarTintColor:blueColor];
//    [[UINavigationBar appearance] setTintColor:kWhiteColor];
    
    
    [[UILabel appearance] setBackgroundColor:[UIColor clearColor]];
    [[UILabel appearance] setTextColor:[UIColor blackColor]];
    
    
    [[UIButton appearance] setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

// 获取当前活动的navigationcontroller
- (UINavigationController *)navigationViewController
{
    UIWindow *window = self.window;
    
    if ([window.rootViewController isKindOfClass:[UINavigationController class]])
    {
        return (UINavigationController *)window.rootViewController;
    }
    else if ([window.rootViewController isKindOfClass:[UITabBarController class]])
    {
        UIViewController *selectVc = [((UITabBarController *)window.rootViewController) selectedViewController];
        if ([selectVc isKindOfClass:[UINavigationController class]])
        {
            return (UINavigationController *)selectVc;
        }
    }
    return nil;
}

- (UIViewController *)topViewController
{
    UINavigationController *nav = [self navigationViewController];
    return nav.topViewController;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    @autoreleasepool
    {
        viewController.hidesBottomBarWhenPushed = YES;
        [[self navigationViewController] pushViewController:viewController animated:animated];
    }
}

- (UIViewController *)popViewController:(BOOL)animated
{
    return [[self navigationViewController] popViewControllerAnimated:animated];
}

- (NSArray *)popToRootViewController
{
    return [[self navigationViewController] popToRootViewControllerAnimated:NO];
}

- (NSArray *)popToViewController:(UIViewController *)viewController
{
    return [[self navigationViewController] popToViewController:viewController animated:NO];
}

- (void)presentViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)())completion
{
    UIViewController *top = [self topViewController];
    
    if (vc.navigationController == nil)
    {
        TCNavigationController *nav = [[TCNavigationController alloc] initWithRootViewController:vc];
        [top presentViewController:nav animated:animated completion:completion];
    }
    else
    {
        [top presentViewController:vc animated:animated completion:completion];
    }
}

- (void)dismissViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)())completion
{
    if (vc.navigationController != [TCBaseAppDelegate sharedAppDelegate].navigationViewController)
    {
        [vc dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [self popViewController:animated];
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self configAppearance];
    return YES;
}

@end
