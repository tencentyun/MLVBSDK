//
//  AppendObject.h
//  AppendObject
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
#import "QCloudCOSStorageClassEnum.h"
NS_ASSUME_NONNULL_BEGIN
/**
Append Object
*/
@interface QCloudAppendObjectRequest <BodyType> : QCloudBizHTTPRequest
@property (nonatomic, strong) BodyType body;
/**
位置
*/
@property (assign, nonatomic) int64_t position;
/**
存储桶名
*/
@property (strong, nonatomic) NSString *bucket;
/**
对象名
*/
@property (strong, nonatomic) NSString *object;
/**
RFC 2616 中定义的缓存策略，将作为 Object 元数据返回
*/
@property (strong, nonatomic) NSString *cacheControl;
/**
RFC 2616 中定义的文件名称，将作为 Object 元数据返回
*/
@property (strong, nonatomic) NSString *contentDisposition;
/**
当使用 Expect: 100-continue 时，在收到服务端确认后，才会发送请求内容
*/
@property (strong, nonatomic) NSString *expect;
/**
RFC 2616 中定义的过期时间，将作为 Object 元数据返回
*/
@property (strong, nonatomic) NSString *expires;
@property (strong, nonatomic) NSString *contentSHA1;
@property (assign, nonatomic) QCloudCOSStorageClass storageClass;
/**
定义 Object 的 ACL 属性。有效值：private，public-read-write，public-read；默认值：private
*/
@property (strong, nonatomic) NSString *accessControlList;
/**
赋予被授权者读的权限。格式：x-cos-grant-read: id=" ",id=" "；
当需要给子账户授权时，id="qcs::cam::uin/<OwnerUin>:uin/<SubUin>"，
当需要给根账户授权时，id="qcs::cam::uin/<OwnerUin>:uin/<OwnerUin>"
*/
@property (strong, nonatomic) NSString *grantRead;
/**
赋予被授权者写的权限。格式：x-cos-grant-write: id=" ",id=" "；
当需要给子账户授权时，id="qcs::cam::uin/<OwnerUin>:uin/<SubUin>"，
当需要给根账户授权时，id="qcs::cam::uin/<OwnerUin>:uin/<OwnerUin>"
*/
@property (strong, nonatomic) NSString *grantWrite;
/**
赋予被授权者读写权限。格式：x-cos-grant-full-control: id=" ",id=" "；
当需要给子账户授权时，id="qcs::cam::uin/<OwnerUin>:uin/<SubUin>"，
当需要给根账户授权时，id="qcs::cam::uin/<OwnerUin>:uin/<OwnerUin>"
*/
@property (strong, nonatomic) NSString *grantFullControl;


@end
NS_ASSUME_NONNULL_END
