//
//  LiteAVPrivacyDataCollectionViewController.m
//  LiteAVPrivacy
//
//  Created by jack on 2022/2/10.
//

#import "LiteAVPrivacyDataCollectionViewController.h"
#import "LiteAVPrivacyDataCollectedTableCell.h"
#import "SDWebImage.h"
#import "LiteAVPrivacyAuthHeaderView.h"

@interface LiteAVPrivacyDataCollectionViewController ()

@property (nonatomic, strong) NSArray *dataSource;

@property (nonatomic, strong) LiteAVPrivacyAuthHeaderView *tableHeaderView;
@end

@implementation LiteAVPrivacyDataCollectionViewController

- (void)initData {
    [super initData];
    _dataSource = [NSArray array];
    // 个人信息收集清单
    NSArray *dataCollectionInfo = self.config.plistInfo[kLiteAVPrivacyDataCollectionKey];
    if (dataCollectionInfo) {
        _dataSource = dataCollectionInfo;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavigationTitle:LiteAVPrivacyLocalize(@"LiteAV.Privacy.dataCollection")];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100.0;
    [self.tableView registerClass:[LiteAVPrivacyDataCollectedTableCell class] forCellReuseIdentifier:@"Cell_ID"];
    self.tableHeaderView.backgroundColor = self.config.backgroundColor;
    self.tableHeaderView.titleLabel.textColor = self.config.textColor;
    self.tableHeaderView.detailLabel.textColor = self.config.textColor;
    self.tableHeaderView.titleLabel.text = LiteAVPrivacyLocalize(@"LiteAV.Privacy.dataCollection");
    NSString *format = LiteAVPrivacyLocalize(@"LiteAV.Privacy.dataCollection.desc");
    self.tableHeaderView.detailLabel.text = [NSString stringWithFormat:format, [self appName]];
    self.tableView.tableHeaderView = self.tableHeaderView;
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LiteAVPrivacyDataCollectedTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_ID" forIndexPath:indexPath];
    cell.backgroundColor = self.config.backgroundColor;
    cell.titleLabel.textColor = self.config.textColor;
    cell.descLabel.textColor = self.config.detailColor;
    cell.purposeTitleLabel.textColor = self.config.textColor;
    cell.purposeTextLabel.textColor = self.config.detailColor;
    NSDictionary *info = _dataSource[indexPath.row];
    NSString *type = info[@"type"];
    NSString *desc = info[@"desc"];
    cell.titleLabel.text = LiteAVPrivacyLocalize([NSString stringWithFormat:@"LiteAV.Privacy.personalAuth.%@", type]);
    cell.descLabel.text = @"";
    cell.purposeTextLabel.text = desc;
    if ([type isEqualToString:@"avatar"]) {
        cell.cellStyle = LiteAVPrivacyDataCollectedUIStyleAvatar;
        NSURL *avatarURL = [NSURL URLWithString:self.config.userAvatar];
        if (avatarURL) {
            [cell.avatarImageView sd_setImageWithURL:avatarURL];
        }
    } else {
        cell.cellStyle = LiteAVPrivacyDataCollectedUIStyleDefault;
        NSString *text = @"";
        if ([type isEqualToString:@"name"]) {
            text = self.config.userName;
        }
        if ([type isEqualToString:@"id"]) {
            text = self.config.userID;
        }
        if ([type isEqualToString:@"phone"]) {
            text = self.config.phone;
        }
        if ([type isEqualToString:@"email"]) {
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
    return UITableViewAutomaticDimension;
}

#pragma mark - Getter
- (LiteAVPrivacyAuthHeaderView *)tableHeaderView {
    if (!_tableHeaderView) {
        _tableHeaderView = [[LiteAVPrivacyAuthHeaderView alloc] initWithFrame:CGRectMake(0.f, 0.f, [UIScreen.mainScreen bounds].size.width, 160.0)];
    }
    return _tableHeaderView;
}

- (NSString *)appName {
    NSString *nameKey = @"CFBundleDisplayName";
    NSString *appName = [NSBundle.mainBundle localizedStringForKey:nameKey
                                                             value:nil
                                                             table:@"InfoPlist"];
    if (!appName || appName.length == 0) {
        appName = [NSBundle mainBundle].infoDictionary[nameKey];
    }
    return appName ?: @"";
}

@end
