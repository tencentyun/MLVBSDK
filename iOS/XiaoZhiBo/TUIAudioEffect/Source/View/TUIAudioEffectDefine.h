//
//  TUIAudioEffectDefine.h
//  Pods
//
//  Created by jack on 2021/9/27.
//

#ifndef TUIAudioEffectDefine_h
#define TUIAudioEffectDefine_h

#import "TUIDefine.h"
#import "Masonry.h"

#import "AudioEffectLocalized.h"

// Categories
#import "UIColor+TUIHexColor.h"
#import "UIView+TUIUtil.h"

// Theme
#import "TUILiveThemeConfig.h"
// Model
#import "TUIAudioEffectModel.h"

#import "txg_log_audio.h"

#define TUIAudioEffectBundle          AudioEffectBundle()
#define TUIAEImageNamed(imageName) [UIImage imageNamed:imageName inBundle:TUIAudioEffectBundle compatibleWithTraitCollection:nil]

#define TUIAEMakeColorHexString(hexString) [UIColor colorWithHex:hexString]

#endif /* TUIAudioEffectDefine_h */
