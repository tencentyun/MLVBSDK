//
//  QCloudCOSXMLService+Manager.h
//  QCloudCOSXML
//
//  Created by erichmzhang(张恒铭) on 07/12/2017.
//

#import <QCloudCOSXML/QCloudCOSXML.h>
#import "QCloudCOSStorageClassEnum.h"
@class QCloudAppendObjectRequest;
@class QCloudGetObjectACLRequest;
@class QCloudPutObjectACLRequest;
@class QCloudDeleteObjectRequest;
@class QCloudDeleteMultipleObjectRequest;
@class QCloudHeadObjectRequest;
@class QCloudOptionsObjectRequest;

@class QCloudAbortMultipfartUploadRequest;
@class QCloudGetBucketRequest;
@class QCloudGetBucketACLRequest;
@class QCloudGetBucketCORSRequest;
@class QCloudGetBucketLocationRequest;
@class QCloudGetBucketLifecycleRequest;
@class QCloudPutBucketRequest;
@class QCloudPutBucketACLRequest;
@class QCloudPutBucketCORSRequest;
@class QCloudPutBucketLifecycleRequest;
@class QCloudDeleteBucketRequest;
@class QCloudDeleteBucketCORSRequest;
@class QCloudDeleteBucketLifeCycleRequest;
@class QCloudHeadBucketRequest;
@class QCloudListBucketMultipartUploadsRequest;
@class QCloudPutObjectCopyRequest;
@class QCloudDeleteBucketRequest;
@class QCloudPutBucketVersioningRequest;
@class QCloudGetBucketVersioningRequest;
@class QCloudPutBucketReplicationRequest;
@class QCloudGetBucketReplicationRequest;
@class QCloudDeleteBucketReplicationRequest;
@class QCloudGetServiceRequest;
@class QCloudUploadPartCopyRequest;
@class QCloudPostObjectRestoreRequest;
@class QCloudListObjectVersionsRequest;
@class QCloudGetPresignedURLRequest;

@interface QCloudCOSXMLService (Manager)
/**
 Android没有
 */
- (void) AppendObject:(QCloudAppendObjectRequest*)request;
/**
 获取 COS 对象的访问权限信息（Access Control List, ACL）的方法.
 
 Bucket 的持有者可获取该 Bucket 下的某个对象的 ACL 信息，如被授权者以及被授权的信息. ACL 权限包括读、写、读写权限.
 
 关于获取 COS 对象的 ACL 接口的具体描述，请查看https://cloud.tencent.com/document/product/436/7744.
 
 cos iOS SDK 中获取 COS 对象的 ACL 的方法具体步骤如下：
 
 1. 实例化 QCloudGetObjectACLRequest，填入存储桶的名称，和需要查询对象的名称。
 
 2. 调用 QCloudCOSXMLService 对象中的 GetObjectACL 方法发出请求。
 
 3. 从回调的 finishBlock 中的获取的 QCloudACLPolicy 对象中获取封装好的 ACL 的具体信息。
 
 示例：
 @code
 QCloudGetObjectACLRequest* request = [QCloudGetObjectACLRequest new];
 request.bucket = @“bucketName"; //存储桶名称(cos v5 的 bucket格式为：xxx-appid, 如 test-1253960454)
 request.object = @"objectName";
 [request setFinishBlock:^(QCloudACLPolicy * _Nonnull policy, NSError * _Nonnull error) {
 //从 QCloudACLPolicy 对象中获取封装好的 ACL 的具体信息
 }];
 [[QCloudCOSXMLService defaultCOSXML] GetObjectACL:request];
 @endcode
 */
- (void) GetObjectACL:(QCloudGetObjectACLRequest*)request;
/**
 设置 COS 对象的访问权限信息（Access Control List, ACL）的方法.
 
 ACL权限包括读、写、读写权限. COS 对象的 ACL 可以通过 header头部："x-cos-acl"，"x-cos-grant-read"，"x-cos-grant-write"， "x-cos-grant-full-control" 传入 ACL 信息，或者通过 Body 以 XML 格式传入 ACL 信息.这两种方式只 能选择其中一种，否则引起冲突. 传入新的 ACL 将覆盖原有 ACL信息.ACL策略数上限1000，建议用户不要每个上传文件都设置 ACL.
 
 关于设置 COS 对象的ACL接口的具体描述，请查看https://cloud.tencent.com/document/product/436/7748.
 
 cos iOS SDK 中设置 COS 对象的 ACL 的方法具体步骤如下：
 
 1. 实例化 QCloudPutObjectACLRequest，填入存储桶名，和一些额外需要的参数，如授权的具体信息等。
 
 2. 调用 QCloudCOSXMLService 对象中的方法发出请求。
 
 3. 从回调的 finishBlock 中获取设置的完成情况，若 error 为空，则设置成功。
 
 示例：
 @code
 QCloudPutObjectACLRequest* request = [QCloudPutObjectACLRequest new];
 request.object = @"需要设置 ACL 的对象名";
 request.bucket = @"testBucket-123456789";
 NSString *ownerIdentifier = [NSString stringWithFormat:@"qcs::cam::uin/%@:uin/%@",self.appID, self.appID];
 NSString *grantString = [NSString stringWithFormat:@"id=\"%@\"",ownerIdentifier];
 request.grantFullControl = grantString;
 __block NSError* localError;
 [request setFinishBlock:^(id outputObject, NSError *error) {
 localError = error;
 }];
 [[QCloudCOSXMLService defaultCOSXML] PutObjectACL:request];
 @endcode
 */
