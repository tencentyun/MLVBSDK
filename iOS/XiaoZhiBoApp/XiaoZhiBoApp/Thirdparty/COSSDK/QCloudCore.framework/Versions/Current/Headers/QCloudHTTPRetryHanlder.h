//
//  QCloudHTTPRetryHanlder.h
//  QCloudNetworking
//
//  Created by tencent on 16/2/24.
//  Copyright © 2016年 QCloudTernimalLab. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^QCloudHTTPRetryFunction)(void);


@interface QCloudHTTPRetryHanlder : NSObject
{
    @protected
    NSSet *_errorCode;
}
+ (QCloudHTTPRetryHanlder*) defaultRetryHandler;
@property (nonatomic, assign) NSInteger maxCount;
/**
   sleeptime = sleepStep * 1^2 ，
 */
@property (nonatomic, assign) NSTimeInterval sleepStep;
- (instancetype) initWithMaxCount:(NSInteger)maxCount sleepTime:(NSTimeInterval)sleepStep;

/**
   try to exe fuction if it can be retry
      @param function the function to exe when satify the args
   @param error    the error occur , it contains the args that will be used to judge retrying
      @return if it can be retry then return YES, otherwise return NO;
 */
- (BOOL) retryFunction:(QCloudHTTPRetryFunction)function whenError:(NSError*)error;

- (void) reset;
@end
