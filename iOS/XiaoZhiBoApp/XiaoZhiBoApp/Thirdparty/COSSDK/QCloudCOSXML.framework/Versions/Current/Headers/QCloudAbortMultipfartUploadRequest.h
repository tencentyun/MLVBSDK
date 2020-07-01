//
//  AbortMultipfartUpload.h
//  AbortMultipfartUpload
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
舍弃一个分块上传且删除已上传的分片块的方法.

COS 支持舍弃一个分块上传且删除已上传的分片块. 注意，已上传但是未终止的分片块会占用存储空间进 而产生存储费用.因此，建议及时完成分块上传 或者舍弃分块上传.

关于分块上传的具体描述，请查看 https://cloud.tencent.com/document/product/436/14112.

关于舍弃一个分块上传且删除已上传的分片块接口的描述，请查看 https://cloud.tencent.com/document/product/436/7740.

cos iOS SDK 中舍弃一个分块上传且删除已上传的分片块请求的方法具体步骤如下：

1. 实例化 QCloudAbortMultipfartUploadRequest，填入需要的参数。

2. 调用 QCloudCOSXMLService 对象中的 AbortMultipfartUpload 方法发出请求。

3. 从回调的 finishBlock 中的 outputObject 获取具体内容。
示例：
@code
QCloudAbortMultipfartUploadRequest *abortRequest = [QCloudAbortMultipfartUploadRequest new];
abortRequest.bucket = @"bucketName"; ////存储桶名称(cos v5 的 bucket格式为：xxx-appid, 如 test-1253960454)
abortRequest.object = [[QCloudCOSXMLTestUtility sharedInstance]createCanbeDeleteTestObject];
abortRequest.uploadId = @"uploadId";
[abortRequest setFinishBlock:^(id outputObject, NSError *error) {
//additional actions after finishing
}];
[[QCloudCOSXMLService defaultCOSXML]AbortMultipfartUpload:abortRequest];
@endcode
*/
@interface QCloudAbortMultipfartUploadRequest : QCloudBizHTTPRequest
/**
对象名
*/
@property (strong, nonatomic) NSString *object;
/**
存储桶名
*/
@property (strong, nonatomic) NSString *bucket;
/**
本次分片上传的UploadId
*/
@property (strong, nonatomic) NSString *uploadId;


@end
NS_ASSUME_NONNULL_END
