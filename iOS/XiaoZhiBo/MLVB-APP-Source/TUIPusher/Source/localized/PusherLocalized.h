//
//  PusherLocalized.h
//  Pods
//
//  Created by gg on 2021/9/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Base

extern NSBundle *PusherBundle(void);

#pragma mark - Replace String

extern NSString *LocalizeReplaceXX(NSString *origin, NSString *xxx_replace);
extern NSString *LocalizeReplace(NSString *origin, NSString *xxx_replace, NSString *yyy_replace);

#pragma mark - TRTC

extern NSString *const Pusher_Localize_TableName;
extern NSString *PusherLocalize(NSString *key);

NS_ASSUME_NONNULL_END
