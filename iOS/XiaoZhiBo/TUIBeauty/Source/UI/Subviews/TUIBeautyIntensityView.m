//
//  TUIBeautyIntensityView.m
//  TUIBeauty
//
//  Created by gg on 2021/9/26.
//

#import "TUIBeautyIntensityView.h"
#import "UIColor+TUIHexColor.h"
#import "BeautyLocalized.h"
#import "Masonry.h"

@interface TUIBeautyIntensityView ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UISlider *slider;

@property (nonatomic, strong) UILabel *detailLabel;


@end

@implementation TUIBeautyIntensityView {
    BOOL _isViewReady;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    
    if (_isViewReady) {
        return;
    }
    _isViewReady = YES;
    [self constructViewHierarchy];
    [self activateConstraints];
    [self bindInteraction];
}

- (void)constructViewHierarchy {
    [self addSubview:self.titleLabel];
    [self addSubview:self.slider];
    [self addSubview:self.detailLabel];
}

- (void)activateConstraints {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.leading.equalTo(self).offset(20);
        make.width.mas_equalTo(50);
    }];
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self).offset(-20);
        make.centerY.equalTo(self);
        make.width.mas_equalTo(30);
    }];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.leading.equalTo(self.titleLabel.mas_trailing).offset(10);
        make.trailing.equalTo(self.detailLabel.mas_leading).offset(-10);
    }];
}

- (void)bindInteraction {
    [self.slider addTarget:self action:@selector(sliderValueChange) forControlEvents:UIControlEventValueChanged];
}

- (void)sliderValueChange {
    float value = self.slider.value;
    [self setSliderValue:value];
    if (self.onSliderValueChanged != nil) {
        self.onSliderValueChanged(value);
    }
}

- (void)setSliderMinValue:(float)minValue maxValue:(float)maxValue {
    self.slider.minimumValue = minValue;
    self.slider.maximumValue = maxValue;
}

- (void)setSliderValue:(float)value {
    if (value > self.slider.maximumValue) {
        value = self.slider.maximumValue;
    }
    else if (value < self.slider.minimumValue) {
        value = self.slider.minimumValue;
    }
    self.slider.value = value;
    self.detailLabel.text = [NSString stringWithFormat:@"%d", (int)(roundf(value))];
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        _titleLabel.textColor = [UIColor colorWithHex:@"666666"];
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.minimumScaleFactor = 0.5;
        _titleLabel.text = BeautyLocalize(@"TC.BeautySettingPanel.Strength");
    }
    return _titleLabel;
}

- (UISlider *)slider {
    if (!_slider) {
        _slider = [[UISlider alloc] initWithFrame:CGRectZero];
    }
    return _slider;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _detailLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16];
        _detailLabel.textColor = [UIColor colorWithHex:@"333333"];
        _detailLabel.adjustsFontSizeToFitWidth = YES;
        _detailLabel.minimumScaleFactor = 0.5;
    }
    return _detailLabel;
}
@end
