//
//  QCloudHTTPRequestDelegate.h
//  QCloudNetworking
//
//  Created by tencent on 15/9/30.
//  Copyright © 2015年 QCloudTernimalLab. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^QCloudRequestFinishBlock)(id outputObject, NSError* error);

@class QCloudAbstractRequest;
@protocol QCloudHTTPRequestDelegate <NSObject>
@optional
- (void) QCloudHTTPRequestDidFinished:(QCloudAbstractRequest*)request succeedWithObject:(id)object;
- (void) QCloudHTTPRequestDidFinished:(QCloudAbstractRequest *)request failed:(NSError*)object;
- (void)QCloudHTTPRequest:(QCloudAbstractRequest *)request
                sendBytes:(int64_t)bytesSent
           totalBytesSent:(int64_t)totalBytesSent
 totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend;
- (void)   QCloudHTTPRequest:(QCloudAbstractRequest *)request
               bytesDownload:(int64_t)bytesDownload
          totalBytesDownload:(int64_t)totalBytesDownload
totalBytesExpectedToDownload:(int64_t)totalBytesExpectedToDownload;
@end
