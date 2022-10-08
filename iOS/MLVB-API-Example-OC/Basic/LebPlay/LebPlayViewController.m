//  Copyright © 2022 Tencent. All rights reserved.
/*
 快直播拉流
 MLVB APP 快直播拉流功能
 本文件展示如何集成快直播拉流功能
 1、设置渲染的view API:[self.livePlayer setRenderView:self.view];
 2、开始播放 API:[self.livePlayer startLivePlay:url];
 参考文档：https://cloud.tencent.com/document/product/454/55880
 */
/*
 LEB Playback
 LEB Playback in MLVB App
 This document shows how to integrate the LEB playback feature.
 1. Set the rendering view: [self.livePlayer setRenderView:self.view]
 2. Start playback: [self.livePlayer startLivePlay:url]
 Documentation: https://cloud.tencent.com/document/product/454/55880
 */

#import "LebPlayViewController.h"

@interface LebPlayViewController ()
@property (weak, nonatomic) IBOutlet UIButton *muteButton;

@property (strong, nonatomic) V2TXLivePlayer *livePlayer;
@property (strong, nonatomic) NSString *streamId;

@end

@implementation LebPlayViewController

- (instancetype)initWithStreamId:(NSString*)streamId {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
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
    
    NSString* url = [URLUtils generateLebPlayUrl:self.streamId];
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
