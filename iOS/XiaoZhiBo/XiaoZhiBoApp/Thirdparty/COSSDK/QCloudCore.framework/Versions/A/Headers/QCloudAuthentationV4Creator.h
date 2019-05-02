//
//  QCloudAuthentationV4Creator.h
//  Pods
//
//  Created by Dong Zhao on 2017/5/17.
//
//

#import "QCloudAuthentationCreator.h"


/**
 COS V4版本签名创建器
 */
@interface QCloudAuthentationV4Creator : QCloudAuthentationCreator
- (QCloudSignature*) signatureForData:(QCloudSignatureFields*)fields;
@end
