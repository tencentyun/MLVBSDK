//
//  TUIAudioEffectExtensionView.m
//  TUIAudioEffect
//
//  Created by jack on 2021/9/29.
//

#import "TUIAudioEffectExtensionView.h"
#import "TUIAudioEffectDefine.h"

@implementation TUIAudioEffectExtensionView

+ (__kindof UIView *)getExtensionView {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:TUIAEImageNamed(@"audioeffect_audioEffect") forState:UIControlStateNormal];
    [btn sizeToFit];
    return btn;
}


@end
