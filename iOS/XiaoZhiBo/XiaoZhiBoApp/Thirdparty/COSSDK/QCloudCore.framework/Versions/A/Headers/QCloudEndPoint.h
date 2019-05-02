//
//  QCloudEndPoint.h
//  Pods
//
//  Created by Dong Zhao on 2017/3/31.
//
//

#import <Foundation/Foundation.h>
typedef NSString* QCloudRegion;
typedef NSString* QCloudServiceName;


/**
 QCloud 云服务的服务器地址，如果您继承该类，并且添加了自定义的参数，请一定要实现NSCopying协议
 */
@interface QCloudEndPoint : NSObject <NSCopying>
{
    @protected
    QCloudRegion _regionName;
    QCloudServiceName   _serviceName;
    NSURL* _serverURLLiteral;
}
/**
 是否启动HTTPS安全连接
 @default NO
 */
@property (nonatomic, assign) BOOL useHTTPS;
/**
 服务园区名称
 */
@property (nonatomic, copy) QCloudRegion        regionName;
/**
 服务的基础名称
 */
@property (nonatomic, copy) QCloudServiceName   serviceName;


/**
 字面URL地址，改地址将作为一个字面量直接返回。
 */
@property (nonatomic, strong, readonly) NSURL* serverURLLiteral;


/**
 通过一个包含字面URL地址的变量初始化endpoint

 @param url 字面URL地址
 @return endpoint实例
 */
- (instancetype) initWithLiteralURL:(NSURL*)url;


/**
 通过存储桶名称和用户的appid构建服务地址

 @param bucket 存储桶名称
 @param appID appid
 @return 对指称的用户的存储桶提供服务的服务器地址
 */
- (NSURL*) serverURLWithBucket:(NSString*)bucket appID:(NSString*)appID;
@end
