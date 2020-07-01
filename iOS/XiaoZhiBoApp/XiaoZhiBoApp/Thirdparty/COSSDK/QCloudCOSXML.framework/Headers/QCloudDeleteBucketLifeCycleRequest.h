//
//  DeleteBucketLifeCycle.h
//  DeleteBucketLifeCycle
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
删除存储桶（Bucket） 的生命周期配置的方法.

COS 支持删除已配置的 Bucket 的生命周期列表. COS 支持以生命周期配置的方式来管理 Bucket 中 对象的生命周期，生命周期配置包含一个或多个将 应用于一组对象规则的规则集 (其中每个规则为 COS 定义一个操作)，请参阅 putBucketLifecycle(PutBucketLifecycleRequest).

关于删除 Bucket 的生命周期配置接口的具体描述，请查看https://cloud.tencent.com/document/product/436/8284.

cos iOS SDK 中删除 Bucket 的生命周期配置的方法具体步骤如下：

实例化 QCloudDeleteBucketLifeCycleRequest，填入需要的参数。

调用 QCloudCOSXMLService 对象中的 DeleteBucketLifeCycle 方法发出请求。

从回调的 finishBlock 中的 QCloudLifecycleConfiguration 获取具体内容。

示例：
@code
QCloudDeleteBucketLifeCycleRequest* request = [[QCloudDeleteBucketLifeCycleRequest alloc ] init];
request.bucket = bucketName; // //存储桶名称(cos v5 的 bucket格式为：xxx-appid, 如 test-1253960454)
[request setFinishBlock:^(QCloudLifecycleConfiguration* deleteResult, NSError* deleteError) {
// additional actions after finishing
}];
[[QCloudCOSXMLService defaultCOSXML] DeleteBucketLifeCycle:request];
}
@endcode
*/
@interface QCloudDeleteBucketLifeCycleRequest : QCloudBizHTTPRequest
/**
存储桶名
*/
@property (strong, nonatomic) NSString *bucket;


@end
NS_ASSUME_NONNULL_END
