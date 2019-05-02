//
//  NSString+QCloudSHA.h
//  Pods
//
//  Created by Dong Zhao on 2017/5/2.
//
//

#import <Foundation/Foundation.h>

@interface NSString (QCloudSHA)
- (NSString *)qcloud_sha1;
+ (NSString *)qcloudHMACHexsha1:(NSString *)data secret:(NSString *)key;
+ (NSData *)qcloudHmacSha1Data:(NSString *)data secret:(NSString *)key;
@end
