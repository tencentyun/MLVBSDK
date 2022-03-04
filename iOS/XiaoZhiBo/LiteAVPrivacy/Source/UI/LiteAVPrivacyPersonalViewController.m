//
//  LiteAVPrivacyPersonalViewController.m
//  LiteAVPrivacy
//
//  Created by jack on 2022/2/10.
//

#import "LiteAVPrivacyPersonalViewController.h"
#import "LiteAVPrivacyMyInfoViewController.h"
#import "LiteAVPrivacyAuthViewController.h"

@interface LiteAVPrivacyPersonalViewController ()

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation LiteAVPrivacyPersonalViewController

- (void)initData {
    [super initData];
    NSDictionary *personalAuthInfo = self.config.plistInfo[kLiteAVPrivacyPersonalAuthKey];
    // 个人信息与权限
    if (personalAuthInfo) {
        NSArray *authInfo = personalAuthInfo[@"auth"];
        if (authInfo) {
            NSString *key = LiteAVPrivacyLocalize(@"LiteAV.Privacy.personalAuth.systemAuth");
            [self.dataSource addObject:@{key: authInfo}];
        }
        NSArray *personalInfo = personalAuthInfo[@"info"];
        if (personalInfo) {
            NSString *key = LiteAVPrivacyLocalize(@"LiteAV.Privacy.personalAuth.info");
            [self.dataSource addObject:@{key: personalInfo}];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavigationTitle:LiteAVPrivacyLocalize(@"LiteAV.Privacy.personalAuth")];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellID"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor = self.config.backgroundColor;
    cell.textLabel.textColor = self.config.textColor;
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
        if ([key isEqualToString:LiteAVPrivacyLocalize(@"LiteAV.Privacy.personalAuth.info")]) {
            [self pushPersonalInfo];
        }
        if ([key isEqualToString:LiteAVPrivacyLocalize(@"LiteAV.Privacy.personalAuth.systemAuth")]) {
            [self pushSystemAuth];
        }
    }
}

#pragma mark - 路由跳转
- (void)pushSystemAuth {
    LiteAVPrivacyAuthViewController *controller = [[LiteAVPrivacyAuthViewController alloc] initWithPrivacyConfig:self.config];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)pushPersonalInfo {
    LiteAVPrivacyMyInfoViewController *controller = [[LiteAVPrivacyMyInfoViewController alloc] initWithPrivacyConfig:self.config];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Getter
- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

@end
