//
//  PutBucket.h
//  PutBucket
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
创建存储桶（Bucket）的方法.

在开始使用 COS 时，需要在指定的账号下先创建一个 Bucket 以便于对象的使用和管理. 并指定 Bucket 所属的地域.创建 Bucket 的用户默认成为 Bucket 的持有者.若创建 Bucket 时没有指定访问权限，则默认 为私有读写（private）权限.

可用地域，可以查看https://cloud.tencent.com/document/product/436/6224.

关于创建 Bucket 描述，请查看 https://cloud.tencent.com/document/product/436/14106.

关于创建存储桶（Bucket）接口的具体 描述，请查看 https://cloud.tencent.com/document/product/436/7738.

cos iOS SDK 中创建 Bucket的方法具体步骤如下：

1. 实例化 QCloudPutBucketRequest，填入需要的参数。

2. 调用 QCloudCOSXMLService 对象中的 PutBucket 方法发出请求。

3. 从回调的 finishBlock 中的 outputObject 获取具体内容。

示例：
@code
QCloudPutBucketRequest* request = [QCloudPutBucketRequest new];
request.bucket = bucketName; //additional actions after finishing
[request setFinishBlock:^(id outputObject, NSError* error) {

}];
[[QCloudCOSXMLService defaultCOSXML] PutBucket:request];
@endcode
*/
@interface QCloudPutBucketRequest : QCloudBizHTTPRequest
/**
定义 Object 的 ACL 属性。有效值：private，public-read-write，public-read；默认值：private
*/
@property (strong, nonatomic) NSString *accessControlList;
/**
赋予被授权者读的权限。格式：x-cos-grant-read: id=" ",id=" "；
当需要给子账户授权时，id="qcs::cam::uin/<OwnerUin>:uin/<SubUin>"，
当需要给根账户授权时，id="qcs::cam::uin/<OwnerUin>:uin/<OwnerUin>"
其中，<OwnerUin>为根账户的uin，而<SubUin>为子账户的uin，使用时替换
*/
@property (strong, nonatomic) NSString *grantRead;
/**
赋予被授权者写的权限。格式：x-cos-grant-write: id=" ",id=" "；
当需要给子账户授权时，id="qcs::cam::uin/<OwnerUin>:uin/<SubUin>"，
当需要给根账户授权时，id="qcs::cam::uin/<OwnerUin>:uin/<OwnerUin>"
其中，<OwnerUin>为根账户的uin，而<SubUin>为子账户的uin，使用时替换
*/
@property (strong, nonatomic) NSString *grantWrite;
/**
赋予被授权者读写权限。格式: id=" ",id=" " ；
当需要给子账户授权时，id="qcs::cam::uin/<OwnerUin>:uin/<SubUin>"，
当需要给根账户授权时，id="qcs::cam::uin/<OwnerUin>:uin/<OwnerUin>"
其中，<OwnerUin>为根账户的uin，而<SubUin>为子账户的uin，使用时替换
*/
@property (strong, nonatomic) NSString *grantFullControl;
/**
要创建的存储桶名
注意存储桶名只能由数字和小写字母组成，并且长度不能超过40个字符，否则会创建失败
*/
@property (strong, nonatomic) NSString *bucket;


@end
NS_ASSUME_NONNULL_END
