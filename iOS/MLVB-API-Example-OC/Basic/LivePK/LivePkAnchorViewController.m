//
//  LivePkAnchorViewController.m
//  MLVB-API-Example-OC
//
//  Created by bluedang on 2021/7/1.
//  Copyright © 2021 Tencent. All rights reserved.
//

/*
主播PK
 MLVB APP 主播PK功能
 本文件展示如何集成主播PK功能
 1、打开扬声器 API:[self.livePusher startMicrophone];
 2、开始采集屏幕 API:[self.livePusher startScreenCapture:@"group.com.tencent.liteav.RPLiveStreamShare"];
 3、开始推流 API：[self.livePusher startPush:url];
 4、开始拉主播的流 API:[self.livePlayer startLivePlay:url];
 5、和主播的流进行混流 API:[self.livePusher setMixTranscodingConfig:config];
 参考文档：https://cloud.tencent.com/document/product/454/52751
 目前仅中国大陆支持，其他地区正陆续开发中。
 */
/*
主播PK
 Anchor Competition
  Anchor Competition in MLVB App
  This document shows how to integrate the anchor competition feature.
  1. Turn speaker on: [self.livePusher startMicrophone]
  2. Capture streams from the screen: [self.livePusher startScreenCapture:@"group.com.tencent.liteav.RPLiveStreamShare"]
  3. Start publishing: [self.livePusher startPush:url]
  4. Play the anchor’s streams: [self.livePlayer startLivePlay:url]
  5. Mix with the anchor’s streams: [self.livePusher setMixTranscodingConfig:config]
  Documentation: https://cloud.tencent.com/document/product/454/52751
  Currently only supported in China, other regions are continuing to develop.
 */

#import "LivePkAnchorViewController.h"
#import "LivePkFindPkUserController.h"

@interface LivePkAnchorViewController ()<V2TXLivePlayerObserver,V2TXLivePusherObserver>
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *remoteView;
@property (weak, nonatomic) IBOutlet UIButton *pkEnterButton;
@property (weak, nonatomic) IBOutlet UIButton *closePkButton;

@property (strong, nonatomic) NSString* streamId;
@property (strong, nonatomic) NSString* userId;

@property (strong, nonatomic) V2TXLivePusher *livePusher;
@property (strong, nonatomic) V2TXLivePlayer *livePlayer;
@end

@implementation LivePkAnchorViewController

- (instancetype)initWithStreamId:(NSString*)streamId userId:(NSString*)userId {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    self.streamId = streamId;
    self.userId = userId;
    return self;
}

- (V2TXLivePlayer *)livePlayer {
    if (!_livePlayer) {
        _livePlayer = [[V2TXLivePlayer alloc] init];
        [_livePlayer setObserver:self];
    }
    return _livePlayer;
}


- (V2TXLivePusher *)livePusher {
    if (!_livePusher) {
        _livePusher = [[V2TXLivePusher alloc] initWithLiveMode:V2TXLiveMode_RTC];
        [_livePusher setObserver:self];
    }
    return _livePusher;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDefaultUIConfig];
    [self startPush];
}

- (void)setupDefaultUIConfig {
    self.title = self.streamId;
    self.pkEnterButton.hidden = NO;
    self.closePkButton.hidden = YES;
}

- (void)dealloc {
    NSLog(@"dealloc:LivePkAnchorViewController");
}

- (void)startPush {
    [self.livePusher startCamera:true];
    [self.livePusher startMicrophone];
    [self.livePusher setRenderView:self.mainView];

    NSString *url = [URLUtils generateTRTCPushUrl:self.streamId userId:self.userId];
    V2TXLiveCode code = [self.livePusher startPush:url];
    if (code != V2TXLIVE_OK) {
        [self.livePusher stopMicrophone];
        [self.livePusher stopCamera];
    }
}

- (void)stopPush {
    [self.livePusher stopMicrophone];
    [self.livePusher stopCamera];
    [self.livePusher stopPush];
}

