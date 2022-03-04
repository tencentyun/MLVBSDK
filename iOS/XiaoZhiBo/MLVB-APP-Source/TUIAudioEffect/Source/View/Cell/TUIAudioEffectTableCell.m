//
//  TUIAudioEffectTableCell.m
//  TUIAudioEffect
//
//  Created by jack on 2021/9/27.
//

#import "TUIAudioEffectTableCell.h"
#import "TUIAudioEffectDefine.h"
#import "TUIAudioEffectView.h"
#import "TUILiveThemeConfig.h"
#import "TUIAudioEffectCollectionCell.h"

//** TUIAudioEffectBaseTableCell **//
@interface TUIAudioEffectBaseTableCell ()

@property (nonatomic, strong) TUIAudioEffectModel *effectModel;

@property (nonatomic, assign) TUIAudioEffectType effectType;

@property (nonatomic, strong) TUILiveThemeConfig *themeConfig;

@end

@implementation TUIAudioEffectBaseTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

#pragma mark - Public
- (void)setupUI{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self.contentView addSubview:self.titleLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(12);
        make.leading.mas_equalTo(20);
    }];
}

- (void)updateUIWithThemeConfig:(TUILiveThemeConfig *)themeConfig{
    self.themeConfig = themeConfig;
    self.contentView.backgroundColor = themeConfig.backgroundColor;
    self.titleLabel.textColor = themeConfig.textColor;
    self.titleLabel.font = themeConfig.normalFont;
}

- (void)updateUIWithData:(TUIAudioEffectModel *)data type:(TUIAudioEffectType)type{
    _effectModel = data;
    _effectType = type;
    if (type == TUIAudioEffectTypeVoiceChange) {
        _titleLabel.text = AudioEffectLocalize(@"TUIKit.AudioEffectView.VoiceChange.title");
    }
    if (type == TUIAudioEffectTypeVoiceReverb) {
        _titleLabel.text = AudioEffectLocalize(@"TUIKit.AudioEffectView.VoiceReverb.title");
    }
    if (type == TUIAudioEffectTypeMusicBackground) {
        _titleLabel.text = AudioEffectLocalize(@"TUIKit.AudioEffectView.MusicBackground.earMonitor");
    }
    if (type == TUIAudioEffectTypeCopyrightLibrary) {
        _titleLabel.text = AudioEffectLocalize(@"TUIKit.AudioEffectView.MusicSelect.copyrights");
    }
    if (type == TUIAudioEffectTypeMusicVolume) {
        _titleLabel.text = AudioEffectLocalize(@"TUIKit.AudioEffectView.MusicVolum.title");
    }
    if (type == TUIAudioEffectTypeVoiceVolume) {
        _titleLabel.text = AudioEffectLocalize(@"TUIKit.AudioEffectView.VoiceVolum.title");
    }
    if (type == TUIAudioEffectTypeMusicRiseFall) {
        _titleLabel.text = AudioEffectLocalize(@"TUIKit.AudioEffectView.MusicRiseFall.title");
    }
}

#pragma mark - Getter
+ (NSString *)reuseId{
    return [NSString stringWithFormat:@"ReuseId_%@", NSStringFromClass([self class])];
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    }
    return _titleLabel;
}

@end

//** TUIAudioEffectNoneTableCell **//
//- None(兼容)
@implementation TUIAudioEffectNoneTableCell
- (void)setupUI{
    [super setupUI];
    self.titleLabel.text = @"none";
}
@end


//** TUIAudioEffectBGMSelectTableCell **//
@interface TUIAudioEffectBGMSelectTableCell ()

@property (nonatomic, strong) UIView *selectContentView;

@property (nonatomic, strong) UIImageView *arrowImageView;

@property (nonatomic, strong) UILabel *selectLabel;

@property (nonatomic, strong) UIView *playContentView;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UIButton *playBtn;

@end

@implementation TUIAudioEffectBGMSelectTableCell

