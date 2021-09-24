//
//  RTCPushAndPlayAudienceViewController.m
//  MLVB-API-Example-OC
//
//  Created by bluedang on 2021/6/30.
//

/*
 RTC连麦+超低延时播放的观众视角
 MLVB RTC连麦+超低延时播放的观众视角
 本文件展示如何集成RTC连麦+超低延时播放功能
 1、拉主播的流 API: [self.livePlayer startPlay:url];
 2、打开扬声器 API:[self.livePusher startMicrophone];
 3、打开摄像头 API: [self.livePusher startCamera:true];
 4、开始推流 API：[self.livePusher startPush:url];
 */
/*
 RTC Co-anchoring + Ultra-low-latency Playback View for Audience
 RTC Co-anchoring + Ultra-low-latency Playback View for Audience in MLVB App
 This document shows how to integrate the RTC co-anchoring + ultra-low-latency playback feature.
 1. Play the anchor’s streams: [self.livePlayer startPlay:url]
 2. Turn speaker on: [self.livePusher startMicrophone]
 3. Turn camera on: [self.livePusher startCamera:true]
 4. Start publishing: [self.livePusher startPush:url]
 */

#import "RTCPushAndPlayAudienceViewController.h"

@interface RTCPushAndPlayAudienceViewController ()
@property (weak, nonatomic) IBOutlet UILabel *streamIdLabel;
@property (weak, nonatomic) IBOutlet UITextField *streamIdTextField;
@property (weak, nonatomic) IBOutlet UIButton *acceptLinkButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *remoteView;

@property (strong, nonatomic) NSString *streamId;

@property (strong, nonatomic) V2TXLivePlayer *remoteLivePlayer;
@property (strong, nonatomic) V2TXLivePlayer *livePlayer;

@end

@implementation RTCPushAndPlayAudienceViewController

- (instancetype)initWithStreamId:(NSString*)streamId {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    self.streamId = streamId;
    return self;
}

- (V2TXLivePlayer *)livePlayer {
    if (!_livePlayer) {
        _livePlayer = [[V2TXLivePlayer alloc] init];
    }
    return _livePlayer;
}

- (V2TXLivePlayer *)remoteLivePlayer {
    if (!_remoteLivePlayer) {
        _remoteLivePlayer = [[V2TXLivePlayer alloc] init];
    }
    return _remoteLivePlayer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDefaultUIConfig];
    [self addKeyboardObserver];
    
    [self startPlayWithPlayer:self.livePlayer streamId:self.streamId];
}

- (void)setupDefaultUIConfig {
    self.title = self.streamId;
    self.streamIdLabel.text = Localize(@"MLVB-API-Example.RTCPushAndPlay.streamIdInput");
    self.streamIdLabel.adjustsFontSizeToFitWidth = true;

    self.acceptLinkButton.backgroundColor = [UIColor themeBlueColor];
    [self.acceptLinkButton setTitle:Localize(@"MLVB-API-Example.RTCPushAndPlay.rtcPlay") forState:UIControlStateNormal];
    [self.acceptLinkButton setTitle:Localize(@"MLVB-API-Example.RTCPushAndPlay.stopPlay") forState:UIControlStateSelected];
    self.acceptLinkButton.titleLabel.adjustsFontSizeToFitWidth = true;
}

- (void)dealloc {
    [self removeKeyboardObserver];
    [self stopPlayWithPlayer:self.livePlayer];
}

- (void)startPlayWithPlayer:(V2TXLivePlayer*)player streamId:(NSString*)streamId {
    NSString *url = [LiveUrl generateLebPlayUrl:streamId];
    
    [player setRenderView:self.view];
    [player startPlay:url];
}

- (void)stopPlayWithPlayer:(V2TXLivePlayer*)player {
    [player stopPlay];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:true];
}

#pragma mark - Actions

- (IBAction)acceptLinkButtonClick:(UIButton*)sender {
    sender.selected = !sender.isSelected;
    if (sender.isSelected) {
        [self startPlayWithPlayer:self.remoteLivePlayer streamId:self.streamIdTextField.text];
    } else {
        [self stopPlayWithPlayer:self.remoteLivePlayer];
    }
}

#pragma mark - Notification

- (void)addKeyboardObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeKeyboardObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (BOOL)keyboardWillShow:(NSNotification *)noti {
    CGFloat animationDuration = [[[noti userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyboardBounds = [[[noti userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:animationDuration animations:^{
        self.bottomConstraint.constant = keyboardBounds.size.height;
    }];
    return YES;
}

- (BOOL)keyboardWillHide:(NSNotification *)noti {
     CGFloat animationDuration = [[[noti userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
     [UIView animateWithDuration:animationDuration animations:^{
         self.bottomConstraint.constant = 25;
     }];
     return YES;
}

@end
