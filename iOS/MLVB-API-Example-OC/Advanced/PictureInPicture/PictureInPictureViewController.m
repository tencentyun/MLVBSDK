//
//  PictureInPictureViewController.m
//  MLVB-API-Example-OC
//
//  Created by adams on 2022/6/29.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "PictureInPictureViewController.h"
#import <AVKit/AVKit.h>

/*
 画中画功能（iOS15及以上支持）
 MLVB APP 画中画功能代码示例：
 本文件展示如何通过移动直播SDK实现iOS系统上的画中画功能
 1、开启自定义渲染 API:[self.livePlayer enableObserveVideoFrame:YES pixelFormat:V2TXLivePixelFormatNV12 bufferType:V2TXLiveBufferTypePixelBuffer];
 2、需要开启SDK的后台解码能力 API:[_livePlayer setProperty:@"enableBackgroundDecoding" value:@(YES)];
 3、使用系统 API创建画中画内容源: AVPictureInPictureControllerContentSource *contentSource = [[AVPictureInPictureControllerContentSource alloc] initWithSampleBufferDisplayLayer:self.sampleBufferDisplayLayer playbackDelegate:self];;
 4、使用系统 API创建画中画控制器: [[AVPictureInPictureController alloc] initWithContentSource:contentSource];
 5、在SDK回调:- (void)onRenderVideoFrame:(id<V2TXLivePlayer>)player frame:(V2TXLiveVideoFrame *)videoFrame内将pixelBuffer转为SampleBuffer并交给AVSampleBufferDisplayLayer进行渲染;
 6、使用系统 API开启画中画功能：[self.pipViewController startPictureInPicture];
 */

/// 画中画功能演示，示例拉流地址。
static NSString * const G_DEFAULT_URL = @"http://liteavapp.qcloud.com/live/liteavdemoplayerstreamid.flv";

@interface PictureInPictureViewController ()<
V2TXLivePlayerObserver,
AVPictureInPictureControllerDelegate,
AVPictureInPictureSampleBufferPlaybackDelegate>

@property (nonatomic, strong) V2TXLivePlayer *livePlayer;
@property (nonatomic, strong) AVPictureInPictureController *pipViewController;
@property (nonatomic, strong) AVSampleBufferDisplayLayer *sampleBufferDisplayLayer;
@property (weak, nonatomic) IBOutlet UIButton *pictureInPictureButton;

@end

@implementation PictureInPictureViewController

- (V2TXLivePlayer *)livePlayer {
    if (!_livePlayer) {
        _livePlayer = [[V2TXLivePlayer alloc] init];
        [_livePlayer enableObserveVideoFrame:YES pixelFormat:V2TXLivePixelFormatNV12 bufferType:V2TXLiveBufferTypePixelBuffer];
        [_livePlayer setObserver:self];
        [_livePlayer setProperty:@"enableBackgroundDecoding" value:@(YES)];
    }
    return _livePlayer;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.pipViewController = nil;
    [self.sampleBufferDisplayLayer removeFromSuperlayer];
    [self.livePlayer stopPlay];
    self.livePlayer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;
    
    self.pictureInPictureButton.layer.cornerRadius = 8;
    [self.pictureInPictureButton setTitle:localize(@"MLVB-API-Example.Home.OpenPictureInPicture") forState:UIControlStateNormal];
    
    [self.livePlayer startLivePlay:G_DEFAULT_URL];
    
    if (@available(iOS 15.0, *)) {
        if ([AVPictureInPictureController isPictureInPictureSupported]) {
            //开启画中画后台声音权限
            NSError *error = nil;
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
            [[AVAudioSession sharedInstance] setActive:YES error:nil];
            if (error) {
                NSLog(@"%@%@",localize(@"MLVB-API-Example.Home.PermissionFailed"),error);
            }
            [self setupSampleBufferDisplayLayer];
            [self.view.layer addSublayer:self.sampleBufferDisplayLayer];
            AVPictureInPictureControllerContentSource *contentSource = [[AVPictureInPictureControllerContentSource alloc]
                                                                        initWithSampleBufferDisplayLayer:self.sampleBufferDisplayLayer
                                                                        playbackDelegate:self];
            self.pipViewController = [[AVPictureInPictureController alloc] initWithContentSource:contentSource];
            self.pipViewController.delegate = self;
            self.pipViewController.canStartPictureInPictureAutomaticallyFromInline = YES;
        } else {
            NSLog(@"%@",localize(@"MLVB-API-Example.Home.NotSupported"));
        }
    }
}

- (IBAction)onPictureInPictureButtonClick:(id)sender {
    //在点击画中画按钮的时候 开启画中画
    if (self.pipViewController.isPictureInPictureActive) {
        [self.pipViewController stopPictureInPicture];
    } else {
        [self.pipViewController startPictureInPicture];
    }
}