- (void) PutObjectACL:(QCloudPutObjectACLRequest*)request;
/**
 删除 COS 上单个对象的方法.
 
 COS 支持直接删除一个或多个对象，当仅需要删除一个对象时,只需要提供对象的名称（即对象键)即可.
 
 关于删除 COS 上单个对象的具体描述，请查看 https://cloud.tencent.com/document/product/436/14119.
 
 关于删除 COS 上单个对象接口的具体描述，请查看 https://cloud.tencent.com/document/product/436/7743.
 
 cos iOS SDK 中删除 COS 上单个对象请求的方法具体步骤如下：
 
 1. 实例化 QCloudDeleteObjectRequest，填入需要的参数。
 
 2. 调用 QCloudCOSXMLService 对象中的 DeleteObject 方法发出请求。
 
 3. 从回调的 finishBlock 中的 outputObject 获取具体内容。
 示例：
 @code
 QCloudDeleteObjectRequest* deleteObjectRequest = [QCloudDeleteObjectRequest new];
 deleteObjectRequest.bucket = self.bucket;
 deleteObjectRequest.object = @"objectName";
 [deleteObjectRequest setFinishBlock:^(id outputObject, NSError *error) {
 //additional actions after finishing
 }];
 [[QCloudCOSXMLService defaultCOSXML] DeleteObject:deleteObjectRequest];
 @endcode
 */
- (void) DeleteObject:(QCloudDeleteObjectRequest*)request;
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
- (void) DeleteMultipleObject:(QCloudDeleteMultipleObjectRequest*)request;
/**
 COS 对象的跨域访问配置预请求的方法.
 
 跨域访问配置的预请求是指在发送跨域请求之前会发送一个 OPTIONS 请求并带上特定的来源域，HTTP 方法 和 header 信息等给 COS，以决定是否可以发送真正的跨域请求. 当跨域访问配置不存在时，请求返回403 Forbidden. 跨域访问配置可以通过 putBucketCORS(PutBucketCORSRequest) 或者 putBucketCORSAsync(PutBucketCORSRequest, CosXmlResultListener) 方法来开启 Bucket 的跨域访问 支持.
 
 关于COS 对象的跨域访问配置预请求接口的具体描述，请查看https://cloud.tencent.com/document/product/436/8288.
 
 cos iOS SDK 中发起COS 对象的跨域访问配置预请求的方法具体步骤如下：
 
 1. 实例化 QCloudOptionsObjectRequest，填入需要设置的对象名、存储桶名、模拟跨域访问请求的 http 方法和模拟跨域访问允许的访问来源。
 
 2. 调用 QCloudCOSXMLService 对象中的方法发出请求。
 
 3. 从回调的 finishBlock 中的获取具体内容。
 
 示例：
 @code
 QCloudOptionsObjectRequest* request = [[QCloudOptionsObjectRequest alloc] init];
 request.bucket =@"存储桶名";
 request.origin = @"*";
 request.accessControlRequestMethod = @"get";
 request.accessControlRequestHeaders = @"host";
 request.object = @"对象名";
 __block id resultError;
 [request setFinishBlock:^(id outputObject, NSError* error) {
 resultError = error;
 }];
 [[QCloudCOSXMLService defaultCOSXML] OptionsObject:request];
 @endcode
 */
- (void) OptionsObject:(QCloudOptionsObjectRequest*)request;

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
 创建存储桶（Bucket）的方法.
 
 在开始使用 COS 时，需要在指定的账号下先创建一个 Bucket 以便于对象的使用和管理. 并指定 Bucket 所属的地域.创建 Bucket 的用户默认成为 Bucket 的持有者.若创建 Bucket 时没有指定访问权限，则默认 为私有读写（private）权限.
 
 可用地域，可以查看https://cloud.tencent.com/document/product/436/6224.
 
 关于创建 Bucket 描述，请查看 https://cloud.tencent.com/document/product/436/14106.
 
 关于创建存储桶（Bucket）接口的具体 描述，请查看 https://cloud.tencent.com/document/product/436/7738.
 
 cos iOS SDK 中创建 Bucket的方法具体步骤如下：
 
 1. 实例化 QCloudPutBucketRequest，填入需要的参数。
 
 2. 调用 QCloudCOSXMLService 对象中的 PutBucket 方法发出请求。
 
 3. 从回调的 finishBlock 中的 outputObject 获取具体内容。
 
 示例：
 @code
 QCloudPutBucketRequest* request = [QCloudPutBucketRequest new];
 request.bucket = bucketName; //additional actions after finishing
 [request setFinishBlock:^(id outputObject, NSError* error) {
 
 }];
 [[QCloudCOSXMLService defaultCOSXML] PutBucket:request];
 @endcode
 */
