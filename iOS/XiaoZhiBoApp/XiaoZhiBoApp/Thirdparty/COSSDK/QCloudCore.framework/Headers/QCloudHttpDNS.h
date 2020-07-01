//
//  QCloudHttpDNS.h
//  TestHttps
//
//  Created by tencent on 16/2/17.
//  Copyright © 2016年 dzpqzb. All rights reserved.
//

#import <Foundation/Foundation.h>



extern NSString* const kQCloudHttpDNSCacheReady;
extern NSString* const kQCloudHttpDNSHost;


@class QCloudHosts;

@protocol QCloudHTTPDNSProtocol <NSObject>
@required

/**
 解析domain，返回对应的ip地址。注意ip地址需要是有效的形式(xxx.xxx.xxx.xxx)否则会导致出错

 @param domain 需要解析的域名
 @return ip地址
 */
- (NSString *)resolveDomain:(NSString *)domain;
@end

@interface QCloudHttpDNS : NSObject
@property (nonatomic, strong, readonly) QCloudHosts* hosts;

/**
 实现自定义解析ip的代理，当在记录里查询不到对应的host时，会向代理去再次请求解析。
 */
@property (nonatomic, weak) id<QCloudHTTPDNSProtocol> delegate;
+ (instancetype) shareDNS;
/**
   对于跟定的域名进行DNS缓存操作
      @param domain 需要缓存IP的域名
   @param error  如果过程出错，该字段表示错误信息
      @return 是否解析DNS成功
 */
- (BOOL) resolveDomain:(NSString*)domain error:(NSError**)error;

/**
   对于URLRequest进行IP重定向，如果改URLRequest原始指向的URL中的host对应的IP已经被解析了，则进行重定向操作，如果没有直接返回原始URLReqest
      @param request 需要被重定向的URLRequest
      @return 如果改URLRequest原始指向的URL中的host对应的IP已经被解析了，则进行重定向操作，如果没有直接返回原始URLReqest
 */
- (NSMutableURLRequest*) resolveURLRequestIfCan:(NSMutableURLRequest*)request;

/**
   判断一个IP是否是被解析出来，且被信任的
      @param ip 需要进行判断的IP
      @return 是否被信任
 */
- (BOOL) isTrustIP:(NSString*)ip;


/**
 手动添加一条hosts记录

 @param ip ip地址
 @param domain 域名
 */
- (void)setIp:(NSString *)ip forDomain:(NSString *)domain;

- (NSString*) queryIPForHost:(NSString*)host;
@end
