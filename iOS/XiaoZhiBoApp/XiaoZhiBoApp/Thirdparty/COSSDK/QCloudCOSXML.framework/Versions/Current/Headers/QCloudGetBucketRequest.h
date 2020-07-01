//
//  GetBucket.h
//  GetBucket
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
#import "QCloudListBucketResult.h"
NS_ASSUME_NONNULL_BEGIN
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
@interface QCloudGetBucketRequest : QCloudBizHTTPRequest
/**
存储桶名
*/
@property (strong, nonatomic) NSString *bucket;
/**
前缀匹配，用来规定返回的文件前缀地址
*/
@property (strong, nonatomic) NSString *prefix;
/**
定界符为一个符号，如果有 Prefix，则将 Prefix 到 delimiter 之间的相同路径归为一类，定义为 Common Prefix，然后列出所有 Common Prefix。如果没有 Prefix，则从路径起点开始
*/
@property (strong, nonatomic) NSString *delimiter;
/**
规定返回值的编码方式，可选值:url
*/
@property (strong, nonatomic) NSString *encodingType;
/**
默认以UTF-8二进制顺序列出条目，所有列出条目从marker开始
*/
@property (strong, nonatomic) NSString *marker;
/**
单次返回的最大条目数量，默认1000
*/
@property (assign, nonatomic) int maxKeys;


- (void) setFinishBlock:(void (^)(QCloudListBucketResult* result, NSError * error))QCloudRequestFinishBlock;
@end
NS_ASSUME_NONNULL_END
