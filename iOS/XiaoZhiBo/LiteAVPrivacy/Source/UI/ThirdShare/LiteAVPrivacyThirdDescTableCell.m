//
//  LiteAVPrivacyThirdDescTableCell.m
//  LiteAVPrivacy
//
//  Created by jack on 2022/2/11.
//

#import "LiteAVPrivacyThirdDescTableCell.h"
#import "Masonry.h"

@interface LiteAVPrivacyThirdDescTableCell ()

@property (nonatomic, assign) BOOL isViewReady;

@end

@implementation LiteAVPrivacyThirdDescTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
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
}

- (void)constructViewHierarchy {
    [self addSubview:self.titleLabel];
    [self addSubview:self.detailLabel];
}

- (void)activateConstraints {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(20);
        make.trailing.mas_equalTo(-20);
        make.top.mas_equalTo(20);
    }];
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(20);
        make.trailing.mas_equalTo(-20);
        make.top.mas_equalTo(_titleLabel.mas_bottom).mas_offset(20);
        make.bottom.mas_equalTo(-20);
    }];
}

#pragma mark - Getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightMedium];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _detailLabel.font = [UIFont systemFontOfSize:18];
        _detailLabel.numberOfLines = 0;
    }
    return _detailLabel;
}
@end
