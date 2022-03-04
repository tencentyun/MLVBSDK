//
//  TUIAudioEffectExtension.m
//  TUIAudioEffect
//
//  Created by jack on 2021/9/29.
//

#import "TUIAudioEffectExtension.h"
#import "TUIAudioEffectDefine.h"
#import "TUICore.h"
#import "TUIAudioEffectView.h"
#import "TUIAudioEffectExtensionView.h"
#import "NSDictionary+TUISafe.h"

@interface TUIAudioEffectExtension ()<TUIExtensionProtocol>

@end

@implementation TUIAudioEffectExtension

/// 注册音效组件
+ (void)load {
    [TUICore registerExtension:TUICore_TUIAudioEffectViewExtension_Extension object:[TUIAudioEffectExtension sharedInstance]];
    [TUICore registerExtension:TUICore_TUIAudioEffectViewExtension_AudioEffectView object:[TUIAudioEffectExtension sharedInstance]];
}

+ (instancetype)sharedInstance {
    static TUIAudioEffectExtension *service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[self alloc] init];
    });
    return service;
}

#pragma mark - TUIExtensionProtocol
- (NSDictionary *)getExtensionInfo:(NSString *)key param:(NSDictionary *)param {
    if (!key || ![param isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    if ([key isEqualToString:TUICore_TUIAudioEffectViewExtension_AudioEffectView]) {
        id audioEffectManager = [param tui_objectForKey:TUICore_TUIAudioEffectViewExtension_AudioEffectView_AudioEffectManager asClass:[NSObject class]];
        if (!audioEffectManager || ![audioEffectManager isKindOfClass:NSClassFromString(@"TXAudioEffectManager")]) {
            return nil;
        }
        TUIAudioEffectView *audioEffectView = [[TUIAudioEffectView alloc] initWithFrame:[UIScreen mainScreen].bounds audioEffectManager:audioEffectManager];
        return @{TUICore_TUIAudioEffectViewExtension_AudioEffectView_View : audioEffectView};
    }
    else if ([key isEqualToString:TUICore_TUIAudioEffectViewExtension_Extension]) {
        return @{TUICore_TUIAudioEffectViewExtension_Extension_View : [TUIAudioEffectExtensionView getExtensionView]};
    }
    return nil;
}


@end
