//
//  TUIBeautyBeautyTypeCell.m
//  TUIBeauty
//
//  Created by gg on 2021/9/26.
//

#import "TUIBeautyBeautyTypeCell.h"
#import "UIColor+TUIHexColor.h"
#import "Masonry.h"

@interface TUIBeautyBeautyTypeCell ()

@end

@implementation TUIBeautyBeautyTypeCell

- (void)setSelected:(BOOL)selected {
    super.selected = selected;
    self.titleLabel.textColor = selected ? [UIColor colorWithHex:@"006EFF"] : [UIColor colorWithHex:@"999999"];
}

+ (UIFont *)titleLabelFont {
    return [UIFont fontWithName:@"PingFangSC-Regular" size:16];
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:16];
        _titleLabel.textColor = [UIColor colorWithHex:@"999999"];
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.minimumScaleFactor = 0.5;
    }
    return _titleLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.equalTo(self.contentView);
            make.leading.greaterThanOrEqualTo(self.contentView);
            make.trailing.lessThanOrEqualTo(self.contentView);
        }];
    }
    return self;
}
@end