- (void)setupUI{
    [super setupUI];
    [self.contentView addSubview:self.playContentView];
    [self.contentView addSubview:self.selectContentView];
    
    [self.playContentView addSubview:self.timeLabel];
    [self.playContentView addSubview:self.playBtn];
    
    [self.selectContentView addSubview:self.selectLabel];
    [self.selectContentView addSubview:self.arrowImageView];
    
    [self.playContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(-20);
        make.centerY.mas_equalTo(self.titleLabel);
        make.height.mas_equalTo(40);
    }];
    [self.selectContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(-20);
        make.centerY.mas_equalTo(self.titleLabel);
        make.height.mas_equalTo(40);
    }];
    
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(0);
        make.top.bottom.mas_equalTo(0);
    }];
    [_playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(0);
        make.centerY.mas_equalTo(self.timeLabel);
        make.leading.mas_equalTo(self.timeLabel.mas_trailing).mas_offset(10);
    }];
    
    [_selectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(0);
        make.top.bottom.mas_equalTo(0);
    }];
    [_arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(0);
        make.centerY.mas_equalTo(self.selectLabel);
        make.leading.mas_equalTo(self.selectLabel.mas_trailing).mas_offset(10);
    }];
}

- (void)updateUIWithThemeConfig:(TUILiveThemeConfig *)themeConfig{
    [super updateUIWithThemeConfig:themeConfig];
    [_selectLabel setTextColor:themeConfig.textPlaceholderColor];
}

- (void)updateUIWithData:(TUIAudioEffectModel *)data type:(TUIAudioEffectType)type{
    [super updateUIWithData:data type:type];
    if (self.effectModel.selectBGMModel) {
        
        [_selectContentView setHidden:YES];
        [_playContentView setHidden:NO];
        // 播放状态
        [_playBtn setSelected:self.effectModel.musicPlaying];
        
        self.titleLabel.text = self.effectModel.selectBGMModel.name;
        [self updatePlayingTimeWithProgressMs:self.effectModel.selectBGMModel.currentProgressMs durationMs:self.effectModel.selectBGMModel.totalDurationMs];
    } else {
        
        [_selectContentView setHidden:NO]; 
        [_playContentView setHidden:YES];
        
        self.titleLabel.text = AudioEffectLocalize(@"TUIKit.AudioEffectView.MusicSelect.copyrights");
        _timeLabel.text = @"00/00";
    }
}

- (void)updatePlayingTimeWithProgressMs:(NSInteger)progressMs durationMs:(NSInteger)durationMs{
    NSString *currentTime = [self stringFromSecond:progressMs/1000];
    NSString *totalTime = [self stringFromSecond:durationMs/1000];
    self.timeLabel.text = [NSString stringWithFormat:@"%@/%@", currentTime, totalTime];
}

- (NSString *)stringFromSecond:(NSInteger)second{
    NSInteger min = second / 60;
    NSInteger sec = second % 60;
    
    NSString *minString = min > 9 ? [NSString stringWithFormat:@"%@", @(min)] : [NSString stringWithFormat:@"0%@", @(min)];
    NSString *secString = sec > 9 ? [NSString stringWithFormat:@"%@", @(sec)] : [NSString stringWithFormat:@"0%@", @(sec)];
    
    return [NSString stringWithFormat:@"%@:%@", minString,secString];
}

#pragma mark - action
- (void)controlPlay{
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioEffectControlWithModel:musicPlaying:)]) {
        [_playBtn setSelected:!_playBtn.isSelected];
        [self.delegate audioEffectControlWithModel:self.effectModel musicPlaying:_playBtn.isSelected];
    }
}

#pragma mark - getter
- (UIView *)selectContentView{
    if (!_selectContentView) {
        _selectContentView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _selectContentView;
}

- (UILabel *)selectLabel{
    if (!_selectLabel) {
        _selectLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _selectLabel.font = [UIFont systemFontOfSize:16];
        _selectLabel.textColor = TUIAEMakeColorHexString(@"#999999");
        _selectLabel.text = AudioEffectLocalize(@"TUIKit.AudioEffectView.MusicSelect.select");
    }
    return _selectLabel;
}

- (UIImageView *)arrowImageView{
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _arrowImageView.contentMode = UIViewContentModeScaleAspectFit;
        _arrowImageView.image = TUIAEImageNamed(@"audioeffect_detail");
    }
    return _arrowImageView;
}

