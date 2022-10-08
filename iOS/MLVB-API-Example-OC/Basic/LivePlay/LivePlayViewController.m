//
//  LivePlayViewController.m
//  MLVB-API-Example-OC
//
//  Created by bluedang on 2021/6/28.
//  Copyright © 2021 Tencent. All rights reserved.
//

/*
 直播拉流
 MLVB APP 直播拉流功能
 本文件展示如何集成直播拉流功能
 1、设置渲染的view API:[self.livePlayer setRenderView:self.view];
 2、开始播放 API:[self.livePlayer startLivePlay:url];
 参考文档：https://cloud.tencent.com/document/product/454/56597
 RTC拉流目前仅中国大陆支持，其他地区正陆续开发中。

 */
/*
 Playback
 Playback in MLVB App
 This document shows how to integrate the playback feature.
 1. Set the rendering view: [self.livePlayer setRenderView:self.view]
 2. Start playback: [self.livePlayer startLivePlay:url]
 Documentation: https://cloud.tencent.com/document/product/454/56597
 Currently only supported in China, other regions are continuing to develop.
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
    [self.muteButton setTitle:localize(@"MLVB-API-Example.LivePlay.mute") forState:UIControlStateNormal];
    [self.muteButton setTitle:localize(@"MLVB-API-Example.LivePlay.unmute") forState:UIControlStateSelected];
}

- (void)startPlay {
    [self.livePlayer setRenderView:self.view];
    
    NSString* url;
    switch (self.mode) {
        case RtmpPlay:
            url = [URLUtils generateRtmpPlayUrl:self.streamId];
            break;
        case FlvPlay:
            url = [URLUtils generateFlvPlayUrl:self.streamId];
            break;
        case HlsPlay:
            url = [URLUtils generateHlsPlayUrl:self.streamId];
            break;
        case RTCPlay:
            url = [URLUtils generateTRTCPlayUrl:self.streamId];
            break;
    }
    [self.livePlayer startLivePlay:url];
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
