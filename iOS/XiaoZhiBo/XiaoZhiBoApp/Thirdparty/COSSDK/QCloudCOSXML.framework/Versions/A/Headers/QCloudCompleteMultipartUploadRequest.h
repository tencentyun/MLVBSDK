//
//  CompleteMultipartUpload.h
//  CompleteMultipartUpload
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
#import "QCloudUploadObjectResult.h"
@class QCloudCompleteMultipartUploadInfo;
NS_ASSUME_NONNULL_BEGIN
/**
完成整个分块上传的方法.

当使用分块上传（uploadPart(UploadPartRequest)）完对象的所有块以后，必须调用该 completeMultiUpload(CompleteMultiUploadRequest) 或者 completeMultiUploadAsync(CompleteMultiUploadRequest, CosXmlResultListener) 来完成整个文件的分块上传.且在该请求的 Body 中需要给出每一个块的 PartNumber 和 ETag，用来校验块的准 确性.

分块上传适合于在弱网络或高带宽环境下上传较大的对象.SDK 支持自行切分对象并分别调用uploadPart(UploadPartRequest)上传各 个分块.

关于分块上传的描述，请查看 https://cloud.tencent.com/document/product/436/14112.

关于完成整个分片上传接口的描述，请查看 https://cloud.tencent.com/document/product/436/7742.

cos iOS SDK 中完成整个分块上传请求的方法具体步骤如下：

1. 实例化 QCloudCompleteMultipartUploadRequest，填入需要的参数。

2. 调用 QCloudCOSXMLService 对象中的 CompleteMultipartUpload 方法发出请求。

3. 从回调的 finishBlock 中的 QCloudUploadObjectResult 获取具体内容。

示例：
示例：
@code
QCloudCompleteMultipartUploadRequest *completeRequst = [QCloudCompleteMultipartUploadRequest new];
completeRequst.bucket = @"bucketName";
completeRequst.object = @"objectName";
completeRequst.uploadId = @"uploadId"; //本次分片上传的UploadID
[completeRequst setFinishBlock:^(QCloudUploadObjectResult * _Nonnull result, NSError * _Nonnull error) {

}];
[[QCloudCOSXMLService defaultCOSXML] CompleteMultipartUpload:completeRequst];
@endcode
*/
@interface QCloudCompleteMultipartUploadRequest : QCloudBizHTTPRequest
/**
对象名
*/
@property (strong, nonatomic) NSString *object;
/**
存储桶名
*/
@property (strong, nonatomic) NSString *bucket;
/**
本次分片上传的UploadID
*/
@property (strong, nonatomic) NSString *uploadId;
/**
完成分片上传的信息
*/
@property (strong, nonatomic) QCloudCompleteMultipartUploadInfo *parts;



- (void) setFinishBlock:(void (^)(QCloudUploadObjectResult* result, NSError * error))QCloudRequestFinishBlock;
@end
NS_ASSUME_NONNULL_END
