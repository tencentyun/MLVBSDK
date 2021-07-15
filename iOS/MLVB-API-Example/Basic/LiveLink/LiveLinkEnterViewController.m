//
//  LiveLinkEnterViewController.m
//  MLVB-API-Example-OC
//
//  Created by bluedang on 2021/6/29.
//

#import "LiveLinkEnterViewController.h"
#import "LiveLinkAnchorViewController.h"
#import "LiveLinkAudienceViewController.h"


@interface LiveLinkEnterViewController ()
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

@implementation LiveLinkEnterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDefaultUIConfig];
    self.isAnchor = true;
}

- (void)setupDefaultUIConfig {
    self.title = Localize(@"MLVB-API-Example.LiveLink.title");
    self.streamIdLabel.text = Localize(@"MLVB-API-Example.LiveLink.streamIdInput");
    self.streamIdLabel.adjustsFontSizeToFitWidth = true;
    
    self.userIdLabel.text = Localize(@"MLVB-API-Example.LiveLink.userIdInput");
    self.userIdLabel.adjustsFontSizeToFitWidth = true;

    self.roleLabel.text = Localize(@"MLVB-API-Example.LiveLink.chooseRole");
    self.roleLabel.adjustsFontSizeToFitWidth = true;
    
    [self.anchorButton setTitle:Localize(@"MLVB-API-Example.LiveLink.anchor") forState:UIControlStateNormal];
    [self.anchorButton setBackgroundColor:[UIColor themeBlueColor]];
    [self.audienceButton setTitle:Localize(@"MLVB-API-Example.LiveLink.audience") forState:UIControlStateNormal];
    [self.audienceButton setBackgroundColor:[UIColor themeGrayColor]];
    self.anchorButton.titleLabel.adjustsFontSizeToFitWidth = true;
    self.audienceButton.titleLabel.adjustsFontSizeToFitWidth = true;
    
    NSString *text = Localize(@"MLVB-API-Example.LiveLink.descripView");
    
    NSRange redRange = [text rangeOfString:Localize(@"MLVB-API-Example.LiveLink.descripViewRed")];
    
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:text];
    [attrText addAttributes:@{
                    (id)NSForegroundColorAttributeName : [UIColor whiteColor],
                    (id)NSFontAttributeName : [UIFont systemFontOfSize:15],
                    } range:NSMakeRange(0, [text length])];
    
    [attrText addAttributes:@{
                    (id)NSForegroundColorAttributeName : [UIColor redColor],
                    (id)NSFontAttributeName : [UIFont systemFontOfSize:15],
                    } range:redRange];

    self.descriptionTextView.attributedText = attrText;
    self.descriptionTextView.backgroundColor = [UIColor themeGrayColor];

    [self.rtcPushButton setTitle:Localize(@"MLVB-API-Example.LiveLink.rtcPush") forState:UIControlStateNormal];
    [self.rtcPushButton setTitle:Localize(@"MLVB-API-Example.LiveLink.lebPlay") forState:UIControlStateSelected];
    [self.rtcPushButton setBackgroundColor:[UIColor themeBlueColor]];
    self.rtcPushButton.titleLabel.adjustsFontSizeToFitWidth = true;
    
    self.streamIdTextField.text = [NSString generateRandomStreamId];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:true];
}

- (void)pushAnchorVC {
    LiveLinkAnchorViewController *anchorVC = [[LiveLinkAnchorViewController alloc] initWithStreamId:self.streamIdTextField.text userId:self.userIdTextField.text];
    [self.navigationController pushViewController:anchorVC animated:YES];
}

- (void)pushAudienceVC {
    LiveLinkAudienceViewController *audienceVC = [[LiveLinkAudienceViewController alloc] initWithStreamId:self.streamIdTextField.text userId:self.userIdTextField.text];
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
    [self.rtcPushButton setTitle:Localize(@"MLVB-API-Example.LiveLink.rtcPush") forState:UIControlStateNormal];
    self.userIdLabel.hidden = false;
    self.userIdTextField.hidden = false;
    self.isAnchor = true;
    self.roleTopConstraint.constant = 110;
}

- (IBAction)onAudienceButtonClick:(id)sender {
    [self.anchorButton setBackgroundColor:[UIColor themeGrayColor]];
    [self.audienceButton setBackgroundColor:[UIColor themeBlueColor]];
    [self.rtcPushButton setTitle:Localize(@"MLVB-API-Example.LiveLink.lebPlay") forState:UIControlStateNormal];
    self.userIdLabel.hidden = true;
    self.userIdTextField.hidden = true;
    self.isAnchor = false;
    self.roleTopConstraint.constant = 20;
}


@end
