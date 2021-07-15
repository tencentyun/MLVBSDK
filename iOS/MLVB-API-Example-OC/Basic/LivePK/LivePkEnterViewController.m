//
//  LivePkEnterViewController.m
//  MLVB-API-Example-OC
//
//  Created by bluedang on 2021/7/1.
//

//
//  LiveLinkEnterViewController.m
//  MLVB-API-Example-OC
//
//  Created by bluedang on 2021/6/29.
//

#import "LivePkEnterViewController.h"
#import "LivePkAnchorViewController.h"
#import "LivePkAudienceViewController.h"


@interface LivePkEnterViewController ()
@property (weak, nonatomic) IBOutlet UILabel *streamIdLabel;
@property (weak, nonatomic) IBOutlet UITextField *streamIdTextField;
@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;
@property (weak, nonatomic) IBOutlet UILabel *roleLabel;

@property (weak, nonatomic) IBOutlet UIButton *anchorButton;
@property (weak, nonatomic) IBOutlet UIButton *audienceButton;

@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIButton *rtcPushButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *roleTopConstraint;


@property (assign, nonatomic) BOOL isAnchor;;
@end

@implementation LivePkEnterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDefaultUIConfig];
    self.isAnchor = true;
}

- (void)setupDefaultUIConfig {
    self.title = Localize(@"MLVB-API-Example.LivePk.title");
    self.streamIdLabel.text = Localize(@"MLVB-API-Example.LivePk.streamIdInput");
    self.streamIdLabel.adjustsFontSizeToFitWidth = true;
    
    self.userIdLabel.text = Localize(@"MLVB-API-Example.LivePk.userIdInput");
    self.userIdLabel.adjustsFontSizeToFitWidth = true;

    self.roleLabel.text = Localize(@"MLVB-API-Example.LivePk.chooseRole");
    self.roleLabel.adjustsFontSizeToFitWidth = true;
    
    [self.anchorButton setTitle:Localize(@"MLVB-API-Example.LivePk.anchor") forState:UIControlStateNormal];
    [self.anchorButton setBackgroundColor:[UIColor themeBlueColor]];
    [self.audienceButton setTitle:Localize(@"MLVB-API-Example.LivePk.audience") forState:UIControlStateNormal];
    [self.audienceButton setBackgroundColor:[UIColor themeGrayColor]];
    self.anchorButton.titleLabel.adjustsFontSizeToFitWidth = true;
    self.audienceButton.titleLabel.adjustsFontSizeToFitWidth = true;
    
    self.descriptionTextView.text = Localize(@"MLVB-API-Example.LivePk.descripView");
    self.descriptionTextView.backgroundColor = [UIColor themeGrayColor];

    [self.rtcPushButton setTitle:Localize(@"MLVB-API-Example.LivePk.rtcPush") forState:UIControlStateNormal];
    [self.rtcPushButton setTitle:Localize(@"MLVB-API-Example.LivePk.lebPlay") forState:UIControlStateSelected];
    [self.rtcPushButton setBackgroundColor:[UIColor themeBlueColor]];
    self.rtcPushButton.titleLabel.adjustsFontSizeToFitWidth = true;
    
    self.streamIdTextField.text = [NSString generateRandomStreamId];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:true];
}

- (void)pushAnchorVC {
    LivePkAnchorViewController *anchorVC = [[LivePkAnchorViewController alloc] initWithStreamId:self.streamIdTextField.text userId:self.userIdTextField.text];
    [self.navigationController pushViewController:anchorVC animated:YES];
}

- (void)pushAudienceVC {
    LivePkAudienceViewController *audienceVC = [[LivePkAudienceViewController alloc] initWithStreamId:self.streamIdTextField.text];
    [self.navigationController pushViewController:audienceVC animated:YES];
}

#pragma mark - Actions

- (IBAction)onRtcPushButtonClick:(UIButton*)button {
    if (self.isAnchor) {
        [self pushAnchorVC];
    } else {
        [self pushAudienceVC];
    }
}

- (IBAction)onAnchorButtonClick:(id)sender {
    [self.anchorButton setBackgroundColor:[UIColor themeBlueColor]];
    [self.audienceButton setBackgroundColor:[UIColor themeGrayColor]];
    [self.rtcPushButton setTitle:Localize(@"MLVB-API-Example.LivePk.rtcPush") forState:UIControlStateNormal];
    self.userIdLabel.hidden = false;
    self.userIdTextField.hidden = false;
    self.isAnchor = true;
    self.roleTopConstraint.constant = 110;
}

- (IBAction)onAudienceButtonClick:(id)sender {
    [self.anchorButton setBackgroundColor:[UIColor themeGrayColor]];
    [self.audienceButton setBackgroundColor:[UIColor themeBlueColor]];
    [self.rtcPushButton setTitle:Localize(@"MLVB-API-Example.LivePk.lebPlay") forState:UIControlStateNormal];
    self.userIdLabel.hidden = true;
    self.userIdTextField.hidden = true;
    self.isAnchor = false;
    self.roleTopConstraint.constant = 20;
}


@end
