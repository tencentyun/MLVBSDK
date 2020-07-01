//
//  PutObjectACL.h
//  PutObjectACL
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
设置 COS 对象的访问权限信息（Access Control List, ACL）的方法.

ACL权限包括读、写、读写权限. COS 对象的 ACL 可以通过 header头部："x-cos-acl"，"x-cos-grant-read"，"x-cos-grant-write"， "x-cos-grant-full-control" 传入 ACL 信息，或者通过 Body 以 XML 格式传入 ACL 信息.这两种方式只 能选择其中一种，否则引起冲突. 传入新的 ACL 将覆盖原有 ACL信息.ACL策略数上限1000，建议用户不要每个上传文件都设置 ACL.

关于设置 COS 对象的ACL接口的具体描述，请查看https://cloud.tencent.com/document/product/436/7748.

cos iOS SDK 中设置 COS 对象的 ACL 的方法具体步骤如下：

1. 实例化 QCloudPutObjectACLRequest，填入存储桶名，和一些额外需要的参数，如授权的具体信息等。

2. 调用 QCloudCOSXMLService 对象中的方法发出请求。

3. 从回调的 finishBlock 中获取设置的完成情况，若 error 为空，则设置成功。

示例：
@code
QCloudPutObjectACLRequest* request = [QCloudPutObjectACLRequest new];
request.object = @"需要设置 ACL 的对象名";
request.bucket = @"testBucket-123456789";
NSString *ownerIdentifier = [NSString stringWithFormat:@"qcs::cam::uin/%@:uin/%@",self.appID, self.appID];
NSString *grantString = [NSString stringWithFormat:@"id=\"%@\"",ownerIdentifier];
request.grantFullControl = grantString;
__block NSError* localError;
[request setFinishBlock:^(id outputObject, NSError *error) {
localError = error;
}];
[[QCloudCOSXMLService defaultCOSXML] PutObjectACL:request];
@endcode
*/
@interface QCloudPutObjectACLRequest : QCloudBizHTTPRequest
/**
object名
*/
@property (strong, nonatomic) NSString *object;
/**
定义 Object 的 ACL 属性。有效值：private，public-read-write，public-read；默认值：private
*/
@property (strong, nonatomic) NSString *accessControlList;
/**
赋予被授权者读的权限。格式：id=" ",id=" "；
当需要给子账户授权时，id="qcs::cam::uin/<OwnerUin>:uin/<SubUin>"，
当需要给根账户授权时，id="qcs::cam::uin/<OwnerUin>:uin/<OwnerUin>"
*/
@property (strong, nonatomic) NSString *grantRead;
/**
赋予被授权者写的权限。格式：id=" ",id=" "；
当需要给子账户授权时，id="qcs::cam::uin/<OwnerUin>:uin/<SubUin>"，
当需要给根账户授权时，id="qcs::cam::uin/<OwnerUin>:uin/<OwnerUin>"
*/
@property (strong, nonatomic) NSString *grantWrite;
/**
赋予被授权者读写权限。格式: id=" ",id=" " ；
当需要给子账户授权时，id="qcs::cam::uin/<OwnerUin>:uin/<SubUin>"，
当需要给根账户授权时，id="qcs::cam::uin/<OwnerUin>:uin/<OwnerUin>"
*/
@property (strong, nonatomic) NSString *grantFullControl;
/**
存储桶名
*/
@property (strong, nonatomic) NSString *bucket;


@end
NS_ASSUME_NONNULL_END