- (void) PutBucket:(QCloudPutBucketRequest*)request;
/**
 查询存储桶（Bucket) 下的部分或者全部对象的方法.
 
 COS 支持列出指定 Bucket 下的部分或者全部对象.
 
 每次默认返回的最大条目数为 1000 条.
 
 如果无法一次返回所有的对象，则返回结果中的 IsTruncated 为 true，同时会附加一个 NextMarker 字段，提示下 一个条目的起点.
 
 若一次请求，已经返回了全部对象，则不会有 NextMarker 这个字段，同时 IsTruncated 为 false.
 
 若把 prefix 设置为某个文件夹的全路径名，则可以列出以此 prefix 为开头的文件，即该文件 夹下递归的所有文件和子文件夹.
 
 如果再设置 delimiter 定界符为 “/”，则只列出该文件夹下的文件，子文件夹下递归的文件和文件夹名 将不被列出.而子文件夹名将会以 CommonPrefix 的形式给出.
 
 关于查询Bucket 下的部分或者全部对象接口的具体描述，请查看https://cloud.tencent.com/document/product/436/7734.
 
 cos iOS SDK 中查询 Bucket 下的部分或者全部对象的方法具体步骤如下：
 
 1. 实例化 QCloudGetBucketRequest，填入需要的参数。
 
 2. 调用 QCloudCOSXMLService 对象中的 GetBucket 方法发出请求。
 
 3. 从回调的 finishBlock 中的 QCloudListBucketResult 获取具体内容。
 
 示例：
 @code
 QCloudGetBucketRequest* request = [QCloudGetBucketRequest new];
 request.bucket = @“testBucket-123456789”; //存储桶名称(cos v5 的 bucket格式为：xxx-appid, 如 test-1253960454)
 request.maxKeys = 1000;
 [request setFinishBlock:^(QCloudListBucketResult * result, NSError*   error) {
 //additional actions after finishing
 }];
 [[QCloudCOSXMLService defaultCOSXML] GetBucket:request];
 @endcode
 */
- (void) GetBucket:(QCloudGetBucketRequest*)request;
/**
 获取存储桶（Bucket) 的访问权限信息（Access Control List, ACL）的方法.
 
 ACL 权限包括读、写、读写权限. COS 中 Bucket 是有访问权限控制的.可以通过获取 Bucket 的 ACL 表(putBucketACL(PutBucketACLRequest))，来查看那些用户拥有 Bucket 访 问权限.
 
 关于获取 Bucket 的 ACL 接口的具体描述，请查看 https://cloud.tencent.com/document/product/436/7733.
 
 cos iOS SDK 中获取 Bucket 的 ACL 的方法具体步骤如下：
 
 1. 实例化 QCloudGetBucketACLRequest，填入获取 ACL 的存储桶。
 
 2. 调用 QCloudCOSXMLService 对象中的 GetBucketACL 方法发出请求。
 
 3. 从回调的 finishBlock 中的 QCloudACLPolicy 获取具体内容。
 
 示例：
 @code
 QCloudGetBucketACLRequest* getBucketACl   = [QCloudGetBucketACLRequest new];
 getBucketACl.bucket = @"testbucket-123456789";
 [getBucketACl setFinishBlock:^(QCloudACLPolicy * _Nonnull result, NSError * _Nonnull error) {
 //QCloudACLPolicy中包含了 Bucket 的 ACL 信息。
 }];
 
 [[QCloudCOSXMLService defaultCOSXML] GetBucketACL:getBucketACl];
 @endcode
 */
- (void) GetBucketACL:(QCloudGetBucketACLRequest*)request;
/**
 查询存储桶（Bucket) 跨域访问配置信息的方法.
 
 COS 支持查询当前 Bucket 跨域访问配置信息，以确定是否配置跨域信息.当跨域访问配置不存在时，请求 返回403 Forbidden. 跨域访问配置可以通过 putBucketCORS(PutBucketCORSRequest) 或者 putBucketCORSAsync(PutBucketCORSRequest, CosXmlResultListener) 方法来开启 Bucket 的跨域访问 支持.
 
 关于查询 Bucket 跨域访问配置信息接口的具体描述， 请查看 https://cloud.tencent.com/document/product/436/8274.
 
 cos iOS SDK 中查询 Bucket 跨域访问配置信息的方法具体步骤如下：
 
 1. 实例化 QCloudGetBucketCORSRequest，填入需要获取 CORS 的存储桶。
 
 2. 调用 QCloudCOSXMLService 对象中的 GetBucketCORS 方法发出请求。
 
 3. 从回调的 finishBlock 中获取结果。结果封装在了 QCloudCORSConfiguration 对象中，该对象的 rules 属性是一个数组，数组里存放着一组 QCloudCORSRule，具体的 CORS 设置就封装在 QCloudCORSRule 对象里。
 
 
 示例：
 
 @code
 QCloudGetBucketCORSRequest* corsReqeust = [QCloudGetBucketCORSRequest new];
 corsReqeust.bucket = @"testBucket-123456789";
 
 [corsReqeust setFinishBlock:^(QCloudCORSConfiguration * _Nonnull result, NSError * _Nonnull error) {
 //CORS设置封装在result中。
 }];
 
 [[QCloudCOSXMLService defaultCOSXML] GetBucketCORS:corsReqeust];
 @endcode
 */
