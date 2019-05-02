//
//  QCloudAuthentationHeadV5Creator.m
//  TCLVBIMDemo
//
//  Created by carolsuo on 2017/10/24.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "QCloudAuthentationHeadV5Creator.h"
#import <QCloudCore/QCloudSignature.h>
#import <QCloudCore/QCloudCredential.h>
#import <QCloudCore/QCloudSignatureFields.h>
#import <QCloudCore/QCloudHTTPRequest.h>
#import <QCloudCore/QCloudRequestSerializer.h>
#import <QCloudCore/NSString+QCloudSHA.h>
#import <CommonCrypto/CommonDigest.h>

@implementation QCloudAuthentationHeadV5Creator
- (instancetype) initWithSignKey:(NSString *) secretID
                         signKey:(NSString *) signKey
                         keyTime:(NSString *) keyTime
{
    self = [super init];
    if (!self) {
        return self;
    }
    _secretID = secretID;
    _signKey = signKey;
    _keyTime = keyTime;
    
    return self;
}

- (void) setSignKey:(NSString *) secretID
            signKey:(NSString *) signKey
            keyTime:(NSString *) keyTime;
{
    _secretID = secretID;
    _signKey = signKey;
    _keyTime = keyTime;
}

- (QCloudSignature*) signatureForData:(NSMutableURLRequest *)urlrequest
{
    NSDictionary* headers = [urlrequest allHTTPHeaderFields];
    
    NSDictionary* urlParamters = QCloudURLReadQuery(urlrequest.URL);
    NSDictionary* (^LowcaseDictionary)(NSDictionary* origin) = ^(NSDictionary* origin) {
        NSMutableDictionary* aim = [NSMutableDictionary new];
        NSArray* allKeys = origin.allKeys;
        
        for (NSString* key in allKeys) {
            NSString* transKey = key;
            if (![key isKindOfClass:[NSString class]]) {
                transKey = [NSString stringWithFormat:@"%@",key];
            }
            NSString* value = origin[key];
            aim[transKey.lowercaseString] = value;
        }
        return [aim copy];
    };
    
    // Step1 构成FormatString
    NSString* headerFormat = QCloudURLEncodeParamters(LowcaseDictionary(headers), YES, NSUTF8StringEncoding);
    NSString* urlFormat = QCloudURLEncodeParamters(LowcaseDictionary(urlParamters), YES, NSUTF8StringEncoding);
    
    NSMutableString* formatString = [NSMutableString new];
    
    void(^AppendFormatString)(NSString*) = ^(NSString* part) {
        [formatString appendFormat:@"%@\n",part];
    };
    
    AppendFormatString(urlrequest.HTTPMethod.lowercaseString);
    NSString* path = urlrequest.URL.path;
    if (path.length == 0) {
        path = @"/";
    }
    AppendFormatString(path);
    AppendFormatString(urlFormat);
    AppendFormatString(headerFormat);
    
    NSString* formatStringSHA = [formatString qcloud_sha1];
    
    // step 2 计算StringToSign
    NSString* stringToSign = [NSString stringWithFormat:@"%@\n%@\n%@\n", @"sha1", _keyTime , formatStringSHA];
    
    // step 3 计算签名
    NSString* signature = [NSString qcloudHMACHexsha1:stringToSign secret:_signKey];
    
    // step 4 构造Authorization
    
    NSString* (^DumpAllKeys)(NSDictionary*) = ^(NSDictionary* info) {
        NSArray* keys = info.allKeys;
        
        NSMutableArray* redirectKeys = [NSMutableArray new];
        for (NSString* key in keys) {
            [redirectKeys addObject:key.lowercaseString];
        }
        [redirectKeys sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
        
        NSString* keyString = @"";
        for (int i = 0; i < redirectKeys.count; i ++) {
            keyString = [keyString stringByAppendingString:redirectKeys[i]];
            if (i < (int)redirectKeys.count -1) {
                keyString = [keyString stringByAppendingString:@";"];
            }
        }
        return keyString;
    };
    
    //key有效期
    NSString* authoration = [NSString stringWithFormat:@"q-sign-algorithm=sha1&q-ak=%@&q-sign-time=%@&q-key-time=%@&q-header-list=%@&q-url-param-list=%@&q-signature=%@", _secretID, _keyTime, _keyTime, DumpAllKeys(headers), DumpAllKeys(urlParamters) ,signature];
    QCloudLogDebug(@"authoration is %@", authoration);
    return [QCloudSignature signatureWith1Day:authoration];
}
@end
