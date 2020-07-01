//
//  QCloudNetResponse.h
//  Pods
//
//  Created by Dong Zhao on 2017/3/9.
//
//


#import "QCloudModel.h"

/**
 COS 服务返回数据的通用模型
 */
@interface QCloudNetResponse : QCloudModel

/**
 业务逻辑结果代码，非0为错误代码
 */
@property (nonatomic, assign) int code;

/**
 用于追踪本次请求的id
 */
@property (nonatomic, strong) NSString* request_id;

/**
 请求的数据内容
 */
@property (nonatomic, strong) NSDictionary* data;

/**
 描述了改次请求结果的信息
 */
@property (nonatomic, strong) NSString* message;
@end
