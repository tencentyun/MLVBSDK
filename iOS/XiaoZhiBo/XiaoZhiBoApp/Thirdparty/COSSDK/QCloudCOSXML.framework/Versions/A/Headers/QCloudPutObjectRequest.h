//
//  PutObject.h
//  PutObject
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
#import "QCloudCOSStorageClassEnum.h"
NS_ASSUME_NONNULL_BEGIN
/**
简单上传的方法.

简单上传主要适用于在单个请求中上传一个小于 5 GB 大小的对象. 对于大于 5 GB 的对象(或者在高带宽或弱网络环境中）优先使用分片上传的方式 (https://cloud.tencent.com/document/product/436/14112).

关于简单上传的具体描述，请查看 https://cloud.tencent.com/document/product/436/14113.

关于简单上传接口的具体描述，请查看 https://cloud.tencent.com/document/product/436/7749.

cos iOS SDK 中简单上传请求的方法具体步骤如下：

1. 实例化 QCloudPutObjectRequest，填入需要的参数。

2. 调用 QCloudCOSXMLService 对象中的 PutObject 方法发出请求。

3. 从回调的 finishBlock 中的 outputObject 获取具体内容。

示例：
@code
QCloudPutObjectRequest* put = [QCloudPutObjectRequest new];
put.object = @"object-name";
put.bucket = @"bucket-12345678";
put.body =  [@"testFileContent" dataUsingEncoding:NSUTF8StringEncoding];
[put setFinishBlock:^(id outputObject, NSError *error) {
//完成回调
if (nil == error) {
//成功
}
}];
[[QCloudCOSXMLService defaultCOSXML] PutObject:put];
@endcode
*/
@interface QCloudPutObjectRequest <BodyType> : QCloudBizHTTPRequest
@property (nonatomic, strong) BodyType body;
/**
 对象 名称
*/
@property (strong, nonatomic) NSString *object;
/**
 存储桶 名称
*/
@property (strong, nonatomic) NSString *bucket;
/**
RFC 2616 中定义的缓存策略，将作为 Object 元数据保存
*/
@property (strong, nonatomic) NSString *cacheControl;
/**
RFC 2616 中定义的文件名称，将作为 Object 元数据保存
*/
@property (strong, nonatomic) NSString *contentDisposition;
/**
当使用 Expect: 100-continue 时，在收到服务端确认后，才会发送请求内容
*/
@property (strong, nonatomic) NSString *expect;
/**
RFC 2616 中定义的过期时间，将作为 Object 元数据保存
*/
@property (strong, nonatomic) NSString *expires;
@property (strong, nonatomic) NSString *contentSHA1;
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
指定对象对应的Version ID（在开启了多版本的情况才有）
*/
@property (strong, nonatomic) NSString *versionID;



@end
NS_ASSUME_NONNULL_END
