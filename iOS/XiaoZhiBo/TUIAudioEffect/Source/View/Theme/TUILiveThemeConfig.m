//
//  TUILiveThemeConfig.m
//  TUIAudioEffect
//
//  Created by jack on 2021/9/27.
//

#import "TUILiveThemeConfig.h"
#import "TUIAudioEffectDefine.h"

@implementation TUILiveThemeConfig

+ (instancetype)defaultConfig{
    TUILiveThemeConfig *defaultTheme = [[TUILiveThemeConfig alloc] init];
    
    return defaultTheme;
}

#pragma mark - init
- (instancetype)init{
    if (self = [super init]) {
        _backgroundColor = [UIColor whiteColor];
        _themeColor = TUIAEMakeColorHexString(@"#006EFF");
        _tintColor = [UIColor blueColor];
        _textColor = [UIColor blackColor];
        _textPlaceholderColor = TUIAEMakeColorHexString(@"#999999");
        _titleFont = [UIFont systemFontOfSize:24 weight:UIFontWeightMedium];
        _normalFont = [UIFont systemFontOfSize:16];
        
    }
    return self;
}

@end
