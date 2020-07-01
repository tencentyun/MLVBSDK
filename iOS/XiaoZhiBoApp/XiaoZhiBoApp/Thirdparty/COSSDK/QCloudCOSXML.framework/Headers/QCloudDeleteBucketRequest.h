//
//  DeleteBucket.h
//  DeleteBucket
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
删除存储桶 (Bucket)的方法.

COS 目前仅支持删除已经清空的 Bucket，如果 Bucket 中仍有对象，将会删除失败. 因此，在执行删除 Bucket 前，需确保 Bucket 内已经没有对象. 删除 Bucket 时，还需要确保操作的身份已被授权该操作，并确认 传入了正确的存储桶名称和地域参数, 请参阅 putBucket(PutBucketRequest).

关于删除 Bucket 的描述,请查看 https://cloud.tencent.com/document/product/436/14105.

关于删除 Bucket 接口的具体描述，请查看https://cloud.tencent.com/document/product/436/7732.

cos iOS SDK 中删除 Bucket 的方法具体步骤如下：

1. 实例化 QCloudDeleteBucketRequest，填入需要的参数。

2. 调用 QCloudCOSXMLService 对象中的 DeleteBucket 方法发出请求。

3. 从回调的 finishBlock 中的 outputObject 获取具体内容。

示例：
@code
QCloudDeleteBucketRequest* request = [[QCloudDeleteBucketRequest alloc ] init];
request.bucket = bucketName;  //存储桶名称(cos v5 的 bucket格式为：xxx-appid, 如 test-1253960454)
[request setFinishBlock:^(id outputObject,NSError*error) {
//additional actions after finishing
}];
[[QCloudCOSXMLService defaultCOSXML] DeleteBucket:request];
@endcode
*/
@interface QCloudDeleteBucketRequest : QCloudBizHTTPRequest
/**
要删除的存储桶名。注意删除之前要求bucket里的内容为空。
*/
@property (strong, nonatomic) NSString *bucket;


@end
NS_ASSUME_NONNULL_END
