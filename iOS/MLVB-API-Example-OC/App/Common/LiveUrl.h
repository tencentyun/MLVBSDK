//
//  LiveUrl.h
//  MLVB-API-Example-OC
//
//  Created by bluedang on 2021/6/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveUrl : NSObject

+ (NSString*)generateRtmpPushUrl:(NSString*)streamId;
+ (NSString*)generateRtmpPlayUrl:(NSString*)streamId;

+ (NSString*)generateTRTCPushUrl:(NSString*)streamId;
+ (NSString*)generateTRTCPlayUrl:(NSString*)streamId;
+ (NSString*)generateTRTCPushUrl:(NSString*)streamId userId:(NSString*)userId;
+ (NSString*)generateTRTCPlayUrl:(NSString*)streamId userId:(NSString*)userId;

+ (NSString*)generateLebPlayUrl:(NSString*)streamId;

@end

NS_ASSUME_NONNULL_END
