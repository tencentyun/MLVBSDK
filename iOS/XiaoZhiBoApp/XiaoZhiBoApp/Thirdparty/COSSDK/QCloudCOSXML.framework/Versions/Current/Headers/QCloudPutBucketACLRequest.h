//
//  PutBucketACL.h
//  PutBucketACL
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
设置存储桶（Bucket） 的访问权限（Access Control List, ACL)的方法.

ACL 权限包括读、写、读写权限. 写入 Bucket 的 ACL 可以通过 header头部："x-cos-acl"，"x-cos-grant-read"，"x-cos-grant-write"， "x-cos-grant-full-control" 传入 ACL 信息，或者通过 Body 以 XML 格式传入 ACL 信息.这两种方式只 能选择其中一种，否则引起冲突. 传入新的 ACL 将覆盖原有 ACL信息. 私有 Bucket 可以下可以给某个文件夹设置成公有，那么该文件夹下的文件都是公有；但是把文件夹设置成私有后，在该文件夹下的文件设置 的公有属性，不会生效.

关于设置 Bucket 的ACL接口的具体描述，请查看 https://cloud.tencent.com/document/product/436/7737.

cos iOS SDK 中设置 Bucket 的ACL的方法具体步骤如下：

1. 实例化 QCloudPutBucketACLRequest，填入需要设置的存储桶，然后根据设置值的权限类型分别填入不同的参数。

2. 调用 QCloudCOSXMLService 对象中的 PutBucketACL 方法发出请求。

3. 从回调的 finishBlock 中的获取设置是否成功，并做设置成功后的一些额外动作。

示例：
@code
QCloudPutBucketACLRequest* putACL = [QCloudPutBucketACLRequest new];
NSString* appID = kAppID;
NSString *ownerIdentifier = [NSString stringWithFormat:@"qcs::cam::uin/%@:uin/%@", appID, appID];
NSString *grantString = [NSString stringWithFormat:@"id=\"%@\"",ownerIdentifier];
putACL.accessControlList = @"private";
putACL.grantFullControl = grantString;
putACL.bucket = bucketName; //存储桶名称(cos v5 的 bucket格式为：xxx-appid, 如 test-1253960454)
[putACL setFinishBlock:^(id outputObject, NSError *error) {
//additional actions after finishing
}];
[[QCloudCOSXMLService defaultCOSXML] PutBucketACL:putACL];
@endcode
*/
@interface QCloudPutBucketACLRequest : QCloudBizHTTPRequest
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
存储桶名
*/
@property (strong, nonatomic) NSString *bucket;


@end
NS_ASSUME_NONNULL_END
