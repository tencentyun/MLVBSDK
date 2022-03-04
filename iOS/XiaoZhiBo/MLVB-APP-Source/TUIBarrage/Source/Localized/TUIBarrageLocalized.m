//
//  TUIGiftViewLocalized.m
//  Pods
//
//  Created by WesleyLei on 2021/9/7.
//  Copyright © 2021 wesleylei. All rights reserved.
//

#import "TUIBarrageLocalized.h"

#pragma mark - Base
NSBundle *TUIBarrageBundle(void) {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //没使用Framework的情况下
        NSURL *associateBundleURL = [[NSBundle mainBundle] URLForResource:@"TUIBarrageBundle" withExtension:@"bundle"];
        //使用framework形式
        if (!associateBundleURL) {
            associateBundleURL = [[NSBundle mainBundle] URLForResource:@"Frameworks" withExtension:nil];
            associateBundleURL = [associateBundleURL URLByAppendingPathComponent:@"TUIBarrage"];
            associateBundleURL = [associateBundleURL URLByAppendingPathExtension:@"framework"];
            NSBundle *associateBundle = [NSBundle bundleWithURL:associateBundleURL];
            associateBundleURL = [associateBundle URLForResource:@"TUIBarrageBundle" withExtension:@"bundle"];
        }
        bundle = [NSBundle bundleWithURL:associateBundleURL];
    });
    return bundle;
}

NSString *TUIBarrageLocalizeLanguageKey(void) {
    NSString *language = [NSLocale preferredLanguages].firstObject;
    if ([language hasPrefix:@"en"]) {
        return @"en";
    } else if ([language hasPrefix:@"zh"]) {
        return @"zh-Hans";
    } else {
        return @"en";
    }
}

NSString *TUIBarrageLocalizeFromTable(NSString *key, NSString *table) {
    //从FrameworkTestBundle.bundle中查找资源
    NSString *bundlePath = [TUIBarrageBundle() pathForResource:TUIBarrageLocalizeLanguageKey() ofType:@"lproj"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    return  [bundle localizedStringForKey:key value:@"" table:table];
}

#pragma mark - Calling
NSString *const TUIBarrage_Localize_TableName = @"Localized";
NSString *TUIBarrageLocalize(NSString *key) {
    return TUIBarrageLocalizeFromTable(key, TUIBarrage_Localize_TableName);
}

