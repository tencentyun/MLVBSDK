//
//  LivePlayViewController.m
//  MLVB-API-Example-OC
//
//  Created by bluedang on 2021/6/28.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "LivePlayEnterViewController.h"
#import "LivePlayViewController.h"

@interface LivePlayEnterViewController ()
@property (weak, nonatomic) IBOutlet UILabel *streamIdLabel;
@property (weak, nonatomic) IBOutlet UITextField *streamIdTextField;


@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIButton *hlsPlayButton;
@property (weak, nonatomic) IBOutlet UIButton *rtcPlayButton;
@property (weak, nonatomic) IBOutlet UIButton *rtmpPlayButton;
@property (weak, nonatomic) IBOutlet UIButton *flvPlayButton;

@end

@implementation LivePlayEnterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDefaultUIConfig];
}

- (void)setupDefaultUIConfig {
    self.title = localize(@"MLVB-API-Example.LivePlay.title");
    self.streamIdLabel.text = localize(@"MLVB-API-Example.LivePlay.streamIdInput");
    self.streamIdLabel.adjustsFontSizeToFitWidth = true;
    
    
    [self.hlsPlayButton setTitle:localize(@"MLVB-API-Example.LivePlay.hlsPlay") forState:UIControlStateNormal];
    [self.hlsPlayButton setBackgroundColor:[UIColor themeBlueColor]];
    self.hlsPlayButton.titleLabel.adjustsFontSizeToFitWidth = true;
    
    [self.rtmpPlayButton setTitle:localize(@"MLVB-API-Example.LivePlay.rtmpPlay") forState:UIControlStateNormal];
    [self.rtmpPlayButton setBackgroundColor:[UIColor themeBlueColor]];
    self.rtmpPlayButton.titleLabel.adjustsFontSizeToFitWidth = true;
    
    [self.flvPlayButton setTitle:localize(@"MLVB-API-Example.LivePlay.flvPlay") forState:UIControlStateNormal];
    [self.flvPlayButton setBackgroundColor:[UIColor themeBlueColor]];
    self.flvPlayButton.titleLabel.adjustsFontSizeToFitWidth = true;
    
    [self.rtcPlayButton setTitle:localize(@"MLVB-API-Example.LivePlay.rtcPlay") forState:UIControlStateNormal];
    [self.rtcPlayButton setBackgroundColor:[UIColor themeBlueColor]];
    self.rtcPlayButton.titleLabel.adjustsFontSizeToFitWidth = true;
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:localize(@"MLVB-API-Example.LivePlay.descripView") attributes:@{
        (id)NSForegroundColorAttributeName : [UIColor whiteColor],
        (id)NSFontAttributeName : [UIFont systemFontOfSize:14],
    }];
    self.descriptionTextView.attributedText = text;

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

- (IBAction)onRtmpPlayButtonClick:(UIButton*)button {
    [self pushPlayViewController:RtmpPlay];
}

- (IBAction)onFlvPlayButtonClick:(UIButton*)button {
    [self pushPlayViewController:FlvPlay];
}

- (IBAction)onHlsPlayButtonClick:(UIButton*)button {
    [self pushPlayViewController:HlsPlay];
}

- (IBAction)onRtcPlayButtonClick:(UIButton*)button {
    [self pushPlayViewController:RTCPlay];
}

@end
