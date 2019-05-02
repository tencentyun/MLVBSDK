//
//  GetService.h
//  GetService
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
#import "QCloudListAllMyBucketsResult.h"
NS_ASSUME_NONNULL_BEGIN


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
@interface QCloudGetServiceRequest : QCloudBizHTTPRequest

/**
 请求完成后的会通过该block回调，返回结果，若error为空，即为成功。
 
 @param QCloudRequestFinishBlock 回调bock
 */
- (void) setFinishBlock:(void (^)(QCloudListAllMyBucketsResult* result, NSError * error))QCloudRequestFinishBlock;
@end
NS_ASSUME_NONNULL_END
