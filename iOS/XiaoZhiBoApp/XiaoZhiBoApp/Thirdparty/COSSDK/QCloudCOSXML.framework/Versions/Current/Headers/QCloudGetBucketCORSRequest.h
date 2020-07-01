//
//  GetBucketCORS.h
//  GetBucketCORS
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
#import "QCloudCORSConfiguration.h"
NS_ASSUME_NONNULL_BEGIN
/**
查询存储桶（Bucket) 跨域访问配置信息的方法.

COS 支持查询当前 Bucket 跨域访问配置信息，以确定是否配置跨域信息.当跨域访问配置不存在时，请求 返回403 Forbidden. 跨域访问配置可以通过 putBucketCORS(PutBucketCORSRequest) 或者 putBucketCORSAsync(PutBucketCORSRequest, CosXmlResultListener) 方法来开启 Bucket 的跨域访问 支持.

关于查询 Bucket 跨域访问配置信息接口的具体描述， 请查看 https://cloud.tencent.com/document/product/436/8274.

cos iOS SDK 中查询 Bucket 跨域访问配置信息的方法具体步骤如下：

1. 实例化 QCloudGetBucketCORSRequest，填入需要获取 CORS 的存储桶。

2. 调用 QCloudCOSXMLService 对象中的 GetBucketCORS 方法发出请求。

3. 从回调的 finishBlock 中获取结果。结果封装在了 QCloudCORSConfiguration 对象中，该对象的 rules 属性是一个数组，数组里存放着一组 QCloudCORSRule，具体的 CORS 设置就封装在 QCloudCORSRule 对象里。


示例：

@code
QCloudGetBucketCORSRequest* corsReqeust = [QCloudGetBucketCORSRequest new];
corsReqeust.bucket = @"testBucket-123456789";

[corsReqeust setFinishBlock:^(QCloudCORSConfiguration * _Nonnull result, NSError * _Nonnull error) {
//CORS设置封装在result中。
}];

[[QCloudCOSXMLService defaultCOSXML] GetBucketCORS:corsReqeust];
@endcode
*/
@interface QCloudGetBucketCORSRequest : QCloudBizHTTPRequest
/**
存储桶名
*/
@property (strong, nonatomic) NSString *bucket;


- (void) setFinishBlock:(void (^)(QCloudCORSConfiguration* result, NSError * error))QCloudRequestFinishBlock;
@end
NS_ASSUME_NONNULL_END
