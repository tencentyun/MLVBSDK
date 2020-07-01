//
//  PutBucketLifecycle.h
//  PutBucketLifecycle
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
@class QCloudLifecycleConfiguration;
NS_ASSUME_NONNULL_BEGIN
/**
设置存储桶（Bucket) 生命周期配置的方法.

COS 支持以生命周期配置的方式来管理 Bucket 中对象的生命周期. 如果该 Bucket 已配置生命周期，新的配置的同时则会覆盖原有的配置. 生命周期配置包含一个或多个将应用于一组对象规则的规则集 (其中每个规则为 COS 定义一个操作)。这些操作分为以下两种：转换操作，过期操作.

转换操作,定义对象转换为另一个存储类的时间(例如，您可以选择在对象创建 30 天后将其转换为低频存储类别，同 时也支持将数据沉降到归档存储类别.

过期操作，指定 Object 的过期时间，COS 将会自动为用户删除过期的 Object.

关于Bucket 生命周期配置接口的具体描述，请查看 https://cloud.tencent.com/document/product/436/8280

cos iOS SDK 中Bucket 生命周期配置的方法具体步骤如下：

1. 实例化 QCloudPutBucketLifecycleRequest，填入需要的参数。

2. 调用 QCloudCOSXMLService 对象中的 PutBucketLifecycle 方法发出请求。

3. 从回调的 finishBlock 中的 outputObject 获取具体内容。

示例：
@code
QCloudPutBucketLifecycleRequest* request = [QCloudPutBucketLifecycleRequest new];
request.bucket = bukcetName;
__block QCloudLifecycleConfiguration* configuration = [[QCloudLifecycleConfiguration alloc] init];
QCloudLifecycleRule* rule = [[QCloudLifecycleRule alloc] init];
rule.identifier = @"identifier";
rule.status = QCloudLifecycleStatueEnabled;
QCloudLifecycleRuleFilter* filter = [[QCloudLifecycleRuleFilter alloc] init];
filter.prefix = @"0";
rule.filter = filter;
QCloudLifecycleTransition* transition = [[QCloudLifecycleTransition alloc] init];
transition.days = 100;
transition.storageClass = QCloudCOSStorageStandarIA;
rule.transition = transition;
request.lifeCycle = configuration;
request.lifeCycle.rules = @[rule];
[request setFinishBlock:^(id outputObject, NSError* error) {
//设置完成回调
}];
[[QCloudCOSXMLService defaultCOSXML] PutBucketLifecycle:request];
@endcode
*/
@interface QCloudPutBucketLifecycleRequest : QCloudBizHTTPRequest
/**
设置bucket生命周期的配置信息
*/
@property (strong, nonatomic) QCloudLifecycleConfiguration *lifeCycle;
/**
存储桶名
*/
@property (strong, nonatomic) NSString *bucket;


@end
NS_ASSUME_NONNULL_END
