//
//  GetObjectACL.h
//  GetObjectACL
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
获取 COS 对象的访问权限信息（Access Control List, ACL）的方法.

Bucket 的持有者可获取该 Bucket 下的某个对象的 ACL 信息，如被授权者以及被授权的信息. ACL 权限包括读、写、读写权限.

关于获取 COS 对象的 ACL 接口的具体描述，请查看https://cloud.tencent.com/document/product/436/7744.

cos iOS SDK 中获取 COS 对象的 ACL 的方法具体步骤如下：

1. 实例化 QCloudGetObjectACLRequest，填入存储桶的名称，和需要查询对象的名称。

2. 调用 QCloudCOSXMLService 对象中的 GetObjectACL 方法发出请求。

3. 从回调的 finishBlock 中的获取的 QCloudACLPolicy 对象中获取封装好的 ACL 的具体信息。

示例：
@code
QCloudGetObjectACLRequest* request = [QCloudGetObjectACLRequest new];
request.bucket = @“bucketName"; //存储桶名称(cos v5 的 bucket格式为：xxx-appid, 如 test-1253960454)
request.object = @"objectName";
[request setFinishBlock:^(QCloudACLPolicy * _Nonnull policy, NSError * _Nonnull error) {
//从 QCloudACLPolicy 对象中获取封装好的 ACL 的具体信息
}];
[[QCloudCOSXMLService defaultCOSXML] GetObjectACL:request];
@endcode
*/
@interface QCloudGetObjectACLRequest : QCloudBizHTTPRequest
/**
 存储桶名
*/
@property (strong, nonatomic) NSString *bucket;
/**
 对象名
*/
@property (strong, nonatomic) NSString *object;
/**
  指定多版本中的 Version ID
*/
@property (strong, nonatomic) NSString *versionID;


- (void) setFinishBlock:(void (^)(QCloudACLPolicy* result, NSError * error))QCloudRequestFinishBlock;
@end
NS_ASSUME_NONNULL_END
