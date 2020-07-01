//
//  QCloudAbstractRequest.h
//  Pods
//
//  Created by Dong Zhao on 2017/3/10.
//
//

#import <Foundation/Foundation.h>
#import "QCloudHTTPRequestDelegate.h"
#import "RNAsyncBenchMark.h"

typedef double QCloudAbstractRequestPriority;

#define QCloudAbstractRequestPriorityHigh   2.0
#define QCloudAbstractRequestPriorityNormal 1.0
#define QCloudAbstractRequestPriorityLow    0.0

typedef void (^QCloudRequestSendProcessBlock)(int64_t bytesSent , int64_t totalBytesSent , int64_t totalBytesExpectedToSend);
typedef void (^QCloudRequestDownProcessBlock)(int64_t bytesDownload, int64_t totalBytesDownload, int64_t totalBytesExpectedToDownload);

/**
 请求的抽象基类，该类封装了用于进行request-response模式数据请求的通用属性和接口。包括发起请求，相应结果，优先级处理，性能监控能常见特性。
 */
@interface QCloudAbstractRequest : NSObject
{
    @protected
    int64_t _requestID;
}
@property (atomic, assign, readonly) BOOL canceled;
@property (nonatomic, assign, readonly) int64_t requestID;
@property (nonatomic, assign) QCloudAbstractRequestPriority priority;
@property (nonatomic, strong, readonly) RNAsyncBenchMark* benchMarkMan;
@property (atomic, assign, readonly) BOOL finished;



/**
  协议执行结果向外通知的委托（delegate）主要包括成功和失败两种情况。与Block方式并存，当两者都设置的时候都会通知。
 */
@property (nonatomic, weak) id<QCloudHTTPRequestDelegate> delegate;
/**
 协议执行结果向外通知的Block，与delegate方式并存，当两者都设置的时候都会通知。
 */
@property (nonatomic, strong) QCloudRequestFinishBlock finishBlock;


@property (nonatomic, strong) QCloudRequestSendProcessBlock sendProcessBlock;

@property (nonatomic, strong) QCloudRequestDownProcessBlock downProcessBlock;


- (void) setFinishBlock:(void(^)(id outputObject, NSError* error))QCloudRequestFinishBlock;


- (void) setDownProcessBlock:(void(^)(int64_t bytesDownload, int64_t totalBytesDownload, int64_t totalBytesExpectedToDownload))downloadProcessBlock;
- (void) setSendProcessBlock:(void (^)(int64_t bytesSent , int64_t totalBytesSent , int64_t totalBytesExpectedToSend))sendProcessBlock;
/**
   请求过程出错，进行处理。默认只处理HTTP协议层错误信息。并进行delegate的通知。
      @param error 请求过程出错信息，默认只处理HTTP层错误信息
 */
- (void) onError:(NSError*)error;

/**
   请求过程成功，并获取到了数据，进行处理。并进行delegate的通知。
      @param object  获取到的数据，经过responseserilizer处理的后的数据。
 */
- (void) onSuccess:(id)object;

- (void) notifySuccess:(id)object;
- (void) notifyError:(NSError*)error;
- (void) notifyDownloadProgressBytesDownload:(int64_t)bytesDownload
                          totalBytesDownload:(int64_t)totalBytesDownload
                totalBytesExpectedToDownload:(int64_t)totalBytesExpectedToDownload;

- (void) notifySendProgressBytesSend:(int64_t)bytesSend
                      totalBytesSend:(int64_t)totalBytesSend
            totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend;
- (void) cancel;

@end
