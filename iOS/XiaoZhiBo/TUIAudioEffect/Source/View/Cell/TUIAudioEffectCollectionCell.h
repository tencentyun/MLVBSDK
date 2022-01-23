//
//  TUIAudioEffectCollectionCell.h
//  TUIAudioEffect
//
//  Created by jack on 2021/9/27.
//

#import <UIKit/UIKit.h>
#import "TUIAudioEffectModel.h"

@class TUILiveThemeConfig;
@interface TUIAudioEffectCollectionCell : UICollectionViewCell

// UI配置文件
@property (nonatomic, strong) TUILiveThemeConfig *themeConfig;

// Cell重用Id
@property (nonatomic, readonly, class) NSString *reuseId;
// Icon
@property (nonatomic, strong) UIImageView *imageView;
// 标题
@property (nonatomic, strong) UILabel *titleLabel;

// 更新变声
- (void)updateUIWithVoiceChange:(TUIAudioEffectVoiceChangeType)voiceChange selected:(BOOL)selected;

// 更新混响
- (void)updateUIWithVoiceReverb:(TUIAudioEffectVoiceReverbType)voiceReverb selected:(BOOL)selected;

@end






