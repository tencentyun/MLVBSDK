//
//  AppDelegate.m
//  TRTCSimpleDemo-OC
//
//  Created by dangjiahe on 2021/4/10.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [TXLiveBase setLicenceURL:LICENSEURL key:LICENSEURLKEY];
    return YES;
}


@end
