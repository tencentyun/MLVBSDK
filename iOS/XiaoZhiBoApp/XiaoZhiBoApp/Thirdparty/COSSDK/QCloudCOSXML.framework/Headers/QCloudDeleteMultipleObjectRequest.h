//
//  DeleteMultipleObject.h
//  DeleteMultipleObject
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
#import "QCloudDeleteResult.h"
@class QCloudDeleteInfo;
NS_ASSUME_NONNULL_BEGIN
/**
批量删除 COS 对象的方法.

COS 支持批量删除指定 Bucket 中 对象，单次请求最大支持批量删除 1000 个 对象. 请求中删除一个不存在的对象，仍然认为是成功的. 对于响应结果，COS提供 Verbose 和 Quiet 两种模式：Verbose 模式将返回每个对象的删除结果;Quiet 模式只返回删除报错的对象信息. 请求必须携带 Content-MD5 用来校验请求Body 的完整性.

关于批量删除 COS 对象接口的描述，请查看https://cloud.tencent.com/document/product/436/8289.

cos iOS SDK 中批量删除 COS 对象的方法具体步骤如下：

1. 实例化 QCloudDeleteMultipleObjectRequest，填入需要的参数。

2. 调用 QCloudCOSXMLService 对象中的方法发出请求。

3. 从回调的 finishBlock 中的获取具体内容。

示例：
@code
QCloudDeleteMultipleObjectRequest* delteRequest = [QCloudDeleteMultipleObjectRequest new];
delteRequest.bucket = @"testBucket-123456789";
QCloudDeleteObjectInfo* deletedObject0 = [QCloudDeleteObjectInfo new];
deletedObject0.key = @"第一个对象名";
QCloudDeleteObjectInfo* deleteObject1 = [QCloudDeleteObjectInfo new];
deleteObject1.key = @"第二个对象名";
QCloudDeleteInfo* deleteInfo = [QCloudDeleteInfo new];
deleteInfo.quiet = NO;
deleteInfo.objects = @[ deletedObject0,deleteObject2];
delteRequest.deleteObjects = deleteInfo;
__block NSError* resultError;
[delteRequest setFinishBlock:^(QCloudDeleteResult* outputObject, NSError *error) {
localError = error;
deleteResult = outputObject;
}];

[[QCloudCOSXMLService defaultCOSXML] DeleteMultipleObject:delteRequest];
@endcode
*/
@interface QCloudDeleteMultipleObjectRequest : QCloudBizHTTPRequest
/**
存储桶名称
*/
@property (strong, nonatomic) NSString *bucket;
/**
放置被删除对象的信息
*/
@property (strong, nonatomic) QCloudDeleteInfo *deleteObjects;


- (void) setFinishBlock:(void (^)(QCloudDeleteResult* result, NSError * error))QCloudRequestFinishBlock;
@end
NS_ASSUME_NONNULL_END
