//
//  GetObject.h
//  GetObject
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
下载 COS 对象的方法.

可以直接发起 GET 请求获取 COS 中完整的对象数据, 或者在 GET 请求 中传入 Range 请求头部获取对象的部分内容. 获取COS 对象的同时，对象的元数据将会作为 HTTP 响应头部随对象内容一同返回，COS 支持GET 请求时 使用 URL 参数的方式覆盖响应的部分元数据值，例如覆盖 Content-iDisposition 的响应值.

关于获取 COS 对象的具体描述，请查看 https://cloud.tencent.com/document/product/436/14115.

关于获取 COS 对象的接口描述，请查看 https://cloud.tencent.com/document/product/436/7753.

cos iOS SDK 中获取 COS 对象请求的方法具体步骤如下：

1. 实例化 QCloudGetObjectRequest，填入需要的参数。

2. 调用 QCloudCOSXMLService 对象中的 GetObject 方法发出请求。

3. 从回调的 finishBlock 中的 outputObject 获取具体内容。

示例：
@code
QCloudGetObjectRequest* request = [[QCloudGetObjectRequest alloc] init];
request.bucket = @"bucketName"; //存储桶名称(cos v5 的 bucket格式为：xxx-appid, 如 test-1253960454)
request.object = @"objectName";;
[request setFinishBlock:^(id outputObject, NSError *error) {
//additional actions after finishing
}];
[[QCloudCOSXMLService defaultCOSXML] GetObject:request];
@endcode
*/
@interface QCloudGetObjectRequest : QCloudBizHTTPRequest
/**
设置响应头部中的 Content-Type参数
*/
@property (strong, nonatomic) NSString *responseContentType;
/**
设置响应头部中的Content-Language参数
*/
@property (strong, nonatomic) NSString *responseContentLanguage;
/**
设置响应头部中的Content-Expires参数
*/
@property (strong, nonatomic) NSString *responseContentExpires;
/**
设置响应头部中的Cache-Control参数
*/
@property (strong, nonatomic) NSString *responseCacheControl;
/**
设置响应头部中的 Content-Disposition 参数。
*/
@property (strong, nonatomic) NSString *responseContentDisposition;
/**
设置响应头部中的 Content-Encoding 参数。
*/
@property (strong, nonatomic) NSString *responseContentEncoding;
/**
RFC 2616 中定义的指定文件下载范围，以字节（bytes）为单位
*/
@property (strong, nonatomic) NSString *range;
/**
如果文件修改时间晚于指定时间，才返回文件内容。否则返回 412 (not modified)
*/
@property (strong, nonatomic) NSString *ifModifiedSince;
/**
如果文件修改时间早于或等于指定时间，才返回文件内容。否则返回 412 (precondition failed)
*/
@property (strong, nonatomic) NSString *ifUnmodifiedModifiedSince;
/**
当 ETag 与指定的内容一致，才返回文件。否则返回 412 (precondition failed)
*/
@property (strong, nonatomic) NSString *ifMatch;
/**
当 ETag 与指定的内容不一致，才返回文件。否则返回 304 (not modified)
*/
@property (strong, nonatomic) NSString *ifNoneMatch;
/**
指定 Object 的 VersionID (在开启多版本的情况下)
*/
@property (strong, nonatomic) NSString *versionID;
/**
对象名
*/
@property (strong, nonatomic) NSString *object;
/**
存储桶名
*/
@property (strong, nonatomic) NSString *bucket;


@end
NS_ASSUME_NONNULL_END
