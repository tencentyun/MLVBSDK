//
//  LiveLinkAnchorViewController.m
//  MLVB-API-Example-OC
//
//  Created by bluedang on 2021/6/29.
//

/*
主播连麦
 MLVB APP 主播连麦功能
 本文件展示如何集成主播连麦功能
 1、打开扬声器 API:[self.livePusher startMicrophone];
 2、开始采集屏幕 API:[self.livePusher startScreenCapture:@"group.com.tencent.liteav.RPLiveStreamShare"];
 3、开始推流 API：[self.livePusher startPush:url];
 4、开始拉观众的流 API:[self.livePlayer startPlay:url];
 5、和观众的流进行混流 API:[self.livePusher setMixTranscodingConfig:config];
 参考文档：https://cloud.tencent.com/document/product/454/52751
 */
/*
 Anchor-Initiated Co-anchoring
  Anchor-Initiated Co-anchoring in MLVB App
  This document shows how to integrate the anchor-initiated co-anchoring feature.
  1. Turn speaker on: [self.livePusher startMicrophone]
  2. Capture streams from the screen: [self.livePusher startScreenCapture:@"group.com.tencent.liteav.RPLiveStreamShare"]
  3. Start publishing: [self.livePusher startPush:url]
  4. Play the co-anchoring audience’s streams: [self.livePlayer startPlay:url]
  5. Mix with the audience’s streams: [self.livePusher setMixTranscodingConfig:config]
  Documentation: https://cloud.tencent.com/document/product/454/52751
 */

#import "LiveLinkAnchorViewController.h"

@interface LiveLinkAnchorViewController ()
@property (weak, nonatomic) IBOutlet UILabel *streamIdLabel;
@property (weak, nonatomic) IBOutlet UITextField *streamIdTextField;
@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;
@property (weak, nonatomic) IBOutlet UIButton *acceptLinkButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *remoteView;

@property (strong, nonatomic) NSString* streamId;
@property (strong, nonatomic) NSString* userId;

@property (strong, nonatomic) V2TXLivePusher *livePusher;
@property (strong, nonatomic) V2TXLivePlayer *livePlayer;

@end

@implementation LiveLinkAnchorViewController

- (instancetype)initWithStreamId:(NSString*)streamId userId:(NSString*)userId {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    self.streamId = streamId;
    self.userId = userId;
    return self;
}

- (V2TXLivePlayer *)livePlayer {
    if (!_livePlayer) {
        _livePlayer = [[V2TXLivePlayer alloc] init];
    }
    return _livePlayer;
}

- (V2TXLivePusher *)livePusher {
    if (!_livePusher) {
        _livePusher = [[V2TXLivePusher alloc] initWithLiveMode:V2TXLiveMode_RTC];
    }
    return _livePusher;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDefaultUIConfig];
    [self addKeyboardObserver];
    
    [self startPush];
}

- (void)setupDefaultUIConfig {
    self.title = self.streamId;
    self.streamIdLabel.adjustsFontSizeToFitWidth = true;
    self.userIdLabel.adjustsFontSizeToFitWidth = true;

    self.acceptLinkButton.backgroundColor = [UIColor themeBlueColor];
    [self.acceptLinkButton setTitle:Localize(@"MLVB-API-Example.LiveLink.acceptLink") forState:UIControlStateNormal];
    [self.acceptLinkButton setTitle:Localize(@"MLVB-API-Example.LiveLink.stopLink") forState:UIControlStateSelected];
    self.acceptLinkButton.titleLabel.adjustsFontSizeToFitWidth = true;

}

- (void)dealloc {
    [self removeKeyboardObserver];
}

- (void)startPush {
    [self.livePusher startCamera:true];
    [self.livePusher startMicrophone];
    [self.livePusher setRenderView:self.view];

    NSString *url = [LiveUrl generateTRTCPushUrl:self.streamId userId:self.userId];
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
    NSString *url = [LiveUrl generateTRTCPlayUrl:streamId];
    
    [self.livePlayer setRenderView:self.remoteView];
    [self.livePlayer startPlay:url];
    
    V2TXLiveTranscodingConfig *config = [[V2TXLiveTranscodingConfig alloc] init];
    config.videoWidth = 360;
    config.videoHeight = 640;
    config.videoBitrate = 900;
    
    V2TXLiveMixStream *mainStream = [[V2TXLiveMixStream alloc] init];
    mainStream.streamId = self.streamId;
    mainStream.userId = self.userId;
    mainStream.height = 640;
    mainStream.width = 360;
    mainStream.x = 0;
    mainStream.y = 0;
    mainStream.zOrder = 1;
    mainStream.inputType = V2TXLiveMixInputTypeAudioVideo;
    
    V2TXLiveMixStream *subStream = [[V2TXLiveMixStream alloc] init];
    subStream.streamId = streamId;
    subStream.userId = userId;
    subStream.height = 180;
    subStream.width = 100;
    subStream.x = 220;
    subStream.y = 400;
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

- (IBAction)acceptLinkButtonClick:(UIButton*)sender {
    sender.selected = !sender.isSelected;
    if (sender.selected) {
        [self startPlay:self.streamIdTextField.text userId:self.userIdTextField.text];
    } else {
        [self stopPlay];
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
