//
//  CustomVideoCaptureViewController.m
//  MLVB-API-Example-OC
//
//  Created by bluedang on 2021/6/29.
//

/*
自定义视频采集
 MLVB APP 自定义视频采集功能
 本文件展示如何集成自定义视频采集功能
 1、打开扬声器 API:[self.livePusher startMicrophone];
 2、开启自定义采集 API: [self.livePusher enableCustomVideoCapture:true];
 3、开始推流 API：[self.livePusher startPush:[LiveUrl generateTRTCPushUrl:streamId]];
 4、发送数据 API: [self.livePusher sendCustomVideoFrame:videoFrame];
 参考文档：https://cloud.tencent.com/document/product/454/56601
 */
/*
 Custom Video Capturing
  Custom Video Capturing in MLVB App
  This document shows how to integrate the custom video capturing feature.
  1. Turn speaker on: [self.livePusher startMicrophone]
  2. Enable custom capturing: [self.livePusher enableCustomVideoCapture:true]
  3. Start publishing: [self.livePusher startPush:[LiveUrl generateTRTCPushUrl:streamId]]
  4. Send data: [self.livePusher sendCustomVideoFrame:videoFrame]
  Documentation: https://cloud.tencent.com/document/product/454/56601
 */

#import "CustomVideoCaptureViewController.h"
#import "CustomCameraHelper.h"

@interface CustomVideoCaptureViewController () <CustomCameraHelperSampleBufferDelegate>
@property (weak, nonatomic) IBOutlet UILabel *streamIdLabel;
@property (weak, nonatomic) IBOutlet UITextField *streamIdTextField;
@property (weak, nonatomic) IBOutlet UIButton *startPushButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (strong, nonatomic) V2TXLivePusher *livePusher;
@property (strong, nonatomic) CustomCameraHelper *customVideoCaputre;

@end

@implementation CustomVideoCaptureViewController

- (V2TXLivePusher *)livePusher {
    if (!_livePusher) {
        _livePusher = [[V2TXLivePusher alloc] initWithLiveMode:V2TXLiveMode_RTC];
    }
    return _livePusher;
}

- (CustomCameraHelper *)customVideoCaputre {
    if (!_customVideoCaputre) {
        _customVideoCaputre = [[CustomCameraHelper alloc] init];
        [_customVideoCaputre setDelegate:self];
    }
    return _customVideoCaputre;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDefaultUIConfig];
    [self addKeyboardObserver];
    [self.customVideoCaputre checkPermission];
    [self.customVideoCaputre createSession];
}

- (void)dealloc {
    [self removeKeyboardObserver];
}

- (void)setupDefaultUIConfig {
    self.streamIdTextField.text = [NSString generateRandomStreamId];
    
    self.streamIdLabel.text = Localize(@"MLVB-API-Example.CustomVideoCapture.streamIdInput");
    self.streamIdLabel.adjustsFontSizeToFitWidth = true;
    
    self.startPushButton.backgroundColor = [UIColor themeBlueColor];
    [self.startPushButton setTitle:Localize(@"MLVB-API-Example.CustomVideoCapture.startPush") forState:UIControlStateNormal];
    [self.startPushButton setTitle:Localize(@"MLVB-API-Example.CustomVideoCapture.stopPush") forState:UIControlStateSelected];
    self.startPushButton.titleLabel.adjustsFontSizeToFitWidth = true;

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:true];
}

- (void)startPush:(NSString*)streamId {
    [self.livePusher setRenderView:self.view];
    [self.livePusher enableCustomVideoCapture:true];
    [self.livePusher startMicrophone];
    [self.customVideoCaputre startCameraCapture];
    
    [self.livePusher startPush:[LiveUrl generateTRTCPushUrl:streamId]];
}

- (void)stopPush {
    [self.customVideoCaputre stopCameraCapture];
    [self.livePusher stopMicrophone];
    [self.livePusher stopPush];
}

#pragma mark - Actions

- (IBAction)onStartPushButtonClick:(UIButton*)sender {
    sender.selected = !sender.isSelected;
    if (sender.selected) {
        NSString* streamId = self.streamIdTextField.text;
        self.title = streamId;
        [self startPush:streamId];
    } else {
        [self stopPush];
    }
}

#pragma mark - CustomCameraHelperSampleBufferDelegate

- (void)onVideoSampleBuffer:(CMSampleBufferRef)videoBuffer {
    V2TXLiveVideoFrame *videoFrame = [[V2TXLiveVideoFrame alloc] init];
    videoFrame.bufferType = V2TXLiveBufferTypePixelBuffer;
    videoFrame.pixelFormat = V2TXLivePixelFormatNV12;
    videoFrame.pixelBuffer = CMSampleBufferGetImageBuffer(videoBuffer);
    
    [self.livePusher sendCustomVideoFrame:videoFrame];
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
