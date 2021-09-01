//
//  LivePushCameraViewController.m
//  MLVB-API-Example-OC
//
//  Created by bluedang on 2021/6/24.
//

/*
摄像头推流
 MLVB APP 摄像头推流功能
 本文件展示如何集成摄像头推流功能
 1、打开扬声器 API:[self.livePusher startMicrophone];
 2、打开摄像头 API: [self.livePusher startCamera:true];
 3、开始推流 API：[self.livePusher startPush:url];
 参考文档：https://cloud.tencent.com/document/product/454/56594
 */
/*
 Publishing from Camera
  Publishing from Camera in MLVB App
  This document shows how to integrate the feature of publishing from the camera.
  1. Turn speaker on: [self.livePusher startMicrophone]
  2. Turn camera on: [self.livePusher startCamera:true]
  3. Start publishing: [self.livePusher startPush:url]
  Documentation: https://cloud.tencent.com/document/product/454/56594
 */

#import "LivePushCameraViewController.h"

@interface LivePushCameraViewController () <V2TXLivePusherObserver>
@property (weak, nonatomic) IBOutlet UILabel *audioSettingLabel;
@property (weak, nonatomic) IBOutlet UIButton *closeMicButton;

@property (weak, nonatomic) IBOutlet UILabel *videoSettingLabel;
@property (weak, nonatomic) IBOutlet UILabel *resolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *rotationLabel;
@property (weak, nonatomic) IBOutlet UILabel *mirrorLabel;
@property (weak, nonatomic) IBOutlet UIButton *resolutonButton;
@property (weak, nonatomic) IBOutlet UIButton *rotationButton;
@property (weak, nonatomic) IBOutlet UIButton *mirrorButton;

@property (strong, nonatomic) V2TXLivePusher *livePusher;
@property (strong, nonatomic) NSString *streamId;
@property (assign, nonatomic) V2TXLiveMode liveMode;
@property (assign, nonatomic) V2TXLiveAudioQuality audioQulity;

@end

@implementation LivePushCameraViewController


- (instancetype)initWithStreamId:(NSString*)streamId isRTCPush:(BOOL)value audioQulity:(V2TXLiveAudioQuality)quality;{
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    self.streamId = streamId;
    self.audioQulity = quality;
    self.liveMode = value ? V2TXLiveMode_RTC : V2TXLiveMode_RTMP;
    self.livePusher = [[V2TXLivePusher alloc] initWithLiveMode:self.liveMode];
    [self.livePusher setObserver:self];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupDefalutUIConfig];
    [self startPush];
}

- (void)setupDefalutUIConfig {
    self.title = self.streamId;
    
    self.audioSettingLabel.text = Localize(@"MLVB-API-Example.LivePushCamera.audioSetting");
    self.audioSettingLabel.adjustsFontSizeToFitWidth = true;
    
    self.videoSettingLabel.text = Localize(@"MLVB-API-Example.LivePushCamera.videoSetting");
    self.videoSettingLabel.adjustsFontSizeToFitWidth = true;
    
    self.resolutionLabel.text = Localize(@"MLVB-API-Example.LivePushCamera.resolution");
    self.resolutionLabel.adjustsFontSizeToFitWidth = true;
    self.rotationLabel.text = Localize(@"MLVB-API-Example.LivePushCamera.rotation");
    self.rotationLabel.adjustsFontSizeToFitWidth = true;
    self.mirrorLabel.text = Localize(@"MLVB-API-Example.LivePushCamera.mirror");
    self.mirrorLabel.adjustsFontSizeToFitWidth = true;

    [self.closeMicButton setTitle:Localize(@"MLVB-API-Example.LivePushCamera.closeMic") forState:UIControlStateNormal];
    [self.closeMicButton setTitle:Localize(@"MLVB-API-Example.LivePushCamera.openMic") forState:UIControlStateSelected];
    [self.closeMicButton setBackgroundColor:[UIColor themeBlueColor]];
    self.closeMicButton.titleLabel.adjustsFontSizeToFitWidth = true;
    
    [self.resolutonButton setTitle:@"540P" forState:UIControlStateNormal];
    [self.rotationButton setTitle:@"0" forState:UIControlStateNormal];
    [self.mirrorButton setTitle:Localize(@"MLVB-API-Example.LivePushCamera.mirrorFront") forState:UIControlStateNormal];
    self.resolutonButton.titleLabel.adjustsFontSizeToFitWidth = true;
    self.rotationButton.titleLabel.adjustsFontSizeToFitWidth = true;
    self.mirrorButton.titleLabel.adjustsFontSizeToFitWidth = true;
}

- (void)dealloc {
    [self.livePusher stopCamera];
    [self.livePusher stopMicrophone];
    [self.livePusher stopPush];
}

