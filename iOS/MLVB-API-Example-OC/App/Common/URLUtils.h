//
//  LiveUrl.h
//  MLVB-API-Example-OC
//
//  Created by bluedang on 2021/6/28.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface URLUtils : NSObject

+ (NSString*)generateRtmpPushUrl:(NSString*)streamId;
+ (NSString*)generateRtmpPlayUrl:(NSString*)streamId;

+ (NSString*)generateFlvPlayUrl:(NSString*)streamId;
+ (NSString*)generateHlsPlayUrl:(NSString*)streamId;

+ (NSString*)generateTRTCPushUrl:(NSString*)streamId;
+ (NSString*)generateTRTCPlayUrl:(NSString*)streamId;
+ (NSString*)generateTRTCPushUrl:(NSString*)streamId userId:(NSString*)userId;
+ (NSString*)generateTRTCPlayUrl:(NSString*)streamId userId:(NSString*)userId;

+ (NSString*)generateLebPlayUrl:(NSString*)streamId;

@end

NS_ASSUME_NONNULL_END
