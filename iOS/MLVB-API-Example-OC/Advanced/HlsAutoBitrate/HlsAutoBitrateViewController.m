//  Copyright © 2022 Tencent. All rights reserved.
/*
HLS自适应码率播放
 MLVB APP 快直播自适应码率播放功能
 本文件展示如何集成快直播自适应码率播放功能
 1、设置渲染画面 API:[self.livePlayer setRenderView:self.view];
 2、开始播放 API: [self.livePlayer startLivePlay:url];
 参考文档：https://cloud.tencent.com/document/product/454/81211
 */
/*
HLS Auto Bitrate
 MLVB APP HLS Auto Bitrate
 1、Set Render View API:[self.livePlayer setRenderView:self.view];
 2、Start Play API: [self.livePlayer startLivePlay:url];
 Documentation: https://cloud.tencent.com/document/product/454/81211
 */

#import "HlsAutoBitrateViewController.h"

static NSString * const G_DEFAULT_URL = @"http://liteavapp.qcloud.com/live/liteavdemoplayerstreamid_autoAdjust.m3u8";

typedef NS_ENUM(NSInteger, PlayResolution) {
    Resolution1080p,
    Resolution720p,
    Resolution540p,
};

@interface HlsAutoBitrateViewController () <V2TXLivePlayerObserver>
@property (strong, nonatomic) V2TXLivePlayer *livePlayer;
@property (strong, nonatomic) NSArray<V2TXLiveStreamInfo *> *streams;
@property (weak, nonatomic) IBOutlet UIButton *autoBitrateButton;
@property (weak, nonatomic) IBOutlet UIButton *switch1080pButton;
@property (weak, nonatomic) IBOutlet UIButton *switch720pButton;
@property (weak, nonatomic) IBOutlet UIButton *switch540pButton;
@end

@implementation HlsAutoBitrateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDefaultUIConfig];

    self.livePlayer = [[V2TXLivePlayer alloc] init];
    [self.livePlayer setObserver:self];
    [self.livePlayer setRenderView:self.view];
    [self.livePlayer setRenderFillMode:V2TXLiveFillModeFit];

    [self.livePlayer startLivePlay:G_DEFAULT_URL];
}

- (void)setupDefaultUIConfig {
    self.title = localize(@"MLVB-API-Example.HlsAutoBitrate.title");

    [self.autoBitrateButton setTitle:localize(@"MLVB-API-Example.HlsAutoBitrate.autoBitrate") forState:UIControlStateNormal];

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

- (NSString*)getUrlWithResolution:(PlayResolution)resolution {
    int length = 0;
    switch (resolution) {
        case Resolution1080p:
            length = 1080;
            break;
        case Resolution720p:
            length = 720;
            break;
        case Resolution540p:
            length = 540;
            break;
    }
    for (V2TXLiveStreamInfo* streamInfo in self.streams) {
        if (streamInfo.width == length || streamInfo.height == length) {
            return streamInfo.url;
        }
    }
    return @"";
}

#pragma mark - V2TXLivePlayerObserver
- (void)onVideoResolutionChanged:(id<V2TXLivePlayer>)player width:(NSInteger)width height:(NSInteger)height {
    [self showAlertViewController:localize(@"MLVB-API-Example.LebAutoBitrate.tips") message:[NSString stringWithFormat:localize(@"MLVB-API-Example.LebAutoBitrate.currentResolution"), (long)width, height] handler:nil];
}

- (void)onConnected:(id<V2TXLivePlayer>)player extraInfo:(NSDictionary *)extraInfo {
    self.streams = [self.livePlayer getStreamList];
}

#pragma mark - Actions
- (IBAction)onAutoBitrateButtonClick:(UIButton*)sender {
    [self.livePlayer switchStream:G_DEFAULT_URL];
}

- (IBAction)onSwitch1080pButtonClick:(UIButton*)sender {
    NSString* url = [self getUrlWithResolution:Resolution1080p];
    [self.livePlayer switchStream:url];
}
- (IBAction)onSwitch720pButtonClick:(UIButton*)sender {
    NSString* url = [self getUrlWithResolution:Resolution720p];
    [self.livePlayer switchStream:url];
}
- (IBAction)onSwitch540pButtonClick:(UIButton*)sender {
    NSString* url = [self getUrlWithResolution:Resolution540p];
    [self.livePlayer switchStream:url];
}

@end
