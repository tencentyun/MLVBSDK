//
//  PlayerLocalized.m
//  Pods
//
//  Created by gg on 2021/9/14.
//

#import "PlayerLocalized.h"

#pragma mark - Base

NSBundle *PlayerBundle(void) {
    NSURL *playerKitBundleURL = [[NSBundle mainBundle] URLForResource:@"TUIPlayerKitBundle" withExtension:@"bundle"];
    return [NSBundle bundleWithURL:playerKitBundleURL];
}

NSString *TPLLocalizeFromTable(NSString *key, NSString *table) {
    return [PlayerBundle() localizedStringForKey:key value:@"" table:table];
}

NSString *TPLLocalizeFromTableAndCommon(NSString *key, NSString *common, NSString *table) {
    return TPLLocalizeFromTable(key, table);
}

#pragma mark - Replace String

NSString *LocalizeReplaceXX(NSString *origin, NSString *xxx_replace) {
    if (xxx_replace == nil) { xxx_replace = @"";}
    return [origin stringByReplacingOccurrencesOfString:@"xxx" withString:xxx_replace];
}

NSString *LocalizeReplace(NSString *origin, NSString *xxx_replace, NSString *yyy_replace) {
    if (yyy_replace == nil) { yyy_replace = @"";}
    return [LocalizeReplaceXX(origin, xxx_replace) stringByReplacingOccurrencesOfString:@"yyy" withString:yyy_replace];
}

NSString *LocalizeReplaceThreeCharacter(NSString *origin, NSString *xxx_replace, NSString *yyy_replace, NSString *zzz_replace) {
    if (zzz_replace == nil) { zzz_replace = @"";}
    return [LocalizeReplace(origin, xxx_replace, yyy_replace) stringByReplacingOccurrencesOfString:@"zzz" withString:zzz_replace];
}

NSString *LocalizeReplaceFourCharacter(NSString *origin, NSString *xxx_replace, NSString *yyy_replace, NSString *zzz_replace, NSString *mmm_replace) {
    if (mmm_replace == nil) { mmm_replace = @"";}
    return [LocalizeReplaceThreeCharacter(origin, xxx_replace, yyy_replace, zzz_replace) stringByReplacingOccurrencesOfString:@"mmm" withString:mmm_replace];
}

NSString *LocalizeReplaceFiveCharacter(NSString *origin, NSString *xxx_replace, NSString *yyy_replace, NSString *zzz_replace, NSString *mmm_replace, NSString *nnn_replace) {
    if (nnn_replace == nil) { nnn_replace = @"";}
    return [LocalizeReplaceFourCharacter(origin, xxx_replace, yyy_replace, zzz_replace, mmm_replace) stringByReplacingOccurrencesOfString:@"nnn" withString:nnn_replace];
}

#pragma mark - Player

NSString *const Player_Localize_TableName = @"PlayerLocalized";
NSString *PlayerLocalize(NSString *key) {
    return TPLLocalizeFromTable(key, Player_Localize_TableName);
}