- (void) GetBucketCORS:(QCloudGetBucketCORSRequest*)request;
/**
 获取存储桶（Bucket) 所在的地域信息的方法.
 
 在创建 Bucket 时，需要指定所属该 Bucket 所属地域信息.
 
 COS 支持的地域信息，可查看https://cloud.tencent.com/document/product/436/6224.
 
 关于获取 Bucket 所在的地域信息接口的具体描述，请查看https://cloud.tencent.com/document/product/436/8275.
 
 cos iOS SDK 中获取 Bucket 所在的地域信息的方法具体步骤如下：
 
 1. 实例化 QCloudGetBucketLocationRequest，填入需要的参数。
 
 2. 调用 QCloudCOSXMLService 对象中的 GetBucketLocation 方法发出请求。
 
 3. 从回调的 finishBlock 中的 QCloudBucketLocationConstraint 获取具体内容。
 
 示例：
 @code
 QCloudGetBucketLocationRequest* locationReq = [QCloudGetBucketLocationRequest new];
 locationReq.bucket = @"bucketName";//存储桶名称(cos v5 的 bucket格式为：xxx-appid, 如 test-1253960454)
 __block QCloudBucketLocationConstraint* location;
 [locationReq setFinishBlock:^(QCloudBucketLocationConstraint * _Nonnull result, NSError * _Nonnull error) {
 location = result;
 }];
 [[QCloudCOSXMLService defaultCOSXML] GetBucketLocation:locationReq];
 @endcode
 */
- (void) GetBucketLocation:(QCloudGetBucketLocationRequest*)request;
/**
 查询存储桶（Bucket) 的生命周期配置的方法.
 
 COS 支持以生命周期配置的方式来管理 Bucket 中对象的生命周期，生命周期配置包含一个或多个将 应用于一组对象规则的规则集 (其中每个规则为 COS 定义一个操作)，请参阅 putBucketLifecycle(PutBucketLifecycleRequest).
 
 关于查询 Bucket 的生命周期配置接口的具体描述，请查看https://cloud.tencent.com/document/product/436/8278.
 
 cos iOS SDK 中查询 Bucket 的生命周期配置的方法具体步骤如下：
 
 1. 实例化 QCloudGetBucketLifecycleRequest，填入需要的参数。
 
 2. 调用 QCloudCOSXMLService 对象中的 GetBucketLifecycle 方法发出请求。
 
 3. 从回调的 finishBlock 中的 QCloudLifecycleConfiguration 获取具体内容。
 
 示例：
 @code
 QCloudGetBucketLifecycleRequest* request = [QCloudGetBucketLifecycleRequest new];
 request.bucket = bucketName; //存储桶名称(cos v5 的 bucket格式为：xxx-appid, 如 test-1253960454)
 [request setFinishBlock:^(QCloudLifecycleConfiguration* result,NSError* error) {
 //设置完成回调
 }];
 [[QCloudCOSXMLService defaultCOSXML] GetBucketLifecycle:request];
 @endcode
 */
- (void) GetBucketLifecycle:(QCloudGetBucketLifecycleRequest*)request;

/**
 设置存储桶（Bucket） 的访问权限（Access Control List, ACL)的方法.
 
 ACL 权限包括读、写、读写权限. 写入 Bucket 的 ACL 可以通过 header头部："x-cos-acl"，"x-cos-grant-read"，"x-cos-grant-write"， "x-cos-grant-full-control" 传入 ACL 信息，或者通过 Body 以 XML 格式传入 ACL 信息.这两种方式只 能选择其中一种，否则引起冲突. 传入新的 ACL 将覆盖原有 ACL信息. 私有 Bucket 可以下可以给某个文件夹设置成公有，那么该文件夹下的文件都是公有；但是把文件夹设置成私有后，在该文件夹下的文件设置 的公有属性，不会生效.
 
 关于设置 Bucket 的ACL接口的具体描述，请查看 https://cloud.tencent.com/document/product/436/7737.
 
 cos iOS SDK 中设置 Bucket 的ACL的方法具体步骤如下：
 
 1. 实例化 QCloudPutBucketACLRequest，填入需要设置的存储桶，然后根据设置值的权限类型分别填入不同的参数。
 
 2. 调用 QCloudCOSXMLService 对象中的 PutBucketACL 方法发出请求。
 
 3. 从回调的 finishBlock 中的获取设置是否成功，并做设置成功后的一些额外动作。
 
 示例：
 @code
 QCloudPutBucketACLRequest* putACL = [QCloudPutBucketACLRequest new];
 NSString* appID = kAppID;
 NSString *ownerIdentifier = [NSString stringWithFormat:@"qcs::cam::uin/%@:uin/%@", appID, appID];
 NSString *grantString = [NSString stringWithFormat:@"id=\"%@\"",ownerIdentifier];
 putACL.accessControlList = @"private";
 putACL.grantFullControl = grantString;
 putACL.bucket = bucketName; //存储桶名称(cos v5 的 bucket格式为：xxx-appid, 如 test-1253960454)
 [putACL setFinishBlock:^(id outputObject, NSError *error) {
 //additional actions after finishing
 }];
 [[QCloudCOSXMLService defaultCOSXML] PutBucketACL:putACL];
 @endcode
 */
