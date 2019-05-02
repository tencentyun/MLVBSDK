//
//  QCloudLifecycleRule.h
//  QCloudLifecycleRule
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
#import "QCloudLifecycleRuleFilter.h"
#import "QCloudLifecycleStatueEnum.h"
#import "QCloudLifecycleAbortIncompleteMultipartUpload.h"
#import "QCloudLifecycleTransition.h"
#import "QCloudLifecycleExpiration.h"
#import "QCloudNoncurrentVersionTransition.h"
#import "QCloudNoncurrentVersionExpiration.h"

NS_ASSUME_NONNULL_BEGIN
@interface QCloudLifecycleRule : NSObject
/**
用于唯一地标识规则，长度不能超过 255 个字符
*/
@property (strong, nonatomic) NSString *identifier;
/**
Filter 用于描述规则影响的 Object 集合
*/
@property (strong, nonatomic) QCloudLifecycleRuleFilter *filter;
/**
指明规则是否启用，枚举值：Enabled，Disabled
*/
@property (assign, nonatomic) QCloudLifecycleStatue status;
/**
设置允许分片上传保持运行的最长时间
*/
@property (strong, nonatomic) QCloudLifecycleAbortIncompleteMultipartUpload *abortIncompleteMultipartUpload;
/**
规则转换属性，对象何时转换被转换为 Standard_IA 等
*/
@property (strong, nonatomic) QCloudLifecycleTransition *transition;
/**
规则过期属性
*/
@property (strong, nonatomic) QCloudLifecycleExpiration *expiration;
/**
指明非当前版本对象何时过期
*/
@property (strong, nonatomic) QCloudNoncurrentVersionTransition *noncurrentVersionExpiration;
/**
指明非当前版本对象何时转换被转换为 Standard_IA 等
*/
@property (strong, nonatomic) QCloudNoncurrentVersionExpiration *noncurrentVersionTransition;
@end
NS_ASSUME_NONNULL_END
