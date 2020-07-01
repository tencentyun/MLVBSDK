//
//  QCloudCOSXMLService+Transfer.h
//  QCloudCOSXML
//
//  Created by erichmzhang(张恒铭) on 07/12/2017.
//

#import <Foundation/Foundation.h>
#import "QCloudCOSXMLService.h"
@class QCloudPutObjectRequest;
@class QCloudGetObjectRequest;
@class QCloudInitiateMultipartUploadRequest;
@class QCloudUploadPartRequest;
@class QCloudListMultipartRequest;
@class QCloudCompleteMultipartUploadRequest;
@class QCloudAbortMultipfartUploadRequest;
@class QCloudHeadObjectRequest;
@class QCloudPutObjectCopyRequest;
@class QCloudUploadPartCopyRequest;
@interface QCloudCOSXMLService (Transfer)
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
- (void) PutObject:(QCloudPutObjectRequest*)request;
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
- (void) GetObject:(QCloudGetObjectRequest*)request;
/**
 初始化分块上传的方法.
 
 使用分块上传对象时，首先要进行初始化分片上传操作，获取对应分块上传的 uploadId，用于后续上传操 作.分块上传适合于在弱网络或高带宽环境下上传较大的对象.SDK 支持自行切分对象并分别调用uploadPart(UploadPartRequest)或者uploadPartAsync(UploadPartRequest, CosXmlResultListener)上传各 个分块.
 
 关于分块上传的描述，请查看 https://cloud.tencent.com/document/product/436/14112.
 
 关于初始化分块上传的描述，请查看 https://cloud.tencent.com/document/product/436/7746.
 
 cos iOS SDK 中初始化分块上传请求的方法具体步骤如下：
 
 1. 实例化 QCloudInitiateMultipartUploadRequest，填入需要的参数。
 
 2. 调用 QCloudCOSXMLService 对象中的 InitiateMultipartUpload 方法发出请求。
 
 3. 从回调的 finishBlock 中的获取具体内容。
 
 示例：
 @code
 QCloudInitiateMultipartUploadRequest* initrequest = [QCloudInitiateMultipartUploadRequest new];
 initrequest.bucket = @"bucketName"; //存储桶名称(cos v5 的 bucket格式为：xxx-appid, 如 test-1253960454)
 initrequest.object = @"objectName"
 
 __block QCloudInitiateMultipartUploadResult* initResult;
 [initrequest setFinishBlock:^(QCloudInitiateMultipartUploadResult* outputObject, NSError *error) {
 initResult = outputObject;
 }];
 [[QCloudCOSXMLService defaultCOSXML] InitiateMultipartUpload:initrequest];
 
 @endcode
 */
- (void) InitiateMultipartUpload:(QCloudInitiateMultipartUploadRequest*)request;
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
- (void) UploadPart:(QCloudUploadPartRequest*)request;
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
- (void) ListMultipart:(QCloudListMultipartRequest*)request;

/**
 完成整个分块上传的方法.
 
 当使用分块上传（uploadPart(UploadPartRequest)）完对象的所有块以后，必须调用该 completeMultiUpload(CompleteMultiUploadRequest) 或者 completeMultiUploadAsync(CompleteMultiUploadRequest, CosXmlResultListener) 来完成整个文件的分块上传.且在该请求的 Body 中需要给出每一个块的 PartNumber 和 ETag，用来校验块的准 确性.
 
 分块上传适合于在弱网络或高带宽环境下上传较大的对象.SDK 支持自行切分对象并分别调用uploadPart(UploadPartRequest)上传各 个分块.
 
 关于分块上传的描述，请查看 https://cloud.tencent.com/document/product/436/14112.
 
 关于完成整个分片上传接口的描述，请查看 https://cloud.tencent.com/document/product/436/7742.
 
 cos iOS SDK 中完成整个分块上传请求的同步方法具体步骤如下：
 
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
 
 */
