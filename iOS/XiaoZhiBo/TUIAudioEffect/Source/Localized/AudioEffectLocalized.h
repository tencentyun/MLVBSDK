//
//  AudioEffectLocalized.h
//  TUIAudioEffect
//
//  Created by jack on 2021/9/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Base

extern NSBundle *AudioEffectBundle(void);

#pragma mark - Replace String

extern NSString *LocalizeReplaceXX(NSString *origin, NSString *xxx_replace);
extern NSString *LocalizeReplace(NSString *origin, NSString *xxx_replace, NSString *yyy_replace);

#pragma mark - AudioEffect String

extern NSString *const AudioEffect_Localize_TableName;
extern NSString *AudioEffectLocalize(NSString *key);

NS_ASSUME_NONNULL_END
