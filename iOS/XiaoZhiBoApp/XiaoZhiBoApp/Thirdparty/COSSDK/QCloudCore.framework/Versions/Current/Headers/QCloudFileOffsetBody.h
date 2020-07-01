//
//  QCloudFileOffsetBody.h
//  Pods
//
//  Created by Dong Zhao on 2017/5/23.
//
//

#import <Foundation/Foundation.h>

@interface QCloudFileOffsetBody : NSObject
@property (nonatomic, strong, readonly) NSURL* fileURL;
@property (nonatomic, assign, readonly) NSUInteger offset;
@property (nonatomic, assign, readonly) NSUInteger sliceLength;
@property (nonatomic, assign) NSUInteger index;
- (instancetype) initWithFile:(NSURL*)fileURL offset:(NSUInteger)offset slice:(NSUInteger)slice;
@end
