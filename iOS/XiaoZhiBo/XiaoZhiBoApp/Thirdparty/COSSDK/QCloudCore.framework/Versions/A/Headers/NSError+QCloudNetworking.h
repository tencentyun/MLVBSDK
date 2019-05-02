//
//  NSError+QCloudNetworking.h
//  QCloudNetworking
//
//  Created by tencent on 16/2/19.
//  Copyright © 2016年 QCloudTernimalLab. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 腾讯云SDK网络层本地客户端自定义错误
 
 - QCloudNetworkErrorCodeDecodeError: 网络数据解析出错，比如一个json接口的数据，按照约定服务器应该返回json类型数据，结果返回了html数据。
 - QCloudNetworkErrorCodeParamterInvalid: 数据拼装过程参数非法，比如一个接受NSString类型的数据，你传了一个NSDictionary类型。又比如一个约束了最大值为2的参数，传入了值3.
 - QCloudNetworkErrorCodeResponseDataTypeInvalid: 网络层返回的数据类型错误，比如约定为JSON的接口，返回了html数据
 */


typedef NS_ENUM(int,QCloudNetworkErrorCode) {
    QCloudNetworkErrorCodeContentError = -34005,
    QCloudNetworkErrorCodeDecodeError = -30005,
    QCloudNetworkErrorCodeParamterInvalid = -34003,
    QCloudNetworkErrorCodeNoNetwork = -34004,
    QCloudNetworkErrorCodeResponseDataTypeInvalid = -34008,
    QCloudNetworkErrorCodeCanceled  = -34009,
    QCloudNetworkErrorCodeAborted = -340010,
    QCloudNetworkErrorCodeAlreadyFinish = -340011,
    QCloudNetworkErrorCodeCredentialNotReady = -340012,
    QCloudNetworkErrorCodeMD5NotMatch = -340013,
    QCloudNetworkErrorCodeCannotResloveDomain = -340014,
    QCloudNetworkErrorCodeSignatureTimeOut = -340015
};

@protocol QCloudNetworkError <NSObject>
+ (NSError*) toError:(NSDictionary*)userInfo;
@end


@interface QCloudCommonNetworkError : NSObject <QCloudNetworkError>
@property (nonatomic, assign) int code;
@property (nonatomic, strong) NSString* message;
@property (nonatomic, strong) NSString* request_id;
@end


FOUNDATION_EXTERN NSString* const kQCloudNetworkDomain;
FOUNDATION_EXTERN NSString* const kQCloudNetworkErrorObject;
@interface NSError (QCloudNetworking)
+ (NSError*) qcloud_errorWithCode:(int)code message:(NSString*)message;
@end



