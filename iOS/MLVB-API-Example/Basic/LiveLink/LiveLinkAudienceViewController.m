//
//  LiveLinkAudienceViewController.m
//  MLVB-API-Example-OC
//
//  Created by bluedang on 2021/6/29.
//

/*
观众连麦
 MLVB APP 观众连麦功能
 本文件展示如何集成观众连麦功能
 1、设置渲染的view API:[self.livePlayer setRenderView:self.view];
 2、开始快直播拉流 API:[self.livePlayer startPlay:url];
 3、停止快直播拉流 API:[self.livePlayer startPlay:url];
 4、开始推流 API:[self.livePusher startPush:url];
 5、开始RTC拉流：API:[self.livePlayer startPlay:url];
 参考文档：https://cloud.tencent.com/document/product/454/52751
 */
/*
 Audience-Initiated Co-anchoring
  Audience-Initiated Co-anchoring in MLVB App
  This document shows how to integrate the audience-initiated co-anchoring feature.
  1. Set the rendering view: [self.livePlayer setRenderView:self.view]
  2. Start LEB playback: [self.livePlayer startPlay:url]
  3. Stop LEB playback: [self.livePlayer startPlay:url]
  4. Start publishing: [self.livePusher startPush:url]
  5. Start RTC playback: [self.livePlayer startPlay:url]
  Documentation: https://cloud.tencent.com/document/product/454/52751
 */


#import "LiveLinkAudienceViewController.h"

@interface LiveLinkAudienceViewController ()
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

@implementation LiveLinkAudienceViewController

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
    
    [self startLebPlay:self.streamId];
}

- (void)setupDefaultUIConfig {
    self.title = self.streamId;
    self.streamIdLabel.adjustsFontSizeToFitWidth = true;
    self.userIdLabel.adjustsFontSizeToFitWidth = true;

    self.acceptLinkButton.backgroundColor = [UIColor themeBlueColor];
    [self.acceptLinkButton setTitle:Localize(@"MLVB-API-Example.LiveLink.startLink") forState:UIControlStateNormal];
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

    NSString *url = [LiveUrl generateTRTCPushUrl:self.streamIdTextField.text userId:self.userIdTextField.text];
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

- (void)startLebPlay:(NSString*)streamId {
    NSString *url = [LiveUrl generateLebPlayUrl:streamId];
    [self.livePlayer setRenderView:self.view];
    [self.livePlayer startPlay:url];

}

- (void)startRtcPlay:(NSString*)streamId {
    NSString *url = [LiveUrl generateTRTCPlayUrl:streamId];
    [self.livePlayer setRenderView:self.remoteView];
    [self.livePlayer startPlay:url];
}

- (void)stopPlay {
    [self.livePlayer stopPlay];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:true];
}

#pragma mark - Actions

- (IBAction)acceptLinkButtonClick:(UIButton*)sender {
    sender.selected = !sender.isSelected;
    [self stopPlay];

    if (sender.isSelected) {
        [self startRtcPlay:self.streamId];
        [self startPush];
    } else {
        [self stopPush];
        [self startLebPlay:self.streamId];
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
