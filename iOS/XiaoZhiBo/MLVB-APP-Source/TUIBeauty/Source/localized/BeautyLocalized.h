//
//  BeautyLocalized.h
//  Pods
//
//  Created by gg on 2021/9/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Base

extern NSBundle *BeautyBundle(void);

#pragma mark - Replace String

extern NSString *LocalizeReplaceXX(NSString *origin, NSString *xxx_replace);
extern NSString *LocalizeReplace(NSString *origin, NSString *xxx_replace, NSString *yyy_replace);

#pragma mark - Beauty

extern NSString *const Beauty_Localize_TableName;
extern NSString *BeautyLocalize(NSString *key);

NS_ASSUME_NONNULL_END
