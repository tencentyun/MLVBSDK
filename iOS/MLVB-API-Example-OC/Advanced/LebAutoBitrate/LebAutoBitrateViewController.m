//  Copyright © 2022 Tencent. All rights reserved.
/*
快直播自适应码率播放
 MLVB APP 快直播自适应码率播放功能
 本文件展示如何集成快直播自适应码率播放功能
 1、设置渲染画面 API:[self.livePlayer setRenderView:self.view];
 2、开始播放 API: [self.livePlayer startLivePlay:url];
 参考文档：https://cloud.tencent.com/document/product/454/81212
 开始自适应码率播放后，就无法进行进行无缝切流了。如果在播放状态进入自适应码率，
 需要先停止当前播放，然后再开始自适应播放
 */
/*
Webrtc Auto Bitrate
 MLVB APP Webrtc Auto Bitrate
 1、Set Render View API:[self.livePlayer setRenderView:self.view];
 2、Start Play API: [self.livePlayer startLivePlay:url];
 Documentation: https://cloud.tencent.com/document/product/454/81212
 After the adaptive bitrate playback is started, seamless streaming cannot be performed.
 If you enter the adaptive bit rate in the playback state,
 Need to stop current playback before starting adaptive playback
 */

#import "LebAutoBitrateViewController.h"

typedef NS_ENUM(NSInteger, PlayResolution) {
    Resolution1080p,
    Resolution720p,
    Resolution540p,
};

@interface LebAutoBitrateViewController () <V2TXLivePlayerObserver>
@property (strong, nonatomic) V2TXLivePlayer *livePlayer;
@property (weak, nonatomic) IBOutlet UIButton *autoBitrateButton;
@property (weak, nonatomic) IBOutlet UIButton *switch1080pButton;
@property (weak, nonatomic) IBOutlet UIButton *switch720pButton;
@property (weak, nonatomic) IBOutlet UIButton *switch540pButton;
@end

@implementation LebAutoBitrateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDefaultUIConfig];
    
    self.livePlayer = [[V2TXLivePlayer alloc] init];
    [self.livePlayer setObserver:self];
    [self.livePlayer setRenderView:self.view];
    [self.livePlayer setRenderFillMode:V2TXLiveFillModeFit];
    
    NSString* url = [self generateUrlWithResolution:Resolution720p];
    [self.livePlayer startLivePlay:url];
}

- (void)setupDefaultUIConfig {
    self.title = localize(@"MLVB-API-Example.LebAutoBitrate.title");
    
    [self.autoBitrateButton setTitle:localize(@"MLVB-API-Example.LebAutoBitrate.startAutoBitrate") forState:UIControlStateNormal];
    [self.autoBitrateButton setTitle:localize(@"MLVB-API-Example.LebAutoBitrate.stopAutoBitrate") forState:UIControlStateSelected];

    [self.autoBitrateButton setBackgroundColor:[UIColor themeBlueColor]];
    self.autoBitrateButton.titleLabel.adjustsFontSizeToFitWidth = true;
    
    [self.switch1080pButton setTitle:localize(@"MLVB-API-Example.LebAutoBitrate.1080p") forState:UIControlStateNormal];
    [self.switch1080pButton setBackgroundColor:[UIColor themeBlueColor]];
    self.switch1080pButton.titleLabel.adjustsFontSizeToFitWidth = true;

    [self.switch720pButton setTitle:localize(@"MLVB-API-Example.LebAutoBitrate.720p") forState:UIControlStateNormal];
    [self.switch720pButton setBackgroundColor:[UIColor themeBlueColor]];
    self.switch720pButton.titleLabel.adjustsFontSizeToFitWidth = true;
    
    [self.switch540pButton setTitle:localize(@"MLVB-API-Example.LebAutoBitrate.540p") forState:UIControlStateNormal];
    [self.switch540pButton setBackgroundColor:[UIColor themeBlueColor]];
    self.switch540pButton.titleLabel.adjustsFontSizeToFitWidth = true;
}

- (NSString*)generateUrlWithResolution:(PlayResolution)resolution {
    NSString* baseUrl = @"webrtc://liteavapp.qcloud.com/live/liteavdemoplayerstreamid";
    NSString* transcodingName = @"";
    switch (resolution) {
        case Resolution1080p:
            transcodingName = @"demo1080p";
            break;
        case Resolution720p:
            transcodingName = @"demo720p";
            break;
        case Resolution540p:
            transcodingName = @"demo540p";
            break;
    }
    return [NSString stringWithFormat:@"%@?tabr_bitrates=demo1080p,demo720p,demo540p&tabr_start_bitrate=%@",
            baseUrl,transcodingName];
}

- (NSString*)generateUrlIsAutoBitrate:(BOOL)isAutoBitrate {
    NSString* url = [self generateUrlWithResolution:Resolution540p];
    if (isAutoBitrate) {
        url = [url stringByAppendingString:@"&tabr_control=auto"];
    }
    return url;
}

#pragma mark - V2TXLivePlayerObserver
- (void)onVideoResolutionChanged:(id<V2TXLivePlayer>)player width:(NSInteger)width height:(NSInteger)height {
    [self showAlertViewController:localize(@"MLVB-API-Example.LebAutoBitrate.tips") message:[NSString stringWithFormat:localize(@"MLVB-API-Example.LebAutoBitrate.currentResolution"), (long)width, height] handler:nil];
}


#pragma mark - Actions
- (IBAction)onAutoBitrateButtonClick:(UIButton*)sender {
    sender.selected = !sender.isSelected;
    if (sender.isSelected) {
        [self.switch1080pButton setBackgroundColor:[UIColor themeGrayColor]];
        [self.switch720pButton setBackgroundColor:[UIColor themeGrayColor]];
        [self.switch540pButton setBackgroundColor:[UIColor themeGrayColor]];
        [self.switch1080pButton setEnabled:false];
        [self.switch720pButton setEnabled:false];
        [self.switch540pButton setEnabled:false];
    } else {
        [self.switch1080pButton setBackgroundColor:[UIColor themeBlueColor]];
        [self.switch720pButton setBackgroundColor:[UIColor themeBlueColor]];
        [self.switch540pButton setBackgroundColor:[UIColor themeBlueColor]];
        [self.switch1080pButton setEnabled:true];
        [self.switch720pButton setEnabled:true];
        [self.switch540pButton setEnabled:true];
    }
    
    NSString* url = [self generateUrlIsAutoBitrate:sender.isSelected];
    [self.livePlayer stopPlay];
    [self.livePlayer startLivePlay:url];
}

- (IBAction)onSwitch1080pButtonClick:(UIButton*)sender {
    NSString* url = [self generateUrlWithResolution:Resolution1080p];
    [self.livePlayer switchStream:url];
}
- (IBAction)onSwitch720pButtonClick:(UIButton*)sender {
    NSString* url = [self generateUrlWithResolution:Resolution720p];
    [self.livePlayer switchStream:url];
}
- (IBAction)onSwitch540pButtonClick:(UIButton*)sender {
    NSString* url = [self generateUrlWithResolution:Resolution540p];
    [self.livePlayer switchStream:url];
}

@end
