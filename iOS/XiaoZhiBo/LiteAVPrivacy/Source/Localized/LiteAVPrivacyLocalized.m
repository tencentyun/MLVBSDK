//
//  LiteAVPrivacyLocalized.m
//  LiteAVPrivacy-LiteAVPrivacyKitBundle
//
//  Created by jack on 2022/2/10.
//

#import "LiteAVPrivacyLocalized.h"

#pragma mark - Base

NSBundle *LiteAVPrivacyBundle(void) {
    NSURL *liteAVPrivacyKitBundleURL = [[NSBundle mainBundle] URLForResource:@"LiteAVPrivacyKitBundle" withExtension:@"bundle"];
    return [NSBundle bundleWithURL:liteAVPrivacyKitBundleURL];
}
       
NSString *LiteAVPrivacyLocalizeFromTable(NSString *key, NSString *table) {
    return [LiteAVPrivacyBundle() localizedStringForKey:key value:@"" table:table];
}

#pragma mark - LiteAVPrivacy

NSString *const LiteAVPrivacy_Localize_TableName = @"LiteAVPrivacyLocalized";
NSString *LiteAVPrivacyLocalize(NSString *key) {
    return LiteAVPrivacyLocalizeFromTable(key, LiteAVPrivacy_Localize_TableName);
}

