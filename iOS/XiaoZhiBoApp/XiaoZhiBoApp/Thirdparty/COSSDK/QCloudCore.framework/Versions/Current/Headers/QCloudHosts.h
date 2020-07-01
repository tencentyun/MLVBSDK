//
//  QCloudHosts.h
//  TestHttps
//
//  Created by tencent on 16/2/17.
//  Copyright © 2016年 dzpqzb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QCloudHosts : NSObject
- (void) putDomain:(NSString*)domain ip:(NSString*)ip;
- (NSArray*) queryIPForDomain:(NSString*)domain;
- (BOOL) checkContainsIP:(NSString*)ip;
- (void) clean;
@end
