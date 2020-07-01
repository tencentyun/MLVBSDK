//
//  QCloudHTTPBodyPart.h
//  QCloudNetworking
//
//  Created by tencent on 16/2/18.
//  Copyright © 2016年 QCloudTernimalLab. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface QCloudHTTPBodyPart : NSObject

@property (nonatomic, assign) NSStringEncoding stringEncoding;
@property (nonatomic, copy) NSString* boundary;
@property (nonatomic, assign) BOOL hasInitialBoundary;
@property (nonatomic, assign) BOOL hasFinalBoundary;

@property (nonatomic, assign, readonly) BOOL hasBytesAvailable;
@property (nonatomic, assign, readonly) unsigned long long contentLength;
@property (nonatomic, readonly, strong) NSError* streamError;
+ (instancetype) new UNAVAILABLE_ATTRIBUTE;
- (instancetype) init UNAVAILABLE_ATTRIBUTE;

- (instancetype) initWithData:(NSData*)data;
- (instancetype) initWithURL:(NSURL*)url withContentLength:(unsigned long long)length;
- (instancetype) initWithURL:(NSURL *)url offetSet:(uint64_t)offset withContentLength:(unsigned long long)length;

- (void) setHeaderValueWithMap:(NSDictionary*)dictionary;
- (void) setValue:(id)value forHeaderKey:(NSString *)key;

- (NSInteger)read:(uint8_t *)buffer
        maxLength:(NSUInteger)length;
@end
