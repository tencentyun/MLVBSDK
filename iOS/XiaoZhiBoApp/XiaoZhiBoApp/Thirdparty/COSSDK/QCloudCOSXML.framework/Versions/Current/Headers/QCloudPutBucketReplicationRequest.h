//
//  PutBucketReplication.h
//  PutBucketReplication
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
@class QCloudBucketReplicationConfiguation;
NS_ASSUME_NONNULL_BEGIN
/**
配置跨区域复制的方法.

跨区域复制是支持不同区域 Bucket 自动异步复制对象.注意，不能是同区域的 Bucket, 且源 Bucket 和目 标 Bucket 必须已启用版本控制putBucketVersioning(PutBucketVersioningRequest).

cos iOS SDK 中配置跨区域复制的方法具体步骤如下：

1. 实例化 QCloudPutBucketReplicationRequest，填入需要的参数。

2. 调用 QCloudCOSXMLService 对象中的 PutBucketRelication 方法发出请求。

3. 从回调的 finishBlock 中的 outputObject 获取具体内容。

示例：

@code
QCloudPutBucketReplicationRequest* request = [[QCloudPutBucketReplicationRequest alloc] init];
request.bucket = bucketName; //存储桶名称(cos v5 的 bucket格式为：xxx-appid, 如 test-1253960454)
QCloudBucketReplicationConfiguation* configuration = [[QCloudBucketReplicationConfiguation alloc] init];
configuration.role = [NSString identifierStringWithID:@"uin" :@"uin"];
QCloudBucketReplicationRule* rule = [[QCloudBucketReplicationRule alloc] init];

rule.identifier = @"identifier";
rule.status = QCloudQCloudCOSXMLStatusEnabled;

QCloudBucketReplicationDestination* destination = [[QCloudBucketReplicationDestination alloc] init];
NSString* destinationBucket = @"destinationBucket";
NSString* region = @"destinationRegion"
destination.bucket = [NSString stringWithFormat:@"qcs:id/0:cos:%@:appid/%@:%@",@"region",@"appid",@"destinationBucket"];
rule.destination = destination;
configuration.rule = @[rule];
request.configuation = configuration;
[request setFinishBlock:^(id outputObject, NSError* error) {
//设置完成回调
}];
[[QCloudCOSXMLService defaultCOSXML] PutBucketRelication:request];
@endcode
*/
@interface QCloudPutBucketReplicationRequest : QCloudBizHTTPRequest
/**
说明所有跨区域配置信息
*/
@property (strong, nonatomic) QCloudBucketReplicationConfiguation *configuation;
/**
存储桶名称
*/
@property (strong, nonatomic) NSString *bucket;


@end
NS_ASSUME_NONNULL_END