- (void) PutBucketACL:(QCloudPutBucketACLRequest*)request;
/**
 设置存储桶（Bucket） 的跨域配置信息的方法.
 
 跨域访问配置的预请求是指在发送跨域请求之前会发送一个 OPTIONS 请求并带上特定的来源域，HTTP 方 法和 header 信息等给 COS，以决定是否可以发送真正的跨域请求. 当跨域访问配置不存在时，请求返回403 Forbidden.
 
 默认情况下，Bucket的持有者可以直接配置 Bucket的跨域信息 ，Bucket 持有者也可以将配置权限授予其他用户.新的配置是覆盖当前的所有配置信 息，而不是新增一条配置.可以通过传入 XML 格式的配置文件来实现配置，文件大小限制为64 KB.
 
 关于设置 Bucket 的跨域配置信息接口的具体描述，请查看 https://cloud.tencent.com/document/product/436/8279.
 
 cos iOS SDK 中设置 Bucket 的跨域配置信息的方法具体步骤如下：
 
 1. 实例化 QCloudPutBucketCORSRequest，填入需要获取 CORS 的存储桶。
 
 2. 调用 QCloudCOSXMLService 对象中的 PutBucketCORS 方法发出请求。
 
 3. 从回调的 finishBlock 中获取结果。结果封装在了 QCloudCORSConfiguration 对象中，该对象的 rules 属性是一个数组，数组里存放着一组 QCloudCORSRule，具体的 CORS 设置就封装在 QCloudCORSRule 对象里。
 
 示例：
 @code
 QCloudPutBucketCORSRequest* putCORS = [QCloudPutBucketCORSRequest new];
 QCloudCORSConfiguration* cors = [QCloudCORSConfiguration new];
 
 QCloudCORSRule* rule = [QCloudCORSRule new];
 rule.identifier = @"sdk";
 rule.allowedHeader = @[@"origin",@"host",@"accept",@"content-type",@"authorization"];
 rule.exposeHeader = @"ETag";
 rule.allowedMethod = @[@"GET",@"PUT",@"POST", @"DELETE", @"HEAD"];
 rule.maxAgeSeconds = 3600;
 rule.allowedOrigin = @"*";
 
 cors.rules = @[rule];
 
 putCORS.corsConfiguration = cors;
 putCORS.bucket = @"testBucket-123456789";
 [putCORS setFinishBlock:^(id outputObject, NSError *error) {
 if (!error) {
 //success
 }
 }];
 [[QCloudCOSXMLService defaultCOSXML] PutBucketCORS:putCORS];
 @endcode
 */
- (void) PutBucketCORS:(QCloudPutBucketCORSRequest*)request;
/**
 设置存储桶（Bucket) 生命周期配置的方法.
 
 COS 支持以生命周期配置的方式来管理 Bucket 中对象的生命周期. 如果该 Bucket 已配置生命周期，新的配置的同时则会覆盖原有的配置. 生命周期配置包含一个或多个将应用于一组对象规则的规则集 (其中每个规则为 COS 定义一个操作)。这些操作分为以下两种：转换操作，过期操作.
 
 转换操作,定义对象转换为另一个存储类的时间(例如，您可以选择在对象创建 30 天后将其转换为低频存储类别，同 时也支持将数据沉降到归档存储类别.
 
 过期操作，指定 Object 的过期时间，COS 将会自动为用户删除过期的 Object.
 
 关于Bucket 生命周期配置接口的具体描述，请查看 https://cloud.tencent.com/document/product/436/8280
 
 cos iOS SDK 中Bucket 生命周期配置的方法具体步骤如下：
 
 1. 实例化 QCloudPutBucketLifecycleRequest，填入需要的参数。
 
 2. 调用 QCloudCOSXMLService 对象中的 PutBucketLifecycle 方法发出请求。
 
 3. 从回调的 finishBlock 中的 outputObject 获取具体内容。
 
 示例：
 @code
 QCloudPutBucketLifecycleRequest* request = [QCloudPutBucketLifecycleRequest new];
 request.bucket = bukcetName;
 __block QCloudLifecycleConfiguration* configuration = [[QCloudLifecycleConfiguration alloc] init];
 QCloudLifecycleRule* rule = [[QCloudLifecycleRule alloc] init];
 rule.identifier = @"identifier";
 rule.status = QCloudLifecycleStatueEnabled;
 QCloudLifecycleRuleFilter* filter = [[QCloudLifecycleRuleFilter alloc] init];
 filter.prefix = @"0";
 rule.filter = filter;
 QCloudLifecycleTransition* transition = [[QCloudLifecycleTransition alloc] init];
 transition.days = 100;
 transition.storageClass = QCloudCOSStorageNearline;
 rule.transition = transition;
 request.lifeCycle = configuration;
 request.lifeCycle.rules = @[rule];
 [request setFinishBlock:^(id outputObject, NSError* error) {
 //设置完成回调
 }];
 [[QCloudCOSXMLService defaultCOSXML] PutBucketLifecycle:request];
 @endcode
 */
- (void) PutBucketLifecycle:(QCloudPutBucketLifecycleRequest*)request;

