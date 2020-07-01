//
//  QCloudFileLogger.h
//  Pods
//
//  Created by Dong Zhao on 2017/3/15.
//
//

#import <Foundation/Foundation.h>
#import "QCloudLoggerOutput.h"
@class QCloudFileLogger;
@protocol QCloudFileLoggerDelegate  <NSObject>
- (void) fileLoggerDidFull:(QCloudFileLogger*)logger;
@end

@class QCloudLogModel;
@interface QCloudFileLogger : QCloudLoggerOutput
@property (nonatomic, weak) id<QCloudFileLoggerDelegate> delegate;
@property (nonatomic, strong, readonly) NSString* path;
@property (nonatomic, assign, readonly) uint64_t maxSize;
@property (nonatomic, assign, readonly) uint64_t currentSize;
@property (nonatomic, assign, readonly) BOOL isFull;
- (instancetype) initWithPath:(NSString *)path maxSize:(uint64_t)maxSize;
@end
