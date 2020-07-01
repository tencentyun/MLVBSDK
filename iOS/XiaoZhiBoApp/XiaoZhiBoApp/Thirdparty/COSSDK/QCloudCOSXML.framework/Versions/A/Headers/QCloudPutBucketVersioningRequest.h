//
//  PutBucketVersioning.h
//  PutBucketVersioning
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
@class QCloudBucketVersioningConfiguration;
NS_ASSUME_NONNULL_BEGIN
/**
存储桶（Bucket）版本控制的方法.

版本管理功能一经打开，只能暂停，不能关闭. 通过版本控制，可以在一个 Bucket 中保留一个对象的多个版本. 版本控制可以防止意外覆盖和删除对象，以便检索早期版本的对象. 默认情况下，版本控制功能处于禁用状态，需要主动去启用或者暂停（Enabled 或者 Suspended）.

cos iOS SDK 中 Bucket 版本控制启用或者暂停的方法具体步骤如下：

1. 实例化 QCloudPutBucketVersioningRequest，填入需要的参数。

2. 调用 QCloudCOSXMLService 对象中的 PutBucketVersioning 方法发出请求。

3. 从回调的 finishBlock 中的 outputObject 获取具体内容。

示例：
@code
QCloudPutBucketVersioningRequest* request = [[QCloudPutBucketVersioningRequest alloc] init];
request.bucket = bucketName;//存储桶名称(cos v5 的 bucket格式为：xxx-appid, 如 test-1253960454)
QCloudBucketVersioningConfiguration* configuration = [[QCloudBucketVersioningConfiguration alloc] init];
request.configuration = configuration;
configuration.status = QCloudCOSBucketVersioningStatusEnabled;
[request setFinishBlock:^(id outputObject, NSError* error) {
//设置完成回调
}];
[[QCloudCOSXMLService defaultCOSXML] PutBucketVersioning:request];
@endcode
*/
@interface QCloudPutBucketVersioningRequest : QCloudBizHTTPRequest
/**
    存储桶名称
    */
@property (strong, nonatomic) NSString *bucket;
/**
    版本控制的具体信息
    */
@property (strong, nonatomic) QCloudBucketVersioningConfiguration *configuration;


@end
NS_ASSUME_NONNULL_END
