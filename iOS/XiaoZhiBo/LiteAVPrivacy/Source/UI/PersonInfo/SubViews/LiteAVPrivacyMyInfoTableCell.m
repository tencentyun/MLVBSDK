//
//  LiteAVPrivacyMyInfoTableCell.m
//  LiteAVPrivacy
//
//  Created by jack on 2022/2/10.
//

#import "LiteAVPrivacyMyInfoTableCell.h"
#import "Masonry.h"

@interface LiteAVPrivacyMyInfoTableCell ()

@property (nonatomic, assign) BOOL isViewReady;

@end

@implementation LiteAVPrivacyMyInfoTableCell

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
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.avatarImageView];
    [self.contentView addSubview:self.descLabel];
}

- (void)activateConstraints {
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(0);
        make.leading.mas_equalTo(20);
    }];
    [_avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(48);
        make.trailing.mas_equalTo(-20);
        make.centerY.mas_equalTo(0);
    }];
    [_descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(-20);
        make.centerY.mas_equalTo(0);
        make.width.mas_lessThanOrEqualTo(UIScreen.mainScreen.bounds.size.width/2.0);
    }];
}

#pragma mark - Setter
- (void)setCellStyle:(LiteAVPrivacyMyInfoUIStyle)cellStyle {
    _cellStyle = cellStyle;
    if (cellStyle == LiteAVPrivacyMyInfoUIStyleDefault) {
        self.avatarImageView.hidden = YES;
        self.descLabel.hidden = NO;
    }
    if (cellStyle == LiteAVPrivacyMyInfoUIStyleAvatar) {
        self.avatarImageView.hidden = NO;
        self.descLabel.hidden = YES;
    }
}

#pragma mark - Getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    }
    return _titleLabel;
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.backgroundColor = [UIColor darkGrayColor];
        _avatarImageView.layer.cornerRadius = 8;
        _avatarImageView.layer.masksToBounds = YES;
        _avatarImageView.hidden = YES;
    }
    return _avatarImageView;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _descLabel.font = [UIFont systemFontOfSize:14];
        _descLabel.hidden = YES;
    }
    return _descLabel;
}

@end