- (UIView *)playContentView{
    if (!_playContentView) {
        _playContentView = [[UIView alloc] initWithFrame:CGRectZero];
        [_playContentView setHidden:YES];
    }
    return _playContentView;
}

- (UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.font = [UIFont systemFontOfSize:16];
        _timeLabel.textColor = TUIAEMakeColorHexString(@"#999999");
        _timeLabel.text = @"00/00";
    }
    return _timeLabel;
}

- (UIButton *)playBtn{
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setImage:TUIAEImageNamed(@"audioeffect_bgm_play") forState:UIControlStateNormal];
        [_playBtn setImage:TUIAEImageNamed(@"audioeffect_bgm_pause") forState:UIControlStateSelected];
        [_playBtn addTarget:self action:@selector(controlPlay) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}
@end


@interface TUIAudioEffectSwitchTableCell ()

@end

@implementation TUIAudioEffectSwitchTableCell

- (void)setupUI{
    [super setupUI];
    [self.contentView addSubview:self.descLabel];
    [self.contentView addSubview:self.switchView];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleLabel.mas_trailing).mas_offset(8);
        make.centerY.mas_equalTo(self.titleLabel);
        make.trailing.mas_lessThanOrEqualTo(self.switchView.mas_leading).mas_offset(-20);
    }];
    [self.switchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(-20);
        make.centerY.mas_equalTo(self.titleLabel);
    }];
}

- (void)updateUIWithThemeConfig:(TUILiveThemeConfig *)themeConfig{
    [super updateUIWithThemeConfig:themeConfig];
    [_switchView setOnTintColor:themeConfig.themeColor];
    
    _descLabel.textColor = themeConfig.textPlaceholderColor;
    _descLabel.text = AudioEffectLocalize(@"TUIKit.AudioEffectView.MusicBackground.useEarphones");
}

- (void)updateUIWithData:(TUIAudioEffectModel *)data type:(TUIAudioEffectType)type{
    [super updateUIWithData:data type:type];
    [self.switchView setOn:data.musicBackgroundStatus animated:NO];
}

#pragma mark - action
- (void)switchValueChanged{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(audioEffectControlWithModel:musicBackgroundStatus:)]) {
//        [self.delegate audioEffectControlWithModel:self.effectModel musicBackgroundStatus:_switchView.isOn];
//    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioEffectControlWithModel:enableVoiceEarMonitor:)]) {
        [self.delegate audioEffectControlWithModel:self.effectModel enableVoiceEarMonitor:_switchView.isOn];
    }
}


#pragma mark - getter
- (UISwitch *)switchView{
    if (!_switchView) {
        _switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        [_switchView setOnTintColor:TUIAEMakeColorHexString(@"#006EFF")];
        [_switchView addTarget:self action:@selector(switchValueChanged) forControlEvents:UIControlEventValueChanged];
    }
    return _switchView;
}

- (UILabel *)descLabel{
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _descLabel.font = [UIFont systemFontOfSize:12];
        _descLabel.textColor = TUIAEMakeColorHexString(@"#999999");
        _descLabel.numberOfLines = 2;
        _descLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _descLabel;
}

@end


//** TUIAudioEffectSlider **/
@interface TUIAudioEfectSlider : UISlider

@end

@implementation TUIAudioEfectSlider

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value{
    CGFloat edge = 4;
    CGRect customRect = rect;
    customRect.origin.x -= edge;
    customRect.size.width += (2 * edge);
    return CGRectInset([super thumbRectForBounds:bounds trackRect:customRect value:value], edge, edge);
}

@end

//** TUIAudioEffectSliderTableCell **//
@interface TUIAudioEffectSliderTableCell ()

@end

@implementation TUIAudioEffectSliderTableCell

