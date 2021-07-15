//
//  LivePushScreenViewController.m
//  MLVB-API-Example-OC
//
//  Created by bluedang on 2021/6/28.
//

#import "LivePushScreenEnterViewController.h"
#import "LivePushScreenViewController.h"

@interface LivePushScreenEnterViewController ()
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

@implementation LivePushScreenEnterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDefaultUIConfig];
    self.qulity = V2TXLiveAudioQualityDefault;
}

- (void)setupDefaultUIConfig {
    self.title = Localize(@"MLVB-API-Example.LivePushScreen.title");
    self.streamIdLabel.text = Localize(@"MLVB-API-Example.LivePushScreen.streamIdInput");
    self.streamIdLabel.adjustsFontSizeToFitWidth = true;
    
    self.audioQualityLabel.text = Localize(@"MLVB-API-Example.LivePushScreen.audioQualityInput");
    self.audioQualityLabel.adjustsFontSizeToFitWidth = true;
    
    [self.defaultAudioButton setTitle:Localize(@"MLVB-API-Example.LivePushScreen.audioDefault") forState:UIControlStateNormal];
    [self.defaultAudioButton setBackgroundColor:[UIColor themeBlueColor]];
    [self.speechAudioButton setTitle:Localize(@"MLVB-API-Example.LivePushScreen.audioSpeech") forState:UIControlStateNormal];
    [self.speechAudioButton setBackgroundColor:[UIColor themeGrayColor]];
    [self.musicAudioButton setTitle:Localize(@"MLVB-API-Example.LivePushScreen.audioMusic") forState:UIControlStateNormal];
    [self.musicAudioButton setBackgroundColor:[UIColor themeGrayColor]];
    
    [self.standLivePushButton setTitle:Localize(@"MLVB-API-Example.LivePushScreen.standPush") forState:UIControlStateNormal];
    [self.standLivePushButton setBackgroundColor:[UIColor themeGrayColor]];
    self.standLivePushButton.titleLabel.adjustsFontSizeToFitWidth = true;
    
    self.descriptionTextView.text = Localize(@"MLVB-API-Example.LivePushScreen.descripView");

    [self.rtcPushButton setTitle:Localize(@"MLVB-API-Example.LivePushScreen.rtcPush") forState:UIControlStateNormal];
    [self.rtcPushButton setBackgroundColor:[UIColor themeBlueColor]];
    self.rtcPushButton.titleLabel.adjustsFontSizeToFitWidth = true;
    
    self.streamIdTextField.text = [NSString generateRandomStreamId];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:true];
}

#pragma mark - Actions

- (IBAction)onStandPushButtonClick:(UIButton*)button {
    LivePushScreenViewController* cameraVC = [[LivePushScreenViewController alloc] initWithStreamId:self.streamIdTextField.text isRTCPush:false audioQulity:self.qulity];
    [self.navigationController pushViewController:cameraVC animated:YES];
}

- (IBAction)onRtcPushButtonClick:(UIButton*)button {
    LivePushScreenViewController* cameraVC = [[LivePushScreenViewController alloc] initWithStreamId:self.streamIdTextField.text isRTCPush:true audioQulity:self.qulity];
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
