//
//  QCloudDomain.h
//  TestHttps
//
//  Created by tencent on 16/2/17.
//  Copyright © 2016年 dzpqzb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QCloudDomain : NSObject
@property (nonatomic, strong, readonly) NSString* domain;
+ (instancetype) new UNAVAILABLE_ATTRIBUTE;
- (instancetype) init UNAVAILABLE_ATTRIBUTE;
- (instancetype) initWithDomain:(NSString*)domain;
@end
