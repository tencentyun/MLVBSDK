//
//  AppDelegate.m
//  TXLiteAVDemo_Professional
//
//  Created by coddyliu on 2021/1/6.
//

#import "AppDelegate.h"
#import "TXLiveBase.h"
#import "V2SimpleMainViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [TXLiveBase setLicenceURL:@"" key:@""];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[V2SimpleMainViewController alloc] init];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
