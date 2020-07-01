//
//  RNAsyncBenchMark.h
//  QCloudTernimalLab_CommonLogic
//
//  Created by tencent on 5/27/16.
//  Copyright © 2016 QCloudTernimalLab. All rights reserved.
//

#import <Foundation/Foundation.h>
extern NSString* const kRNBenchmarkRTT;
extern NSString* const kRNBenchmarkServerCost;
extern NSString* const kRNBenchmarkRequest;
extern NSString* const kRNBenchmarkResponse;
extern NSString* const kRNBenchmarkLogic;
extern NSString* const kRNBenchmarkLogicOnly;
extern NSString* const kRNBenchmarkOnlyNet;
extern NSString* const kRNBenchmarkBuildData;
extern NSString* const kRNBenchmarkBuildRequest;
extern NSString* const kRNBenchmarkSizeRequeqstHeader;
extern NSString* const kRNBenchmarkSizeRequeqstBody;
extern NSString* const kRNBenchmarkSizeResponseHeader;
extern NSString* const kRNBenchmarkSizeResponseBody;
extern NSString* const kRNBenchmarkUploadTime;
extern NSString* const kRNBenchmarkServerTime;
extern NSString* const kRNBenchmarkDownploadTime;
extern NSString* const kRNBenchmarkConnectionTime;
extern NSString* const kRNBenchmarkDNSLoopupTime;
extern NSString* const kRNBenchmarkSecureConnectionTime;

@interface RNAsyncBenchMark : NSObject
- (void) benginWithKey:(NSString*)key;
- (void) markFinishWithKey:(NSString*)key;
- (void) directSetCost:(double)cost forKey:(NSString*)key;

- (double) costTimeForKey:(NSString*)key;

- (NSString*) readablityDescription;
@end
