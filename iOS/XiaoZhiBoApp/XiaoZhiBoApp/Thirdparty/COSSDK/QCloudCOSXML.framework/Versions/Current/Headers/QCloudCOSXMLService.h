//
//  QCloudCOSXMLService.h
//  QCloudCOSXMLService
//
//  Created by tencent
//
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
#import <QCloudCore/QCloudService.h>
#import <QCloudCore/QCloudCore.h>


@interface QCloudCOSXMLService : QCloudService
#pragma hidden super selectors
- (int) performRequest:(QCloudBizHTTPRequest *)httpRequst NS_UNAVAILABLE;
- (int) performRequest:(QCloudBizHTTPRequest *)httpRequst withFinishBlock:(QCloudRequestFinishBlock)block NS_UNAVAILABLE;

#pragma Factory
+ (QCloudCOSXMLService*) defaultCOSXML;
+ (QCloudCOSXMLService*) cosxmlServiceForKey:(NSString*)key;
#pragma hidden super selectors
/**
 检查是否存在key对应的service

 @param key key
 @return 存在与否

 */
+ (BOOL) hasServiceForKey:(NSString*)key;
+ (QCloudCOSXMLService*) registerDefaultCOSXMLWithConfiguration:(QCloudServiceConfiguration*)configuration;
+ (QCloudCOSXMLService*) registerCOSXMLWithConfiguration:(QCloudServiceConfiguration*)configuration withKey:(NSString*)key;
+ (void) removeCOSXMLWithKey:(NSString*)key;

/**
根据Bukcet, Object来生成可以直接访问的URL。如果您的Bucket是私有读的话，那么访问的时候需要带上签名，反之则不需要。
 
 
需要注意的是，如果通过该接口来生成带签名的URL的话，因为签名可能是在服务器生成的，该方法是同步方法，可能因为网络请求阻塞，建议不要在主线程里调用。

此外, 传入的Object需要是URLEncode后的结果。
 
 @param bucket 存储桶
 @param object 存储对象, 请传入URL Encode后的结果
 @param withAuthorization 是否需要签名，如果是私有读的Bucket，那么该URL需要带上签名才能访问
 @return object URL
 */
- (NSString*)getURLWithBucket:(NSString*)bucket object:(NSString*)object withAuthorization:(BOOL)withAuthorization;

@end
