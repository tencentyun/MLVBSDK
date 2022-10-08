//
//  LivePushCameraEnterViewController.m
//  MLVB-API-Example-OC
//
//  Created by bluedang on 2021/6/24.
//  Copyright © 2021 Tencent. All rights reserved.
//
//

#import "LivePushCameraEnterViewController.h"
#import "LivePushCameraViewController.h"


@interface LivePushCameraEnterViewController ()
@property (weak, nonatomic) IBOutlet UILabel *streamIdLabel;
@property (weak, nonatomic) IBOutlet UITextField *streamIdTextField;
@property (weak, nonatomic) IBOutlet UILabel *audioQualityLabel;

@property (weak, nonatomic) IBOutlet UIButton *defaultAudioButton;
@property (weak, nonatomic) IBOutlet UIButton *speechAudioButton;
@property (weak, nonatomic) IBOutlet UIButton *musicAudioButton;

@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIButton *standLivePushButton;
@property (weak, nonatomic) IBOutlet UIButton *rtcPushButton;

@property (assign, nonatomic) V2TXLiveAudioQuality qulity;
@end

@implementation LivePushCameraEnterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDefaultUIConfig];
    self.qulity = V2TXLiveAudioQualityDefault;
}

- (void)setupDefaultUIConfig {
    self.title = localize(@"MLVB-API-Example.LivePushCamera.title");
    self.streamIdLabel.text = localize(@"MLVB-API-Example.LivePushCamera.streamIdInput");
    self.streamIdLabel.adjustsFontSizeToFitWidth = true;
    
    self.audioQualityLabel.text = localize(@"MLVB-API-Example.LivePushCamera.audioQualityInput");
    self.audioQualityLabel.adjustsFontSizeToFitWidth = true;
    
    [self.defaultAudioButton setTitle:localize(@"MLVB-API-Example.LivePushCamera.audioDefault") forState:UIControlStateNormal];
    [self.defaultAudioButton setBackgroundColor:[UIColor themeBlueColor]];
    [self.speechAudioButton setTitle:localize(@"MLVB-API-Example.LivePushCamera.audioSpeech") forState:UIControlStateNormal];
    [self.speechAudioButton setBackgroundColor:[UIColor themeGrayColor]];
    [self.musicAudioButton setTitle:localize(@"MLVB-API-Example.LivePushCamera.audioMusic") forState:UIControlStateNormal];
    [self.musicAudioButton setBackgroundColor:[UIColor themeGrayColor]];
    
    [self.standLivePushButton setTitle:localize(@"MLVB-API-Example.LivePushCamera.standPush") forState:UIControlStateNormal];
    [self.standLivePushButton setBackgroundColor:[UIColor themeBlueColor]];
    self.standLivePushButton.titleLabel.adjustsFontSizeToFitWidth = true;
    
    self.descriptionTextView.text = localize(@"MLVB-API-Example.LivePushCamera.descripView");

    [self.rtcPushButton setTitle:localize(@"MLVB-API-Example.LivePushCamera.rtcPush") forState:UIControlStateNormal];
    [self.rtcPushButton setBackgroundColor:[UIColor themeBlueColor]];
    self.rtcPushButton.titleLabel.adjustsFontSizeToFitWidth = true;
    
    self.streamIdTextField.text = [NSString generateRandomStreamId];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:true];
}

#pragma mark - Actions

- (IBAction)onStandPushButtonClick:(UIButton*)button {
    LivePushCameraViewController* cameraVC = [[LivePushCameraViewController alloc]
     initWithStreamId:self.streamIdTextField.text isRTCPush:false audioQulity:self.qulity];
    [self.navigationController pushViewController:cameraVC animated:YES];
}

- (IBAction)onRtcPushButtonClick:(UIButton*)button {
    LivePushCameraViewController* cameraVC = [[LivePushCameraViewController alloc]
     initWithStreamId:self.streamIdTextField.text isRTCPush:true audioQulity:self.qulity];
    [self.navigationController pushViewController:cameraVC animated:YES];
}

- (IBAction)onDefaultAudioButtonClick:(id)sender {
    [self.defaultAudioButton setBackgroundColor:[UIColor themeBlueColor]];
    [self.speechAudioButton setBackgroundColor:[UIColor themeGrayColor]];
    [self.musicAudioButton setBackgroundColor:[UIColor themeGrayColor]];
    self.qulity = V2TXLiveAudioQualityDefault;
}

- (IBAction)onSpeechAudioButtonClick:(id)sender {
    [self.defaultAudioButton setBackgroundColor:[UIColor themeGrayColor]];
    [self.speechAudioButton setBackgroundColor:[UIColor themeBlueColor]];
    [self.musicAudioButton setBackgroundColor:[UIColor themeGrayColor]];
    self.qulity = V2TXLiveAudioQualitySpeech;
}

- (IBAction)onMusicAudioButtonClick:(id)sender {
    [self.defaultAudioButton setBackgroundColor:[UIColor themeGrayColor]];
    [self.speechAudioButton setBackgroundColor:[UIColor themeGrayColor]];
    [self.musicAudioButton setBackgroundColor:[UIColor themeBlueColor]];
    self.qulity = V2TXLiveAudioQualityMusic;
}


@end
