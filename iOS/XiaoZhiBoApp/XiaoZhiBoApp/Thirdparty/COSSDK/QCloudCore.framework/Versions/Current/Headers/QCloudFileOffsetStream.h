//
//  QCloudFileOffsetStream.h
//  Pods
//
//  Created by Dong Zhao on 2017/5/22.
//
//

#import <Foundation/Foundation.h>

@interface QCloudFileOffsetStream : NSInputStream
@property (nonatomic, assign) NSUInteger offset;
@property (nonatomic, assign) NSUInteger sliceLength;
- (instancetype) initWithFileAtPath:(NSString *)path NS_UNAVAILABLE;
- (instancetype) initWithData:(NSData *)data NS_UNAVAILABLE;
- (instancetype) initWithURL:(NSURL *)url NS_UNAVAILABLE;

- (instancetype) initWithFileAtPath:(NSString *)path offset:(NSUInteger)offset slice:(NSUInteger)sliceLength;
@end
