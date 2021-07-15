//
//  LivePlayViewController.m
//  MLVB-API-Example-OC
//
//  Created by bluedang on 2021/6/28.
//

/*
 直播拉流
 MLVB APP 直播拉流功能
 本文件展示如何集成直播拉流功能
 1、设置渲染的view API:[self.livePlayer setRenderView:self.view];
 2、开始播放 API:[self.livePlayer startPlay:url];
 参考文档：https://cloud.tencent.com/document/product/454/55880
 */
/*
 Playback
 Playback in MLVB App
 This document shows how to integrate the playback feature.
 1. Set the rendering view: [self.livePlayer setRenderView:self.view]
 2. Start playback: [self.livePlayer startPlay:url]
 Documentation: https://cloud.tencent.com/document/product/454/55880
 */


#import "LivePlayViewController.h"

@interface LivePlayViewController () <V2TXLivePlayerObserver>
@property (weak, nonatomic) IBOutlet UIButton *muteButton;

@property (strong, nonatomic) V2TXLivePlayer *livePlayer;
@property (strong, nonatomic) NSString *streamId;

@property (assign, nonatomic) LivePlayMode mode;
@end

@implementation LivePlayViewController


- (instancetype)initWithStreamId:(NSString*)streamId playMode:(LivePlayMode)mode {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    self.mode = mode;
    self.streamId = streamId;
    
    self.livePlayer = [[V2TXLivePlayer alloc] init];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDefaultUIConfig];
    [self startPlay];
}

- (void)setupDefaultUIConfig {
    self.title = self.streamId;
    [self.muteButton setBackgroundColor:[UIColor themeBlueColor]];
    [self.muteButton setTitle:Localize(@"MLVB-API-Example.LivePlay.mute") forState:UIControlStateNormal];
    [self.muteButton setTitle:Localize(@"MLVB-API-Example.LivePlay.unmute") forState:UIControlStateSelected];
}

- (void)startPlay {
    [self.livePlayer setRenderView:self.view];
    
    NSString* url;
    switch (self.mode) {
        case StandPlay:
            url = [LiveUrl generateRtmpPlayUrl:self.streamId];
            break;
        case RTCPlay:
            url = [LiveUrl generateTRTCPlayUrl:self.streamId];
            break;
        case LebPlay:
            url = [LiveUrl generateLebPlayUrl:self.streamId];
            break;
    }
    [self.livePlayer startPlay:url];
}

#pragma mark - Actions

- (IBAction)onMuteAudioButtonClick:(UIButton*)sender {
    sender.selected = !sender.isSelected;
    if (sender.isSelected) {
        [self.livePlayer setPlayoutVolume:0];
    } else {
        [self.livePlayer setPlayoutVolume:100];
    }
}

@end
