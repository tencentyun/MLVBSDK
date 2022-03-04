//
//  LiteAVPrivacyAuthViewController.m
//  LiteAVPrivacy
//
//  Created by jack on 2022/2/10.
//

#import "LiteAVPrivacyAuthViewController.h"
#import "LiteAVPrivacyAuthDetailViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

@interface LiteAVPrivacyAuthViewController ()

@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation LiteAVPrivacyAuthViewController

- (void)initData {
    [super initData];
    _dataSource = [NSArray array];
    NSDictionary *personalAuthInfo = self.config.plistInfo[kLiteAVPrivacyPersonalAuthKey];
    // 个人信息与权限
    if (personalAuthInfo) {
        NSArray *authInfo = personalAuthInfo[@"auth"];
        if (authInfo) {
            _dataSource = authInfo;
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavigationTitle:LiteAVPrivacyLocalize(@"LiteAV.Privacy.personalAuth.systemAuth")];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // Add TableFooterView
    CGFloat screenWidth = [UIScreen.mainScreen bounds].size.width;
    CGFloat footerViewHeight = 40.f;
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.f, 0.f, screenWidth, footerViewHeight)];
    tableFooterView.backgroundColor = [UIColor clearColor];
    UIButton *systemSettingBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    systemSettingBtn.frame = CGRectMake(screenWidth / 2 - 100.f, 0.f, 200.f, footerViewHeight);
    [systemSettingBtn addTarget:self action:@selector(goToSystemSetting) forControlEvents:UIControlEventTouchUpInside];
    [systemSettingBtn setTitle: LiteAVPrivacyLocalize(@"LiteAV.Privacy.personalAuth.systemSetting") forState:UIControlStateNormal];
    [tableFooterView addSubview:systemSettingBtn];
    self.tableView.tableFooterView = tableFooterView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)goToSystemSetting {
    NSURL *settingURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:settingURL]) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:settingURL options:@{} completionHandler:^(BOOL success) {
                
            }];
        } else {
            [[UIApplication sharedApplication] openURL:settingURL];
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CellID"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor = self.config.backgroundColor;
    cell.textLabel.textColor = self.config.textColor;
    cell.detailTextLabel.textColor = self.config.detailColor;
    NSString *key = [_dataSource objectAtIndex:indexPath.row];
    if ([key isEqualToString:@"camera"]) {
        cell.textLabel.text = LiteAVPrivacyLocalize(@"LiteAV.Privacy.personalAuth.camera");
        cell.detailTextLabel.text = [self authTextWithAuthType:LiteAVPrivacyAuthTypeCamera];
    }
    if ([key isEqualToString:@"microphone"]) {
        cell.textLabel.text = LiteAVPrivacyLocalize(@"LiteAV.Privacy.personalAuth.microphone");
        cell.detailTextLabel.text = [self authTextWithAuthType:LiteAVPrivacyAuthTypeMicrophone];
    }
    if ([key isEqualToString:@"photos"]) {
        cell.textLabel.text = LiteAVPrivacyLocalize(@"LiteAV.Privacy.personalAuth.photos");
        cell.detailTextLabel.text = [self authTextWithAuthType:LiteAVPrivacyAuthTypePhotos];
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 49.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *key = [_dataSource objectAtIndex:indexPath.row];
    if ([key isEqualToString:@"camera"]) {
        [self pushAuthDetail:LiteAVPrivacyAuthTypeCamera];
    }
    if ([key isEqualToString:@"microphone"]) {
        [self pushAuthDetail:LiteAVPrivacyAuthTypeMicrophone];
    }
    if ([key isEqualToString:@"photos"]) {
        [self pushAuthDetail:LiteAVPrivacyAuthTypePhotos];
    }
}

#pragma mark - Private

- (NSString *)authTextWithAuthType:(LiteAVPrivacyAuthType)authType {
    if (authType == LiteAVPrivacyAuthTypeCamera) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (status == AVAuthorizationStatusAuthorized) {
            return LiteAVPrivacyLocalize(@"LiteAV.Privacy.personalAuth.allow");
        }
        if (status == AVAuthorizationStatusNotDetermined) {
            return LiteAVPrivacyLocalize(@"LiteAV.Privacy.personalAuth.unauthorized");
        }
    }
    if (authType == LiteAVPrivacyAuthTypeMicrophone) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        if (status == AVAuthorizationStatusAuthorized) {
            return LiteAVPrivacyLocalize(@"LiteAV.Privacy.personalAuth.allow");
        }
        if (status == AVAuthorizationStatusNotDetermined) {
            return LiteAVPrivacyLocalize(@"LiteAV.Privacy.personalAuth.unauthorized");
        }
    }
    if (authType == LiteAVPrivacyAuthTypePhotos) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusAuthorized) {
            return LiteAVPrivacyLocalize(@"LiteAV.Privacy.personalAuth.allow");
        }
        if (status == PHAuthorizationStatusNotDetermined) {
            return LiteAVPrivacyLocalize(@"LiteAV.Privacy.personalAuth.unauthorized");
        }
    }
    return LiteAVPrivacyLocalize(@"LiteAV.Privacy.personalAuth.deny");
}

#pragma mark - 路由跳转

- (void)pushAuthDetail:(LiteAVPrivacyAuthType)authType {
    LiteAVPrivacyAuthDetailViewController *controller = [[LiteAVPrivacyAuthDetailViewController alloc] initWithAuthType:authType privacyConfig:self.config];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
