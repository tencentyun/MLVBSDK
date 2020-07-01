//
//  OptionsObject.h
//  OptionsObject
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
NS_ASSUME_NONNULL_BEGIN
/**
COS 对象的跨域访问配置预请求的方法.

跨域访问配置的预请求是指在发送跨域请求之前会发送一个 OPTIONS 请求并带上特定的来源域，HTTP 方法 和 header 信息等给 COS，以决定是否可以发送真正的跨域请求. 当跨域访问配置不存在时，请求返回403 Forbidden. 跨域访问配置可以通过 putBucketCORS(PutBucketCORSRequest) 或者 putBucketCORSAsync(PutBucketCORSRequest, CosXmlResultListener) 方法来开启 Bucket 的跨域访问 支持.

关于COS 对象的跨域访问配置预请求接口的具体描述，请查看https://cloud.tencent.com/document/product/436/8288.

cos iOS SDK 中发起COS 对象的跨域访问配置预请求的方法具体步骤如下：

1. 实例化 QCloudOptionsObjectRequest，填入需要设置的对象名、存储桶名、模拟跨域访问请求的 http 方法和模拟跨域访问允许的访问来源。

2. 调用 QCloudCOSXMLService 对象中的方法发出请求。

3. 从回调的 finishBlock 中的获取具体内容。

示例：
@code
QCloudOptionsObjectRequest* request = [[QCloudOptionsObjectRequest alloc] init];
request.bucket =@"存储桶名";
request.origin = @"*";
request.accessControlRequestMethod = @"get";
request.accessControlRequestHeaders = @"host";
request.object = @"对象名";
__block id resultError;
[request setFinishBlock:^(id outputObject, NSError* error) {
resultError = error;
}];
[[QCloudCOSXMLService defaultCOSXML] OptionsObject:request];
@endcode
*/
@interface QCloudOptionsObjectRequest : QCloudBizHTTPRequest
/**
对象的key
*/
@property (strong, nonatomic) NSString *object;
/**
存储桶名
*/
@property (strong, nonatomic) NSString *bucket;
/**
模拟跨域访问的请求来源域名
*/
@property (strong, nonatomic) NSString *origin;
/**
模拟跨域访问的请求HTTP方法
*/
@property (strong, nonatomic) NSString *accessControlRequestMethod;
/**
模；模拟跨域访问的请求头部
*/
@property (strong, nonatomic) NSString *accessControlRequestHeaders;


@end
NS_ASSUME_NONNULL_END
