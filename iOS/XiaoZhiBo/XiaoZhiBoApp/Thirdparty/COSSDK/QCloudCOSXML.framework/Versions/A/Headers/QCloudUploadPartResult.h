//
//  QCloudUploadPartResult.h
//  QCloudUploadPartResult
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
@interface QCloudUploadPartResult : NSObject
/**
上传一个分片块的方法.

使用分块上传时，可将对象切分成一个个分块的方式上传到 COS，每个分块上传需要携带分块号（partNumber） 和 uploadId（initMultipartUpload(InitMultipartUploadRequest)）， 每个分块大小为 1 MB 到 5 GB ，最后一个分块可以小于 1 MB, 若传入 uploadId 和 partNumber都相同， 后传入的块将覆盖之前传入的块，且支持乱序上传.

关于分块上传的描述，请查看 https://cloud.tencent.com/document/product/436/14112.

关于上传一个对象的分块接口的描述，请查看 https://cloud.tencent.com/document/product/436/7750.

cos iOS SDK 中上传一个对象某个分片块请求的方法具体步骤如下：

1. 实例化 QCloudUploadPartRequest，填入需要的参数。

2. 调用 QCloudCOSXMLService 对象中的 UploadPart 方法发出请求。

3. 从回调的 finishBlock 中的 QCloudUploadPartResult 获取具体内容。
示例：
@code
QCloudUploadPartRequest *partRequest = [QCloudUploadPartRequest new];
partRequest.bucket = @"bucketName";
partRequest.object = @"object";
partRequest.uploadId = @"uploadId"; //标识本次分块上传的 ID；
使用 Initiate Multipart Upload 接口初始化分片上传时会得到一个 uploadId，该 ID 不但唯一标识这一分块数据，也标识了这分块数据在整个文件内的相对位置
partRequest.partNumber = 1; //标识本次分块上传的编号
[partRequest setFinishBlock:^(QCloudUploadPartResult * _Nonnull result, NSError * _Nonnull error) {
}];
[[QCloudCOSXMLService defaultCOSXML]UploadPart:partRequest];
@endcode
*/
@property (strong, nonatomic) NSString *eTag;
@end
NS_ASSUME_NONNULL_END
