// Copyright (c) 2020 Tencent. All rights reserved.

#import "LiveLinkOrPkSwitchRoleViewController.h"
#import "LiveLinkOrPkStreamInputViewController.h"

@interface LiveLinkOrPkSwitchRoleViewController ()
@property (weak, nonatomic) IBOutlet UILabel *roleLabel;
@property (weak, nonatomic) IBOutlet UIButton *anchorButton;
@property (weak, nonatomic) IBOutlet UIButton *audienceButton;
@property (weak, nonatomic) IBOutlet UIButton *nextStepButton;
/// 用户id
@property (nonatomic, strong) NSString *userId;
/// 是否是主播
@property (nonatomic, assign) BOOL isAnchor;
/// 页面titleStr
@property (nonatomic, strong) NSString *titleStr;
@end

@implementation LiveLinkOrPkSwitchRoleViewController

- (instancetype)initWithUserId:(NSString *)userId title:(NSString *)title{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.userId = userId;
        self.titleStr = title;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDefaultUIConfig];
    self.isAnchor = true;
}

- (void)setupDefaultUIConfig {
    self.title = self.titleStr;
    self.roleLabel.adjustsFontSizeToFitWidth = true;
    self.nextStepButton.titleLabel.adjustsFontForContentSizeCategory = true;
    
    self.roleLabel.text = Localize(@"MLVB-API-Example.LiveLink.chooseRole");
    [self.nextStepButton setTitle:Localize(@"MLVB-API-Example.LiveLink.nextStep") forState:UIControlStateNormal];
    [self.anchorButton setTitle:Localize(@"MLVB-API-Example.LiveLink.iAmAnchor") forState:UIControlStateNormal];
    [self.audienceButton setTitle:Localize(@"MLVB-API-Example.LiveLink.iAmAudience") forState:UIControlStateNormal];
    [self.anchorButton setBackgroundColor:[UIColor themeBlueColor]];
    [self.audienceButton setBackgroundColor:[UIColor themeGrayColor]];
}

- (IBAction)onAnchorButtonClick:(id)sender {
    [self.anchorButton setBackgroundColor:[UIColor themeBlueColor]];
    [self.audienceButton setBackgroundColor:[UIColor themeGrayColor]];
    self.isAnchor = true;
}

- (IBAction)onAudienceButtonClick:(id)sender {
    [self.anchorButton setBackgroundColor:[UIColor themeGrayColor]];
    [self.audienceButton setBackgroundColor:[UIColor themeBlueColor]];
    self.isAnchor = false;
}

- (IBAction)onNextButtonClick:(id)sender {
    [self.view endEditing:true];
    if (self.didClickNextBlock) {
        self.didClickNextBlock(self.userId, self.isAnchor);
    }
}

@end
