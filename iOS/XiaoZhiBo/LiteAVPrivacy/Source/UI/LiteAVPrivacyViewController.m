//
//  LiteAVPrivacyViewController.m
//  LiteAVPrivacy-LiteAVPrivacyKitBundle
//
//  Created by jack on 2022/2/10.
//

#import "LiteAVPrivacyViewController.h"
#import "LiteAVPrivacyLocalized.h"
#import "LiteAVPrivacyDataCollectionViewController.h"
#import "LiteAVPrivacyPersonalViewController.h"
#import "LiteAVPrivacyThirdShareViewController.h"
#import <SafariServices/SafariServices.h>

static NSString *kCellReuseID = @"CellID";
@interface LiteAVPrivacyViewController ()

/// 合规配置信息
@property (nonatomic, strong) LiteAVPrivacyConfig *config;

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation LiteAVPrivacyViewController

#pragma mark - init
- (instancetype)initWithPrivacyConfig:(LiteAVPrivacyConfig *)config {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.config = config;
        [self initData];
    }
    return self;
}

- (void)initData {
    NSDictionary *personalAuthInfo = _config.plistInfo[kLiteAVPrivacyPersonalAuthKey];
    // 个人信息与权限
    if (personalAuthInfo) {
        NSString *key = LiteAVPrivacyLocalize(@"LiteAV.Privacy.personalAuth");
        [self.dataSource addObject:@{key: personalAuthInfo}];
    }
    // 个人信息收集清单
    NSArray *dataCollectionInfo = _config.plistInfo[kLiteAVPrivacyDataCollectionKey];
    if (dataCollectionInfo) {
        NSString *key = LiteAVPrivacyLocalize(@"LiteAV.Privacy.dataCollection");
        [self.dataSource addObject:@{key: dataCollectionInfo}];
    }
    // 第三方信息共享清单
    NSArray *thirdShareInfo = _config.plistInfo[kLiteAVPrivacyThirdShareKey];
    if (thirdShareInfo) {
        NSString *key = LiteAVPrivacyLocalize(@"LiteAV.Privacy.thirdShare");
        [self.dataSource addObject:@{key: thirdShareInfo}];
    }
    // 隐私协议
    NSString *privacyURL = _config.plistInfo[kLiteAVPrivacyURLKey];
    if (privacyURL && [privacyURL isKindOfClass:[NSString class]] && privacyURL.length > 0) {
        NSString *key = LiteAVPrivacyLocalize(@"LiteAV.Privacy.privacyAgreement");
        [self.dataSource addObject:@{key: privacyURL}];
    }
    // 用户协议
    NSString *agreementURL = _config.plistInfo[kLiteAVPrivacyUserProtocolKey];
    if (agreementURL && [agreementURL isKindOfClass:[NSString class]] && agreementURL.length > 0) {
        NSString *key = LiteAVPrivacyLocalize(@"LiteAV.Privacy.userAgreement");
        [self.dataSource addObject:@{key: agreementURL}];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = _config.backgroundColor;
    self.tableView.backgroundColor = _config.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0);
    self.tableView.tableFooterView = [UIView new];
    [self setNavigationItem];
    [self setNavigationTitle:LiteAVPrivacyLocalize(@"LiteAV.Privacy.privacy")];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)setNavigationItem {
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *backImage = [UIImage imageNamed:@"back" inBundle:LiteAVPrivacyBundle() compatibleWithTraitCollection:nil];
    backImage = [backImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [backButton setImage:backImage forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backItemClick) forControlEvents:UIControlEventTouchUpInside];
    [backButton sizeToFit];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    if (_config.style == LiteAVPrivacyUIStyleLight) {
        backButton.tintColor = [UIColor blackColor];
    } else {
        backButton.tintColor = [UIColor whiteColor];
    }
    self.navigationItem.leftBarButtonItem = backItem;
}

- (void)setNavigationTitle:(NSString *)title {
    self.title = title;
    self.navigationController.navigationBar.titleTextAttributes = @{
        NSFontAttributeName: [UIFont systemFontOfSize:18],
        NSForegroundColorAttributeName: self.config.textColor
    };
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellReuseID];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor = _config.backgroundColor;
    cell.textLabel.textColor = _config.textColor;
    NSDictionary *info = _dataSource[indexPath.row];
    if (info) {
        cell.textLabel.text = info.allKeys.firstObject;
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 49.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *info = _dataSource[indexPath.row];
    if (info) {
        NSString *key = info.allKeys.firstObject;
        if ([key isEqualToString:LiteAVPrivacyLocalize(@"LiteAV.Privacy.personalAuth")]) {
            [self pushPersonalAuth];
        }
        if ([key isEqualToString:LiteAVPrivacyLocalize(@"LiteAV.Privacy.dataCollection")]) {
            [self pushDataCollection];
        }
        if ([key isEqualToString:LiteAVPrivacyLocalize(@"LiteAV.Privacy.thirdShare")]) {
            [self pushThirdShare];
        }
        if ([key isEqualToString:LiteAVPrivacyLocalize(@"LiteAV.Privacy.privacyAgreement")]) {
            [self openURLString:info[key] title:key];
        }
        if ([key isEqualToString:LiteAVPrivacyLocalize(@"LiteAV.Privacy.userAgreement")]) {
            [self openURLString:info[key] title:key];
        }
    }
}

#pragma mark - Action
- (void)backItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 路由跳转
/// 打开个人收集清单
- (void)pushDataCollection {
    LiteAVPrivacyDataCollectionViewController *controller = [[LiteAVPrivacyDataCollectionViewController alloc] initWithPrivacyConfig:_config];
    [self.navigationController pushViewController:controller animated:YES];
}

/// 打开个人信息展示和系统权限
- (void)pushPersonalAuth {
    LiteAVPrivacyPersonalViewController *controller = [[LiteAVPrivacyPersonalViewController alloc] initWithPrivacyConfig:_config];
    [self.navigationController pushViewController:controller animated:YES];
}

/// 打开第三方数据共享
- (void)pushThirdShare {
    LiteAVPrivacyThirdShareViewController *controller = [[LiteAVPrivacyThirdShareViewController alloc] initWithPrivacyConfig:_config];
    [self.navigationController pushViewController:controller animated:YES];
}

/// 打开URL
- (void)openURLString:(NSString *)urlString title:(NSString *)title {
    NSURL *url = [NSURL URLWithString:urlString];
    if (url) {
        SFSafariViewController *controller = [[SFSafariViewController alloc] initWithURL:url];
        controller.title = title;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

#pragma mark - Getter
- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}
@end
