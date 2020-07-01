//
//  QCloudGetPresignedURLRequest.h
//  QCloudCOSXML
//
//  Created by erichmzhang(张恒铭) on 17/01/2018.
//

#import <Foundation/Foundation.h>
#import <QCloudCore/QCloudCore.h>
#import "QCloudGetPresignedURLResult.h"

NS_ASSUME_NONNULL_BEGIN
@interface QCloudGetPresignedURLRequest :QCloudBizHTTPRequest

/**
 填入使用预签名请求的Bucket
 */
@property (nonatomic, copy) NSString* bucket;

/**
 填入对应的Object
 */
@property (nonatomic, copy) NSString* object;

/**
 填入使用预签名URL的请求的HTTP方法。有效值(大小写敏感)为:@"GET",@"PUT",@"POST",@"DELETE"
 */
@property (nonatomic, copy) NSString* HTTPMethod;

/**
 如果使用预签名URL的请求有该头部，那么通过这里设置
 */
@property (nonatomic, readonly) NSString* contentType;

/**
 如果使用预签名URL的请求有该头部，那么通过这里设置
 */
@property (nonatomic, readonly) NSString* contentMD5;
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *requestHeaders;
@property (nonatomic, readonly) NSDictionary<NSString *, NSString *> *requestParameters;

/**
 添加使用预签名请求的头部

 @param value HTTP header的值
 @param requestHeader HTTP header的key
 */
- (void)setValue:(NSString * _Nullable)value forRequestHeader:(NSString *_Nullable)requestHeader;

/**
 添加使用预签名请求的URL参数

 @param value 参数的值
 @param requestParameter 参数的key
 */
- (void)setValue:(NSString * _Nullable)value forRequestParameter:(NSString *_Nullable)requestParameter;

/**
 设置完成回调。请求完成后会通过该回调来获取结果，如果没有error，那么可以认为请求成功。

 @param finishBlock 请求完成回调
 */
- (void) setFinishBlock:(void(^)(QCloudGetPresignedURLResult* result, NSError* error))finishBlock;
@end


NS_ASSUME_NONNULL_END
