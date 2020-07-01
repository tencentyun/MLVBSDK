//
//  QCloudHTTPSessionManager_Private.h
//  Pods
//
//  Created by Dong Zhao on 2017/3/10.
//
//

#import "QCLOUDRestNet.h"
@class QCloudURLSessionTaskData;
@interface QCloudHTTPSessionManager ()
@property (nonatomic, strong, readonly) NSURLSession* session;
- (void) cacheTask:(NSURLSessionTask*)task data:(QCloudURLSessionTaskData*)data forSEQ:(int)seq;
@end
