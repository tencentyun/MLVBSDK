//
//  QCloudListPartsResult.h
//  QCloudListPartsResult
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
#import "QCloudMultipartUploadInitiator.h"
#import "QCloudMultipartUploadOwner.h"
#import "QCloudMultipartUploadPart.h"

NS_ASSUME_NONNULL_BEGIN
@interface QCloudListPartsResult : NSObject
/**
存储桶名
*/
@property (strong, nonatomic) NSString *bucket;
/**
规定返回值的编码格式
*/
@property (strong, nonatomic) NSString *encodingType;
/**
对象的名称
*/
@property (strong, nonatomic) NSString *key;
/**
标识本次分块上传的uploadId
*/
@property (strong, nonatomic) NSString *uploadId;
/**
用来表示这些分块的存储级别
*/
@property (assign, nonatomic) QCloudCOSStorageClass storageClass;
/**
默认以 UTF-8 二进制顺序列出条目，所有列出条目从 marker 开始
*/
@property (strong, nonatomic) NSString *partNumberMarker;
/**
假如返回条目被截断，则返回 NextMarker 就是下一个条目的起点
*/
@property (strong, nonatomic) NSString *nextNumberMarker;
/**
单次返回的最大条目数
*/
@property (strong, nonatomic) NSString *maxParts;
/**
返回条目是否被截断
*/
@property (assign, nonatomic) BOOL isTruncated;
/**
用来标识本次上传发起者的信息
*/
@property (strong, nonatomic) QCloudMultipartUploadInitiator *initiator;
/**
用来标识这些分块所有者的信息
*/
@property (strong, nonatomic) QCloudMultipartUploadOwner *owner;
/**
用来表示每一个块的信息
*/
@property (strong, nonatomic) NSArray<QCloudMultipartUploadPart*> *parts;
@end
NS_ASSUME_NONNULL_END
