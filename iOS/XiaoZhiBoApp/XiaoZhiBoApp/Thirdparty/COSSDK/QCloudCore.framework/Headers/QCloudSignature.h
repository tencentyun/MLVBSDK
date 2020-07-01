//
//  QCloudSignature.h
//  Pods
//
//  Created by Dong Zhao on 2017/4/5.
//
//

#import <Foundation/Foundation.h>


/**
 访问腾讯云的服务需要对请求进行签名，以确定访问的用户身份，同时也保障访问的安全性。该类为腾讯云签名的抽象类。他代表了一个用于访问腾讯云服务的签名信息。需要您注意的是，签名信息是有有效期的。而您在创建签名信息的时候，也请您赋值相应的有效期。这个有效期在您进行签名的时候已经指定了，请确保此处的有效期和您进行签名的时候保持一致。否则将会产生不能访问腾讯云服务的问题。
 */
@interface QCloudSignature : NSObject

/**
 签名字符串，经过签名算法计算之后的字符串。
 */
@property (nonatomic, strong) NSString* signature;

/**
 签名过期时间，最长为1个月（30天）当您传入大于30天的数值的时候，会自动降级到30天
 */
@property (nonatomic, strong) NSDate* expiration;



/**
 创建一个有效期为一天的签名

 @param signature 签名字符串
 @return 一个有效期为一天的签名
 */
+ (QCloudSignature*) signatureWith1Day:(NSString*)signature;

/**
 创建一个有效期为七天的签名
 
 @param signature 签名字符串
 @return 一个有效期为七天的签名
 */
+ (QCloudSignature*) signatureWith7Day:(NSString*)signature;

/**
 创建一个有效期为30天的签名。我们认为一个签名超过一个月将会带来安全性问题，因而建议您的签名有效期保持在30天以下。
 
 @param signature 签名字符串
 @return 一个有效期为30天的签名
 */
+ (QCloudSignature*) signatureWithMaxExpiration:(NSString*)signature;



/**
 通过签名字符串和过期日期创建一个签名信息。签名是一个有有效期的概念，在有效期内签名有效，代表请求可以访问腾讯云的服务。当签名过了有效期之后，则不可以访问腾讯云的服务。同时我们会向您请求一个新的签名。

 @param signature 签名字符串，通过secretID和secretKey进行签名后的字符串
 @param expiration 签名过期日期，当过了改日期之后，该签名失效
 @return 一个包含签名字符串并在指定日期实效的签名
 */
- (instancetype) initWithSignature:(NSString*)signature expiration:(NSDate*)expiration;
@end
