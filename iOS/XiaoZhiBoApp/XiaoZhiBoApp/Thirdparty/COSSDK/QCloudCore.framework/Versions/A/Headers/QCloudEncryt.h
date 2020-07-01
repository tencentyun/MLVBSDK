//
//  QCloudEncryt.h
//  Pods
//
//  Created by Dong Zhao on 2017/6/6.
//
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSString* QCloudEncrytNSDataMD5Base64(NSData* data);
FOUNDATION_EXPORT NSString* QCloudEncrytNSDataMD5(NSData* data);
FOUNDATION_EXTERN NSString* QCloudEncrytFileMD5Base64(NSString* filePath);
FOUNDATION_EXTERN NSString* QCloudEncrytFileMD5(NSString* filePath);
FOUNDATION_EXTERN NSString* QCloudEncrytFileOffsetMD5Base64(NSString* filePath, int64_t offset , int64_t siliceLength);
FOUNDATION_EXTERN NSString* QCloudEncrytFileOffsetMD5(NSString* filePath, int64_t offset , int64_t siliceLength);
FOUNDATION_EXTERN NSString* QCloudEncrytMD5String(NSString* originString);
FOUNDATION_EXTERN NSString* QCloudHmacSha1Encrypt(NSString *data , NSString* key);
