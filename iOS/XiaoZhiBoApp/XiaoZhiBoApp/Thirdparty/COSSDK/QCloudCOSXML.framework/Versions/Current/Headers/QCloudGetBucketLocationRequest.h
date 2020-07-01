//
//  GetBucketLocation.h
//  GetBucketLocation
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
#import "QCloudBucketLocationConstraint.h"
NS_ASSUME_NONNULL_BEGIN
/**
获取存储桶（Bucket) 所在的地域信息的方法.

在创建 Bucket 时，需要指定所属该 Bucket 所属地域信息.

COS 支持的地域信息，可查看https://cloud.tencent.com/document/product/436/6224.

关于获取 Bucket 所在的地域信息接口的具体描述，请查看https://cloud.tencent.com/document/product/436/8275.

cos iOS SDK 中获取 Bucket 所在的地域信息的方法具体步骤如下：

1. 实例化 QCloudGetBucketLocationRequest，填入需要的参数。

2. 调用 QCloudCOSXMLService 对象中的 GetBucketLocation 方法发出请求。

3. 从回调的 finishBlock 中的 QCloudBucketLocationConstraint 获取具体内容。

示例：
@code
QCloudGetBucketLocationRequest* locationReq = [QCloudGetBucketLocationRequest new];
locationReq.bucket = @"bucketName";//存储桶名称(cos v5 的 bucket格式为：xxx-appid, 如 test-1253960454)
__block QCloudBucketLocationConstraint* location;
[locationReq setFinishBlock:^(QCloudBucketLocationConstraint * _Nonnull result, NSError * _Nonnull error) {
location = result;
}];
[[QCloudCOSXMLService defaultCOSXML] GetBucketLocation:locationReq];
@endcode
*/
@interface QCloudGetBucketLocationRequest : QCloudBizHTTPRequest
/**p
存储桶名
*/
@property (strong, nonatomic) NSString *bucket;


- (void) setFinishBlock:(void (^)(QCloudBucketLocationConstraint* result, NSError * error))QCloudRequestFinishBlock;
@end
NS_ASSUME_NONNULL_END
