//
//  TUIGiftViewLocalized.m
//  Pods
//
//  Created by WesleyLei on 2021/9/7.
//  Copyright © 2021 wesleylei. All rights reserved.
//

#import "TUIGiftLocalized.h"

#pragma mark - Base

NSBundle *TUIGiftBundle(void) {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //没使用Framework的情况下
        NSURL *associateBundleURL = [[NSBundle mainBundle] URLForResource:@"TUIGiftBundle" withExtension:@"bundle"];
        //使用framework形式
        if (!associateBundleURL) {
            associateBundleURL = [[NSBundle mainBundle] URLForResource:@"Frameworks" withExtension:nil];
            associateBundleURL = [associateBundleURL URLByAppendingPathComponent:@"TUIGift"];
            associateBundleURL = [associateBundleURL URLByAppendingPathExtension:@"framework"];
            NSBundle *associateBundle = [NSBundle bundleWithURL:associateBundleURL];
            associateBundleURL = [associateBundle URLForResource:@"TUIGiftBundle" withExtension:@"bundle"];
        }
        bundle = [NSBundle bundleWithURL:associateBundleURL];
    });
    return bundle;
}

NSString *TUIGiftLocalizeLanguageKey(void) {
    NSString *language = [NSLocale preferredLanguages].firstObject;
    if ([language hasPrefix:@"en"]) {
        return @"en";
    } else if ([language hasPrefix:@"zh"]) {
        return @"zh-Hans";
    } else {
        return @"en";
    }
}

NSString *TUIGiftLocalizeFromTable(NSString *key, NSString *table) {
    //从FrameworkTestBundle.bundle中查找资源
    NSString *bundlePath = [TUIGiftBundle() pathForResource:TUIGiftLocalizeLanguageKey() ofType:@"lproj"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    return  [bundle localizedStringForKey:key value:@"" table:table];
}

#pragma mark - Calling

NSString *const TUIGift_Localize_TableName = @"Localized";
NSString *TUIGiftLocalize(NSString *key) {
    return TUIGiftLocalizeFromTable(key, TUIGift_Localize_TableName);
}
