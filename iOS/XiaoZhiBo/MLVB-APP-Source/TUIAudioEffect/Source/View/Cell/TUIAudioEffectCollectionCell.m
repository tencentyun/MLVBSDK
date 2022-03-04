//
//  TUIAudioEffectCollectionCell.m
//  TUIAudioEffect
//
//  Created by jack on 2021/9/27.
//

#import "TUIAudioEffectCollectionCell.h"
#import "TUIAudioEffectDefine.h"

@interface TUIAudioEffectCollectionCell ()

@end

@implementation TUIAudioEffectCollectionCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.titleLabel];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(50);
        make.leading.trailing.top.mas_equalTo(0);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(0);
        make.top.mas_equalTo(_imageView.mas_bottom).mas_offset(4);
    }];
}

#pragma mark - updateUI
- (void)updateUIWithVoiceChange:(TUIAudioEffectVoiceChangeType)voiceChange selected:(BOOL)selected{
    NSString *imageName = @"";
    if (voiceChange == TXVoiceChangeType_0) {
        _titleLabel.text = AudioEffectLocalize(@"TUIKit.AudioEffectView.VoiceChange.Original");
        imageName = selected ? @"audioeffect_originState_sel":@"audioeffect_originState_nor";
    }
    if (voiceChange == TXVoiceChangeType_1) {
        _titleLabel.text = AudioEffectLocalize(@"TUIKit.AudioEffectView.VoiceChange.Naughty boy");
        imageName = selected ? @"audioeffect_voiceChange_xionghaizi_sel":@"audioeffect_voiceChange_xionghaizi_nor";
    }
    if (voiceChange == TXVoiceChangeType_2) {
        _titleLabel.text = AudioEffectLocalize(@"TUIKit.AudioEffectView.VoiceChange.Little girl");
        imageName = selected ? @"audioeffect_voiceChange_loli_sel":@"audioeffect_voiceChange_loli_nor";
    }
    if (voiceChange == TXVoiceChangeType_3) {
        _titleLabel.text = AudioEffectLocalize(@"TUIKit.AudioEffectView.VoiceChange.Middle-aged man");
        imageName = selected ? @"audioeffect_voiceChange_dashu_sel":@"audioeffect_voiceChange_dashu_nor";
    }
    if (voiceChange == TXVoiceChangeType_11) {
        _titleLabel.text = AudioEffectLocalize(@"TUIKit.AudioEffectView.VoiceChange.Ethereal voice");
        imageName = selected ? @"audioeffect_voiceChange_kongling_sel":@"audioeffect_voiceChange_kongling_nor";
    }
    _imageView.image = TUIAEImageNamed(imageName);
    _titleLabel.highlighted = selected;
}

- (void)updateUIWithVoiceReverb:(TUIAudioEffectVoiceReverbType)voiceReverb selected:(BOOL)selected{
    NSString *imageName = @"";
    if (voiceReverb == TXVoiceReverbType_0) {
        _titleLabel.text = AudioEffectLocalize(@"TUIKit.AudioEffectView.VoiceReverb.No effect");
        imageName = selected ? @"audioeffect_originState_sel":@"audioeffect_originState_nor";
    }
    if (voiceReverb == TXVoiceReverbType_1) {
        _titleLabel.text = AudioEffectLocalize(@"TUIKit.AudioEffectView.VoiceReverb.Karaoke room");
        imageName = selected ? @"audioeffect_Reverb_Karaoke_sel":@"audioeffect_Reverb_Karaoke_nor";
    }
    if (voiceReverb == TXVoiceReverbType_6) {
        _titleLabel.text = AudioEffectLocalize(@"TUIKit.AudioEffectView.VoiceReverb.Metallic");
        imageName = selected ? @"audioeffect_Reverb_jinshu_sel":@"audioeffect_Reverb_jinshu_nor";
    }
    if (voiceReverb == TXVoiceReverbType_4) {
        _titleLabel.text = AudioEffectLocalize(@"TUIKit.AudioEffectView.VoiceReverb.Deep");
        imageName = selected ? @"audioeffect_Reverb_dichen_sel":@"audioeffect_Reverb_dichen_nor";
    }
    if (voiceReverb == TXVoiceReverbType_5) {
        _titleLabel.text = AudioEffectLocalize(@"TUIKit.AudioEffectView.VoiceReverb.Resonant");
        imageName = selected ? @"audioeffect_Reverb_hongliang_sel":@"audioeffect_Reverb_hongliang_nor";
    }
    _imageView.image = TUIAEImageNamed(imageName);
    _titleLabel.highlighted = selected;
}

#pragma mark - setter
- (void)setThemeConfig:(TUILiveThemeConfig *)themeConfig{
    _themeConfig = themeConfig;
    _titleLabel.highlightedTextColor = themeConfig.themeColor;
}

#pragma mark - getter
+ (NSString *)reuseId{
    return [NSString stringWithFormat:@"ReuseId_%@", NSStringFromClass([self class])];
}

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _imageView.contentMode = UIViewContentModeScaleToFill;
    }
    return _imageView;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = UIColor.blackColor;
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.minimumScaleFactor = 0.5;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = TUIAEMakeColorHexString(@"#666666");
        _titleLabel.highlightedTextColor = TUIAEMakeColorHexString(@"#006EFF");
    }
    return _titleLabel;
}

@end
