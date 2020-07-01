//
//  InitiateMultipartUpload.h
//  InitiateMultipartUpload
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
#import "QCloudInitiateMultipartUploadResult.h"
#import "QCloudCOSStorageClassEnum.h"
NS_ASSUME_NONNULL_BEGIN
/**
初始化分块上传的方法.

使用分块上传对象时，首先要进行初始化分片上传操作，获取对应分块上传的 uploadId，用于后续上传操 作.分块上传适合于在弱网络或高带宽环境下上传较大的对象.SDK 支持自行切分对象并分别调用uploadPart(UploadPartRequest)或者uploadPartAsync(UploadPartRequest, CosXmlResultListener)上传各 个分块.

关于分块上传的描述，请查看 https://cloud.tencent.com/document/product/436/14112.

关于初始化分块上传的描述，请查看 https://cloud.tencent.com/document/product/436/7746.

cos iOS SDK 中初始化分块上传请求的方法具体步骤如下：

1. 实例化 QCloudInitiateMultipartUploadRequest，填入需要的参数。

2. 调用 QCloudCOSXMLService 对象中的 InitiateMultipartUpload 方法发出请求。

3. 从回调的 finishBlock 中的获取具体内容。

示例：
@code
QCloudInitiateMultipartUploadRequest* initrequest = [QCloudInitiateMultipartUploadRequest new];
initrequest.bucket = @"bucketName"; //存储桶名称(cos v5 的 bucket格式为：xxx-appid, 如 test-1253960454)
initrequest.object = @"objectName"

__block QCloudInitiateMultipartUploadResult* initResult;
[initrequest setFinishBlock:^(QCloudInitiateMultipartUploadResult* outputObject, NSError *error) {
initResult = outputObject;
}];
[[QCloudCOSXMLService defaultCOSXML] InitiateMultipartUpload:initrequest];

@endcode
*/
@interface QCloudInitiateMultipartUploadRequest : QCloudBizHTTPRequest
/**
对象的名称
*/
@property (strong, nonatomic) NSString *object;
/**
存储桶名
*/
@property (strong, nonatomic) NSString *bucket;
/**
RFC 2616 中定义的缓存策略，将作为对象的元数据返回
*/
@property (strong, nonatomic) NSString *cacheControl;
/**
RFC 2616 中定义的文件名称，将作为 Object 元数据保存
*/
@property (strong, nonatomic) NSString *contentDisposition;
@property (strong, nonatomic) NSString *expect;
/**
RFC 2616 中定义的文件名称，将作为 Object 元数据保存。
*/
@property (strong, nonatomic) NSString *expires;
@property (strong, nonatomic) NSString *contentSHA1;
/**
设置 Object 的存储级别
*/
@property (assign, nonatomic) QCloudCOSStorageClass storageClass;
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



- (void) setFinishBlock:(void (^)(QCloudInitiateMultipartUploadResult* result, NSError * error))QCloudRequestFinishBlock;
@end
NS_ASSUME_NONNULL_END
