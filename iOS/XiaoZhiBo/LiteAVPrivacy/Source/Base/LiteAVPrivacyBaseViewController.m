//
//  LiteAVPrivacyBaseViewController.m
//  LiteAVPrivacy
//
//  Created by jack on 2022/2/11.
//

#import "LiteAVPrivacyBaseViewController.h"

@interface LiteAVPrivacyBaseViewController ()

@end

@implementation LiteAVPrivacyBaseViewController

#pragma mark - init
- (instancetype)initWithPrivacyConfig:(LiteAVPrivacyConfig *)config {
    if (self = [super init]) {
        self.config = config;
        [self initData];
    }
    return self;
}

/// 数据初始化
- (void)initData {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self setNavigationItem];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
}

#pragma mark - UI设置
- (void)setupUI {
    self.view.backgroundColor = _config.backgroundColor;
    self.tableView.backgroundColor = _config.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 20, 0);
    self.tableView.tableFooterView = [UIView new];
}

#pragma mark - 导航栏设置

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

#pragma mark - Action
- (void)backItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
