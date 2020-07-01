//
//  QCloudService.h
//  Pods
//
//  Created by Dong Zhao on 2017/3/13.
//
//

#import <Foundation/Foundation.h>
#import "QCloudServiceConfiguration.h"
#import "QCloudBizHTTPRequest.h"
@class QCloudSignature;
@class QCloudHTTPSessionManager;
NS_ASSUME_NONNULL_BEGIN

@class QCloudHTTPRequest;
@class QCloudSignatureFields;
@class UIApplication;
@interface QCloudService : NSObject
{
    @protected
    QCloudServiceConfiguration* _configuration;
}
/**
 改服务的配置信息，您可以通过在初始化接口中设置改参数来控制服务的行为。该属性为只读，只能在初始化中配置一次。后序的修改会无效。
 */
@property (nonatomic, strong, readonly) QCloudServiceConfiguration* configuration;

/**
 当前服务所运行的HTTP Session Manager。一般情况下，所有服务都运行在统一的全局单例上面。
 */
@property (nonatomic, strong,readonly) QCloudHTTPSessionManager* sessionManager;

/**
 通过服务配置信息初始化服务

 @param configuration 服务配置信息
 @return QCloudService实例
 */
- (instancetype) initWithConfiguration:(QCloudServiceConfiguration *)configuration;
//

/**
 执行一个HTTP的请求，您必须在外部将该请求构建好之后，才能调用该接口去执行请求。该接口不接受nil。

 @param httpRequst http请求
 @return 请求的序列号
 */
- (int) performRequest:(QCloudBizHTTPRequest*)httpRequst;

/**
 执行一个HTTP的请求，您必须在外部将该请求构建好之后，才能调用该接口去执行请求。该接口不接受nil。


 @param httpRequst http请求
 @param block 执行结果回调
 @return 请求的序列号
 */
- (int) performRequest:(QCloudBizHTTPRequest *)httpRequst withFinishBlock:(QCloudRequestFinishBlock)block;
#pragma mark ---权限相关函数
- (void) loadCOSXMLAuthorizationForBiz:(QCloudBizHTTPRequest *)request urlRequest:(NSURLRequest *)urlrequest compelete:(QCloudHTTPAuthentationContinueBlock)cotinueBlock;
- (void) loadCOSV4AuthorizationForBiz:(QCloudBizHTTPRequest *)request urlRequest:(NSURLRequest *)urlrequest compelete:(QCloudHTTPAuthentationContinueBlock)cotinueBlock;

- (void) loadAuthorizationForBiz:(QCloudBizHTTPRequest*)bizRequest urlRequest:(NSMutableURLRequest*)urlrequest compelete:(QCloudHTTPAuthentationContinueBlock)cotinueBlock;
//
- (BOOL) fillCommonParamtersForRequest:(QCloudBizHTTPRequest *)request error:(NSError* __autoreleasing*)error;

- (QCloudSignatureFields*) signatureFiledsForRequest:(QCloudBizHTTPRequest*)request;
+ (void)interceptApplication:(UIApplication *)application
handleEventsForBackgroundURLSession:(NSString *)identifier
           completionHandler:(void (^)(void))completionHandler;
@end
NS_ASSUME_NONNULL_END