- (void)setupUI{
    [super setupUI];
    
    [self.contentView addSubview:self.sliderView];
    [self.contentView addSubview:self.valueLabel];
    
    [self.sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel);
        make.trailing.mas_equalTo(self.valueLabel.mas_leading).mas_offset(-10);
        make.leading.mas_equalTo(130);
    }];
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel);
        make.trailing.mas_equalTo(-10);
        make.width.mas_equalTo(50);
    }];
}

- (void)updateUIWithThemeConfig:(TUILiveThemeConfig *)themeConfig{
    [super updateUIWithThemeConfig:themeConfig];
    _valueLabel.textColor = themeConfig.textColor;
//    _valueLabel.font = themeConfig.normalFont;
    _valueLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    
    [_sliderView setMinimumTrackTintColor:themeConfig.themeColor];
}

- (void)updateUIWithData:(TUIAudioEffectModel *)data type:(TUIAudioEffectType)type{
    [super updateUIWithData:data type:type];
    if (self.effectType == TUIAudioEffectTypeMusicVolume) {
        _sliderView.minimumValue = 0;
        _sliderView.maximumValue = 100;
        [_sliderView setValue:data.musicVolume animated:NO];
        _valueLabel.text = [NSString stringWithFormat:@"%@", @(data.musicVolume)];
    }
    if (self.effectType == TUIAudioEffectTypeVoiceVolume) {
        _sliderView.minimumValue = 0;
        _sliderView.maximumValue = 100;
        [_sliderView setValue:data.voiceVolume animated:NO];
        _valueLabel.text = [NSString stringWithFormat:@"%@", @(data.voiceVolume)];
    }
    if (self.effectType == TUIAudioEffectTypeMusicRiseFall) {
        _sliderView.minimumValue = -1.0;
        _sliderView.maximumValue = 1.0;
        [_sliderView setValue:data.musicRiseFallValue animated:NO];
        _valueLabel.text = [NSString stringWithFormat:@"%.2f", data.musicRiseFallValue];
    }
}

#pragma mark - updateValueLabel
- (void)updateSlideValue{
    if (self.effectType == TUIAudioEffectTypeMusicVolume) {
        _valueLabel.text = [NSString stringWithFormat:@"%.0f", _sliderView.value];
    }
    if (self.effectType == TUIAudioEffectTypeVoiceVolume) {
        _valueLabel.text = [NSString stringWithFormat:@"%.0f", _sliderView.value];
    }
    if (self.effectType == TUIAudioEffectTypeMusicRiseFall) {
        _valueLabel.text = [NSString stringWithFormat:@"%.2f", _sliderView.value];
    }
}

#pragma mark - action
- (void)sliderValueChanged{
    if (!self.delegate) {
        return;
    }
    if (self.effectType == TUIAudioEffectTypeMusicVolume && [self.delegate respondsToSelector:@selector(audioEffectControlWithModel:musicVolumeChanged:)]) {
        NSInteger value = @(self.sliderView.value).integerValue;
        [self.delegate audioEffectControlWithModel:self.effectModel musicVolumeChanged:value];
    }
    if (self.effectType == TUIAudioEffectTypeVoiceVolume && [self.delegate respondsToSelector:@selector(audioEffectControlWithModel:voiceVolumeChanged:)]) {
        NSInteger value = @(self.sliderView.value).integerValue;
        [self.delegate audioEffectControlWithModel:self.effectModel voiceVolumeChanged:value];
    }
    if (self.effectType == TUIAudioEffectTypeMusicRiseFall && [self.delegate respondsToSelector:@selector(audioEffectControlWithModel:musicRiseFallChanged:)]) {
        [self.delegate audioEffectControlWithModel:self.effectModel musicRiseFallChanged:self.sliderView.value];
    }
    [self updateSlideValue];
}