/**
 删除跨域访问配置信息的方法.
 
 若是 Bucket 不需要支持跨域访问配置，可以调用此接口删除已配置的跨域访问信息. 跨域访问配置可以通过 putBucketCORS(PutBucketCORSRequest) 或者 putBucketCORSAsync(PutBucketCORSRequest, CosXmlResultListener) 方法来开启 Bucket 的跨域访问 支持.
 
 关于删除跨域访问配置信息接口的具体描述，请查看https://cloud.tencent.com/document/product/436/8283.
 
 cos ios SDK 中删除跨域访问配置信息的方法具体步骤如下：
 
 1. 实例化 QCloudDeleteBucketCORSRequest，填入需要的参数。
 
 2. 调用 QCloudCOSXMLService 对象中的 DeleteBucketCORS 方法发出请求。
 
 3. 从回调的 finishBlock 中的 outputObject 获取具体内容。
 
 示例：
 @code
 QCloudDeleteBucketCORSRequest* deleteCORS = [QCloudDeleteBucketCORSRequest new];
 deleteCORS.bucket = bucketName; //存储桶名称(cos v5 的 bucket格式为：xxx-appid, 如 test-1253960454)
 __block NSError* localError;
 XCTestExpectation* exp = [self expectationWithDescription:@"putacl"];
 [deleteCORS setFinishBlock:^(id outputObject, NSError *error) {
 //additional actions after finishing
 }];
 [[QCloudCOSXMLService defaultCOSXML] DeleteBucketCORS:deleteCORS];
 @endcode
 */
- (void) DeleteBucketCORS:(QCloudDeleteBucketCORSRequest*)request;
/**
 删除存储桶（Bucket） 的生命周期配置的方法.
 
 COS 支持删除已配置的 Bucket 的生命周期列表. COS 支持以生命周期配置的方式来管理 Bucket 中 对象的生命周期，生命周期配置包含一个或多个将 应用于一组对象规则的规则集 (其中每个规则为 COS 定义一个操作)，请参阅 putBucketLifecycle(PutBucketLifecycleRequest).
 
 关于删除 Bucket 的生命周期配置接口的具体描述，请查看https://cloud.tencent.com/document/product/436/8284.
 
 cos iOS SDK 中删除 Bucket 的生命周期配置的方法具体步骤如下：
 
 实例化 QCloudDeleteBucketLifeCycleRequest，填入需要的参数。
 
 调用 QCloudCOSXMLService 对象中的 DeleteBucketLifeCycle 方法发出请求。
 
 从回调的 finishBlock 中的 QCloudLifecycleConfiguration 获取具体内容。
 
 示例：
 @code
 QCloudDeleteBucketLifeCycleRequest* request = [[QCloudDeleteBucketLifeCycleRequest alloc ] init];
 request.bucket = bucketName; // //存储桶名称(cos v5 的 bucket格式为：xxx-appid, 如 test-1253960454)
 [request setFinishBlock:^(QCloudLifecycleConfiguration* deleteResult, NSError* deleteError) {
 // additional actions after finishing
 }];
 [[QCloudCOSXMLService defaultCOSXML] DeleteBucketLifeCycle:request];
 }
 @endcode
 */
- (void) DeleteBucketLifeCycle:(QCloudDeleteBucketLifeCycleRequest*)request;
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
- (void) DeleteBucket:(QCloudDeleteBucketRequest*)request;
/**
 存储桶（Bucket） 是否存在的方法.
 
 在开始使用 COS 时，需要确认该 Bucket 是否存在，是否有权限访问.若不存在，则可以调用putBucket(PutBucketRequest) 创建.
 
 关于确认该 Bucket 是否存在，是否有权限访问接口的具体描述，请查看https://cloud.tencent.com/document/product/436/7735.
 
 cos iOS SDK 中Bucket 是否存在的方法具体步骤如下：
 
 1. 实例化 QCloudHeadBucketRequest，填入需要的参数。
 
 2. 调用 QCloudCOSXMLService 对象中的 HeadBucket 方法发出请求。
 
 3. 从回调的 finishBlock 中的 outputObject 获取具体内容。
 
 示例：
 @code
 QCloudHeadBucketRequest* request = [QCloudHeadBucketRequest new];
 request.bucket = bucketName; //存储桶名称(cos v5 的 bucket格式为：xxx-appid, 如 test-1253960454)
 [request setFinishBlock:^(id outputObject, NSError* error) {
 //设置完成回调。如果没有error，则可以正常访问bucket。如果有error，可以从error code和messasge中获取具体的失败原因。
 }];
 [[QCloudCOSXMLService defaultCOSXML] HeadBucket:request];
 @endcode
 */
- (void) HeadBucket:(QCloudHeadBucketRequest*)request;
/**
 查询存储桶（Bucket）中正在进行中的分块上传对象的方法.
 
 COS 支持查询 Bucket 中有哪些正在进行中的分块上传对象，单次请求操作最多列出 1000 个正在进行中的 分块上传对象.
 
 关于查询 Bucket 中正在进行中的分块上传对象接口的具体描述，请查看 https://cloud.tencent.com/document/product/436/7736.
 
 cos iOS SDK 中查询 Bucket 中正在进行中的分块上传对象的方法具体步骤如下：
 
 1. 实例化 QCloudListBucketMultipartUploadsRequest，填入需要的参数，如返回结果的前缀、编码方式等。
 
 2. 调用 QCloudCOSXMLService 对象中的 ListBucketMultipartUploads 方法发出请求。
 
 3. 从回调的 finishBlock 中的获取具体内容。
 示例：
 
 QCloudListBucketMultipartUploadsRequest* uploads = [QCloudListBucketMultipartUploadsRequest new];
 uploads.bucket = @"testBucket-123456789";
 uploads.maxUploads = 100;
 __block NSError* resulError;
 __block QCloudListMultipartUploadsResult* multiPartUploadsResult;
 [uploads setFinishBlock:^(QCloudListMultipartUploadsResult* result, NSError *error) {
 multiPartUploadsResult = result;
 localError = error;
 }];
 [[QCloudCOSXMLService defaultCOSXML] ListBucketMultipartUploads:uploads];
 */
