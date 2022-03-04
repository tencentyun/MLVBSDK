//
//  LiteAVPrivacyThirdShareViewController.m
//  LiteAVPrivacy
//
//  Created by jack on 2022/2/10.
//

#import "LiteAVPrivacyThirdShareViewController.h"
#import "LiteAVPrivacyThirdDescTableCell.h"
#import "LiteAVPrivacyItemTableCell.h"

@interface LiteAVPrivacyThirdShareViewController ()

@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation LiteAVPrivacyThirdShareViewController

#pragma mark - init
- (instancetype)initWithPrivacyConfig:(LiteAVPrivacyConfig *)config {
    if (self = [super init]) {
        self.config = config;
        [self initData];
    }
    return self;
}

- (void)initData {
    [super initData];
    _dataSource = [NSArray array];
    // 第三方信息共享清单
    NSArray *thirdShareInfo = self.config.plistInfo[kLiteAVPrivacyThirdShareKey];
    if (thirdShareInfo) {
        _dataSource = thirdShareInfo;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setNavigationTitle:LiteAVPrivacyLocalize(@"LiteAV.Privacy.thirdShare")];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100.0;
    [self.tableView registerClass:[LiteAVPrivacyThirdDescTableCell class] forCellReuseIdentifier:@"Cell_desc"];
    [self.tableView registerClass:[LiteAVPrivacyItemTableCell class] forCellReuseIdentifier:@"Cell_item"];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == 0) {
        LiteAVPrivacyThirdDescTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_desc" forIndexPath:indexPath];
        cell.backgroundColor = self.config.backgroundColor;
        cell.titleLabel.textColor = self.config.textColor;
        cell.detailLabel.textColor = self.config.textColor;
        cell.titleLabel.text = LiteAVPrivacyLocalize(@"LiteAV.Privacy.thirdShare");
        NSString *format = LiteAVPrivacyLocalize(@"LiteAV.Privacy.thirdShare.desc");
        cell.detailLabel.text = [NSString stringWithFormat:format, [self appName]];
        return cell;
    }
    LiteAVPrivacyItemTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_item" forIndexPath:indexPath];
    cell.backgroundColor = self.config.backgroundColor;
    [cell updateUIData:_dataSource[indexPath.item-1] config:self.config];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

#pragma mark - Getter
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
