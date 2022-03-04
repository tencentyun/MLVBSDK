//
//  TUIBeautyBeautyCell.m
//  TUIBeauty
//
//  Created by gg on 2021/9/26.
//

#import "TUIBeautyBeautyCell.h"
#import "UIColor+TUIHexColor.h"
#import "Masonry.h"

@interface TUIBeautyBeautyCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIImageView *headImageView;

@end

@implementation TUIBeautyBeautyCell

- (void)setModel:(TCBeautyBaseItem *)model {
    _model = model;
    if (!model) {
        return;
    }
    self.headImageView.image = model.normalIcon;
    self.titleLabel.text = model.title;
}

- (void)setSelected:(BOOL)selected {
    super.selected = selected;
    self.titleLabel.textColor = selected ? [UIColor colorWithHex:@"006EFF"] : [UIColor colorWithHex:@"666666"];
    if (self.model != nil && self.model.selectIcon != nil) {
        self.headImageView.image = selected ? self.model.selectIcon : self.model.normalIcon;
    }
    else {
        self.headImageView.tintColor = selected ? [UIColor colorWithHex:@"006EFF"] : [UIColor colorWithHex:@"666666"];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:self.headImageView];
        [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.centerX.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(52, 52));
        }];
        
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.centerX.equalTo(self.contentView);
            make.leading.greaterThanOrEqualTo(self.contentView);
            make.trailing.lessThanOrEqualTo(self.contentView);
        }];
    }
    return self;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        _titleLabel.textColor = [UIColor colorWithHex:@"666666"];
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.minimumScaleFactor = 0.5;
    }
    return _titleLabel;
}

- (UIImageView *)headImageView {
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _headImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _headImageView;
}

@end
