//
//  QCloudNetEnv.h
//  QCloudTernimalLab_CommonLogic
//
//  Created by tencent on 16/3/24.
//  Copyright © 2016年 QCloudTernimalLab. All rights reserved.
//

#import <Foundation/Foundation.h>

#define QCloudNetworkShareEnv [QCloudNetEnv shareEnv]

typedef NS_ENUM(NSInteger, QCloudNetworkStatus) {
    QCloudNotReachable = 0,
    QCloudReachableViaWiFi = 2,
    QCloudReachableViaWWAN = 1,
};

#define kNetworkSituationChangeKey @"kNetworkSituationChangeKey"
/**
 表明当前网络的情况，是弱网络或者网络情况良好

 - QCloudNetworkSituationWeakNetwork: 当前是弱网络，延迟和丢包率较高
 - QCloudNetworkSituationGreatNetork: 当前网络较好，可以适当增加并发数
 */
typedef NS_ENUM(NSInteger, QCloudNetworkSituation) {
    QCloudNetworkSituationWeakNetwork = 0,
    QCloudNetworkSituationGreatNetork = 1
};


extern NSString* const kQCloudNetEnvChangedNotification;

@interface QCloudNetEnv : NSObject
+ (instancetype) shareEnv;
@property (nonatomic, assign, readonly) QCloudNetworkStatus currentNetStatus;
- (BOOL) isReachableViaWifi;
- (BOOL) isReachableVia2g3g4g;
- (BOOL) isReachable;
@end
