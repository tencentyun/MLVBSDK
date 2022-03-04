//
//  LiteAVPrivacyDataCollectedTableCell.m
//  LiteAVPrivacy
//
//  Created by jack on 2022/2/10.
//

#import "LiteAVPrivacyDataCollectedTableCell.h"
#import "Masonry.h"
#import "LiteAVPrivacyLocalized.h"

@interface LiteAVPrivacyDataCollectedTableCell ()

@property (nonatomic, assign) BOOL isViewReady;

@end

@implementation LiteAVPrivacyDataCollectedTableCell

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
    [self.contentView addSubview:self.purposeTitleLabel];
    [self.contentView addSubview:self.purposeTextLabel];
}

- (void)activateConstraints {
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(20);
        make.leading.mas_equalTo(20);
    }];
    [_avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(40);
        make.trailing.mas_equalTo(-20);
        make.centerY.mas_equalTo(_titleLabel);
    }];
    [_descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(-20);
        make.centerY.mas_equalTo(_titleLabel);
        make.width.mas_lessThanOrEqualTo(UIScreen.mainScreen.bounds.size.width/2.0);
    }]; 
    [_purposeTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_titleLabel.mas_bottom).mas_offset(20);
        make.leading.mas_equalTo(_titleLabel);
    }];
    [_purposeTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_purposeTitleLabel.mas_bottom).mas_offset(10);
        make.leading.mas_equalTo(_purposeTitleLabel);
        make.trailing.mas_equalTo(-20);
        make.bottom.mas_equalTo(-15);
    }];
}


#pragma mark - Setter
- (void)setCellStyle:(LiteAVPrivacyDataCollectedUIStyle)cellStyle {
    _cellStyle = cellStyle;
    if (cellStyle == LiteAVPrivacyDataCollectedUIStyleDefault) {
        self.avatarImageView.hidden = YES;
        self.descLabel.hidden = NO;
    }
    if (cellStyle == LiteAVPrivacyDataCollectedUIStyleAvatar) {
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

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _descLabel.font = [UIFont systemFontOfSize:14];
    }
    return _descLabel;
}

- (UILabel *)purposeTitleLabel {
    if (!_purposeTitleLabel) {
        _purposeTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _purposeTitleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        _purposeTitleLabel.text = LiteAVPrivacyLocalize(@"LiteAV.Privacy.dataCollection.purpose");
    }
    return _purposeTitleLabel;
}

- (UILabel *)purposeTextLabel {
    if (!_purposeTextLabel) {
        _purposeTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _purposeTextLabel.font = [UIFont systemFontOfSize:14];
        _purposeTextLabel.numberOfLines = 0;
    }
    return _purposeTextLabel;
}

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarImageView.backgroundColor = [UIColor darkGrayColor];
        _avatarImageView.layer.cornerRadius = 8;
        _avatarImageView.layer.masksToBounds = YES;
    }
    return _avatarImageView;
}

@end
