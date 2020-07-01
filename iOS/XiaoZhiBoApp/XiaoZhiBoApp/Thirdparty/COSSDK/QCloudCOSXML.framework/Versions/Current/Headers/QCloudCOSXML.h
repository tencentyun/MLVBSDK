//
//  QCloudCOSXML.h
//  Pods
//
//  Created by Dong Zhao on 2017/5/2.
//
//

#ifndef QCloudCOSXML_h
#define QCloudCOSXML_h

#import "QCloudCOSXMLService.h"
#import "QCloudCOSXMLService+Transfer.h"
#import "QCloudCOSXMLService+Manager.h"
#import "QCloudGetObjectACLRequest.h"
#import "QCloudPutObjectRequest.h"
#import "QCloudInitiateMultipartUploadRequest.h"
#import "QCloudCOSTransferMangerService.h"
#import "QCloudCOSXMLUploadObjectRequest.h"
#import "QCloudUploadObjectResult.h"

#import "QCloudPutObjectACLRequest.h"
#import "QCloudDeleteObjectRequest.h"
#import "QCloudDeleteMultipleObjectRequest.h"
#import "QCloudListMultipartRequest.h"
#import "QCloudDeleteObjectInfo.h"
#import "QCloudDeleteInfo.h"
#import "QCloudHeadObjectRequest.h"
#import "QCloudAppendObjectRequest.h"
#import "QCloudGetObjectRequest.h"
#import "QCloudGetObjectRequest+Custom.h"
#import "QCloudPutObjectRequest+Custom.h"
/**
 简单复制对象的方法.
 
 COS 中复制对象可以完成如下功能:
 
 创建一个新的对象副本.
 
 复制对象并更名，删除原始对象，实现重命名
 
 修改对象的存储类型，在复制时选择相同的源和目标对象键，修改存储类型.
 
 在不同的腾讯云 COS 地域复制对象.
 
 修改对象的元数据，在复制时选择相同的源和目标对象键，并修改其中的元数据,复制对象时，默认将继承原对象的元数据，但创建日期将会按新对象的时间计算.
 
 1. 当复制的对象小于等于 5 GB ，可以使用简单复制（https://cloud.tencent.com/document/product/436/14117).
 
 2. 当复制对象超过 5 GB 时，必须使用分块复制（https://cloud.tencent.com/document/product/436/14118 ） 来实现复制.
 
 3. 关于简单复制接口的具体描述，请查看https://cloud.tencent.com/document/product/436/10881.
 
 cos iOS SDK 中简单复制对象的同步方法具体步骤如下：
 
 1. 实例化 QCloudPutObjectRequest 对象;
 
 2. 调用 QCloudCOSXMLService 对象中的 GetBucket 方法发出请求
 
 3. 从回调的 finishBlock 中的 QCloudCopyObjectResult 获取具体内容。
 
 示例：
 @code
 QCloudPutObjectCopyRequest* request = [[QCloudPutObjectCopyRequest alloc] init];
 request.bucket = self.bucket; //存储桶名称(cos v5 的 bucket格式为：xxx-appid, 如 test-1253960454)
 request.object = [NSUUID UUID].UUIDString; //对象名
 request.objectCopySource = objectCopySource; //源文件 URL 路径，可以通过 versionid 子资源指定历史版本
 [request setFinishBlock:^(QCloudCopyObjectResult* result, NSError* error) {
 //additional actions after finishing
 }];
 [[QCloudCOSXMLService defaultCOSXML] PutObjectCopy:request];
 @endcode
 
 */
#import "QCloudCopyObjectResult.h"
/**
 简单复制对象的方法.
 
 COS 中复制对象可以完成如下功能:
 
 创建一个新的对象副本.
 
 复制对象并更名，删除原始对象，实现重命名
 
 修改对象的存储类型，在复制时选择相同的源和目标对象键，修改存储类型.
 
 在不同的腾讯云 COS 地域复制对象.
 
 修改对象的元数据，在复制时选择相同的源和目标对象键，并修改其中的元数据,复制对象时，默认将继承原对象的元数据，但创建日期将会按新对象的时间计算.
 
 1. 当复制的对象小于等于 5 GB ，可以使用简单复制（https://cloud.tencent.com/document/product/436/14117).
 
 2. 当复制对象超过 5 GB 时，必须使用分块复制（https://cloud.tencent.com/document/product/436/14118 ） 来实现复制.
 
 3. 关于简单复制接口的具体描述，请查看https://cloud.tencent.com/document/product/436/10881.
 
 cos iOS SDK 中简单复制对象的同步方法具体步骤如下：
 
 1. 实例化 QCloudPutObjectRequest 对象;
 
 2. 调用 QCloudCOSXMLService 对象中的 GetBucket 方法发出请求
 
 3. 从回调的 finishBlock 中的 QCloudCopyObjectResult 获取具体内容。
 
 示例：
 @code
 QCloudPutObjectCopyRequest* request = [[QCloudPutObjectCopyRequest alloc] init];
 request.bucket = self.bucket; //存储桶名称(cos v5 的 bucket格式为：xxx-appid, 如 test-1253960454)
 request.object = [NSUUID UUID].UUIDString; //对象名
 request.objectCopySource = objectCopySource; //源文件 URL 路径，可以通过 versionid 子资源指定历史版本
 [request setFinishBlock:^(QCloudCopyObjectResult* result, NSError* error) {
 //additional actions after finishing
 }];
 [[QCloudCOSXMLService defaultCOSXML] PutObjectCopy:request];
 @endcode
 
 */
#import "QCloudPutObjectCopyRequest.h"
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
#import "QCloudGetBucketRequest.h"
#import "QCloudGetBucketACLRequest.h"

#import "QCloudGetBucketCORSRequest.h"
#import "QCloudGetBucketLocationRequest.h"
#import "QCloudPutBucketACLRequest.h"
#import "QCloudPutBucketCORSRequest.h"


#import "QCloudDeleteBucketCORSRequest.h"
#import "QCloudListBucketMultipartUploadsRequest.h"
#import "QCloudOptionsObjectRequest.h"


#import "QCloudHeadBucketRequest.h"
#import "QCloudCOSXMLEndPoint.h"

#import "QCloudPutBucketRequest.h"


#import "QCloudDeleteBucketRequest.h"
#import "QCloudLifecycleConfiguration.h"
#import "QCloudLifecycleRule.h"

#import "QCloudPutBucketLifecycleRequest.h"

#import "QCloudGetBucketLifecycleRequest.h"

#import "QCloudDeleteBucketLifeCycleRequest.h"

#import "QCloudPutBucketVersioningRequest.h"
#import "QCloudGetBucketVersioningRequest.h"
#import "QCloudBucketReplicationConfiguation.h"

#import "QCloudPutBucketReplicationRequest.h"

#import "QCloudGetBucketReplicationRequest.h"
#import "QCloudDeleteBucketReplicationRequest.h"

#import "QCloudGetServiceRequest.h"
//分块copy
#import "QCloudUploadPartCopyRequest.h"
#import "QCloudCOSXMLCopyObjectRequest.h"
#import "QCloudPostObjectRestoreRequest.h"
#import "QCloudRestoreRequest.h"
#import "QCloudListObjectVersionsRequest.h"
#import "QCloudGetPresignedURLRequest.h"
#endif /* QCloudCOSXML_h */

