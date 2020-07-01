//
//  QCloudURLSessionTaskData.h
//  QCloudTernimalLab_CommonLogic
//
//  Created by tencent on 5/12/16.
//  Copyright © 2016 QCloudTernimalLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QCloudHTTPRetryHanlder;
@class QCloudHTTPRequest;

@interface QCloudURLSessionTaskData : NSObject
@property (nonatomic, assign) int identifier;
@property (nonatomic, strong) QCloudHTTPRetryHanlder* retryHandler;
@property (nonatomic, strong) QCloudHTTPRequest* httpRequest;
@property (nonatomic, assign, readonly) NSUInteger totalRecivedLength;
@property (nonatomic, strong, readonly) NSData* data;
@property (nonatomic, strong) NSHTTPURLResponse* response;
@property (nonatomic, strong, readonly) NSString* uploadTempFilePath;
@property (nonatomic, assign) BOOL forbidenWirteToFile;
- (instancetype) init;
- (instancetype) initWithDowndingFileHandler:(NSFileHandle*)fileHandler;
- (void) restData;
- (void) appendData:(NSData*)data;
- (void) closeWrite;
@end
