//
//  PutObjectCopy.h
//  PutObjectCopy
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
#import "QCloudCopyObjectResult.h"
#import "QCloudCOSStorageClassEnum.h"
NS_ASSUME_NONNULL_BEGIN
/**
简单复制对象的方法.

COS 中复制对象可以完成如下功能:

创建一个新的对象副本.

复制对象并更名，删除原始对象，实现重命名

修改对象的存储类型，在复制时选择相同的源和目标对象键，修改存储类型.

在不同的腾讯云 COS 地域复制对象.

修改对象的元数据，在复制时选择相同的源和目标对象键，并修改其中的元数据,复制对象时，默认将继承原对象的元数据，但创建日期将会按新对象的时间计算.

当复制的对象小于等于 5 GB ，可以使用简单复制（https://cloud.tencent.com/document/product/436/14117).

当复制对象超过 5 GB 时，必须使用分块复制（https://cloud.tencent.com/document/product/436/14118 ） 来实现复制.

关于简单复制接口的具体描述，请查看https://cloud.tencent.com/document/product/436/10881.

cos iOS SDK 中简单复制对象的方法具体步骤如下：

1. 实例化 QCloudPutObjectCopyRequest，填入需要的参数。

2. 调用 QCloudCOSXMLService 对象中的 PutObjectCopy 方法发出请求。

3. 从回调的 finishBlock 中的 QCloudCopyObjectResult 获取具体内容。

示例：
@code
QCloudPutObjectCopyRequest* request = [[QCloudPutObjectCopyRequest alloc] init];
request.bucket = @"bucketName";
request.object = @"objectName";
request.objectCopySource = @"objectCopySource";

[request setFinishBlock:^(QCloudCopyObjectResult* result, NSError* error) {
}];
[[QCloudCOSXMLService defaultCOSXML] PutObjectCopy:request];
@endcode
*/
@interface QCloudPutObjectCopyRequest : QCloudBizHTTPRequest
/**
对象名
*/
@property (strong, nonatomic) NSString *object;
/**
存储桶名
*/
@property (strong, nonatomic) NSString *bucket;
/**
源文件 URL 路径，可以通过 versionid 子资源指定历史版本
*/
@property (strong, nonatomic) NSString *objectCopySource;
/**
是否拷贝元数据，枚举值：Copy, Replaced，默认值 Copy。假如标记为 Copy，忽略 Header 中的用户元数据信息直接复制；假如标记为 Replaced，按 Header 信息修改元数据。当目标路径和原路径一致，即用户试图修改元数据时，必须为 Replaced
*/
@property (strong, nonatomic) NSString *metadataDirective;
/**
当 Object 在指定时间后被修改，则执行操作，否则返回 412。可与 x-cos-copy-source-If-None-Match 一起使用，与其他条件联合使用返回冲突。
*/
@property (strong, nonatomic) NSString *objectCopyIfModifiedSince;
/**
当 Object 在指定时间后未被修改，则执行操作，否则返回 412。可与 x-cos-copy-source-If-Match 一起使用，与其他条件联合使用返回冲突。
*/
@property (strong, nonatomic) NSString *objectCopyIfUnmodifiedSince;
/**
当 Object 的 Etag 和给定一致时，则执行操作，否则返回 412。可与x-cos-copy-source-If-Unmodified-Since 一起使用，与其他条件联合使用返回冲突。
*/
@property (strong, nonatomic) NSString *objectCopyIfMatch;
/**
当 Object 的 Etag 和给定不一致时，则执行操作，否则返回 412。可与 x-cos-copy-source-If-Modified-Since 一起使用，与其他条件联合使用返回冲突。
*/
@property (strong, nonatomic) NSString *objectCopyIfNoneMatch;
/**
    Object 的存储级别
    */
@property (assign, nonatomic) QCloudCOSStorageClass storageClass;
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
    指定源文件的versionID
    */
@property (strong, nonatomic) NSString *versionID;


- (void) setFinishBlock:(void (^)(QCloudCopyObjectResult* result, NSError * error))QCloudRequestFinishBlock;
@end
NS_ASSUME_NONNULL_END