- (void) ListBucketMultipartUploads:(QCloudListBucketMultipartUploadsRequest*)request;
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
- (void) PutBucketVersioning:(QCloudPutBucketVersioningRequest*)request;
/**
 获取存储桶（Bucket）版本控制信息的方法.
 
 通过查询版本控制信息，可以得知该 Bucket 的版本控制功能是处于禁用状态还是启用状态（Enabled 或者 Suspended）, 开启版本控制功能，可参考putBucketVersioning(PutBucketVersioningRequest).
 
 cos iOS SDK 中获取 Bucket 版本控制信息的方法具体步骤如下：
 
 1. 实例化 QCloudGetBucketVersioningRequest，填入需要的参数。
 
 2. 调用 QCloudCOSXMLService 对象中的 GetBucketVersioning 方法发出请求。
 
 3. 从回调的 finishBlock 中的 QCloudBucketVersioningConfiguration 获取具体内容。
 
 示例：
 @code
 QCloudGetBucketVersioningRequest* request = [[QCloudGetBucketVersioningRequest alloc] init];
 request.bucket = @"bucketName";  //存储桶名称(cos v5 的 bucket格式为：xxx-appid, 如 test-1253960454)
 [request setFinishBlock:^(QCloudBucketVersioningConfiguration* result, NSError* error) {
 //设置完成回调
 }];
 [[QCloudCOSXMLService defaultCOSXML] GetBucketVersioning:request];
 @endcode
 */
- (void) GetBucketVersioning:(QCloudGetBucketVersioningRequest*)request;
/**
 配置跨区域复制的方法.
 
 跨区域复制是支持不同区域 Bucket 自动异步复制对象.注意，不能是同区域的 Bucket, 且源 Bucket 和目 标 Bucket 必须已启用版本控制putBucketVersioning(PutBucketVersioningRequest).
 
 cos iOS SDK 中配置跨区域复制的方法具体步骤如下：
 
 1. 实例化 QCloudPutBucketReplicationRequest，填入需要的参数。
 
 2. 调用 QCloudCOSXMLService 对象中的 PutBucketRelication 方法发出请求。
 
 3. 从回调的 finishBlock 中的 outputObject 获取具体内容。
 
 示例：
 
 @code
 QCloudPutBucketReplicationRequest* request = [[QCloudPutBucketReplicationRequest alloc] init];
 request.bucket = bucketName; //存储桶名称(cos v5 的 bucket格式为：xxx-appid, 如 test-1253960454)
 QCloudBucketReplicationConfiguation* configuration = [[QCloudBucketReplicationConfiguation alloc] init];
 configuration.role = [NSString identifierStringWithID:@"uin" :@"uin"];
 QCloudBucketReplicationRule* rule = [[QCloudBucketReplicationRule alloc] init];
 
 rule.identifier = @"identifier";
 rule.status = QCloudQCloudCOSXMLStatusEnabled;
 
 QCloudBucketReplicationDestination* destination = [[QCloudBucketReplicationDestination alloc] init];
 NSString* destinationBucket = @"destinationBucket";
 NSString* region = @"destinationRegion"
 destination.bucket = [NSString stringWithFormat:@"qcs:id/0:cos:%@:appid/%@:%@",@"region",@"appid",@"destinationBucket"];
 rule.destination = destination;
 configuration.rule = @[rule];
 request.configuation = configuration;
 [request setFinishBlock:^(id outputObject, NSError* error) {
 //设置完成回调
 }];
 [[QCloudCOSXMLService defaultCOSXML] PutBucketRelication:request];
 @endcode
 
 */
- (void) PutBucketRelication:(QCloudPutBucketReplicationRequest*)request;
/**
 获取跨区域复制配置信息的方法.
 
 跨区域复制是支持不同区域 Bucket 自动复制对象, 请查阅putBucketReplication(PutBucketReplicationRequest).
 
 cos iOS SDK 中获取跨区域复制配置信息的方法具体步骤如下：
 
 1. 实例化 QCloudGetBucketReplicationRequest，填入需要的参数。
 
 2. 调用 QCloudCOSXMLService 对象中的 GetBucketReplication 方法发出请求。
 
 3. 从回调的 finishBlock 中的 QCloudBucketReplicationConfiguation 获取具体内容。
 
 示例：
 @code
 QCloudGetBucketReplicationRequest* request = [[QCloudGetBucketReplicationRequest alloc] init];
 request.bucket = bucketBame; // //存储桶名称(cos v5 的 bucket格式为：xxx-appid, 如 test-1253960454)
 [request setFinishBlock:^(QCloudBucketReplicationConfiguation* result, NSError* error) {
 //设置完成回调
 }];
 [[QCloudCOSXMLService defaultCOSXML] GetBucketReplication:request];
 @endcode
 */

