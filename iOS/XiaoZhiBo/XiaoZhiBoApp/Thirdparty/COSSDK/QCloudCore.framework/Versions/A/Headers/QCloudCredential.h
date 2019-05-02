//
//  QCloudCredential.h
//  Pods
//
//  Created by Dong Zhao on 2017/5/2.
//
//

#import <Foundation/Foundation.h>

/**
 密钥
 */
@interface QCloudCredential : NSObject

/**
 开发者拥有的项目身份识别 ID，用以身份认证
 */
@property (nonatomic, strong) NSString* secretID;

/**
开发者拥有的项目身份密钥。可以为永久密钥，也可以是临时密钥（参考CAM系统）。
 */
@property (nonatomic, strong) NSString* secretKey;


/**
 签名有效期的起始时间。默认是设备的本地时间，如果传入起始时间，那么将以起始时间去计算签名。
 */
@property (nonatomic, strong) NSDate* startDate;

/**
 签名有效期截止的时间。没有设置的话，默认是起始时间加十分钟。
 */
@property (nonatomic, strong) NSDate* experationDate;

/**
 改签名是否有效。
 */
@property (nonatomic, assign, readonly) BOOL valid;


/**
 当您使用了CAM系统获取临时密钥的时候，请设置改值，代表回话的ID。
 */
@property (nonatomic, strong) NSString* token;
@end
