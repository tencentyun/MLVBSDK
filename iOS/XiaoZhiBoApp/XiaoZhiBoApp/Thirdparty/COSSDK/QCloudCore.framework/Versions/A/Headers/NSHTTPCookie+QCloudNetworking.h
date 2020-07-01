//
//  NSHTTPCookie+QCloudNetworking.h
//  QCloudNetworking
//
//  Created by tencent on 15/9/29.
//  Copyright © 2015年 QCloudTernimalLab. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSArray* QCloudFuseAndUpdateCookiesArray(NSArray* source, NSArray* aim);
@interface NSHTTPCookie (QCloudNetworking)
- (BOOL) isEqualToQCloudCookie:(NSHTTPCookie*)c;
@end
