//
//  PlayerLocalized.h
//  Pods
//
//  Created by gg on 2021/9/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Base

extern NSBundle *PlayerBundle(void);

#pragma mark - Replace String

extern NSString *LocalizeReplaceXX(NSString *origin, NSString *xxx_replace);
extern NSString *LocalizeReplace(NSString *origin, NSString *xxx_replace, NSString *yyy_replace);

#pragma mark - Player

extern NSString *const Player_Localize_TableName;
extern NSString *PlayerLocalize(NSString *key);

NS_ASSUME_NONNULL_END