//把pixelBuffer包装成samplebuffer送给displayLayer
- (void)dispatchPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    if (!pixelBuffer) {
        return;
    }
    //不设置具体时间信息
    CMSampleTimingInfo timing = {kCMTimeInvalid, kCMTimeInvalid, kCMTimeInvalid};
    //获取视频信息
    CMVideoFormatDescriptionRef videoInfo = NULL;
    OSStatus result = CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuffer, &videoInfo);
    NSParameterAssert(result == 0 && videoInfo != NULL);
    
    CMSampleBufferRef sampleBuffer = NULL;
    result = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault,pixelBuffer, true, NULL, NULL, videoInfo, &timing, &sampleBuffer);
    NSParameterAssert(result == 0 && sampleBuffer != NULL);
    CFRelease(videoInfo);
    CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, YES);
    CFMutableDictionaryRef dict = (CFMutableDictionaryRef)CFArrayGetValueAtIndex(attachments, 0);
    CFDictionarySetValue(dict, kCMSampleAttachmentKey_DisplayImmediately, kCFBooleanTrue);
    [self enqueueSampleBuffer:sampleBuffer toLayer:self.sampleBufferDisplayLayer];
    CFRelease(sampleBuffer);
}

- (void)enqueueSampleBuffer:(CMSampleBufferRef)sampleBuffer toLayer:(AVSampleBufferDisplayLayer*)layer {
    if (sampleBuffer) {
        CFRetain(sampleBuffer);
        [layer enqueueSampleBuffer:sampleBuffer];
        CFRelease(sampleBuffer);
        if (layer.status == AVQueuedSampleBufferRenderingStatusFailed) {
            NSLog(@"%@%@",localize(@"MLVB-API-Example.Home.Errormessage"),layer.error);
            [layer flush];
            if (-11847 == layer.error.code) {
                [self rebuildSampleBufferDisplayLayer];
            }
        }
    } else {
        NSLog(@"%@",localize(@"MLVB-API-Example.Home.Ignorenullsamplebuffer"));
    }
}

- (void)rebuildSampleBufferDisplayLayer {
    @synchronized(self) {
        [self teardownSampleBufferDisplayLayer];
        [self setupSampleBufferDisplayLayer];
    }
}
  
- (void)teardownSampleBufferDisplayLayer {
    if (self.sampleBufferDisplayLayer) {
        [self.sampleBufferDisplayLayer stopRequestingMediaData];
        [self.sampleBufferDisplayLayer removeFromSuperlayer];
        self.sampleBufferDisplayLayer = nil;
    }
}
  
- (void)setupSampleBufferDisplayLayer {
    if (!self.sampleBufferDisplayLayer) {
        self.sampleBufferDisplayLayer = [[AVSampleBufferDisplayLayer alloc] init];
        self.sampleBufferDisplayLayer.frame = UIApplication.sharedApplication.keyWindow.bounds;
        self.sampleBufferDisplayLayer.position = CGPointMake(CGRectGetMidX(self.sampleBufferDisplayLayer.bounds),
                                                             CGRectGetMidY(self.sampleBufferDisplayLayer.bounds));
        self.sampleBufferDisplayLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        self.sampleBufferDisplayLayer.opaque = YES;
        [self.view.layer addSublayer:self.sampleBufferDisplayLayer];
    } else {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.sampleBufferDisplayLayer.frame = self.view.bounds;
        self.sampleBufferDisplayLayer.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
        [CATransaction commit];
    }
}

#pragma mark - V2TXLivePlayerObserver
- (void)onRenderVideoFrame:(id<V2TXLivePlayer>)player frame:(V2TXLiveVideoFrame *)videoFrame {
    if (videoFrame.bufferType != V2TXLiveBufferTypeTexture && videoFrame.pixelFormat != V2TXLivePixelFormatTexture2D) {
        [self dispatchPixelBuffer:videoFrame.pixelBuffer];
    }
}

#pragma mark - AVPictureInPictureControllerDelegate
- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"pictureInPictureControllerWillStartPictureInPicture");
}

- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    [self.pictureInPictureButton setTitle:localize(@"MLVB-API-Example.Home.ClosePictureInPicture") forState:UIControlStateNormal];
    NSLog(@"pictureInPictureControllerDidStartPictureInPicture");
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
failedToStartPictureInPictureWithError:(NSError *)error {
    NSLog(@"failedToStartPictureInPictureWithError");
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL))completionHandler {
    NSLog(@"restoreUserInterfaceForPictureInPictureStopWithCompletionHandler");
    // 执行回调的闭包
    completionHandler(true);
}

- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"pictureInPictureControllerWillStopPictureInPicture");
}

- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    [self.pictureInPictureButton setTitle:localize(@"MLVB-API-Example.Home.OpenPictureInPicture") forState:UIControlStateNormal];
    NSLog(@"pictureInPictureControllerDidStopPictureInPicture");
}


#pragma mark - AVPictureInPictureSampleBufferPlaybackDelegate
- (BOOL)pictureInPictureControllerIsPlaybackPaused:(nonnull AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"pictureInPictureControllerIsPlaybackPaused");
    return NO;
}

- (CMTimeRange)pictureInPictureControllerTimeRangeForPlayback:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"pictureInPictureControllerTimeRangeForPlayback");
    return  CMTimeRangeMake(kCMTimeZero, kCMTimePositiveInfinity); // for live streaming
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
         didTransitionToRenderSize:(CMVideoDimensions)newRenderSize {
    NSLog(@"didTransitionToRenderSize");
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController setPlaying:(BOOL)playing {
    NSLog(@"setPlaying");
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController
                    skipByInterval:(CMTime)skipInterval
                 completionHandler:(void (^)(void))completionHandler {
    NSLog(@"skipByInterval");
}

@end
