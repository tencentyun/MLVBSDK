//
//  AppDelegate.m
//  TCLVBIMDemo
//
//  Created by kuenzhang on 16/7/29.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "AppDelegate.h"
#import "SDKHeader.h"
#import "TCMainTabViewController.h"
#import "TCLoginViewController.h"
#import "TCLog.h"
#import "TCConstants.h"
#import <Bugly/Bugly.h>
#import "TCUserAgreementController.h"
#import "TCUtil.h"

@interface AppDelegate ()
{
    uint64_t          _beginTime;
    uint64_t          _endTime;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    application.statusBarStyle = UIStatusBarStyleDefault;
    
    [self initCrashReport];
    // 请参考 https://cloud.tencent.com/document/product/454/34750 获取License
    [TXLiveBase setLicenceURL:@"<#Licence URL#>" key:@"<#License Key#>"];

    //初始化log模块
    [TXLiveBase sharedInstance].delegate = [TCLog shareInstance];
    
    UIColor *blueColor = [UIColor colorWithRed:51/255.0 green:139/255.0 blue:255/255.0 alpha:1.0];
    [[UINavigationBar appearance] setBarTintColor:blueColor];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.backgroundColor = [UIColor whiteColor];
   
    [self enterLoginUI];
    
    // ELK
    if (![[NSUserDefaults standardUserDefaults] boolForKey:isFirstInstallApp]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:isFirstInstallApp];
    }
    
    // Config UMSocial
    [TCUtil initializeShare];
    
    _beginTime = [[NSDate date] timeIntervalSince1970];
    
    if ([kHttpServerAddr length] == 0) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"未填写后台服务地址"
                                                                            message:@"需要搭建小直播后台，详情请点击“查看”"
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *viewAction = [UIAlertAction actionWithTitle:@"查看" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [application openURL:[NSURL URLWithString:@"https://cloud.tencent.com/document/product/454/15187"]];
        }];
        [controller addAction:viewAction];
        
        [self.window.rootViewController presentViewController:controller animated:YES completion:nil];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    _endTime = [[NSDate date] timeIntervalSince1970];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    _beginTime = [[NSDate date] timeIntervalSince1970];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)initCrashReport {

    //启动bugly组件，bugly组件为腾讯提供的用于crash上报和分析的开放组件，如果您不需要该组件，可以自行移除
    BuglyConfig * config = [[BuglyConfig alloc] init];
    config.version = [TXLiveBase getSDKVersionStr];
#if DEBUG
    config.debugMode = YES;
#endif
    
    config.channel = @"xiaozhibo";
    
    [Bugly startWithAppId:BUGLY_APP_ID config:config];
    
    NSLog(@"rtmp demo init crash report");
    
}

- (void)enterLoginUI {
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[TCLoginViewController alloc] init]];
    [self.window makeKeyAndVisible];
}

- (void)enterMainUI {
    if (YES == [[[NSUserDefaults standardUserDefaults] objectForKey:hasEnteredXiaoZhiBo] boolValue]) {
        [self confirmEnterMainUI];
    }else{
        [self enterUserAgreementUI];
    }
}

- (void)confirmEnterMainUI{
    self.window.rootViewController = [[TCMainTabViewController alloc] init];
    [self.window makeKeyAndVisible];
}

- (void)enterUserAgreementUI{
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[TCUserAgreementController alloc] init]];
}
/*
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        
    }
    return result;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        
    }
    return result;
}
*/

@end
