//
//  HeadObject.h
//  HeadObject
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
获取 COS 对象的元数据信息(meta data)的方法.

获取 COS 对象的元数据信息，需要与 Get 的权限一致.且请求是不返回消息体的.若请求中需要设置If-Modified-Since 头部，则统一采用 GMT(RFC822) 时间格式，例如：Tue, 22 Oct 2017 01:35:21 GMT.如果对象不存在，则 返回404.

关于获取 COS 对象的元数据信息接口的具体描述，请查看https://cloud.tencent.com/document/product/436/7745.

cos iOS SDK 中获取 COS 对象的元数据信息的方法具体步骤如下：

1. 实例化 QCloudHeadObjectRequest，填入需要的参数。

2. 调用 QCloudCOSXMLService 对象中的 HeadObject 方法发出请求。

3. 从回调的 finishBlock 中的获取具体内容。
示例：
@code
QCloudHeadObjectRequest* headerRequest = [QCloudHeadObjectRequest new];
headerRequest.bucket = @"bucketName"; //存储桶名称(cos v5 的 bucket格式为：xxx-appid, 如 test-1253960454)
headerRequest.object = @"objectName";
__block id resultError;
[headerRequest setFinishBlock:^(NSDictionary* result, NSError *error) {
resultError = error;
}];

[[QCloudCOSXMLService defaultCOSXML] HeadObject:headerRequest];
@endcode
*/
@interface QCloudHeadObjectRequest : QCloudBizHTTPRequest
/**
对象的key
*/
@property (strong, nonatomic) NSString *object;
/**
存储桶名
*/
@property (strong, nonatomic) NSString *bucket;
/**
如果HEAD指定版本的Object,请在该参数中指定versionID（在开启了多版本的情况才有）
*/
@property (strong, nonatomic) NSString *versionID;
@property (strong, nonatomic) NSString *ifModifiedSince;


@end
NS_ASSUME_NONNULL_END
