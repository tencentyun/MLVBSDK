//
//  DeleteBucketCORS.h
//  DeleteBucketCORS
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
删除跨域访问配置信息的方法.

若是 Bucket 不需要支持跨域访问配置，可以调用此接口删除已配置的跨域访问信息. 跨域访问配置可以通过 putBucketCORS(PutBucketCORSRequest) 或者 putBucketCORSAsync(PutBucketCORSRequest, CosXmlResultListener) 方法来开启 Bucket 的跨域访问 支持.

关于删除跨域访问配置信息接口的具体描述，请查看https://cloud.tencent.com/document/product/436/8283.

cos ios SDK 中删除跨域访问配置信息的方法具体步骤如下：

1. 实例化 QCloudDeleteBucketCORSRequest，填入需要的参数。

2. 调用 QCloudCOSXMLService 对象中的 DeleteBucketCORS 方法发出请求。

3. 从回调的 finishBlock 中的 outputObject 获取具体内容。

示例：
@code
QCloudDeleteBucketCORSRequest* deleteCORS = [QCloudDeleteBucketCORSRequest new];
deleteCORS.bucket = bucketName; //存储桶名称(cos v5 的 bucket格式为：xxx-appid, 如 test-1253960454)
__block NSError* localError;
XCTestExpectation* exp = [self expectationWithDescription:@"putacl"];
[deleteCORS setFinishBlock:^(id outputObject, NSError *error) {
//additional actions after finishing
}];
[[QCloudCOSXMLService defaultCOSXML] DeleteBucketCORS:deleteCORS];
@endcode
*/
@interface QCloudDeleteBucketCORSRequest : QCloudBizHTTPRequest
/**
存储桶名
*/
@property (strong, nonatomic) NSString *bucket;


@end
NS_ASSUME_NONNULL_END
