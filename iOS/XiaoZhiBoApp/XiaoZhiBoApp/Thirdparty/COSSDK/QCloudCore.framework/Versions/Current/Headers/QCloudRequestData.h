//
//  QCloudRequestData.h
//  QCloudNetworking
//
//  Created by tencent on 15/9/24.
//  Copyright © 2015年 QCloudTernimalLab. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "QCloudHTTPMultiDataStream.h"

NS_ASSUME_NONNULL_BEGIN
extern NSString* const HTTPHeaderUserAgent;



/**
   网络请求参数的容器类
 */

@interface QCloudRequestData<BodyType> : NSObject



@property (nonatomic, strong , readonly) NSDictionary* queryParamters;

/**
 数据的编码格式
 */
@property (nonatomic, assign) NSStringEncoding stringEncoding;
/**
   服务器地址
 */
@property (strong, nonatomic) NSString* serverURL;


/**
 * 统一资源标识符，用来标识调用的具体的资源地址
 */
@property (nonatomic, strong) NSString* URIMethod;

/**
 如果URIMethod不足以表示所有的命令字的时候，可以在改字段中按照顺序添加URI分片，将会按照顺序组装起来。
 */
@property (nonatomic, strong) NSArray* URIComponents;
/**
   HTTP headers参数，用来配置Request
 */
@property (nonatomic, strong, nonnull , readonly) NSDictionary* httpHeaders;

/**
   所有的参数，填充在这里面的参数为不需要添加在HTTPHeaders里面的参数
 */
@property (nonnull, strong, nonatomic, readonly) NSDictionary* allParamters;


/**
   使用multipart/form-data上传数据时所需要的数据流，默认为空，只有当添加了form data后该字段才有值
 */
@property (nonatomic, strong, readonly, nullable) QCloudHTTPMultiDataStream* multiDataStream;


@property (nonnull, strong) NSString* boundary;
/**
   请求中要使用到的Cookies
 */
@property (nonatomic, strong, nonnull, readonly) NSArray* cookies;


@property (nonnull, strong) BodyType directBody;


/**
 清除所有参数
 */
- (void)clean;

/**
   添加类型为NSString的参数
      @param paramter 添加的参数
   @param key      关键字
 */
- (void) setParameter:(nonnull id)paramter withKey:(nonnull NSString*)key;

/**
   添加类型为NSNumber的请求参数
      @param paramter 添加的参数
   @param key      参数对应的关键字
 */
- (void) setNumberParamter:(nonnull NSNumber*)paramter
                   withKey:(nonnull NSString*)key;


- (void)setQueryStringParamter:(nonnull NSString *)paramter
                       withKey:(nonnull NSString*)key;
/**
   通过指定的Key获取
      @param key 参数的Key
      @return 获取到的参数值
 */


- (id) paramterForKey:(NSString*)key;
/**
   添加HTTP header中的信息
   其中User-Agent等有默认信息
      @param value 要添加的信息
   @param field 对应的关键字
 */
- (void) setValue:(nonnull id)value forHTTPHeaderField:(nonnull NSString *)field;

/**
   通过URL Paramater字符串的方式来添加参数
      @param paramters 参数字符串，按照xx=xx&xx=xx的形式
 */
- (void) setParamatersWithString:(nonnull NSString*)paramters;

/**
   通过字典的形式添加参数
      @param paramters 参数字典容器
 */
- (void) setParametersInDictionary:(nonnull NSDictionary*)paramters;

/**
   删除指定Key的Header
      @param key 要删除的Header
 */
- (void) removeHTTPHeaderForKey:(NSString*)key;
/**
   手动添加Cookie
      @param domain 域
   @param path   路径
   @param name   名称
   @param value  值
 */
- (void) addCookieWithDomain:(nonnull NSString*)domain
                  path:(nonnull NSString*)path
                  name:(nonnull NSString*)name
                 value:(nonnull id)value;



/**
 通过KeyValue形式添加FormData的参数

 @param key key
 @param value value
 @return 是否添加成功
 */
- (BOOL) appendFormDataKey:(NSString*)key
                     value:(NSString*)value;

/**
 添加文件内容部分

 @param fileURL URL
 @param name 文件名
 @param fileName 文件名
 @param mimeType mimeType
 @param paramerts 头部参数
 @param error error
 @return 成功与否
 */
- (BOOL)appendPartWithFileURL:(nonnull NSURL *)fileURL
                         name:(nonnull NSString *)name
                     fileName:(nonnull NSString *)fileName
                     mimeType:(nonnull NSString *)mimeType
              headerParamters:(nullable NSDictionary*)paramerts
                        error:(  NSError * _Nullable   __autoreleasing   *)error;

/**
 添加分片文件内容部分

 @param fileURL url
 @param name name
 @param fileName fileName
 @param offset offset
 @param sliceLength sliceLength
 @param mimeType mimeType
 @param paramerts parameters
 @param error error
 @return 成功与否
 */
- (BOOL)appendPartWithFileURL:(nonnull NSURL *)fileURL
                         name:(nonnull NSString *)name
                     fileName:(nonnull NSString *)fileName
                       offset:(int64_t)offset
                  sliceLength:(int)sliceLength
                     mimeType:(nonnull NSString *)mimeType
              headerParamters:(nullable NSDictionary*)paramerts
                        error:(  NSError * _Nullable   __autoreleasing   *)error;

@end
NS_ASSUME_NONNULL_END