- (void)startPush {
    if (!self.livePusher) {
        return;
    }
    [self.livePusher setRenderMirror:V2TXLiveMirrorTypeAuto];
    V2TXLiveVideoEncoderParam *videoEncoderParam = [[V2TXLiveVideoEncoderParam alloc] initWith:V2TXLiveVideoResolution960x540];
    videoEncoderParam.videoResolutionMode = V2TXLiveVideoResolutionModePortrait;
    [self.livePusher setVideoQuality:videoEncoderParam];
    [self.livePusher setRenderView:self.view];
    [self.livePusher setAudioQuality:self.audioQulity];
    
    [self.livePusher startCamera:true];
    [self.livePusher startMicrophone];
    
    NSString *url;
    if (self.liveMode == V2TXLiveMode_RTC) {
        url = [LiveUrl generateTRTCPushUrl:self.streamId];
    } else {
        url = [LiveUrl generateRtmpPushUrl:self.streamId];
    }
    
    V2TXLiveCode code = [self.livePusher startPush:url];
    if (code != V2TXLIVE_OK) {
        [self.livePusher stopMicrophone];
        [self.livePusher stopCamera];
    }
}

- (void)showAlertListWithArray:(NSArray*)array handler:(void (^ __nullable)(int index))handler {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    int index = 0;
    for (NSString* item in array) {
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:item style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            if (handler) { handler(index); }
        }];
        [alertVC addAction: alertAction];
        index++;
    }
    [self presentViewController:alertVC animated:true completion:nil];
}

#pragma mark - Actions

- (IBAction)onCloseMicButtonClick:(UIButton*)sender {
    sender.selected = !sender.isSelected;
    if (sender.isSelected) {
        [self.livePusher stopMicrophone];
    } else {
        [self.livePusher startMicrophone];
    }
}

- (IBAction)onResolutionButtonClick:(UIButton*)sender {
    NSArray *resolutionArr = @[@"360P", @"540P", @"720P", @"1080P"];
    NSDictionary *resolutionDic = @{
        resolutionArr[0] : @(V2TXLiveVideoResolution480x360),
        resolutionArr[1] : @(V2TXLiveVideoResolution960x540),
        resolutionArr[2] : @(V2TXLiveVideoResolution1280x720),
        resolutionArr[3] : @(V2TXLiveVideoResolution1920x1080),
    };
    
    [self showAlertListWithArray:resolutionArr handler:^(int index) {
        V2TXLiveVideoResolution resolution = [resolutionDic[resolutionArr[index]] intValue];
        V2TXLiveVideoEncoderParam *videoEncoderParam = [[V2TXLiveVideoEncoderParam alloc] initWith:resolution];
        videoEncoderParam.videoResolutionMode = V2TXLiveVideoResolutionModePortrait;
        [self.livePusher setVideoQuality:videoEncoderParam];
        [self.resolutonButton setTitle:resolutionArr[index] forState:UIControlStateNormal];
    }];
}

- (IBAction)onRotationButtonClick:(UIButton*)sender {
    NSArray *rotationArr = @[@"0", @"90", @"180", @"270"];
    NSDictionary *rotationDic = @{
        rotationArr[0] : @(V2TXLiveRotation0),
        rotationArr[1] : @(V2TXLiveRotation90),
        rotationArr[2] : @(V2TXLiveRotation180),
        rotationArr[3] : @(V2TXLiveRotation270),
    };
    
    [self showAlertListWithArray:rotationArr handler:^(int index) {
        V2TXLiveRotation rotation = [rotationDic[rotationArr[index]] intValue];
        [self.livePusher setRenderRotation:rotation];
        [self.rotationButton setTitle:rotationArr[index] forState:UIControlStateNormal];
    }];
}

- (IBAction)onMirrorButtonClick:(UIButton*)sender {
    NSArray *mirrorArr = @[Localize(@"MLVB-API-Example.LivePushCamera.mirrorFront"),
                             Localize(@"MLVB-API-Example.LivePushCamera.mirrorAll"),
                             Localize(@"MLVB-API-Example.LivePushCamera.mirrorNO")];
    NSDictionary *mirrorDic = @{
        mirrorArr[0] : @(V2TXLiveMirrorTypeAuto),
        mirrorArr[1] : @(V2TXLiveMirrorTypeEnable),
        mirrorArr[2] : @(V2TXLiveMirrorTypeDisable),
    };
    
    [self showAlertListWithArray:mirrorArr handler:^(int index) {
        V2TXLiveMirrorType type = [mirrorDic[mirrorArr[index]] intValue];
        [self.livePusher setRenderMirror:type];
        [self.mirrorButton setTitle:mirrorArr[index] forState:UIControlStateNormal];
    }];
}

#pragma mark - V2TxLivePusher Observer

- (void)onError:(V2TXLiveCode)code message:(NSString *)msg extraInfo:(NSDictionary *)extraInfo {
}

- (void)onPushStatusUpdate:(V2TXLivePushStatus)status message:(NSString *)msg extraInfo:(NSDictionary *)extraInfo{
}

@end
