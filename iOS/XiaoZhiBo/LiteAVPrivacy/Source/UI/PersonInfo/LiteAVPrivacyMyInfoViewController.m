//
//  LiteAVPrivacyMyInfoViewController.m
//  LiteAVPrivacy
//
//  Created by jack on 2022/2/10.
//

#import "LiteAVPrivacyMyInfoViewController.h"
#import "Masonry.h"
#import "SDWebImage.h"

#import "LiteAVPrivacyMyInfoTableCell.h"

@interface LiteAVPrivacyMyInfoViewController ()

@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) UILabel *tipLabel;
@end

@implementation LiteAVPrivacyMyInfoViewController

- (void)initData {
    [super initData];
    _dataSource = [NSArray array];
    NSDictionary *personalAuthInfo = self.config.plistInfo[kLiteAVPrivacyPersonalAuthKey];
    // 个人信息与权限
    if (personalAuthInfo) {
        NSArray *authInfo = personalAuthInfo[@"info"];
        if (authInfo) {
            _dataSource = authInfo;
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavigationTitle:LiteAVPrivacyLocalize(@"LiteAV.Privacy.personalAuth.info")];
    [self.tableView registerClass:[LiteAVPrivacyMyInfoTableCell class] forCellReuseIdentifier:@"Cell_ID"];
    [self constructViewHierarchy];
    [self activateConstraints];
}

- (void)constructViewHierarchy {
    [self.view addSubview:self.tipLabel];
}

- (void)activateConstraints {
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(0.0);
        make.width.mas_equalTo(150.0);
        make.height.mas_equalTo(30.0);
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = _dataSource[indexPath.row];
    LiteAVPrivacyMyInfoTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_ID" forIndexPath:indexPath];
    cell.backgroundColor = self.config.backgroundColor;
    cell.titleLabel.textColor = self.config.textColor;
    cell.titleLabel.text = LiteAVPrivacyLocalize([NSString stringWithFormat:@"LiteAV.Privacy.personalAuth.%@", key]);
    cell.descLabel.textColor = self.config.detailColor;
    cell.descLabel.text = @"";
    if ([key isEqualToString:@"avatar"]) {
        cell.cellStyle = LiteAVPrivacyMyInfoUIStyleAvatar;
        NSURL *avatarURL = [NSURL URLWithString:self.config.userAvatar];
        if (avatarURL) {
            [cell.avatarImageView sd_setImageWithURL:avatarURL];
        }
    } else {
        cell.cellStyle = LiteAVPrivacyMyInfoUIStyleDefault;
        NSString *text = @"";
        if ([key isEqualToString:@"name"]) {
            text = self.config.userName;
        }
        if ([key isEqualToString:@"id"]) {
            text = self.config.userID;
        }
        if ([key isEqualToString:@"phone"]) {
            text = self.config.phone;
        }
        if ([key isEqualToString:@"email"]) {
            text = self.config.email;
        }
        if (!text || ![text isKindOfClass:[NSString class]] || text.length == 0) {
            text = LiteAVPrivacyLocalize(@"LiteAV.Privacy.dataCollection.none");
        }
        cell.descLabel.text = text;
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = _dataSource[indexPath.row];
    if ([key isEqualToString:@"avatar"]) {
        return 74.0;
    }
    return 49.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = _dataSource[indexPath.row];
    if ([key isEqualToString:@"avatar"]) {
        // 头像暂不提供复制功能
        // pasteboard.string = _config.userAvatar;
    } else {
        if ([key isEqualToString:@"name"]) {
            [self copyText:self.config.userName];
        }
        if ([key isEqualToString:@"id"]) {
            [self copyText:self.config.userID];
        }
        if ([key isEqualToString:@"phone"]) {
            [self copyText:self.config.phone];
        }
        if ([key isEqualToString:@"email"]) {
            [self copyText:self.config.email];
        }
    }
}
  
#pragma mark - Private
- (void)copyText:(NSString *)text {
    if (!text || ![text isKindOfClass:[NSString class]] || text.length == 0) {
        return;
    }
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = text;
    [self showCopyTip];
}

- (void)showCopyTip {
    [_tipLabel.layer removeAllAnimations];
    __weak typeof(self) weakSelf = self;
    [UIView animateKeyframesWithDuration:2.0 delay:0.0 options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.f relativeDuration:0.5 animations:^{
            if (!weakSelf) {
                return;
            }
            weakSelf.tipLabel.alpha = 1.0;
        }];
        [UIView addKeyframeWithRelativeStartTime:1.5 relativeDuration:0.5 animations:^{
            if (!weakSelf) {
                return;
            }
            weakSelf.tipLabel.alpha = 0.0;
        }];
    } completion:^(BOOL finished) {
        if (!weakSelf) {
            return;
        }
        weakSelf.tipLabel.alpha = 0.0;
    }];
}

#pragma mark - Getter
- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipLabel.backgroundColor = [UIColor blackColor];
        _tipLabel.layer.cornerRadius = 4.0;
        _tipLabel.layer.masksToBounds = YES;
        _tipLabel.text = LiteAVPrivacyLocalize(@"LiteAV.Privacy.tip.copy");
        _tipLabel.textColor = [UIColor whiteColor];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.alpha = 0.0;
    }
    return _tipLabel;
}
@end
