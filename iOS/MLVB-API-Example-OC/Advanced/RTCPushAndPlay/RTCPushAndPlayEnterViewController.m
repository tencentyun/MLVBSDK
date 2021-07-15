//
//  RTCPushAndPlayEnterViewController.m
//  MLVB-API-Example-OC
//
//  Created by bluedang on 2021/6/30.
//

#import "RTCPushAndPlayEnterViewController.h"
#import "RTCPushAndPlayAnchorViewController.h"
#import "RTCPushAndPlayAudienceViewController.h"

@interface RTCPushAndPlayEnterViewController ()
@property (weak, nonatomic) IBOutlet UILabel *streamIdLabel;
@property (weak, nonatomic) IBOutlet UITextField *streamIdTextField;
@property (weak, nonatomic) IBOutlet UILabel *roleLabel;

@property (weak, nonatomic) IBOutlet UIButton *anchorButton;
@property (weak, nonatomic) IBOutlet UIButton *audienceButton;

@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIButton *rtcPushButton;

@property (assign, nonatomic) BOOL isAnchor;;
@end

@implementation RTCPushAndPlayEnterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDefaultUIConfig];
    self.isAnchor = true;
}

- (void)setupDefaultUIConfig {
    self.title = Localize(@"MLVB-API-Example.RTCPushAndPlay.title");
    UILabel* tlabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, 200, 40)];
    tlabel.text = self.navigationItem.title;
    tlabel.textColor = [UIColor whiteColor];
    tlabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 17.0];
    tlabel.backgroundColor = [UIColor clearColor];
    tlabel.adjustsFontSizeToFitWidth = YES;
    tlabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = tlabel;

    self.streamIdLabel.text = Localize(@"MLVB-API-Example.RTCPushAndPlay.streamIdInput");
    self.streamIdLabel.adjustsFontSizeToFitWidth = true;
    
    self.roleLabel.text = Localize(@"MLVB-API-Example.RTCPushAndPlay.chooseRole");
    self.roleLabel.adjustsFontSizeToFitWidth = true;
    
    [self.anchorButton setTitle:Localize(@"MLVB-API-Example.RTCPushAndPlay.anchor") forState:UIControlStateNormal];
    [self.anchorButton setBackgroundColor:[UIColor themeBlueColor]];
    [self.audienceButton setTitle:Localize(@"MLVB-API-Example.RTCPushAndPlay.audience") forState:UIControlStateNormal];
    [self.audienceButton setBackgroundColor:[UIColor themeGrayColor]];
    self.anchorButton.titleLabel.adjustsFontSizeToFitWidth = true;
    self.audienceButton.titleLabel.adjustsFontSizeToFitWidth = true;
    
    self.descriptionTextView.text = Localize(@"MLVB-API-Example.RTCPushAndPlay.descripView");
    self.descriptionTextView.backgroundColor = [UIColor themeGrayColor];

    [self.rtcPushButton setTitle:Localize(@"MLVB-API-Example.RTCPushAndPlay.rtcPush") forState:UIControlStateNormal];
    [self.rtcPushButton setTitle:Localize(@"MLVB-API-Example.RTCPushAndPlay.rtcPlay") forState:UIControlStateSelected];
    [self.rtcPushButton setBackgroundColor:[UIColor themeBlueColor]];
    self.rtcPushButton.titleLabel.adjustsFontSizeToFitWidth = true;
    
    self.streamIdTextField.text = [NSString generateRandomStreamId];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:true];
}

- (void)pushAnchorVC {
    RTCPushAndPlayAnchorViewController *anchorVC = [[RTCPushAndPlayAnchorViewController alloc] initWithStreamId:self.streamIdTextField.text];
    [self.navigationController pushViewController:anchorVC animated:YES];
}

- (void)pushAudienceVC {
    RTCPushAndPlayAudienceViewController *anchorVC = [[RTCPushAndPlayAudienceViewController alloc] initWithStreamId:self.streamIdTextField.text];
    [self.navigationController pushViewController:anchorVC animated:YES];
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
    [self.rtcPushButton setTitle:Localize(@"MLVB-API-Example.RTCPushAndPlay.rtcPush") forState:UIControlStateNormal];
    self.isAnchor = true;
}

- (IBAction)onAudienceButtonClick:(id)sender {
    [self.anchorButton setBackgroundColor:[UIColor themeGrayColor]];
    [self.audienceButton setBackgroundColor:[UIColor themeBlueColor]];
    [self.rtcPushButton setTitle:Localize(@"MLVB-API-Example.RTCPushAndPlay.lebPlay") forState:UIControlStateNormal];
    self.isAnchor = false;
}


@end