- (void)startPlay:(NSString*)streamId userId:(NSString*)userId {
    NSString *url = [URLUtils generateTRTCPlayUrl:streamId];
    
    [self.livePlayer setRenderView:self.remoteView];
    V2TXLiveCode code = [self.livePlayer startLivePlay:url];
    NSLog(@"%ld",code);
    
    V2TXLiveTranscodingConfig *config = [[V2TXLiveTranscodingConfig alloc] init];
    config.videoWidth = 400;
    config.videoHeight = 820;
    config.videoBitrate = 900;
    config.backgroundColor = 0;
    
    V2TXLiveMixStream *mainStream = [[V2TXLiveMixStream alloc] init];
    mainStream.streamId = self.streamId;
    mainStream.userId = self.userId;
    mainStream.height = 300;
    mainStream.width = 170;
    mainStream.x = 20;
    mainStream.y = 170;
    mainStream.zOrder = 1;
    mainStream.inputType = V2TXLiveMixInputTypeAudioVideo;
    
    V2TXLiveMixStream *subStream = [[V2TXLiveMixStream alloc] init];
    subStream.streamId = streamId;
    subStream.userId = streamId;
    subStream.height = 300;
    subStream.width = 170;
    subStream.x = 210;
    subStream.y = 170;
    subStream.zOrder = 2;
    subStream.inputType = V2TXLiveMixInputTypeAudioVideo;

    config.mixStreams = @[mainStream, subStream];

    [self.livePusher setMixTranscodingConfig:config];
}

- (void)stopPlay {
    [self.livePlayer stopPlay];
    [self.livePusher setMixTranscodingConfig:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:true];
}

#pragma mark - Actions

- (IBAction)clickClosePkButton:(id)sender {
    self.pkEnterButton.hidden = NO;
    self.closePkButton.hidden = YES;
    [self stopPlay];
}

- (IBAction)clickPkEnterButton:(id)sender {
    LivePkFindPkUserController *controller = [[LivePkFindPkUserController alloc] initWithNibName:@"LivePkFindPkUserController" bundle:nil];
    __weak typeof(self) wealSelf = self;
    controller.didClickNextBlock = ^(NSString *streamId) {
        __strong typeof(wealSelf) strongSelf = wealSelf;
        strongSelf.pkEnterButton.hidden = YES;
        strongSelf.closePkButton.hidden = NO;
        [strongSelf startPlay:streamId userId:self.userId];
    };
    [self.navigationController pushViewController:controller animated:true];
}

#pragma mark - V2TXLivePlayerObserver

- (void)onStatisticsUpdate:(id<V2TXLivePlayer>)player
                statistics:(V2TXLivePlayerStatistics *)statistics {
}

- (void)onWarning:(id<V2TXLivePlayer>)player
             code:(V2TXLiveCode)code
          message:(NSString *)msg
        extraInfo:(NSDictionary *)extraInfo {
}

- (void)onError:(id<V2TXLivePlayer>)player
           code:(V2TXLiveCode)code
        message:(NSString *)msg
      extraInfo:(NSDictionary *)extraInfo {
}

- (void)onVideoLoading:(id<V2TXLivePlayer>)player extraInfo:(NSDictionary *)extraInfo {
    
}

- (void)onVideoPlaying:(id<V2TXLivePlayer>)player firstPlay:(BOOL)firstPlay extraInfo:(NSDictionary *)extraInfo {
    
}

- (void)onReceiveSeiMessage:(id<V2TXLivePlayer>)player
                payloadType:(int)payloadType
                       data:(NSData *)data{
}

- (void)onRenderVideoFrame:(id<V2TXLivePlayer>)player
                     frame:(V2TXLiveVideoFrame *)videoFrame {
}

#pragma mark - V2TXLivePusherObserver
- (void)onSetMixTranscodingConfig:(V2TXLiveCode)code message:(NSString *)msg {
    if (code != V2TXLIVE_OK) {
        NSLog(@"混流error message:%@",msg);
    }
}
@end
