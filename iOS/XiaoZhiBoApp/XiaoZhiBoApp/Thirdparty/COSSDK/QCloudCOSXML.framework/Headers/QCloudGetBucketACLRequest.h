//
//  GetBucketACL.h
//  GetBucketACL
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
#import "QCloudACLPolicy.h"
NS_ASSUME_NONNULL_BEGIN
/**
获取存储桶（Bucket) 的访问权限信息（Access Control List, ACL）的方法.

ACL 权限包括读、写、读写权限. COS 中 Bucket 是有访问权限控制的.可以通过获取 Bucket 的 ACL 表(putBucketACL(PutBucketACLRequest))，来查看那些用户拥有 Bucket 访 问权限.

关于获取 Bucket 的 ACL 接口的具体描述，请查看 https://cloud.tencent.com/document/product/436/7733.

cos iOS SDK 中获取 Bucket 的 ACL 的方法具体步骤如下：

1. 实例化 QCloudGetBucketACLRequest，填入获取 ACL 的存储桶。

2. 调用 QCloudCOSXMLService 对象中的 GetBucketACL 方法发出请求。

3. 从回调的 finishBlock 中的 QCloudACLPolicy 获取具体内容。

示例：
@code
QCloudGetBucketACLRequest* getBucketACl   = [QCloudGetBucketACLRequest new];
getBucketACl.bucket = @"testbucket-123456789";
[getBucketACl setFinishBlock:^(QCloudACLPolicy * _Nonnull result, NSError * _Nonnull error) {
//QCloudACLPolicy中包含了 Bucket 的 ACL 信息。
}];

[[QCloudCOSXMLService defaultCOSXML] GetBucketACL:getBucketACl];
@endcode
*/
@interface QCloudGetBucketACLRequest : QCloudBizHTTPRequest
/**
获取存储桶（Bucket) 的访问权限信息（Access Control List, ACL）的方法.

ACL 权限包括读、写、读写权限. COS 中 Bucket 是有访问权限控制的.可以通过获取 Bucket 的 ACL 表(putBucketACL(PutBucketACLRequest))，来查看那些用户拥有 Bucket 访 问权限.

关于获取 Bucket 的 ACL 接口的具体描述，请查看 https://cloud.tencent.com/document/product/436/7733.

cos iOS SDK 中获取 Bucket 的 ACL 的方法具体步骤如下：

1. 实例化 QCloudGetBucketACLRequest，填入获取 ACL 的存储桶。

2. 调用 QCloudCOSXMLService 对象中的 GetBucketACL 方法发出请求。

3. 从回调的 finishBlock 中的 QCloudACLPolicy 获取具体内容。

示例：
@code
QCloudGetBucketACLRequest* getBucketACl   = [QCloudGetBucketACLRequest new];
getBucketACl.bucket = @"testbucket-123456789";
[getBucketACl setFinishBlock:^(QCloudACLPolicy * _Nonnull result, NSError * _Nonnull error) {
//QCloudACLPolicy中包含了 Bucket 的 ACL 信息。
}];

[[QCloudCOSXMLService defaultCOSXML] GetBucketACL:getBucketACl];
@endcode
*/
/**
存储桶名
*/
@property (strong, nonatomic) NSString *bucket;


- (void) setFinishBlock:(void (^)(QCloudACLPolicy* result, NSError * error))QCloudRequestFinishBlock;
@end
NS_ASSUME_NONNULL_END
