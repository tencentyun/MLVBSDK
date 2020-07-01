//
//  GetBucketReplication.h
//  GetBucketReplication
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
#import "QCloudBucketReplicationConfiguation.h"
NS_ASSUME_NONNULL_BEGIN
/**
获取跨区域复制配置信息的方法.

跨区域复制是支持不同区域 Bucket 自动复制对象, 请查阅putBucketReplication(PutBucketReplicationRequest).

cos iOS SDK 中获取跨区域复制配置信息的方法具体步骤如下：

1. 实例化 QCloudGetBucketReplicationRequest，填入需要的参数。

2. 调用 QCloudCOSXMLService 对象中的 GetBucketReplication 方法发出请求。

3. 从回调的 finishBlock 中的 QCloudBucketReplicationConfiguation 获取具体内容。

示例：
@code
QCloudGetBucketReplicationRequest* request = [[QCloudGetBucketReplicationRequest alloc] init];
request.bucket = bucketBame; // //存储桶名称(cos v5 的 bucket格式为：xxx-appid, 如 test-1253960454)
[request setFinishBlock:^(QCloudBucketReplicationConfiguation* result, NSError* error) {
//设置完成回调
}];
[[QCloudCOSXMLService defaultCOSXML] GetBucketReplication:request];
@endcode
*/
@interface QCloudGetBucketReplicationRequest : QCloudBizHTTPRequest
/**
存储桶信息
*/
@property (strong, nonatomic) NSString *bucket;


- (void) setFinishBlock:(void (^)(QCloudBucketReplicationConfiguation* result, NSError * error))QCloudRequestFinishBlock;
@end
NS_ASSUME_NONNULL_END
