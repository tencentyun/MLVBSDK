//
//  GetBucketLifecycle.h
//  GetBucketLifecycle
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
#import "QCloudLifecycleConfiguration.h"
NS_ASSUME_NONNULL_BEGIN
/**
查询存储桶（Bucket) 的生命周期配置的方法.

COS 支持以生命周期配置的方式来管理 Bucket 中对象的生命周期，生命周期配置包含一个或多个将 应用于一组对象规则的规则集 (其中每个规则为 COS 定义一个操作)，请参阅 putBucketLifecycle(PutBucketLifecycleRequest).

关于查询 Bucket 的生命周期配置接口的具体描述，请查看https://cloud.tencent.com/document/product/436/8278.

cos iOS SDK 中查询 Bucket 的生命周期配置的方法具体步骤如下：

1. 实例化 QCloudGetBucketLifecycleRequest，填入需要的参数。

2. 调用 QCloudCOSXMLService 对象中的 GetBucketLifecycle 方法发出请求。

3. 从回调的 finishBlock 中的 QCloudLifecycleConfiguration 获取具体内容。

示例：
@code
QCloudGetBucketLifecycleRequest* request = [QCloudGetBucketLifecycleRequest new];
request.bucket = bucketName; //存储桶名称(cos v5 的 bucket格式为：xxx-appid, 如 test-1253960454)
[request setFinishBlock:^(QCloudLifecycleConfiguration* result,NSError* error) {
//设置完成回调
}];
[[QCloudCOSXMLService defaultCOSXML] GetBucketLifecycle:request];
@endcode
*/
@interface QCloudGetBucketLifecycleRequest : QCloudBizHTTPRequest
/**
需要获取lifecycle的存储桶名
*/
@property (strong, nonatomic) NSString *bucket;


- (void) setFinishBlock:(void (^)(QCloudLifecycleConfiguration* result, NSError * error))QCloudRequestFinishBlock;
@end
NS_ASSUME_NONNULL_END