- (void) GetBucketReplication:(QCloudGetBucketReplicationRequest*)request;
/**
 删除跨区域复制配置的方法.
 
 当不需要进行跨区域复制时，可以删除 Bucket 的跨区域复制配置. 跨区域复制，可以查阅putBucketReplication(PutBucketReplicationRequest)
 
 cos iOS SDK 中删除跨区域复制配置的方法具体步骤如下：
 
 1. 实例化 QCloudDeleteBucketReplicationRequest，填入需要的参数。
 
 2. 调用 QCloudCOSXMLService 对象中的 DeleteBucketReplication 方法发出请求。
 
 3. 从回调的 finishBlock 中的 outputObject 获取具体内容。
 
 示例：
 @code
 //delete bucket replication
 QCloudDeleteBucketReplicationRequest* request = [[QCloudDeleteBucketReplicationRequest alloc] init];
 request.bucket = @"bucketName";  //存储桶名称(cos v5 的 bucket格式为：xxx-appid, 如 test-1253960454)
 [request setFinishBlock:^(id outputObject, NSError* error) {
 
 }];
 [[QCloudCOSXMLService defaultCOSXML] DeleteBucketReplication:request];
 @endcode
 */
- (void) DeleteBucketReplication:(QCloudDeleteBucketReplicationRequest*)request;
/**
 获取所属账户的所有存储空间列表的方法.
 
 通过使用帯 Authorization 签名认证的请求，可以获取签名中 APPID 所属账户的所有存储空间列表 (Bucket list).
 
 关于获取所有存储空间列表接口的具体描述，请查看https://cloud.tencent.com/document/product/436/8291.
 
 cos iOS SDK 中获取所属账户的所有存储空间列表的方法具体步骤如下：
 
 1. 实例化 QCloudGetServiceRequest。
 
 2. 调用 QCloudCOSXMLService 对象中的 GetService 方法发出请求。
 
 3. 从回调的 finishBlock 中的 QCloudListAllMyBucketsResult 获取具体内容
 
 示例：
 @code
 QCloudGetServiceRequest* request = [[QCloudGetServiceRequest alloc] init];
 [request setFinishBlock:^(QCloudListAllMyBucketsResult* result, NSError* error) {
 //additional actions after finishing
 }];
 [[QCloudCOSXMLService defaultCOSXML] GetService:request];
 @endcode
 */
- (void) GetService:(QCloudGetServiceRequest*)request;

- (void) PostObjectRestore:(QCloudPostObjectRestoreRequest*)request;
- (void) ListObjectVersions:(QCloudListObjectVersionsRequest*)request;
- (void) getPresignedURL:(QCloudGetPresignedURLRequest*)request;

#pragma mark - Encapsulated Interface


/**
 查询 Bucket 是否存在。注意该方法是同步方法，会阻塞当前线程直到返回结果，请勿在主线程内调用。
 
 
 @param bucketName bucket
 @return bucket 是否存在。如果返回YES那说明bucket一定存在，但返回 NO 的时候并不一定是因为 Bucket 不存在，还有可能因为超时、签名错误等问题导致请求失败了。
 */
- (BOOL) doesBucketExist:(NSString*)bucketName;

/**
 查询 Object 是否存在。注意该方法是同步方法，会阻塞当前线程直到返回结果，请勿在主线程内调用。
 
 该方法返回不存在可能存在两种情况： 1. Bucket 并不存在。 2. Bucket 存在，但 Object 并不存在。

 @param objectName object
 @param bucket bucket
 @return object 是否存在。如果返回YES那说明bucket一定存在，但返回 NO 的时候并不一定是因为 Bucket 不存在，还有可能因为超时、签名错误等问题导致请求失败了。
 */
- (BOOL) doesObjectExistWithBucket:(NSString*)bucket object:(NSString*)objectName;

/**
 直接删除对象的接口。注意该方法是同步方法，会阻塞当前线程直到返回完成，请勿在主线程内调用。

 @param bucket bucket
 @param objectName object
 */
- (void) deleteObjectWithBucket:(NSString*)bucket object:(NSString*)objectName;

/**
 删除多版本中指定版本对象的接口。注意该方法是同步方法，会阻塞当前线程直到返回完成，请勿在主线程内调用。

 @param bucket bucket
 @param object object
 @param versionID versionID
 */
- (void) deleteVersionWithBucket:(NSString*)bucket object:(NSString*)object version:(NSString*)versionID;

/**
 更改对象的存储级别，内部通过 CopyObject 操作来实现。注意该方法是同步方法，会阻塞当前线程直到返回完成，请勿在主线程内调用。

 @param bucket bucket
 @param object object
 @param storageClass 存储级别
 */
- (void) changeObjectStorageClassWithBucket:(NSString*)bucket object:(NSString*)object storageClass:(QCloudCOSStorageClass)storageClass;

/**
 更改对象的元数据，内部通过 CopyObject 操作来实现。注意该方法是同步方法，会阻塞当前线程直到返回完成，请勿在主线程内调用。

 @param bucket bucket
 @param object object
 @param meta 元数据，以键值对的方式传入。
 */
- (void) updateObjectMedaWithBucket:(NSString*)bucket object:(NSString*)object meta:(NSDictionary*)meta;

@end