- (void) CompleteMultipartUpload:(QCloudCompleteMultipartUploadRequest*)request;
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
- (void) AbortMultipfartUpload:(QCloudAbortMultipfartUploadRequest*)request;
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
- (void) HeadObject:(QCloudHeadObjectRequest*)request;
/**
 简单复制对象的方法.
 
 COS 中复制对象可以完成如下功能:
 
 创建一个新的对象副本.
 
 复制对象并更名，删除原始对象，实现重命名
 
 修改对象的存储类型，在复制时选择相同的源和目标对象键，修改存储类型.
 
 在不同的腾讯云 COS 地域复制对象.
 
 修改对象的元数据，在复制时选择相同的源和目标对象键，并修改其中的元数据,复制对象时，默认将继承原对象的元数据，但创建日期将会按新对象的时间计算.
 
 当复制的对象小于等于 5 GB ，可以使用简单复制（https://cloud.tencent.com/document/product/436/14117).
 
 当复制对象超过 5 GB 时，必须使用分块复制（https://cloud.tencent.com/document/product/436/14118 ） 来实现复制.
 
 关于简单复制接口的具体描述，请查看https://cloud.tencent.com/document/product/436/10881.
 
 cos iOS SDK 中简单复制对象的方法具体步骤如下：
 
 1. 实例化 QCloudPutObjectCopyRequest，填入需要的参数。
 
 2. 调用 QCloudCOSXMLService 对象中的 PutObjectCopy 方法发出请求。
 
 3. 从回调的 finishBlock 中的 QCloudCopyObjectResult 获取具体内容。
 
 示例：
 @code
 QCloudPutObjectCopyRequest* request = [[QCloudPutObjectCopyRequest alloc] init];
 request.bucket = @"bucketName";
 request.object = @"objectName";
 request.objectCopySource = @"objectCopySource";
 
 [request setFinishBlock:^(QCloudCopyObjectResult* result, NSError* error) {
 }];
 [[QCloudCOSXMLService defaultCOSXML] PutObjectCopy:request];
 @endcode
 */
- (void) PutObjectCopy:(QCloudPutObjectCopyRequest*)request;

/**
 分块复制的方法.
 
 COS 中复制对象可以完成如下功能:
 
 创建一个新的对象副本.
 
 复制对象并更名，删除原始对象，实现重命名
 
 修改对象的存储类型，在复制时选择相同的源和目标对象键，修改存储类型.
 
 在不同的腾讯云 COS 地域复制对象.
 
 修改对象的元数据，在复制时选择相同的源和目标对象键，并修改其中的元数据,复制对象时，默认将继承原对象的元数据，但创建日期将会按新对象的时间计算.
 
 当复制的对象小于等于 5 GB ，可以使用简单复制（https://cloud.tencent.com/document/product/436/14117).
 
 当复制对象超过 5 GB 时，必须使用分块复制（https://cloud.tencent.com/document/product/436/14118 ） 来实现复制.
 
 关于分块复制接口的具体描述，请查看https://cloud.tencent.com/document/product/436/8287.
 
 cos iOS SDK 中分块复制的方法具体步骤如下：
 
 1. 实例化 QCloudUploadPartCopyRequest，填入需要的参数。
 
 2. 调用 QCloudCOSXMLService 对象中的 UploadPartCopy 方法发出请求。
 
 3. 从回调的 finishBlock 中的 QCloudCopyObjectResult 获取具体内容。
 
 示例：
 @code
 QCloudUploadPartCopyRequest* request = [[QCloudUploadPartCopyRequest alloc] init];
 request.bucket = @"bucketName";
 request.object = @"objectName";
 request.source = @"objectCopySource"; //  源文件 URL 路径，可以通过 versionid 子资源指定历史版本
 request.uploadID = @"uploadID"; // 在初始化分块上传的响应中，会返回一个唯一的描述符（upload ID）
 request.partNumber = 1; // 标志当前分块的序号
 [request setFinishBlock:^(QCloudCopyObjectResult* result, NSError* error) {
 }];
 [[QCloudCOSXMLService defaultCOSXML]UploadPartCopy:request];
 @endcode
 */
- (void) UploadPartCopy:(QCloudUploadPartCopyRequest*)request;

@end
