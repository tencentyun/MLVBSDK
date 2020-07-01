//
//  PutBucketCORS.h
//  PutBucketCORS
//
//  Created by tencent
//  Copyright (c) 2015年 tencent. All rights reserved.
//
//   ██████╗  ██████╗██╗      ██████╗ ██╗   ██╗██████╗     ████████╗███████╗██████╗ ███╗   ███╗██╗███╗   ██╗ █████╗ ██╗         ██╗      █████╗ ██████╗
//  ██╔═══██╗██╔════╝██║     ██╔═══██╗██║   ██║██╔══██╗    ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║████╗  ██║██╔══██╗██║         ██║     ██╔══██╗██╔══██╗
//  ██║   ██║██║     ██║     ██║   ██║██║   ██║██║  ██║       ██║   █████╗  ██████╔╝██╔████╔██║██║██╔██╗ ██║███████║██║         ██║     ███████║██████╔╝
//  ██║▄▄ ██║██║     ██║     ██║   ██║██║   ██║██║  ██║       ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║██║╚██╗██║██╔══██║██║         ██║     ██╔══██║██╔══██╗
//  ╚██████╔╝╚██████╗███████╗╚██████╔╝╚██████╔╝██████╔╝       ██║   ███████╗██║  ██║██║ ╚═╝ ██║██║██║ ╚████║██║  ██║███████╗    ███████╗██║  ██║██████╔╝
//   ╚══▀▀═╝  ╚═════╝╚══════╝ ╚═════╝  ╚═════╝ ╚═════╝        ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝    ╚══════╝╚═╝  ╚═╝╚═════╝
//
//
//                                                                              _             __                 _                _
//                                                                             (_)           / _|               | |              | |
//                                                          ___  ___ _ ____   ___  ___ ___  | |_ ___  _ __    __| | _____   _____| | ___  _ __   ___ _ __ ___
//                                                         / __|/ _ \ '__\ \ / / |/ __/ _ \ |  _/ _ \| '__|  / _` |/ _ \ \ / / _ \ |/ _ \| '_ \ / _ \ '__/ __|
//                                                         \__ \  __/ |   \ V /| | (_|  __/ | || (_) | |    | (_| |  __/\ V /  __/ | (_) | |_) |  __/ |  \__
//                                                         |___/\___|_|    \_/ |_|\___\___| |_| \___/|_|     \__,_|\___| \_/ \___|_|\___/| .__/ \___|_|  |___/
//    ______ ______ ______ ______ ______ ______ ______ ______                                                                            | |
//   |______|______|______|______|______|______|______|______|                                                                           |_|
//



#import <Foundation/Foundation.h>
#import <QCloudCore/QCloudCore.h>
@class QCloudCORSConfiguration;
NS_ASSUME_NONNULL_BEGIN
/**
设置存储桶（Bucket） 的跨域配置信息的方法.

跨域访问配置的预请求是指在发送跨域请求之前会发送一个 OPTIONS 请求并带上特定的来源域，HTTP 方 法和 header 信息等给 COS，以决定是否可以发送真正的跨域请求. 当跨域访问配置不存在时，请求返回403 Forbidden.

默认情况下，Bucket的持有者可以直接配置 Bucket的跨域信息 ，Bucket 持有者也可以将配置权限授予其他用户.新的配置是覆盖当前的所有配置信 息，而不是新增一条配置.可以通过传入 XML 格式的配置文件来实现配置，文件大小限制为64 KB.

关于设置 Bucket 的跨域配置信息接口的具体描述，请查看 https://cloud.tencent.com/document/product/436/8279.

cos iOS SDK 中设置 Bucket 的跨域配置信息的方法具体步骤如下：

1. 实例化 QCloudPutBucketCORSRequest，填入需要获取 CORS 的存储桶。

2. 调用 QCloudCOSXMLService 对象中的 PutBucketCORS 方法发出请求。

3. 从回调的 finishBlock 中获取结果。结果封装在了 QCloudCORSConfiguration 对象中，该对象的 rules 属性是一个数组，数组里存放着一组 QCloudCORSRule，具体的 CORS 设置就封装在 QCloudCORSRule 对象里。

示例：
@code
QCloudPutBucketCORSRequest* putCORS = [QCloudPutBucketCORSRequest new];
QCloudCORSConfiguration* cors = [QCloudCORSConfiguration new];

QCloudCORSRule* rule = [QCloudCORSRule new];
rule.identifier = @"sdk";
rule.allowedHeader = @[@"origin",@"host",@"accept",@"content-type",@"authorization"];
rule.exposeHeader = @"ETag";
rule.allowedMethod = @[@"GET",@"PUT",@"POST", @"DELETE", @"HEAD"];
rule.maxAgeSeconds = 3600;
rule.allowedOrigin = @"*";

cors.rules = @[rule];

putCORS.corsConfiguration = cors;
putCORS.bucket = @"testBucket-123456789";
[putCORS setFinishBlock:^(id outputObject, NSError *error) {
if (!error) {
//success
}
}];
[[QCloudCOSXMLService defaultCOSXML] PutBucketCORS:putCORS];
@endcode
*/
@interface QCloudPutBucketCORSRequest : QCloudBizHTTPRequest
/**
设置跨bucket域访问的配置信息
*/
@property (strong, nonatomic) QCloudCORSConfiguration *corsConfiguration;
/**
存储桶名
*/
@property (strong, nonatomic) NSString *bucket;


@end
NS_ASSUME_NONNULL_END
