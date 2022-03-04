//
//  LiteAVPrivacyConfig.m
//  LiteAVPrivacy
//
//  Created by jack on 2022/2/10.
//

#import "LiteAVPrivacyConfig.h"

NSString *const kLiteAVPrivacyURLKey = @"privacyURL";
NSString *const kLiteAVPrivacyUserProtocolKey = @"userProtocolURL";
NSString *const kLiteAVPrivacyVersionKey = @"version";
NSString *const kLiteAVPrivacyPersonalAuthKey = @"personalAuth";
NSString *const kLiteAVPrivacyDataCollectionKey = @"dataCollection";
NSString *const kLiteAVPrivacyThirdShareKey = @"thirdShare";

@interface LiteAVPrivacyConfig ()

@property (strong, nonatomic) NSDictionary *plistInfo;

@end

@implementation LiteAVPrivacyConfig

#pragma mark - Getter
- (NSDictionary *)plistInfo {
    if (!_plistInfo) {
        _plistInfo = [self readPlistInfoFromPath:_plistPath];
    }
    return _plistInfo;
}

- (NSDictionary *)readPlistInfoFromPath:(NSString *)plistPath {
    if (plistPath && [plistPath isKindOfClass:[NSString class]] && plistPath.length > 0) {
        return [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    }
    return nil;
}

@end

@implementation LiteAVPrivacyConfig (UIMode)

- (UIColor *)backgroundColor {
    if (_style == LiteAVPrivacyUIStyleDark) {
        return [UIColor colorWithRed:(19.0/255.0) green:(41.0/255.0) blue:(75.0/255.0) alpha:1];
    }
    return [UIColor whiteColor];
}

- (UIColor *)textColor {
    if (_style == LiteAVPrivacyUIStyleDark) {
        return [UIColor whiteColor];
    }
    return [UIColor blackColor];
}

- (UIColor *)detailColor {
    return [UIColor grayColor];
}

@end
