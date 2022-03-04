//
//  LiteAVPrivacyItemTableCell.m
//  LiteAVPrivacy
//
//  Created by jack on 2022/2/11.
//

#import "LiteAVPrivacyItemTableCell.h"
#import "Masonry.h"
#import "LiteAVPrivacyConfig.h"
#import "LiteAVPrivacyLocalized.h"

@interface LiteAVPrivacyItemTableCell ()

@property (nonatomic, assign) BOOL isViewReady;
/// 第三方共享名称
@property (nonatomic, strong) UILabel *nameLabel;
/// 第三方主体名称
@property (nonatomic, strong) UILabel *companyTextLabel;
/// 共享信息内容
@property (nonatomic, strong) UILabel *shareInfoTextLabel;
/// 使用场景内容
@property (nonatomic, strong) UILabel *sceneTextLabel;
/// 使用目的内容
@property (nonatomic, strong) UILabel *purposeTextLabel;
/// 共享方式内容
@property (nonatomic, strong) UILabel *shareTextLabel;
/// 第三方个人信息处理规则内容
@property (nonatomic, strong) UILabel *privacyTextLabel;

@property (nonatomic, strong) LiteAVPrivacyConfig *config;

@property (nonatomic, strong) NSString *privacyLinkURL;
@end

@implementation LiteAVPrivacyItemTableCell

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
    [self bindInteraction];
}

- (void)constructViewHierarchy {
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.companyTextLabel];
    [self.contentView addSubview:self.shareInfoTextLabel];
    [self.contentView addSubview:self.sceneTextLabel];
    [self.contentView addSubview:self.purposeTextLabel];
    [self.contentView addSubview:self.shareTextLabel];
    [self.contentView addSubview:self.privacyTextLabel];
}

- (void)activateConstraints {
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(20);
        make.trailing.mas_equalTo(-20);
        make.top.mas_equalTo(10);
    }];
    [_companyTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(20);
        make.trailing.mas_equalTo(-20);
        make.top.mas_equalTo(_nameLabel.mas_bottom).mas_offset(8);
    }];
    [_shareInfoTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(20);
        make.trailing.mas_equalTo(-20);
        make.top.mas_equalTo(_companyTextLabel.mas_bottom).mas_offset(8);
    }];
    [_sceneTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(20);
        make.trailing.mas_equalTo(-20);
        make.top.mas_equalTo(_shareInfoTextLabel.mas_bottom).mas_offset(8);
    }];
    [_purposeTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(20);
        make.trailing.mas_equalTo(-20);
        make.top.mas_equalTo(_sceneTextLabel.mas_bottom).mas_offset(8);
    }];
    [_shareTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(20);
        make.trailing.mas_equalTo(-20);
        make.top.mas_equalTo(_purposeTextLabel.mas_bottom).mas_offset(8);
    }];
    [_privacyTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(20);
        make.trailing.mas_equalTo(-20);
        make.top.mas_equalTo(_shareTextLabel.mas_bottom).mas_offset(8);
        make.bottom.mas_equalTo(-10);
    }];
}

- (void)bindInteraction {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickPrivacyLink)];
    _privacyTextLabel.userInteractionEnabled = YES;
    [_privacyTextLabel addGestureRecognizer:tap];
}

#pragma mark - Public
- (void)updateUIData:(NSDictionary *)thirdData config:(LiteAVPrivacyConfig *)config {
    self.nameLabel.textColor = config.textColor;
    _config = config;
    for (NSString *key in thirdData.allKeys) {
        if ([key isEqualToString:@"name"]) {
            self.nameLabel.text = thirdData[@"name"];
        }
        if ([key isEqualToString:@"company"]) {
            self.companyTextLabel.attributedText = [self contentWithKey:key value:thirdData[key]];
        }
        if ([key isEqualToString:@"info"]) {
            self.shareInfoTextLabel.attributedText = [self contentWithKey:key value:thirdData[key]];
        }
        if ([key isEqualToString:@"scene"]) {
            self.sceneTextLabel.attributedText = [self contentWithKey:key value:thirdData[key]];
        }
        if ([key isEqualToString:@"purpose"]) {
            self.purposeTextLabel.attributedText = [self contentWithKey:key value:thirdData[key]];
        }
        if ([key isEqualToString:@"method"]) {
            self.shareTextLabel.attributedText = [self contentWithKey:key value:thirdData[key]];
        }
        if ([key isEqualToString:@"privacy"]) {
            self.privacyLinkURL = thirdData[key];
            self.privacyTextLabel.attributedText = [self contentWithKey:key value:LiteAVPrivacyLocalize(@"LiteAV.Privacy.thirdShare.privacyLink")];
        }
    }
}

#pragma mark - Private
- (NSMutableAttributedString *)contentWithKey:(NSString *)key value:(NSString *)value{
    NSString *keyString = LiteAVPrivacyLocalize([NSString stringWithFormat:@"LiteAV.Privacy.thirdShare.%@", key]);
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: %@", keyString, value]];
    UIFont *titleFont = [UIFont systemFontOfSize:20 weight:UIFontWeightMedium];
    UIFont *textFont = [UIFont systemFontOfSize:18];
    NSDictionary *keyAttributes = @{
        NSFontAttributeName: titleFont,
        NSForegroundColorAttributeName: _config.textColor
    };
    [content addAttributes:keyAttributes
                     range:[content.string rangeOfString:keyString]];
    if ([key isEqualToString:@"privacy"]) {
        NSDictionary *valueAttributes = @{
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: UIColor.blueColor
        };
        [content addAttributes:valueAttributes
                         range:[content.string rangeOfString:value]];
    } else {
        NSDictionary *valueAttributes = @{
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: _config.textColor
        };
        [content addAttributes:valueAttributes
                         range:[content.string rangeOfString:value]];
    }
    return content;
}

#pragma mark - Action
- (void)clickPrivacyLink {
    NSURL *linkURL = [NSURL URLWithString:_privacyLinkURL];
    if (linkURL && [[UIApplication sharedApplication] canOpenURL:linkURL]) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:linkURL options:@{} completionHandler:^(BOOL success) {
                
            }];
        } else {
            [[UIApplication sharedApplication] openURL:linkURL];
        }
    }
}

#pragma mark - Getter
- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightMedium];
        _nameLabel.numberOfLines = 0;
    }
    return _nameLabel;
}

- (UILabel *)companyTextLabel {
    if (!_companyTextLabel) {
        _companyTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _companyTextLabel.numberOfLines = 0;
    }
    return _companyTextLabel;
}

- (UILabel *)shareInfoTextLabel {
    if (!_shareInfoTextLabel) {
        _shareInfoTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _shareInfoTextLabel.numberOfLines = 0;
    }
    return _shareInfoTextLabel;
}

- (UILabel *)sceneTextLabel {
    if (!_sceneTextLabel) {
        _sceneTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _sceneTextLabel.numberOfLines = 0;
    }
    return _sceneTextLabel;
}

- (UILabel *)shareTextLabel {
    if (!_shareTextLabel) {
        _shareTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _shareTextLabel.numberOfLines = 0;
    }
    return _shareTextLabel;
}

- (UILabel *)purposeTextLabel {
    if (!_purposeTextLabel) {
        _purposeTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _purposeTextLabel.numberOfLines = 0;
    }
    return _purposeTextLabel;
}

- (UILabel *)privacyTextLabel {
    if (!_privacyTextLabel) {
        _privacyTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _privacyTextLabel.numberOfLines = 0;
    }
    return _privacyTextLabel;
}
@end
