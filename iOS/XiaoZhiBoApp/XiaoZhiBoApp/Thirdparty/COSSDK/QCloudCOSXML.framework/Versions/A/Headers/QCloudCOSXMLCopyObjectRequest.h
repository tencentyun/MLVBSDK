//
//  QCloudCOSXMLCopyObjectRequest.h
//  QCloudCOSXML
//
//  Created by erichmzhang(张恒铭) on 16/11/2017.
//
#import <Foundation/Foundation.h>
#import <QCloudCore/QCloudCore.h>
#import "QCloudCOSStorageClassEnum.h"
#import "QCloudCopyObjectResult.h"
#import "QCloudCOSTransferMangerService.h"
typedef void(^CopyProgressBlock)(int64_t partsSent, int64_t totalPartsExpectedToSent) ;


@interface QCloudCOSXMLCopyObjectRequest : QCloudAbstractRequest
/**
 对象名
 */
@property (strong, nonatomic) NSString *object;
/**
 存储桶名
 */
@property (strong, nonatomic) NSString *bucket;

/**
 复制的源文件所在Bucket
 */
@property (nonatomic, copy) NSString* sourceBucket;

/**
 复制的源文件的对象名，key
 */
@property (nonatomic, copy) NSString* sourceObject;

/**
 复制的源文件的appID
 */
@property (nonatomic, copy) NSString* sourceAPPID;

/**
 复制的源文件所在的区域。
 */
@property (nonatomic, copy) NSString* sourceRegion;

/**
 是否拷贝元数据，枚举值：Copy, Replaced，默认值 Copy。假如标记为 Copy，忽略 Header 中的用户元数据信息直接复制；假如标记为 Replaced，按 Header 信息修改元数据。当目标路径和原路径一致，即用户试图修改元数据时，必须为 Replaced
 */
@property (strong, nonatomic) NSString *metadataDirective;
/**
 当 Object 在指定时间后被修改，则执行操作，否则返回 412。可与 x-cos-copy-source-If-None-Match 一起使用，与其他条件联合使用返回冲突。
 */
@property (strong, nonatomic) NSString *objectCopyIfModifiedSince;
/**
 当 Object 在指定时间后未被修改，则执行操作，否则返回 412。可与 x-cos-copy-source-If-Match 一起使用，与其他条件联合使用返回冲突。
 */
@property (strong, nonatomic) NSString *objectCopyIfUnmodifiedSince;
/**
 当 Object 的 Etag 和给定一致时，则执行操作，否则返回 412。可与x-cos-copy-source-If-Unmodified-Since 一起使用，与其他条件联合使用返回冲突。
 */
@property (strong, nonatomic) NSString *objectCopyIfMatch;
/**
 当 Object 的 Etag 和给定不一致时，则执行操作，否则返回 412。可与 x-cos-copy-source-If-Modified-Since 一起使用，与其他条件联合使用返回冲突。
 */
@property (strong, nonatomic) NSString *objectCopyIfNoneMatch;
/**
 Object 的存储级别
 */
@property (assign, nonatomic) QCloudCOSStorageClass storageClass;
/**
 定义 Object 的 ACL 属性。有效值：private，public-read-write，public-read；默认值：private
 */
@property (strong, nonatomic) NSString *accessControlList;
/**
 赋予被授权者读的权限。格式：id=" ",id=" "；
 当需要给子账户授权时，id="qcs::cam::uin/<OwnerUin>:uin/<SubUin>"，
 当需要给根账户授权时，id="qcs::cam::uin/<OwnerUin>:uin/<OwnerUin>"
 */
@property (strong, nonatomic) NSString *grantRead;
/**
 赋予被授权者写的权限。格式：id=" ",id=" "；
 当需要给子账户授权时，id="qcs::cam::uin/<OwnerUin>:uin/<SubUin>"，
 当需要给根账户授权时，id="qcs::cam::uin/<OwnerUin>:uin/<OwnerUin>"
 */
@property (strong, nonatomic) NSString *grantWrite;
/**
 赋予被授权者读写权限。格式: id=" ",id=" " ；
 当需要给子账户授权时，id="qcs::cam::uin/<OwnerUin>:uin/<SubUin>"，
 当需要给根账户授权时，id="qcs::cam::uin/<OwnerUin>:uin/<OwnerUin>"
 */
@property (strong, nonatomic) NSString *grantFullControl;



@property (nonatomic, weak) QCloudCOSTransferMangerService* transferManager;
/*
 在进行HTTP请求的时候，可以通过设置该参数来设置自定义的一些头部信息。
 通常情况下，携带特定的额外HTTP头部可以使用某项功能，如果是这类需求，可以通过设置该属性来实现。
 */
@property (strong, nonatomic) NSMutableDictionary* customHeaders;

/**
 在对大文件进行复制的过程中，会通过分片的方式进行复制。从该进度回调里可以获取当前已经复制了多少分片。

 @param copyProgressBlock 进度回调block
 */
- (void)setCopyProgressBlock:(void(^)(int64_t partsSent, int64_t totalPartsExpectedToSent))copyProgressBlock;



/**
 Copy操作完成后的回调

 @param QCloudRequestFinishBlock 完成回调
 */
- (void) setFinishBlock:(void (^)(QCloudCopyObjectResult* result, NSError * error))QCloudRequestFinishBlock;
-(void)setCOSServerSideEncyption;
-(void)setCOSServerSideEncyptionWithCustomerKey:(NSString *)customerKey;
@end
