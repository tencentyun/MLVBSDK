//
//  QCloudHTTPSessionManager.h
//  QCloudTernimalLab_CommonLogic
//
//  Created by tencent on 16/3/30.
//  Copyright © 2016年 QCloudTernimalLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QCloudNetworkingAPI.h"
@class QCloudThreadSafeMutableDictionary;
typedef void (^QCloudURLSessionDidFinishEventsForBackgroundURLSessionBlock)(void);


@interface QCloudHTTPSessionManager : NSObject <QCloudNetworkingAPI>
@property (nonatomic ,strong) NSURLSessionConfiguration* configuration;

@property (copy, nonatomic) QCloudURLSessionDidFinishEventsForBackgroundURLSessionBlock didFinishEventsForBackgroundURLSession ;
FOUNDATION_EXTERN QCloudThreadSafeMutableDictionary* cloudBackGroundSessionManagersCache;
+ (QCloudHTTPSessionManager*)sessionManagerWithBackgroundIdentifier:(NSString *)backgroundIdentifier;
+ (QCloudHTTPSessionManager*) shareClient;

@end
