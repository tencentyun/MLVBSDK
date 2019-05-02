//
//  QCloudRequestSerializer.h
//  QCloudNetworking
//
//  Created by tencent on 15/9/23.
//  Copyright © 2015年 QCloudTernimalLab. All rights reserved.
//

#import <Foundation/Foundation.h>
@class QCloudRequestData;
NS_ASSUME_NONNULL_BEGIN
FOUNDATION_EXTERN NSString* QCloudStrigngURLEncode(NSString *string , NSStringEncoding stringEncoding);
FOUNDATION_EXTERN NSString*  QCloudURLEncodeParamters(NSDictionary* dic, BOOL willUrlEncoding, NSStringEncoding stringEncoding);
FOUNDATION_EXTERN NSString* QCloudURLEncodeUTF8(NSString* string);
FOUNDATION_EXTERN NSString* QCloudURLDecodeUTF8(NSString* string);
FOUNDATION_EXTERN NSString* QCloudNSURLEncode(NSString* url);
FOUNDATION_EXTERN NSDictionary* QCloudURLReadQuery(NSURL* url);
/**
  HTTP POST 方法
 */
extern NSString* const HTTPMethodPOST;
/**
   HTTP GET方法
 */
extern NSString* const HTTPMethodGET;


extern NSString* const HTTPHeaderHOST;


@class QCloudRequestData;

typedef NSMutableURLRequest* _Nullable  (^QCloudRequestSerializerBlock)(NSMutableURLRequest* request, QCloudRequestData* data, NSError* __autoreleasing*error);

/**
  进行Request参数拼装的类，此类可以配置HTTP相关的一些参数，也可以配置协议相关的一些参数
 */
@interface QCloudRequestSerializer : NSObject
@property (nonnull, nonatomic, strong) NSString* HTTPMethod;
@property (nonatomic, assign) BOOL useCookies;
@property (nonatomic, assign) NSURLRequestCachePolicy cachePolicy;
/**
   是否开启HTTPS验证，默认为YES
 */
@property (nonatomic, assign) BOOL shouldAuthentication;

/**
   是否处理cookies
 */
@property (nonatomic, assign) BOOL HTTPShouldHandleCookies;

/**
   是否开启pipeline功能
 */
@property (nonatomic, assign) BOOL HTTPShouldUsePipelining;

@property (nonatomic, assign) NSURLRequestNetworkServiceType networkServiceType;

@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/**
  设置根据requestData对请求的URL进行拼装的功能
 */
@property (nonatomic, strong, nullable) NSArray<QCloudRequestSerializerBlock>* serializerBlocks;

/**
  是否开启GZIP压缩Response
 */
@property (nonatomic, assign) BOOL allowCompressedResponse;

/**
   是否使用HTTPDNSPrefetch功能获取到IP
 */
@property (nonatomic, assign) BOOL HTTPDNSPrefetch;

- ( NSMutableURLRequest* _Nullable ) requestWithData:(QCloudRequestData*)data error:(NSError* __autoreleasing*)error;


@end


/**
   按照Get请求拼参的方式，将所有参数和URL拼接到URL中，并获得URLRequet
 */
extern _Nonnull QCloudRequestSerializerBlock QCloudURLAssembleWithParamters;
/**
   只拼接ServerURL和MethodURL部分，组成一个URL，并获得URLRequest
 */
extern _Nonnull QCloudRequestSerializerBlock QCloudURLFuseSimple;
/**
   在URL尾部按照?xx=xx&y=y的方式将所有参数拼接，并获得URLRequest, @note 使用该方法将不会对Value进行URLEncode
 */
extern _Nonnull QCloudRequestSerializerBlock QCloudURLFuseWithParamters;
/**
   在URL尾部按照?xx=xx&y=y的方式将所有参数拼接，并获得URLRequest, @note 使用该方法将会对Value进行URLEncode
 */
extern _Nonnull  QCloudRequestSerializerBlock QCloudURLFuseWithURLEncodeParamters;
/**
   将所有参数按照xx=x&y=sdf的格式拼接在包体中，并返回响应URLRequest
 */
extern _Nonnull QCloudRequestSerializerBlock QCloudURLSerilizerURLEncodingBody;
/**
   清除所有的头部参数
 */
extern _Nonnull QCloudRequestSerializerBlock QCloudURLCleanAllHeader;

/**
  将所有body参数按照JSON方式拼接到HTTPBody中，并设置content-type为application/json
 */
extern _Nonnull QCloudRequestSerializerBlock QCloudURLFuseWithJSONParamters;

extern _Nonnull QCloudRequestSerializerBlock QCloudFuseMultiFormData;

/**
  按照formdata方式将参数拼入到formdata中
 */
extern _Nonnull QCloudRequestSerializerBlock QCloudFuseParamtersASMultiData;

/**
 将一个KeyValueMap品入URL之中
 */
extern _Nonnull QCloudRequestSerializerBlock QCloudURLSerilizerAppendURLParamters(NSDictionary* keyValueMaps);

/**
 将requestData的URIMethod字段按照URL Paramters的形式拼装入url中
 */
extern _Nonnull QCloudRequestSerializerBlock QCloudURLFuseURIMethodASURLParamters;

extern _Nonnull QCloudRequestSerializerBlock QCloudURLFuseWithXMLParamters;

extern _Nonnull QCloudRequestSerializerBlock QCloudURLFuseContentMD5Base64StyleHeaders;
NS_ASSUME_NONNULL_END
