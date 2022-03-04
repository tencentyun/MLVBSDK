//
//  LiteAVPrivacyAuthDetailViewController.m
//  LiteAVPrivacy
//
//  Created by jack on 2022/2/10.
//

#import "LiteAVPrivacyAuthDetailViewController.h"
#import "LiteAVPrivacyAuthHeaderView.h"

@interface LiteAVPrivacyAuthDetailViewController ()

@property (nonatomic, assign) LiteAVPrivacyAuthType authType;

@property (nonatomic, strong) LiteAVPrivacyAuthHeaderView *tableHeaderView;
@end

@implementation LiteAVPrivacyAuthDetailViewController

- (instancetype)initWithAuthType:(LiteAVPrivacyAuthType)authType privacyConfig:(LiteAVPrivacyConfig *)config {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.authType = authType;
        self.config = config;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavigationTitle:[self titleWithAuthType:_authType]];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableHeaderView.backgroundColor = self.config.backgroundColor;
    self.tableHeaderView.titleLabel.textColor = self.config.textColor;
    self.tableHeaderView.detailLabel.textColor = self.config.textColor;
    self.tableHeaderView.titleLabel.text = [self titleWithAuthType:_authType];
    self.tableHeaderView.detailLabel.text = [self descWithAuthType:_authType];
    self.tableView.tableHeaderView = self.tableHeaderView;
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
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
    NSString *format = LiteAVPrivacyLocalize(@"LiteAV.Privacy.personalAuth.manage");
    cell.textLabel.text = [NSString stringWithFormat:format, [self titleWithAuthType:_authType]];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 49.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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

#pragma mark - Private
- (NSString *)titleWithAuthType:(LiteAVPrivacyAuthType)authType {
    if (authType == LiteAVPrivacyAuthTypeCamera) {
        return LiteAVPrivacyLocalize(@"LiteAV.Privacy.personalAuth.camera");
    }
    if (authType == LiteAVPrivacyAuthTypeMicrophone) {
        return LiteAVPrivacyLocalize(@"LiteAV.Privacy.personalAuth.microphone");
    }
    if (authType == LiteAVPrivacyAuthTypePhotos) {
        return LiteAVPrivacyLocalize(@"LiteAV.Privacy.personalAuth.photos");
    }
    return @"";
}

- (NSString *)descWithAuthType:(LiteAVPrivacyAuthType)authType {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *key = @"";
    NSString *desc = @"";
    if (authType == LiteAVPrivacyAuthTypeCamera) {
        key = @"NSCameraUsageDescription";
    }
    if (authType == LiteAVPrivacyAuthTypeMicrophone) {
        key = @"NSMicrophoneUsageDescription";
    }
    if (authType == LiteAVPrivacyAuthTypePhotos) {
        key = @"NSPhotoLibraryUsageDescription";
    }
    if (key.length > 0) {
        desc = [NSBundle.mainBundle localizedStringForKey:key value:@"" table:@"InfoPlist"];
        if (!desc || ![desc isKindOfClass:[NSString class]] || desc.length == 0) {
            desc = infoDictionary[key] ?: @"";
        }
    }
    return desc;
}

#pragma mark - Getter
- (LiteAVPrivacyAuthHeaderView *)tableHeaderView {
    if (!_tableHeaderView) {
        _tableHeaderView = [[LiteAVPrivacyAuthHeaderView alloc] initWithFrame:CGRectMake(0.f, 0.f, [UIScreen.mainScreen bounds].size.width, 180.0)];
    }
    return _tableHeaderView;
}
@end
