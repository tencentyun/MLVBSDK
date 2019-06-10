/**
 * Module: AppDelegate
 *
 * Function: App入口 & 初始化
 */

#import "AppDelegate.h"
#import "TXLivePlayer.h"
#import "TCMainTabViewController.h"
#import "TCLoginViewController.h"
#import "TCLog.h"
#import "TCGlobalConfig.h"
#import <Bugly/Bugly.h>
#import "TCUserAgreementController.h"
#import "TCUtil.h"

@interface AppDelegate () <UISplitViewControllerDelegate>
{
    // 统计App使用时长
    uint64_t          _beginTime;
    uint64_t          _endTime;
}
@end

@implementation AppDelegate

+ (instancetype)sharedInstance {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 设置默认属性
    application.statusBarStyle = UIStatusBarStyleDefault;
    
    UIColor *blueColor = [UIColor colorWithRed:51/255.0 green:139/255.0 blue:255/255.0 alpha:1.0];
    [[UINavigationBar appearance] setBarTintColor:blueColor];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    
    // 初始化crash上报
    [self initCrashReport];
    
    // 请参考 https://cloud.tencent.com/document/product/454/34750 获取License

    [TXLiveBase setLicenceURL:@"<#Licence URL#>" key:@"<#License Key#>"];
    
    //初始化log模块
    [TXLiveBase sharedInstance].delegate = [TCLog shareInstance];
    
    

    // 进入登录界面
    [self enterLoginUI];
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
    
    NSLog(@"xiaozhibo init crash report");
}

- (void)enterLoginUI {
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[TCLoginViewController alloc] init]];
    [self.window makeKeyAndVisible];
}

- (void)enterMainUI {
    if (YES == [[[NSUserDefaults standardUserDefaults] objectForKey:hasEnteredXiaoZhiBo] boolValue]) {
        [self confirmEnterMainUI];
    } else {
        [self enterUserAgreementUI];
    }
}

- (void)confirmEnterMainUI {
    self.window.rootViewController = [[TCMainTabViewController alloc] init];
    [self.window makeKeyAndVisible];
}

- (void)enterUserAgreementUI {
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[TCUserAgreementController alloc] init]];
}

#pragma mark - utils

// 获取当前活动的NavigationController
- (UINavigationController *)navigationViewController {
    UIWindow *window = self.window;
    if ([window.rootViewController isKindOfClass:[UINavigationController class]]) {
        return (UINavigationController *)window.rootViewController;
    } else if ([window.rootViewController isKindOfClass:[UITabBarController class]]) {
        UIViewController *selectVc = [((UITabBarController *)window.rootViewController) selectedViewController];
        if ([selectVc isKindOfClass:[UINavigationController class]]) {
            return (UINavigationController *)selectVc;
        }
    }
    return nil;
}

- (UIViewController *)topViewController {
    UINavigationController *nav = [self navigationViewController];
    return nav.topViewController;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    viewController.hidesBottomBarWhenPushed = YES;
    [[self navigationViewController] pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewController:(BOOL)animated {
    return [[self navigationViewController] popViewControllerAnimated:animated];
}

- (void)presentViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)(void))completion {
    UIViewController *top = [self topViewController];
    if (vc.navigationController == nil) {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [top presentViewController:nav animated:animated completion:completion];
    } else {
        [top presentViewController:vc animated:animated completion:completion];
    }
}

- (void)dismissViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)(void))completion {
    if (vc.navigationController != [[AppDelegate sharedInstance] navigationViewController]) {
        [vc dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self popViewController:animated];
    }
}

@end
