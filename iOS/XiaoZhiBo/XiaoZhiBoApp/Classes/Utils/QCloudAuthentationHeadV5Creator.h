//
//  QCloudAuthentationHeadV5Creator.h
//  TCLVBIMDemo
//
//  Created by carolsuo on 2017/10/24.
//  Copyright © 2017年 tencent. All rights reserved.
//


#import <QCloudCore/QCloudCore.h>


/**
 小直播头像COS存储 V5（XML）版本签名创建器。
 */
@class QCloudHTTPRequest;
@interface QCloudAuthentationHeadV5Creator : QCloudAuthentationCreator

@property (nonatomic, strong) NSString* secretID;
@property (nonatomic, strong) NSString* signKey;
@property (nonatomic, strong) NSString* keyTime;


/**
 初始化头像上传签名创建器。

 @param secretId COS上传的secretId
 @paeam signKey:后台根据COS文档计算出来的signKey
 @param keyTime:后台返回的签名有效期，格式为 startTime;endTime
 @return 签名创建器
 */
- (instancetype) initWithSignKey:(NSString *) secretID
                         signKey:(NSString *) signKey
                         keyTime:(NSString *) keyTime;

- (void) setSignKey:(NSString *) secretID
            signKey:(NSString *) signKey
            keyTime:(NSString *) keyTime;

- (QCloudSignature*) signatureForData:(NSMutableURLRequest*)signData;
@end
