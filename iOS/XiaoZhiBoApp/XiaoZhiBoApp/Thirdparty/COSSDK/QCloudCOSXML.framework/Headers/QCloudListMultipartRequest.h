//
//  ListMultipart.h
//  ListMultipart
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
#import "QCloudListPartsResult.h"
NS_ASSUME_NONNULL_BEGIN
/**
查询特定分块上传中的已上传的块的方法.

COS 支持查询特定分块上传中的已上传的块, 即可以 罗列出指定 UploadId 所属的所有已上传成功的分块. 因此，基于此可以完成续传功能.

关于分块上传的描述，请查看 https://cloud.tencent.com/document/product/436/14112,

关于查询特定分块上传中的已上传块接口的描述，请查看 https://cloud.tencent.com/document/product/436/7747.

cos iOS SDK 中查询特定分块上传中的已上传块请求的方法具体步骤如下：

1. 实例化 QCloudListMultipartRequest，填入需要的参数。
2. 调用 QCloudCOSXMLService 对象中的 ListMultipart 方法发出请求。
3. 从回调的 finishBlock 中的 QCloudListPartsResult 获取具体内容。
示例：
@code
QCloudListMultipartRequest* request = [[QCloudListMultipartRequest alloc] init];
request.bucket = @"bucketName"; //存储桶名称(cos v5 的 bucket格式为：xxx-appid, 如 test-1253960454)
request.object = @"objectName";
request.uploadId = @"uploadID";
[request setFinishBlock:^(QCloudListPartsResult * _Nonnull result, NSError * _Nonnull error) {
//additional actions after finishing
}];
[[QCloudCOSXMLService defaultCOSXML] ListMultipart:request];
@endcode
*/
@interface QCloudListMultipartRequest : QCloudBizHTTPRequest
/**
对象的名称
*/
@property (strong, nonatomic) NSString *object;
/**
存储桶名
*/
@property (strong, nonatomic) NSString *bucket;
/**
标识本次分块上传的uploadId
*/
@property (strong, nonatomic) NSString *uploadId;
/**
单次返回最大的条目数量，默认 1000
*/
@property (strong, nonatomic) NSString *maxPartsCount;
/**
默认以 UTF-8 二进制顺序列出条目，所有列出条目从 marker 开始
*/
@property (strong, nonatomic) NSString *partNumberMarker;
/**
规定返回值的编码方式
*/
@property (strong, nonatomic) NSString *encodingType;


- (void) setFinishBlock:(void (^)(QCloudListPartsResult* result, NSError * error))QCloudRequestFinishBlock;
@end
NS_ASSUME_NONNULL_END