#pragma mark - getter
- (TUIAudioEfectSlider *)sliderView{
    if (!_sliderView) {
        _sliderView = [[TUIAudioEfectSlider alloc] initWithFrame:CGRectZero];
        [_sliderView setThumbImage:TUIAEImageNamed(@"audioeffect_slider") forState:UIControlStateNormal];
        _sliderView.minimumTrackTintColor = TUIAEMakeColorHexString(@"#006EFF");
        _sliderView.maximumTrackTintColor = TUIAEMakeColorHexString(@"#F4F5F9");
        [_sliderView addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
        [_sliderView setValue:0 animated:NO];
    }
    return _sliderView;
}

- (UILabel *)valueLabel{
    if (!_valueLabel) {
        _valueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    }
    return _valueLabel;
}
@end

//** TUIAudioEffectCollectionTableCell **//
@interface TUIAudioEffectCollectionTableCell ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionViewFlowLayout *collectionLayout;

@end

@implementation TUIAudioEffectCollectionTableCell

- (void)setupUI{
    [super setupUI];
    [self.contentView addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(10);
        make.height.mas_equalTo(75);
        make.leading.mas_equalTo(0);
        make.width.mas_equalTo(Screen_Width);
    }];
}

- (void)updateUIWithThemeConfig:(TUILiveThemeConfig *)themeConfig{
    [super updateUIWithThemeConfig:themeConfig];
    [self.collectionView reloadData];
}

- (void)updateUIWithData:(TUIAudioEffectModel *)data type:(TUIAudioEffectType)type{
    [super updateUIWithData:data type:type];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.effectType == TUIAudioEffectTypeVoiceChange) {
        return self.effectModel.voiceChanges.count;
    }
    if (self.effectType == TUIAudioEffectTypeVoiceReverb) {
        return self.effectModel.voiceReverbs.count;
    }
    return 0;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    TUIAudioEffectCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TUIAudioEffectCollectionCell.reuseId forIndexPath:indexPath];
    cell.themeConfig = self.themeConfig;
    if (self.effectType == TUIAudioEffectTypeVoiceChange) {
        TUIAudioEffectVoiceChangeType type = ((NSNumber *)self.effectModel.voiceChanges[indexPath.item]).integerValue;
        [cell updateUIWithVoiceChange:type selected:(self.effectModel.currentVoiceChangeType == type)];
    }
    if (self.effectType == TUIAudioEffectTypeVoiceReverb) {
        TUIAudioEffectVoiceReverbType type = ((NSNumber *)self.effectModel.voiceReverbs[indexPath.item]).integerValue;
        [cell updateUIWithVoiceReverb:type selected:(self.effectModel.currentVoiceReverbType == type)];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.effectType == TUIAudioEffectTypeVoiceChange) {
        self.effectModel.currentVoiceChangeType = ((NSNumber *)self.effectModel.voiceChanges[indexPath.item]).integerValue;
        if (self.delegate && [self.delegate respondsToSelector:@selector(audioEffectControlWithModel:voiceChangeChanged:)]) {
            [self.delegate audioEffectControlWithModel:self.effectModel voiceChangeChanged:self.effectModel.currentVoiceChangeType];
        }
    }
    if (self.effectType == TUIAudioEffectTypeVoiceReverb) {
        self.effectModel.currentVoiceReverbType = ((NSNumber *)self.effectModel.voiceReverbs[indexPath.item]).integerValue;
        if (self.delegate && [self.delegate respondsToSelector:@selector(audioEffectControlWithModel:voiceReverbChanged:)]) {
            [self.delegate audioEffectControlWithModel:self.effectModel voiceReverbChanged:self.effectModel.currentVoiceReverbType];
        }
    }
    [collectionView reloadData];
    
}

#pragma mark - getter
- (UICollectionViewFlowLayout *)collectionLayout{
    if (!_collectionLayout) {
        _collectionLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionLayout.itemSize = CGSizeMake(50, 75);
        _collectionLayout.minimumLineSpacing = 15;
        _collectionLayout.minimumInteritemSpacing = 15;
        _collectionLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
    }
    return _collectionLayout;
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.collectionLayout];
        _collectionView.backgroundColor = UIColor.clearColor;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[TUIAudioEffectCollectionCell class] forCellWithReuseIdentifier:TUIAudioEffectCollectionCell.reuseId];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
    }
    return _collectionView;
}
@end
