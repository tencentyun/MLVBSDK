//
//  LivePlayViewController.m
//  MLVB-API-Example-OC
//
//  Created by bluedang on 2021/6/28.
//

#import "LivePlayEnterViewController.h"
#import "LivePlayViewController.h"

@interface LivePlayEnterViewController ()
@property (weak, nonatomic) IBOutlet UILabel *streamIdLabel;
@property (weak, nonatomic) IBOutlet UITextField *streamIdTextField;


@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIButton *standPlayButton;
@property (weak, nonatomic) IBOutlet UIButton *rtcPlayButton;
@property (weak, nonatomic) IBOutlet UIButton *lebPlayButton;

@end

@implementation LivePlayEnterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDefaultUIConfig];
}

- (void)setupDefaultUIConfig {
    self.title = Localize(@"MLVB-API-Example.LivePlay.title");
    self.streamIdLabel.text = Localize(@"MLVB-API-Example.LivePlay.streamIdInput");
    self.streamIdLabel.adjustsFontSizeToFitWidth = true;
    
    
    [self.standPlayButton setTitle:Localize(@"MLVB-API-Example.LivePlay.standPlay") forState:UIControlStateNormal];
    [self.standPlayButton setBackgroundColor:[UIColor themeGrayColor]];
    self.standPlayButton.titleLabel.adjustsFontSizeToFitWidth = true;
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:Localize(@"MLVB-API-Example.LivePlay.descripView") attributes:@{
        (id)NSForegroundColorAttributeName : [UIColor whiteColor],
        (id)NSFontAttributeName : [UIFont systemFontOfSize:14],
    }];
    [text appendAttributedString:[[NSAttributedString alloc] initWithString:Localize(@"MLVB-API-Example.LivePlay.descripRecommend") attributes:@{
        (id)NSForegroundColorAttributeName : [UIColor redColor],
        (id)NSFontAttributeName : [UIFont systemFontOfSize:14],
    }]];
    self.descriptionTextView.attributedText = text;
    
    [self.rtcPlayButton setTitle:Localize(@"MLVB-API-Example.LivePlay.rtcPlay") forState:UIControlStateNormal];
    [self.rtcPlayButton setBackgroundColor:[UIColor themeGrayColor]];
    self.rtcPlayButton.titleLabel.adjustsFontSizeToFitWidth = true;
    
    [self.lebPlayButton setTitle:Localize(@"MLVB-API-Example.LivePlay.lebPlay") forState:UIControlStateNormal];
    [self.lebPlayButton setBackgroundColor:[UIColor themeBlueColor]];
    self.lebPlayButton.titleLabel.adjustsFontSizeToFitWidth = true;

    self.streamIdTextField.text = [NSString generateRandomStreamId];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:true];
}

- (void)pushPlayViewController:(LivePlayMode)mode {
    LivePlayViewController *playVC = [[LivePlayViewController alloc] initWithStreamId:self.streamIdTextField.text playMode:mode];
    [self.navigationController pushViewController:playVC animated:YES];
}

#pragma mark - Actions

- (IBAction)onStandPushButtonClick:(UIButton*)button {
    [self pushPlayViewController:StandPlay];
}

- (IBAction)onRtcPushButtonClick:(UIButton*)button {
    [self pushPlayViewController:RTCPlay];
}

- (IBAction)onLebPushButtonClick:(UIButton*)button {
    [self pushPlayViewController:LebPlay];
}

@end
