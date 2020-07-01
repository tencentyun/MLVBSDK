//
//  QCloudSHAPart.h
//  Pods
//
//  Created by Dong Zhao on 2017/3/8.
//
//

#import "QCloudModel.h"
@interface QCloudSHAPart : QCloudModel

/**
 sha值
 */
@property (nonatomic, strong) NSString* datasha;

/**
 offset
 */
@property (nonatomic, assign) uint64_t offset;

/**
 长度
 */
@property (nonatomic, assign) uint64_t datalen;
@end
