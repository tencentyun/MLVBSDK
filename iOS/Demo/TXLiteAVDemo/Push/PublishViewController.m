//
//  PublishController.m
//  RTMPiOSDemo
//
//  Created by 蓝鲸 on 16/4/1.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PublishViewController.h"
#import "ScanQRController.h"
#import "TXLiveSDKTypeDef.h"
#import <sys/types.h>
#import <sys/sysctl.h>
#import <UIKit/UIKit.h>
#import <mach/mach.h>
#import "AppLogMgr.h"
//#import "TXUGCPublish.h"
#import "UIView+Additions.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AFNetworkReachabilityManager.h"
#import "CWStatusBarNotification.h"
#import "TCHttpUtil.h"
#import "MBProgressHUD.h"
#import "SmallButton.h"
#import "AddressBarController.h"
#import "AppDelegate.h"

//#define CUSTOM_AUDIO_RECORD

#ifdef CUSTOM_AUDIO_RECORD
#import "CustomAudioCapturor.h"
#endif

// 清晰度定义
#define    HD_LEVEL_720P       1  // 1280 * 720
#define    HD_LEVEL_540P       2  //  960 * 540
#define    HD_LEVEL_360P       3  //  640 * 360
#define    HD_LEVEL_LINKMIC_BIG   4
#define    HD_LEVEL_LINKMIC_SMALL 5
#define    HD_LEVEL_REALTIME_CHAT 6  //实时音视频

//#define CUSTOM_PROCESS  //在自定义处理回调出来的画面纹理

#ifdef CUSTOM_PROCESS
#import "CustomProcessFilter.h"
#endif
#ifndef DISABLE_VOD
#define PUSH_RECORD
#endif
#ifdef PUSH_RECORD
#import "LiveRecordPreviewViewController.h"
#endif

#define RTMP_PUBLISH_URL    @"请输入推流地址或者扫二维码进行输入"  //调试期间您可以修改之以避免输入地址的麻烦

//void testHookVideoFunc(unsigned char * yuv_buffer, int len_buffer, int width, int height)
//{
//    NSLog(@"hook video %p %d %d %d", yuv_buffer, len_buffer, width, height);

//    //比如：画面镜像(左右颠倒画面)
//    unsigned char * des_yuv = (unsigned char*)malloc(len_buffer);
//
//    int hw = width / 2;
//    int hh = height / 2;
//
//    int fs = width * height;
//    int qfs = fs*5/4;
//
//    for(int j=0; j<height; ++j)
//    {
//        for(int i=0; i<width; ++i)
//        {
//            des_yuv[j*width + i] = yuv_buffer[j*width + width - i - 1];
//
//            if(i<hw && j<hh)
//            {
//                des_yuv[fs + j*hw + i] = yuv_buffer[fs + j*hw + hw - i -1];
//                des_yuv[qfs + j*hw + i] = yuv_buffer[qfs + j*hw + hw - i -1];
//            }
//        }
//    }
//
//    memcpy(yuv_buffer, des_yuv, len_buffer);
//
//    free(des_yuv);
//}

//void testHookAudioFunc(unsigned char * pcm_buffer, int len_buffer, int sample_rate, int channels, int bit_size)
//{
//    NSLog(@"hook audio %p %d %d %d %d", pcm_buffer, len_buffer, sample_rate, channels, bit_size);

//    // 比如：静音
//    memset(pcm_buffer, 0, len_buffer);
//}

@implementation PushMusicInfo


@end


#ifndef CUSTOM_AUDIO_RECORD
@interface PublishViewController () <
TXLivePushListener,
TXVideoCustomProcessDelegate,
BeautySettingPanelDelegate,
BeautyLoadPituDelegate,
#if defined(PUSH_RECORD) && !defined(DISABLE_LIVERECORD)
TXLiveRecordListener,
#endif
ScanQRDelegate,
AddressBarControllerDelegate
>
#else
@interface PublishViewController () <
TXLivePushListener,
TXVideoCustomProcessDelegate,
BeautySettingPanelDelegate,
BeautyLoadPituDelegate,
ScanQRDelegate,
CustomAudioCapturorDelegate,
AddressBarControllerDelegate
>
#endif

@property (nonatomic, strong) TXLivePush * txLivePublisher;
@property (nonatomic, copy)    NSString *pushUrl;


@end

@implementation PublishViewController {
    BOOL _appIsInActive;
    BOOL _appIsBackground;
    UIView *preViewContainer;
    UIDeviceOrientation _deviceOrientation;
//    TXUGCPublish      *_videoPublish;
//    TXRecordResult      *_recordResult;
    CWStatusBarNotification *_notification;
    MBProgressHUD *_hub;
#ifdef CUSTOM_PROCESS
    CustomProcessFilter*    _filter;
    UIButton*               _btnSwitchCustom;
#endif
    AddressBarController *_addressBarController;
}

- (PublishViewController *)init {
    if (self = [super init]) {
//        [TXUGCRecord shareInstance].recordDelegate = self;
        _isPlayBgm = NO;
        _appIsInActive = NO;
        _appIsBackground = NO;
    }


    return self;
}

- (void)dealloc {
    [self stopRtmp];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _deviceOrientation = UIDeviceOrientationPortrait;
    
    TXLivePushConfig *_config = [[TXLivePushConfig alloc] init];
    _config.videoEncodeGop = 5;
//    _config.watermark = [UIImage imageNamed:@"watermark.png"];
//    _config.watermarkPos = (CGPoint) {10, 10};
    //    _config.frontCamera = NO;
    _txLivePublisher = [[TXLivePush alloc] initWithConfig:_config];
#if defined(PUSH_RECORD) && !defined(DISABLE_LIVERECORD)
     _txLivePublisher.recordDelegate = self;
#endif
    //    _videoPublish = [[TXUGCPublish alloc] init];
    //    _videoPublish.delegate = self;
    
    [self initUI];
    [_vBeauty resetValues];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidEnterBackGround:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    
    HelpBtnUI(rtmp推流)
}

- (void)viewDidDisappear:(BOOL)animated; {
    [super viewDidDisappear:animated];
}

- (void)onAppWillResignActive:(NSNotification *)notification {
    _appIsInActive = YES;
    [_txLivePublisher pausePush];
}

- (void)onAppDidBecomeActive:(NSNotification *)notification {
    _appIsInActive = NO;
    if (!_appIsBackground && !_appIsInActive)
        [_txLivePublisher resumePush];
}

- (void)onAppDidEnterBackGround:(NSNotification *)notification {
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{

    }];

    _appIsBackground = YES;
    [_txLivePublisher pausePush];

}

- (void)onAppWillEnterForeground:(NSNotification *)notification {
    _appIsBackground = NO;
    if (!_appIsBackground && !_appIsInActive) [_txLivePublisher resumePush];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];


#if !TARGET_IPHONE_SIMULATOR
    //是否有摄像头权限
    AVAuthorizationStatus statusVideo = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (statusVideo == AVAuthorizationStatusDenied) {
        [self toastTip:@"获取摄像头权限失败，请前往隐私-相机设置里面打开应用权限"];
        return;
    }

//    if (!_isPreviewing) {
//        [_txLivePublisher startPreview:preViewContainer];
//        _isPreviewing = YES;
//    }
#endif

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)clearLog {
    _tipsMsg = @"";

    _startTime = (unsigned long long int) ([[NSDate date] timeIntervalSince1970] * 1000);
    _lastTime = _startTime;
}

- (BOOL)startRtmp {
    NSString *rtmpUrl = _addressBarController.text;
    if (!([rtmpUrl hasPrefix:@"rtmp://"])) {
        rtmpUrl = RTMP_PUBLISH_URL;
    }
    if (!([rtmpUrl hasPrefix:@"rtmp://"])) {
        [self toastTip:@"推流地址不合法，目前支持rtmp推流!"];
        return NO;
    }

    //是否有摄像头权限
    AVAuthorizationStatus statusVideo = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (statusVideo == AVAuthorizationStatusDenied) {
        [self toastTip:@"获取摄像头权限失败，请前往隐私-相机设置里面打开应用权限"];
        return NO;
    }

    //是否有麦克风权限
    AVAuthorizationStatus statusAudio = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (statusAudio == AVAuthorizationStatusDenied) {
        [self toastTip:@"获取麦克风权限失败，请前往隐私-麦克风设置里面打开应用权限"];
        return NO;
    }

    if (_txLivePublisher != nil) {

        TXLivePushConfig *_config = _txLivePublisher.config;
//        _config.watermark = [UIImage imageNamed:@"watermark.png"];
//        _config.watermarkPos = (CGPoint){0,0};

        //【示例代码1】设置自定义视频采集逻辑（自定义视频采集逻辑不要调用startPreview）
//        _config.customModeType |= CUSTOM_MODE_VIDEO_CAPTURE;
//        _config.videoResolution= VIDEO_RESOLUTION_TYPE_1280_720;
//        [[[NSThread alloc] initWithTarget:self
//                                 selector:@selector(customVideoCaptureThread)
//                                   object:nil] start];

//        【示例代码2】设置自定义音频采集逻辑（音频采样位宽必须是16）
#ifdef CUSTOM_AUDIO_RECORD
        int sampleRate = 48000;
        int channels = 2;
        int bytes = 2;
        _config.customModeType |= CUSTOM_MODE_AUDIO_CAPTURE;
        _config.audioSampleRate = AUDIO_SAMPLE_RATE_48000;
        _config.audioChannels   = channels;
        [CustomAudioCapturor sharedInstance].delegate = self;
#endif
//        [[[NSThread alloc] initWithTarget:self
//                                 selector:@selector(customAudioCaptureThread)
//                                   object:nil] start];

        // 【示例代码3】设置自定义音频预处理逻辑
//        _config.customModeType |= CUSTOM_MODE_AUDIO_PREPROCESS;
//        _config.pAudioFuncPtr = testHookAudioFunc;

        //【示例代码4】设置自定义视频预处理逻辑
//        _config.customModeType |= CUSTOM_MODE_VIDEO_PREPROCESS;
//        _config.pVideoFuncPtr = testHookVideoFunc;

        _config.pauseFps = 10;
        _config.pauseTime = 300;
        _config.pauseImg = [UIImage imageNamed:@"pause_publish.jpg"];
        [_txLivePublisher setConfig:_config];

        _txLivePublisher.delegate = self;
#ifdef CUSTOM_PROCESS
       //_txLivePublisher.videoProcessDelegate = self;
#endif

        if (!_isPreviewing) {
            [_txLivePublisher startPreview:preViewContainer];
            _isPreviewing = YES;
            [_txLivePublisher showVideoDebugLog:_log_switch];

        }

        if ([_txLivePublisher startPush:rtmpUrl] != 0) {
            NSLog(@"推流器启动失败");
            return NO;
        }
#ifdef CUSTOM_AUDIO_RECORD
        [[CustomAudioCapturor sharedInstance] start:sampleRate nChannels:channels nSampleLen:(channels*bytes*1024)];
#endif

//        [_txLivePublisher setBeautyFilterDepth:6.3 setWhiteningFilterDepth:2.7];

    }

    _pushUrl = rtmpUrl;

    [_vBeauty trigglerValues];
    return YES;
}


- (void)stopRtmp {
    _pushUrl = @"";
    if (_txLivePublisher != nil) {
#ifdef CUSTOM_AUDIO_RECORD
        [[CustomAudioCapturor sharedInstance] stop];
        [CustomAudioCapturor sharedInstance].delegate = nil;
#endif
        _txLivePublisher.delegate = nil;
        [_txLivePublisher stopPreview];
        _isPreviewing = NO;
        [_txLivePublisher stopPush];
    }
//    [_vBeauty resetValues];
}

// RTMP 推流事件通知
#pragma - TXLivePushListener

- (void)onPushEvent:(int)EvtID withParam:(NSDictionary *)param; {
    NSDictionary *dict = param;

    dispatch_async(dispatch_get_main_queue(), ^{
        if (EvtID == PUSH_ERR_NET_DISCONNECT || EvtID == PUSH_ERR_INVALID_ADDRESS) {
            [self clickPublish:_btnPublish];
        } else if (EvtID == PUSH_WARNING_HW_ACCELERATION_FAIL) {
            _txLivePublisher.config.enableHWAcceleration = false;
            [_btnHardware setImage:[UIImage imageNamed:@"quick2"] forState:UIControlStateNormal];
        } else if (EvtID == PUSH_ERR_OPEN_CAMERA_FAIL) {
            [self stopRtmp];
            [_btnPublish setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
            _publish_switch = NO;
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            [self toastTip:@"获取摄像头权限失败，请前往隐私-相机设置里面打开应用权限"];
        } else if (EvtID == PUSH_ERR_OPEN_MIC_FAIL) {
            [self stopRtmp];
            [_btnPublish setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
            _publish_switch = NO;
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            [self toastTip:@"获取麦克风权限失败，请前往隐私-麦克风设置里面打开应用权限"];
        } else if (EvtID == PUSH_EVT_CONNECT_SUCC) {
            BOOL isWifi = [AFNetworkReachabilityManager sharedManager].reachableViaWiFi;
            if (!isWifi) {
                __weak __typeof(self) weakSelf = self;
                [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
                    if (weakSelf.pushUrl.length == 0) {
                        return;
                    }
                    if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                                       message:@"您要切换到WiFi再推流吗?"
                                                                                preferredStyle:UIAlertControllerStyleAlert];
                        [alert addAction:[UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
                            [alert dismissViewControllerAnimated:YES completion:nil];
//                            [weakSelf stopRtmp];
//                            [weakSelf startRtmp];
                            [weakSelf.txLivePublisher stopPush];
                            [weakSelf.txLivePublisher startPush:weakSelf.pushUrl];
                        }]];
                        [alert addAction:[UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action) {
                            [alert dismissViewControllerAnimated:YES completion:nil];
                        }]];
                        [weakSelf presentViewController:alert animated:YES completion:nil];
                    }
                }];
            }
        } else if (EvtID == PUSH_WARNING_NET_BUSY) {
            [_notification displayNotificationWithMessage:@"您当前的网络环境不佳，请尽快更换网络保证正常直播" forDuration:5];
        }


        //NSLog(@"evt:%d,%@", EvtID, dict);
        long long time = [(NSNumber *) [dict valueForKey:EVT_TIME] longLongValue];
//        int mil = (int) (time % 1000);
//        NSDate *date = [NSDate dateWithTimeIntervalSince1970:time / 1000];
//        NSString *Msg = (NSString *) [dict valueForKey:EVT_MSG];
    });
}

static vm_size_t get_app_consumed_memory_bytes() {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        return info.resident_size;
    } else {
        return 0;
    }
}


- (void)onNetStatus:(NSDictionary *)param {
    NSDictionary *dict = param;

    NSString *streamID = [dict valueForKey:STREAM_ID];
    if (![streamID isEqualToString:_pushUrl]) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        int netspeed = [(NSNumber *) [dict valueForKey:NET_STATUS_NET_SPEED] intValue];
        int vbitrate = [(NSNumber *) [dict valueForKey:NET_STATUS_VIDEO_BITRATE] intValue];
        int abitrate = [(NSNumber *) [dict valueForKey:NET_STATUS_AUDIO_BITRATE] intValue];
        int cachesize = [(NSNumber *) [dict valueForKey:NET_STATUS_CACHE_SIZE] intValue];
        int dropsize = [(NSNumber *) [dict valueForKey:NET_STATUS_DROP_SIZE] intValue];
        int jitter = [(NSNumber *) [dict valueForKey:NET_STATUS_NET_JITTER] intValue];
        int fps = [(NSNumber *) [dict valueForKey:NET_STATUS_VIDEO_FPS] intValue];
        int width = [(NSNumber *) [dict valueForKey:NET_STATUS_VIDEO_WIDTH] intValue];
        int height = [(NSNumber *) [dict valueForKey:NET_STATUS_VIDEO_HEIGHT] intValue];
        float cpu_usage = [(NSNumber *) [dict valueForKey:NET_STATUS_CPU_USAGE] floatValue];
        float cpu_usage_ = [(NSNumber *) [dict valueForKey:NET_STATUS_CPU_USAGE_D] floatValue];
        int codecCacheSize = [(NSNumber *) [dict valueForKey:NET_STATUS_CODEC_CACHE] intValue];
        int nCodecDropCnt = [(NSNumber *) [dict valueForKey:NET_STATUS_CODEC_DROP_CNT] intValue];
        NSString *serverIP = [dict valueForKey:NET_STATUS_SERVER_IP];
        int nSetVideoBitrate = [(NSNumber *) [dict valueForKey:NET_STATUS_SET_VIDEO_BITRATE] intValue];
        int videoGop = (int)([(NSNumber *) [dict valueForKey:NET_STATUS_VIDEO_GOP] doubleValue]+0.5f);
        NSString * audioInfo = [dict valueForKey:NET_STATUS_AUDIO_INFO];
        NSString *log = [NSString stringWithFormat:@"CPU:%.1f%%|%.1f%%\tRES:%d*%d\tSPD:%dkb/s\nJITT:%d\tFPS:%d\tGOP:%ds\tARA:%dkb/s\nQUE:%d|%d\tDRP:%d|%d\tVRA:%dkb/s\nSVR:%@\tAUDIO:%@",
                                                   cpu_usage_ * 100,
                                                   cpu_usage * 100,
                                                   width,
                                                   height,
                                                   netspeed,
                                                   jitter,
                                                   fps,
                                                   videoGop,
                                                   abitrate,
                                                   codecCacheSize,
                                                   cachesize,
                                                   nCodecDropCnt,
                                                   dropsize,
                                                   vbitrate,
                                                   serverIP,
                                                   audioInfo];
        AppDemoLogOnlyFile(@"Current status, VideoBitrate:%d, AudioBitrate:%d, FPS:%d, RES:%d*%d, netspeed:%d", vbitrate, abitrate, fps, width, height, netspeed);

        NSLog(@"mem %llu", get_app_consumed_memory_bytes());
    });
}


#pragma - ui util

- (void)initUI {

    _notification = [CWStatusBarNotification new];
    _notification.notificationLabelBackgroundColor = [UIColor redColor];
    _notification.notificationLabelTextColor = [UIColor whiteColor];

    //主界面排版
    self.title = @"RTMP推流";
    
//    self.view.backgroundColor = UIColor.blackColor;
    [self.view setBackgroundImage:[UIImage imageNamed:@"background.jpg"]];

    _addressBarController = [[AddressBarController alloc] initWithButtonOption:AddressBarButtonOptionNew | AddressBarButtonOptionQRScan];
    _addressBarController.qrPresentView = self.view;
    CGSize size = [[UIScreen mainScreen] bounds].size;
    int ICON_SIZE = 46;
    CGFloat topOffset = [UIApplication sharedApplication].statusBarFrame.size.height;
    topOffset += self.navigationController.navigationBar.height+5;
    _addressBarController.view.frame = CGRectMake(10, topOffset, self.view.width-20, ICON_SIZE);
    _addressBarController.view.textField.placeholder = RTMP_PUBLISH_URL;
    _addressBarController.delegate = self;
    [self.view addSubview:_addressBarController.view];
    
    

    float startSpace = 12;
    float centerInterVal = (size.width - 2 * startSpace - ICON_SIZE) / 6;
    float iconY = size.height - ICON_SIZE / 2 - 10;
    if (@available(iOS 11, *)) {
        iconY -= [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    }
    //start or stop 按钮
    _publish_switch = NO;
    _btnPublish = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnPublish.center = CGPointMake(startSpace + ICON_SIZE / 2, iconY);
    _btnPublish.bounds = CGRectMake(0, 0, ICON_SIZE, ICON_SIZE);
    [_btnPublish setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
    [_btnPublish addTarget:self action:@selector(clickPublish:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnPublish];


    //前置后置摄像头切换
    _camera_switch = NO;
    _btnCamera = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnCamera.center = CGPointMake(startSpace + ICON_SIZE / 2 + centerInterVal, iconY);
    _btnCamera.bounds = CGRectMake(0, 0, ICON_SIZE, ICON_SIZE);
    [_btnCamera setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    [_btnCamera addTarget:self action:@selector(clickCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnCamera];
    
    //美颜开关按钮
    _btnBeauty = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnBeauty.center = CGPointMake(startSpace + ICON_SIZE / 2 + centerInterVal * 2, iconY);
    _btnBeauty.bounds = CGRectMake(0, 0, ICON_SIZE, ICON_SIZE);
    [_btnBeauty setImage:[UIImage imageNamed:@"beauty"] forState:UIControlStateNormal];
    [_btnBeauty addTarget:self action:@selector(clickBeauty:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnBeauty];

    //硬件加速
    _hardware_switch = NO;
    _btnHardware = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnHardware.center = CGPointMake(startSpace + ICON_SIZE / 2 + centerInterVal * 3, iconY);
    _btnHardware.bounds = CGRectMake(0, 0, ICON_SIZE, ICON_SIZE);
    [_btnHardware setImage:[UIImage imageNamed:@"quick"] forState:UIControlStateNormal];
    [_btnHardware addTarget:self action:@selector(clickHardware:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnHardware];

    //开启横屏推流
    _screenPortrait = NO;
    _btnScreenOrientation = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnScreenOrientation.center = CGPointMake(startSpace + ICON_SIZE / 2 + centerInterVal * 4, iconY);
    _btnScreenOrientation.bounds = CGRectMake(0, 0, ICON_SIZE, ICON_SIZE);
    [_btnScreenOrientation setImage:[UIImage imageNamed:@"portrait"] forState:UIControlStateNormal];
    [_btnScreenOrientation addTarget:self action:@selector(clickScreenOrientation:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnScreenOrientation];

    //log显示或隐藏
    _log_switch = NO;
    _btnLog = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnLog.center = CGPointMake(startSpace + ICON_SIZE / 2 + centerInterVal * 5, iconY);
    _btnLog.bounds = CGRectMake(0, 0, ICON_SIZE, ICON_SIZE);
    [_btnLog setImage:[UIImage imageNamed:@"log"] forState:UIControlStateNormal];
    [_btnLog addTarget:self action:@selector(clickLog:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnLog];

    //清晰度按钮
    _btnResolution = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnResolution.center = CGPointMake(startSpace + ICON_SIZE / 2 + centerInterVal * 6, iconY);
    _btnResolution.bounds = CGRectMake(0, 0, ICON_SIZE, ICON_SIZE);
    [_btnResolution setImage:[UIImage imageNamed:@"set"] forState:UIControlStateNormal];
    [_btnResolution addTarget:self action:@selector(clickHD:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnResolution];
/*
    //镜像按钮
    _isMirror = NO;
    _btnMirror = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnMirror.center = CGPointMake(startSpace + ICON_SIZE / 2 + centerInterVal * 7, iconY);
    _btnMirror.bounds = CGRectMake(0, 0, ICON_SIZE, ICON_SIZE);
    [_btnMirror setTitle:@"镜像" forState:UIControlStateNormal];
    _btnMirror.titleLabel.font = [UIFont systemFontOfSize:15];
    [_btnMirror setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_btnMirror setBackgroundColor:[UIColor whiteColor]];
    _btnMirror.layer.cornerRadius = _btnMirror.frame.size.width / 2;
    [_btnMirror setAlpha:0.5];
    [_btnMirror addTarget:self action:@selector(clickMirror:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnMirror];
    */
    //录制按钮
#ifdef PUSH_RECORD
    _btnRecordVideo = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnRecordVideo.center = CGPointMake(startSpace + ICON_SIZE / 2 + centerInterVal * 0, iconY - ICON_SIZE);
    _btnRecordVideo.bounds = CGRectMake(0, 0, ICON_SIZE, ICON_SIZE);
    [_btnRecordVideo setImage:[UIImage imageNamed:@"video_press"] forState:UIControlStateNormal];
    [_btnRecordVideo addTarget:self action:@selector(clickRecord) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnRecordVideo];
#endif
    _labProgress = [[UILabel alloc] init];
    _labProgress.frame = CGRectMake(_btnRecordVideo.left, _btnRecordVideo.top - 30, 50, 30);
    [_labProgress setText:@""];
    [_labProgress setTextColor:[UIColor redColor]];
    [self.view addSubview:_labProgress];
    
    //BGM
    _btnBgm = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnBgm.center = CGPointMake(startSpace + ICON_SIZE / 2 + centerInterVal * 6, iconY-ICON_SIZE*2);
    _btnBgm.bounds = CGRectMake(0, 0, ICON_SIZE, ICON_SIZE);
    [_btnBgm setTitle:@"音乐" forState:UIControlStateNormal];
    _btnBgm.titleLabel.font = [UIFont systemFontOfSize:15];
    [_btnBgm setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_btnBgm setBackgroundColor:[UIColor whiteColor]];
    _btnBgm.layer.cornerRadius = _btnBgm.frame.size.width / 2;
    [_btnBgm setAlpha:0.5];
    [_btnBgm addTarget:self action:@selector(clickBgm:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnBgm];
    _btnBgm.hidden = YES;
    
#ifdef CUSTOM_PROCESS
    _btnSwitchCustom = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnSwitchCustom.center = CGPointMake(startSpace + ICON_SIZE / 2 + centerInterVal * 7, iconY-ICON_SIZE*2);
    _btnSwitchCustom.bounds = CGRectMake(0, 0, ICON_SIZE, ICON_SIZE);
    [_btnSwitchCustom setTitle:@"定制" forState:UIControlStateNormal];
    _btnSwitchCustom.titleLabel.font = [UIFont systemFontOfSize:15];
    [_btnSwitchCustom setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_btnSwitchCustom setBackgroundColor:[UIColor whiteColor]];
    _btnSwitchCustom.layer.cornerRadius = _btnSwitchCustom.frame.size.width / 2;
    [_btnSwitchCustom setAlpha:0.5];
    [_btnSwitchCustom addTarget:self action:@selector(clickCustom:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnSwitchCustom];
#endif
    
    NSUInteger controlHeight = [BeautySettingPanel getHeight];
    _vBeauty = [[BeautySettingPanel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - controlHeight, self.view.frame.size.width, controlHeight)];
    _vBeauty.hidden = YES;
    _vBeauty.delegate = self;
    _vBeauty.pituDelegate = self;
    [self.view addSubview:_vBeauty];

    _vHD = [[UIControl alloc] init];
    _vHD.frame = CGRectMake(0, size.height - 150, size.width, 180);
    [_vHD setBackgroundColor:[UIColor whiteColor]];


    UILabel *txtHD = [[UILabel alloc] init];
    txtHD.frame = CGRectMake(0, 0, size.width, 50);
    [txtHD setText:@"推流模式"];
    txtHD.textAlignment = NSTextAlignmentCenter;
    [txtHD setFont:[UIFont boldSystemFontOfSize:18]];
    
    _btnAutoBitrate = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnAutoBitrate.frame = CGRectMake(10, 110, self.view.width / 2 - 15, 30);
    [_btnAutoBitrate setTitle:@"码率自适应" forState:UIControlStateNormal];
    [_btnAutoBitrate addTarget:self action:@selector(onBtnAutoBitrateClick) forControlEvents:UIControlEventTouchUpInside];
    [_btnAutoBitrate setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
    [_btnAutoBitrate setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
     
     _btnAutoResolution = [UIButton buttonWithType:UIButtonTypeCustom];
     _btnAutoResolution.frame = CGRectMake(_btnAutoBitrate.right + 10, 110, self.view.width / 2 - 15, 30);
     [_btnAutoResolution setTitle:@"分辨率自适应" forState:UIControlStateNormal];
     [_btnAutoResolution addTarget:self action:@selector(onBtnAutoResolutionClick) forControlEvents:UIControlEventTouchUpInside];
    [_btnAutoResolution setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
    [_btnAutoResolution setTitleColor:UIColor.blackColor forState:UIControlStateNormal];

    [_vHD addSubview:_btnAutoBitrate];
    [_vHD addSubview:txtHD];
    [_vHD addSubview:_btnAutoResolution];

    int gap = 0;
    int width = (int) ((size.width - gap * 5 - 20) / 6);
    _radioBtnSD = [UIButton buttonWithType:UIButtonTypeCustom];
    _radioBtnSD.frame = CGRectMake(10, 60, width, 40);
    [_radioBtnSD setTitle:@"SD" forState:UIControlStateNormal];
    [_radioBtnSD addTarget:self action:@selector(changeHD:) forControlEvents:UIControlEventTouchUpInside];

    _radioBtnHD = [UIButton buttonWithType:UIButtonTypeCustom];
    _radioBtnHD.frame = CGRectMake(10 + gap + width, 60, width, 40);
    [_radioBtnHD setTitle:@"HD" forState:UIControlStateNormal];
    [_radioBtnHD addTarget:self action:@selector(changeHD:) forControlEvents:UIControlEventTouchUpInside];

    _radioBtnFHD = [UIButton buttonWithType:UIButtonTypeCustom];
    _radioBtnFHD.frame = CGRectMake(10 + (gap + width) * 2, 60, width, 40);
    [_radioBtnFHD setTitle:@"FHD" forState:UIControlStateNormal];
    [_radioBtnFHD addTarget:self action:@selector(changeHD:) forControlEvents:UIControlEventTouchUpInside];

    _radioBtnLinkmicBig = [UIButton buttonWithType:UIButtonTypeCustom];
    _radioBtnLinkmicBig.frame = CGRectMake(10 + (gap + width) * 3, 60, width, 40);
    [_radioBtnLinkmicBig setTitle:@"连麦大" forState:UIControlStateNormal];
    [_radioBtnLinkmicBig.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [_radioBtnLinkmicBig addTarget:self action:@selector(changeHD:) forControlEvents:UIControlEventTouchUpInside];
    
    _radioBtnLinkmicSmall = [UIButton buttonWithType:UIButtonTypeCustom];
    _radioBtnLinkmicSmall.frame = CGRectMake(10 + (gap + width) * 4, 60, width, 40);
    [_radioBtnLinkmicSmall setTitle:@"连麦小" forState:UIControlStateNormal];
    [_radioBtnLinkmicSmall.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [_radioBtnLinkmicSmall addTarget:self action:@selector(changeHD:) forControlEvents:UIControlEventTouchUpInside];
    
    _radioBtnVideoChat = [UIButton buttonWithType:UIButtonTypeCustom];
    _radioBtnVideoChat.frame = CGRectMake(_radioBtnLinkmicSmall.right, 60, width, 40);
    [_radioBtnVideoChat setTitle:@"实时" forState:UIControlStateNormal];
    [_radioBtnVideoChat addTarget:self action:@selector(changeHD:) forControlEvents:UIControlEventTouchUpInside];

    [_vHD addSubview:_radioBtnSD];
    [_vHD addSubview:_radioBtnHD];
    [_vHD addSubview:_radioBtnFHD];
    [_vHD addSubview:_radioBtnLinkmicBig];
    [_vHD addSubview:_radioBtnLinkmicSmall];
    [_vHD addSubview:_radioBtnVideoChat];

    _vHD.hidden = YES;
    [self.view addSubview:_vHD];

    // DEMO 默认采用 540 * 960 的分辨率
    _hd_level = HD_LEVEL_540P;
    [self setHDUI:_hd_level];
    [self changeHD:_radioBtnHD];

#if TARGET_IPHONE_SIMULATOR
    [self toastTip:@"iOS模拟器不支持推流和播放，请使用真机体验"];
#endif

    CGRect previewFrame = self.view.bounds;
    preViewContainer = [[UIView alloc] initWithFrame:previewFrame];

    [self.view insertSubview:preViewContainer atIndex:0];
    preViewContainer.center = self.view.center;
}

- (void)clickRecord {
#if defined(PUSH_RECORD) && !defined(DISABLE_LIVERECORD)
    if(!_publish_switch) return;
    _recordStart = !_recordStart;
    _btnRecordVideo.selected = NO;
    if (!_recordStart) {
        [_btnRecordVideo setImage:[UIImage imageNamed:@"video_press"] forState:UIControlStateNormal];
        _labProgress.text = @"";
        [_txLivePublisher stopRecord];
    } else {
        [_btnRecordVideo setImage:[UIImage imageNamed:@"suspend"] forState:UIControlStateNormal];
        [_txLivePublisher startRecord:[NSTemporaryDirectory() stringByAppendingPathComponent:@"pushRecord.mp4"]];
    }
#endif
}

#if defined(PUSH_RECORD) && !defined(DISABLE_LIVERECORD)
#pragma mark - TXLiveRecordListener
-(void) onRecordProgress:(NSInteger)milliSecond
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _labProgress.text = [NSString stringWithFormat:@"%.2f",milliSecond / 1000.0];

    });
}

-(void) onRecordComplete:(TXRecordResult*)result
{
    dispatch_async(dispatch_get_main_queue(), ^{
        LiveRecordPreviewViewController* vc = [[LiveRecordPreviewViewController alloc] initWithCoverImage:result.coverImage videoPath:result.videoPath renderMode:RENDER_MODE_FILL_EDGE isFromRecord:NO];
        if (_publish_switch){
            [self clickPublish:nil];
        }
        [self.navigationController presentViewController:vc animated:YES completion:^{
            //to do
        }];
    });
}
#endif

#pragma mark - ScanQRDelegate

- (void)onScanResult:(NSString *)result {
    _addressBarController.text = result;
}


- (void)setHDUI:(int)level {
    switch (level) {
        case HD_LEVEL_720P:
            [_radioBtnFHD setBackgroundImage:[UIImage imageNamed:@"black"] forState:UIControlStateNormal];
            [_radioBtnHD setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnSD setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnLinkmicBig setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnLinkmicSmall setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnVideoChat setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnFHD setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_radioBtnHD setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnSD setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnLinkmicBig setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnLinkmicSmall setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnVideoChat setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_btnResolution setImage:[UIImage imageNamed:@"set"] forState:UIControlStateNormal];
            break;
        case HD_LEVEL_540P:
            [_radioBtnFHD setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnHD setBackgroundImage:[UIImage imageNamed:@"black"] forState:UIControlStateNormal];
            [_radioBtnSD setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnLinkmicBig setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnLinkmicSmall setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnVideoChat setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnFHD setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnHD setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_radioBtnSD setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnLinkmicBig setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnLinkmicSmall setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnVideoChat setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_btnResolution setImage:[UIImage imageNamed:@"set"] forState:UIControlStateNormal];
            break;
        case HD_LEVEL_360P:
            [_radioBtnFHD setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnHD setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnSD setBackgroundImage:[UIImage imageNamed:@"black"] forState:UIControlStateNormal];
            [_radioBtnLinkmicBig setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnLinkmicSmall setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnVideoChat setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnFHD setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnHD setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnSD setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_radioBtnLinkmicBig setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnLinkmicSmall setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnVideoChat setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_btnResolution setImage:[UIImage imageNamed:@"set"] forState:UIControlStateNormal];

            break;
        case HD_LEVEL_LINKMIC_BIG:
            [_radioBtnFHD setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnHD setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnSD setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnLinkmicBig setBackgroundImage:[UIImage imageNamed:@"black"] forState:UIControlStateNormal];
            [_radioBtnLinkmicSmall setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnVideoChat setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnFHD setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnHD setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnSD setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnLinkmicBig setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_radioBtnLinkmicSmall setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnVideoChat setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_btnResolution setImage:[UIImage imageNamed:@"set"] forState:UIControlStateNormal];
            break;
        case HD_LEVEL_LINKMIC_SMALL:
            [_radioBtnFHD setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnHD setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnSD setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnLinkmicBig setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnLinkmicSmall setBackgroundImage:[UIImage imageNamed:@"black"] forState:UIControlStateNormal];
            [_radioBtnVideoChat setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnFHD setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnHD setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnSD setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnLinkmicBig setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnLinkmicSmall setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_radioBtnVideoChat setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_btnResolution setImage:[UIImage imageNamed:@"set"] forState:UIControlStateNormal];
            break;
        case HD_LEVEL_REALTIME_CHAT:
            [_radioBtnFHD setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnHD setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnSD setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnLinkmicBig setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnLinkmicSmall setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnVideoChat setBackgroundImage:[UIImage imageNamed:@"black"] forState:UIControlStateNormal];
            [_radioBtnFHD setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnHD setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnSD setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnLinkmicBig setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnLinkmicSmall setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnVideoChat setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_btnResolution setImage:[UIImage imageNamed:@"set"] forState:UIControlStateNormal];
        default:
            break;
    }
    
    if (_autoBitrate) {
        [_btnAutoBitrate setBackgroundImage:[UIImage imageNamed:@"black"] forState:UIControlStateNormal];
        [_btnAutoBitrate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        [_btnAutoBitrate setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
        [_btnAutoBitrate setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    
    if (_autoResolution) {
        [_btnAutoResolution setBackgroundImage:[UIImage imageNamed:@"black"] forState:UIControlStateNormal];
        [_btnAutoResolution setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        [_btnAutoResolution setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
        [_btnAutoResolution setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

- (NSString *)addressBarController:(AddressBarController *)controller qrCodeStringForAddress:(NSString *)string
{
    return [string stringByReplacingOccurrencesOfString:@".livepush.mycloud.com" withString:@".liveplay.mycloud.com"];
}

- (void)addressBarControllerTapScanQR:(AddressBarController *)controller {
    [_btnPublish setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
    _publish_switch = NO;
    [self stopRtmp];
    ScanQRController *vc = [[ScanQRController alloc] init];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:NO];
}

- (void)addressBarControllerTapCreateURL:(AddressBarController *)controller
{
    [_btnPublish setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
    _publish_switch = NO;
    [self stopRtmp];
    
    _hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _hub.mode = MBProgressHUDModeIndeterminate;
    _hub.label.text = @"地址获取中";
    [_hub showAnimated:YES];
    __weak PublishViewController* weakSelf = self;
    [TCHttpUtil asyncSendHttpRequest:@"get_test_pushurl" httpServerAddr:kHttpServerAddr HTTPMethod:@"GET" param:nil handler:^(int result, NSDictionary *resultDict) {
        if (result != 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                _hub = [MBProgressHUD HUDForView:weakSelf.view];
                _hub.mode = MBProgressHUDModeText;
                _hub.label.text = @"获取推流地址失败";
                [_hub showAnimated:YES];
                [_hub hideAnimated:YES afterDelay:2];
            });
        }
        else
        {
            NSString* pusherUrl = nil;
            NSString* rtmpPlayUrl = nil;
            NSString* flvPlayUrl = nil;
            NSString* hlsPlayUrl = nil;
            NSString* accPlayUrl = nil;
            if (resultDict)
            {
                pusherUrl = resultDict[@"url_push"];
                rtmpPlayUrl = resultDict[@"url_play_rtmp"];
                flvPlayUrl = resultDict[@"url_play_flv"];
                hlsPlayUrl = resultDict[@"url_play_hls"];
                accPlayUrl = resultDict[@"url_play_acc"];
            }
            controller.text = pusherUrl;
            NSString *(^c)(NSString *x, NSString *y) = ^(NSString *x, NSString *y) {
                return [NSString stringWithFormat:@"%@,%@", x, y];
            };
            controller.qrStrings = @[c(@"rtmp", rtmpPlayUrl),
                                     c(@"flv", flvPlayUrl),
                                     c(@"hls", hlsPlayUrl),
                                     c(@"低延时", accPlayUrl)];

            NSString* playUrls = [NSString stringWithFormat:@"rtmp播放地址:%@\n\nflv播放地址:%@\n\nhls播放地址:%@\n\n低延时播放地址:%@", rtmpPlayUrl, flvPlayUrl, hlsPlayUrl, accPlayUrl];
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = playUrls;
//            _addressBarController.qrString = accPlayUrl;
            dispatch_async(dispatch_get_main_queue(), ^{
                _hub = [MBProgressHUD HUDForView:weakSelf.view];
                _hub.mode = MBProgressHUDModeText;
                _hub.label.text = @"获取地址成功";
                _hub.detailsLabel.text = @"播放地址已复制到剪贴板";
                [_hub showAnimated:YES];
                [_hub hideAnimated:YES afterDelay:3];
            });
        }
    }];
}

- (void)clickPublish:(UIButton *)btn {
    //-[UIApplication setIdleTimerDisabled:]用于控制自动锁屏，SDK内部并无修改系统锁屏的逻辑
    if (_publish_switch) {
        [self stopRtmp];
        [_btnPublish setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
        _publish_switch = NO;
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

        [_btnRecordVideo setImage:[UIImage imageNamed:@"video_press"] forState:UIControlStateNormal];
        _labProgress.text = @"";
    } else {
        [self doChangeHD];
        if (![self startRtmp]) {
            return;
        }
        [_btnPublish setImage:[UIImage imageNamed:@"suspend"] forState:UIControlStateNormal];
        _publish_switch = YES;
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
}


- (void)clickCamera:(UIButton *)btn {
    _camera_switch = !_camera_switch;

    [btn setImage:[UIImage imageNamed:(_camera_switch ? @"camera2" : @"camera")] forState:UIControlStateNormal];
    [_txLivePublisher switchCamera];
//    [[TXUGCRecord shareInstance] switchCamera:_camera_switch];
}

- (void)clickBeauty:(UIButton *)btn {
    _vBeauty.hidden = NO;
    [self hideToolButtons:YES];
}

- (void)hideToolButtons:(BOOL)bHide
{
    _btnPublish.hidden = bHide;
    _btnCamera.hidden = bHide;
    _btnBeauty.hidden = bHide;
    _btnHardware.hidden = bHide;
    _btnLog.hidden = bHide;
    _btnResolution.hidden = bHide;
    _btnScreenOrientation.hidden = bHide;
    _btnMirror.hidden = bHide;
    _radioBtnFHD.hidden = bHide;
    _radioBtnHD.hidden = bHide;
    _radioBtnSD.hidden = bHide;
    _radioBtnLinkmicBig.hidden = bHide;
    _radioBtnLinkmicSmall.hidden = bHide;
    _radioBtnVideoChat.hidden = bHide;
}

/**
 @method 获取指定宽度width的字符串在UITextView上的高度
 @param textView 待计算的UITextView
 @param Width 限制字符串显示区域的宽度
 @result float 返回的高度
 */
- (float)heightForString:(UITextView *)textView andWidth:(float)width {
    CGSize sizeToFit = [textView sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    return sizeToFit.height;
}

- (void)toastTip:(NSString *)toastInfo {
    CGRect frameRC = [[UIScreen mainScreen] bounds];
    frameRC.origin.y = frameRC.size.height - 110;
    frameRC.size.height -= 110;
    __block UITextView *toastView = [[UITextView alloc] init];

    toastView.editable = NO;
    toastView.selectable = NO;

    frameRC.size.height = [self heightForString:toastView andWidth:frameRC.size.width];

    toastView.frame = frameRC;

    toastView.text = toastInfo;
    toastView.backgroundColor = [UIColor whiteColor];
    toastView.alpha = 0.5;

    [self.view addSubview:toastView];

    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);

    dispatch_after(popTime, dispatch_get_main_queue(), ^() {
        [toastView removeFromSuperview];
        toastView = nil;
    });
}

- (void)clickHardware:(UIButton *)btn {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        [self toastTip:@"iOS 版本低于8.0，不支持硬件加速."];
        return;
    }

    if (_txLivePublisher != nil) {
        TXLivePushConfig *configTmp = _txLivePublisher.config;
        if (!configTmp.enableHWAcceleration) {
            NSString *strTip = @"iOS SDK启用硬件加速.";
            if (_publish_switch) {
                strTip = @"iOS SDK启用硬件加速，切换后会重新开始推流";
            }

            [self toastTip:strTip];
            configTmp.enableHWAcceleration = YES;
            [btn setImage:[UIImage imageNamed:@"quick"] forState:UIControlStateNormal];
        } else {
            NSString *strTip = @"iOS SDK停止硬件加速.";
            if (_publish_switch) {
                strTip = @"iOS SDK停止硬件加速，切换后会重新开始推流";
            }

            [self toastTip:strTip];
            configTmp.enableHWAcceleration = NO;
            [btn setImage:[UIImage imageNamed:@"quick2"] forState:UIControlStateNormal];
        }
        _txLivePublisher.config = configTmp;
    }
}

- (void)clickMirror:(UIButton *)btn {
    _isMirror = !_isMirror;
    [_txLivePublisher setMirror:_isMirror];

    if (_isMirror) {
        [_btnMirror setAlpha:1];
    } else {
        [_btnMirror setAlpha:0.5];
    }
}

- (void)clickBgm:(UIButton *)btn {
    _isPlayBgm = !_isPlayBgm;
    if (_isPlayBgm) {
        //创建播放器控制器
        MPMediaPickerController *mpc = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
        mpc.delegate = self;
        mpc.editing = YES;
        [self presentViewController:mpc animated:YES completion:nil];
    } else {
        [_txLivePublisher stopBGM];
    }
}

- (void)clickCustom:(UIButton*)btn
{
    if (_txLivePublisher.videoProcessDelegate != nil) {
        _txLivePublisher.videoProcessDelegate = nil;
    }
    else {
        _txLivePublisher.videoProcessDelegate = self;
    }
}

- (void)clickLog:(UIButton *)btn {
    if (_log_switch) {
        [btn setImage:[UIImage imageNamed:@"log"] forState:UIControlStateNormal];
    } else {
        [btn setImage:[UIImage imageNamed:@"log2"] forState:UIControlStateNormal];
    }
    _log_switch = !_log_switch;
    [_txLivePublisher setLogViewMargin:UIEdgeInsetsMake(120, 10, 60, 10)];
    [_txLivePublisher showVideoDebugLog:_log_switch];
//    if (_log_switch) {
//        _statusView.hidden = YES;
//        _logViewEvt.hidden = YES;
//        [btn setImage:[UIImage imageNamed:@"log"] forState:UIControlStateNormal];
//        _cover.hidden = YES;
//        _log_switch = NO;
//        [_txLivePublisher showVideoDebugLog:NO];
//    } else {
//        _statusView.hidden = NO;
//        _logViewEvt.hidden = NO;
//        [btn setImage:[UIImage imageNamed:@"log2"] forState:UIControlStateNormal];
//        _cover.hidden = NO;
//        _log_switch = YES;
//        [_txLivePublisher showVideoDebugLog:YES];
//    }

}

- (void)clickScreenOrientation:(UIButton *)btn {
    _screenPortrait = !_screenPortrait;

    if (_screenPortrait) {
        //activity竖屏模式，home在右横屏推流
        [btn setImage:[UIImage imageNamed:@"landscape"] forState:UIControlStateNormal];
        TXLivePushConfig *_config = _txLivePublisher.config;

        _config.homeOrientation = HOME_ORIENTATION_RIGHT;
        [_txLivePublisher setConfig:_config];
        [_txLivePublisher setRenderRotation:90];


        //activity竖屏模式，home在左横屏推流
//        [btn setImage:[UIImage imageNamed:@"landscape"] forState:UIControlStateNormal];
//        TXLivePushConfig* _config = _txLivePublisher.config;
//        _config.homeOrientation = HOME_ORIENTATION_LEFT;
//        [_txLivePublisher setConfig:_config];
//        [_txLivePublisher setRenderRotation:270];

    } else {
        //activity竖屏模式，竖屏推流
        [btn setImage:[UIImage imageNamed:@"portrait"] forState:UIControlStateNormal];
        TXLivePushConfig *_config = _txLivePublisher.config;
        _config.homeOrientation = HOME_ORIENTATION_DOWN;
        [_txLivePublisher setConfig:_config];
        
        [_txLivePublisher setRenderRotation:0];

    }
}


- (void)statusBarOrientationChanged:(NSNotification *)note {
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationPortrait:        //activity竖屏模式，竖屏推流
        {
            if (_deviceOrientation != UIDeviceOrientationPortrait) {
                TXLivePushConfig *_config = _txLivePublisher.config;
                _config.homeOrientation = HOME_ORIENTATION_DOWN;
                [_txLivePublisher setConfig:_config];
                [_txLivePublisher setRenderRotation:0];
                _deviceOrientation = UIDeviceOrientationPortrait;
            }
        }
            break;
        case UIDeviceOrientationLandscapeLeft:   //activity横屏模式，home在右横屏推流 注意：渲染view（demo里面是：preViewContainer）要跟着activity旋转
        {
            if (_deviceOrientation != UIDeviceOrientationLandscapeLeft) {
                TXLivePushConfig *_config = _txLivePublisher.config;
                _config.homeOrientation = HOME_ORIENTATION_RIGHT;
                [_txLivePublisher setConfig:_config];
                [_txLivePublisher setRenderRotation:0];
                _deviceOrientation = UIDeviceOrientationLandscapeLeft;
            }

        }
            break;
        case UIDeviceOrientationLandscapeRight:   //activity横屏模式，home在左横屏推流 注意：渲染view（demo里面是：preViewContainer）要跟着activity旋转
        {
            if (_deviceOrientation != UIDeviceOrientationLandscapeRight) {
                TXLivePushConfig *_config = _txLivePublisher.config;
                _config.homeOrientation = HOME_ORIENTATION_LEFT;
                [_txLivePublisher setConfig:_config];
                [_txLivePublisher setRenderRotation:0];
                _deviceOrientation = UIDeviceOrientationLandscapeRight;
            }
        }
            break;
        default:
            break;
    }
}

- (void)clickHD:(UIButton *)btn {
    _vHD.hidden = NO;
}

- (void)onBtnAutoBitrateClick
{
    _autoBitrate = !_autoBitrate;
    [self doChangeHD];
}

- (void)onBtnAutoResolutionClick
{
    _autoResolution = !_autoResolution;
    [self doChangeHD];
}

- (void)changeHD:(UIButton *)btn {
    if ([btn.titleLabel.text isEqualToString:@"FHD"] && ![self isSuitableMachine:7]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"直播推流"
                                                        message:@"iphone 6 及以上机型适合开启720p!"
                                                       delegate:nil
                                              cancelButtonTitle:@"确认"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }

    if ([btn.titleLabel.text isEqualToString:@"HD"] && ![self isSuitableMachine:5]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"直播推流"
                                                        message:@"iphone 5 及以上机型适合开启540p!"
                                                       delegate:nil
                                              cancelButtonTitle:@"确认"
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }

    if (_txLivePublisher == nil) return;

//    if (_publish_switch == YES) {
//        [self stopRtmp];
//    }

    if ([btn.titleLabel.text isEqualToString:@"FHD"]) {
        _hd_level = HD_LEVEL_720P;
    } else if ([btn.titleLabel.text isEqualToString:@"HD"]) {
        _hd_level = HD_LEVEL_540P;
    } else if ([btn.titleLabel.text isEqualToString:@"SD"]) {
        _hd_level = HD_LEVEL_360P;
    } else if ([btn.titleLabel.text isEqualToString:@"连麦大"]) {
        _hd_level = HD_LEVEL_LINKMIC_BIG;
    } else if ([btn.titleLabel.text isEqualToString:@"连麦小"]) {
        _hd_level = HD_LEVEL_LINKMIC_SMALL;
    }
    else if ([btn.titleLabel.text isEqualToString:@"实时"]) {
        _hd_level = HD_LEVEL_REALTIME_CHAT;
    }

   

    [self doChangeHD];
//    _vHD.hidden = YES;
}

- (void)doChangeHD
{
    TXLivePushConfig *configTmp = _txLivePublisher.config;
    if (_hd_level == HD_LEVEL_720P) {
        [_txLivePublisher setVideoQuality:VIDEO_QUALITY_SUPER_DEFINITION adjustBitrate:_autoBitrate adjustResolution:_autoResolution];
        configTmp.videoEncodeGop = 5;
    }
    else if (_hd_level == HD_LEVEL_540P) {
        [_txLivePublisher setVideoQuality:VIDEO_QUALITY_HIGH_DEFINITION adjustBitrate:_autoBitrate adjustResolution:_autoResolution];
        configTmp.videoEncodeGop = 5;
    }
    else if (_hd_level == HD_LEVEL_360P) {
        [_txLivePublisher setVideoQuality:VIDEO_QUALITY_STANDARD_DEFINITION adjustBitrate:_autoBitrate adjustResolution:_autoResolution];
        configTmp.videoEncodeGop = 5;
    }
    else if (_hd_level == HD_LEVEL_LINKMIC_BIG) {
        [_txLivePublisher setVideoQuality:VIDEO_QUALITY_LINKMIC_MAIN_PUBLISHER adjustBitrate:_autoBitrate adjustResolution:_autoResolution];
    }
    else if (_hd_level == HD_LEVEL_LINKMIC_SMALL) {
        [_txLivePublisher setVideoQuality:VIDEO_QUALITY_LINKMIC_SUB_PUBLISHER  adjustBitrate:_autoBitrate adjustResolution:_autoResolution];
    }
    else if (_hd_level == HD_LEVEL_REALTIME_CHAT) {
        [_txLivePublisher setVideoQuality:VIDEO_QUALITY_REALTIME_VIDEOCHAT adjustBitrate:_autoBitrate adjustResolution:_autoResolution];
    }

    if (!configTmp.enableHWAcceleration) {
        [_btnHardware setImage:[UIImage imageNamed:@"quick2"] forState:UIControlStateNormal];
    } else {
        [_btnHardware setImage:[UIImage imageNamed:@"quick"] forState:UIControlStateNormal];
    }
    
    [self setHDUI:_hd_level];
}


// iphone 6 及以上机型适合开启720p, 否则20帧的帧率可能无法达到, 这种"流畅不足,清晰有余"的效果并不好
- (BOOL)isSuitableMachine:(int)targetPlatNum {
    int mib[2] = {CTL_HW, HW_MACHINE};
    size_t len = 0;
    char *machine;
    
    sysctl(mib, 2, NULL, &len, NULL, 0);
    
    machine = (char *) malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    
    NSRange range = [platform rangeOfString:@"iPhone"];
    if ([platform length] > 6 && range.location != NSNotFound) {
        NSRange range2 = [platform rangeOfString:@","];
        NSString *platNum = [platform substringWithRange:NSMakeRange(range.location + range.length, range2.location - range.location - range.length)];
        return ([platNum intValue] >= targetPlatNum);
    } else {
        return YES;
    }
}

#pragma mark - BeautyLoadPituDelegate
- (void)onLoadPituStart
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hub.mode = MBProgressHUDModeText;
        _hub.label.text = @"开始加载资源";
    });
}
- (void)onLoadPituProgress:(CGFloat)progress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _hub.label.text = [NSString stringWithFormat:@"正在加载资源%d %%",(int)(progress * 100)];
    });
}
- (void)onLoadPituFinished
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _hub.label.text = @"资源加载成功";
        [_hub hideAnimated:YES afterDelay:1];
    });
}
- (void)onLoadPituFailed
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _hub.label.text = @"资源加载失败";
        [_hub hideAnimated:YES afterDelay:1];
    });
}


#pragma mark - BeautySettingPanelDelegate
- (void)onSetBeautyStyle:(int)beautyStyle beautyLevel:(float)beautyLevel whitenessLevel:(float)whitenessLevel ruddinessLevel:(float)ruddinessLevel{
    [_txLivePublisher setBeautyStyle:beautyStyle beautyLevel:beautyLevel whitenessLevel:whitenessLevel ruddinessLevel:ruddinessLevel];
}

- (void)onSetEyeScaleLevel:(float)eyeScaleLevel {
    [_txLivePublisher setEyeScaleLevel:eyeScaleLevel];
}

- (void)onSetFaceScaleLevel:(float)faceScaleLevel {
    [_txLivePublisher setFaceScaleLevel:faceScaleLevel];
}

- (void)onSetFilter:(UIImage *)filterImage {
    [_txLivePublisher setFilter:filterImage];
}


- (void)onSetGreenScreenFile:(NSURL *)file {
    [_txLivePublisher setGreenScreenFile:file];
}

- (void)onSelectMotionTmpl:(NSString *)tmplName inDir:(NSString *)tmplDir {
    [_txLivePublisher selectMotionTmpl:tmplName inDir:tmplDir];
}

- (void)onSetFaceVLevel:(float)vLevel{
    [_txLivePublisher setFaceVLevel:vLevel];
}

- (void)onSetFaceShortLevel:(float)shortLevel{
    [_txLivePublisher setFaceShortLevel:shortLevel];
}

- (void)onSetNoseSlimLevel:(float)slimLevel{
    [_txLivePublisher setNoseSlimLevel:slimLevel];
}

- (void)onSetChinLevel:(float)chinLevel{
    [_txLivePublisher setChinLevel:chinLevel];
}

- (void)onSetMixLevel:(float)mixLevel{
    [_txLivePublisher setSpecialRatio:mixLevel / 10.0];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    _vHD.hidden = YES;
    _vBeauty.hidden = YES;
    [self hideToolButtons:NO];
}

#ifdef CUSTOM_PROCESS
//////////////////////////////////// GPU 自定义处理 ////////////////////////////////////
- (GLuint)onPreProcessTexture:(GLuint)texture width:(CGFloat)width height:(CGFloat)height
{
    //NSLog(@"custom %d, %f, %f", texture, width, height);
//    return texture;

    if (_filter == nil) {
        _filter = [[CustomProcessFilter alloc] init];
    }
    return [_filter renderToTextureWithSize:CGSizeMake(width, height) sourceTexture:texture];
}

- (void)onTextureDestoryed
{
    NSLog(@"onTextureDestoryed");
    [_filter destroyFramebuffer];
    _filter = nil;
}

- (void)onDetectFacePoints:(NSArray *)points
{
    NSLog(@"%lu", (unsigned long)points.count);
}
#endif

#pragma -- bgm

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
    NSArray *items = mediaItemCollection.items;
    MPMediaItem *songItem = [items objectAtIndex:0];
    
    NSURL *url = [songItem valueForProperty:MPMediaItemPropertyAssetURL];
    NSString* songName = [songItem valueForProperty: MPMediaItemPropertyTitle];
    NSString* authorName = [songItem valueForProperty:MPMediaItemPropertyArtist];
    NSNumber* duration = [songItem valueForKey:MPMediaItemPropertyPlaybackDuration];
    NSLog(@"MPMediaItemPropertyAssetURL = %@", url);
    
    PushMusicInfo* musicInfo = [PushMusicInfo new];
    musicInfo.duration = duration.floatValue;
    musicInfo.soneName = songName;
    musicInfo.singerName = authorName;
    
    if (mediaPicker.editing) {
        mediaPicker.editing = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self saveAssetURLToFile:musicInfo assetURL:url];
        });
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

// 将AssetURL(音乐)导出到app的文件夹并播放
- (void)saveAssetURLToFile:(PushMusicInfo*)musicInfo assetURL:(NSURL*)assetURL
{
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:songAsset presetName:AVAssetExportPresetAppleM4A];
    NSLog (@"created exporter. supportedFileTypes: %@", exporter.supportedFileTypes);
    exporter.outputFileType = @"com.apple.m4a-audio";
    
    [AVAssetExportSession exportPresetsCompatibleWithAsset:songAsset];
    NSString *docDir = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"LocalMusics/"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:docDir]) {
        [fileManager createDirectoryAtPath:docDir withIntermediateDirectories:NO attributes:nil error:nil];
    }
    //    NSString *exportFilePath = [docDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.m4a", musicInfo.soneName, musicInfo.singerName]];
    NSString *exportFilePath = [docDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_%@.m4a", musicInfo.soneName, musicInfo.singerName]];
    
    exporter.outputURL = [NSURL fileURLWithPath:exportFilePath];
    musicInfo.filePath = exportFilePath;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportFilePath]) {
        [_txLivePublisher playBGM:musicInfo.filePath withBeginNotify:^(NSInteger errCode) {
            NSLog(@"start bgm with err %ld", (long)errCode);
        } withProgressNotify:^(NSInteger progressMS, NSInteger durationMS) {
            NSLog(@"bgm play progress %ld|%ld", progressMS, durationMS);
        } andCompleteNotify:^(NSInteger errCode) {
            NSLog(@"bgm play complete %ld", errCode);
        }];
        return;
    }
    
    //    MBProgressHUD* hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    //    hub.label.text = @"音频读取中...";
    
    
    
    // do the export
    //__weak typeof(self) weakSelf = self;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            //            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        int exportStatus = exporter.status;
        switch (exportStatus) {
            case AVAssetExportSessionStatusFailed: {
                NSLog (@"AVAssetExportSessionStatusFailed: %@", exporter.error);
                break;
                
            }
            case AVAssetExportSessionStatusCompleted: {
                NSLog(@"AVAssetExportSessionStatusCompleted: %@", exporter.outputURL);
                
                // 播放背景音乐
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_txLivePublisher playBGM:musicInfo.filePath withBeginNotify:^(NSInteger errCode) {
                        NSLog(@"start bgm with err %ld", (long)errCode);
                    } withProgressNotify:^(NSInteger progressMS, NSInteger durationMS) {
                        NSLog(@"bgm play progress %ld|%ld", progressMS, durationMS);
                    } andCompleteNotify:^(NSInteger errCode) {
                        NSLog(@"bgm play complete %ld", errCode);
                    }];
                });
                break;
            }
            case AVAssetExportSessionStatusUnknown: { NSLog (@"AVAssetExportSessionStatusUnknown"); break;}
            case AVAssetExportSessionStatusExporting: { NSLog (@"AVAssetExportSessionStatusExporting"); break;}
            case AVAssetExportSessionStatusCancelled: { NSLog (@"AVAssetExportSessionStatusCancelled"); break;}
            case AVAssetExportSessionStatusWaiting: { NSLog (@"AVAssetExportSessionStatusWaiting"); break;}
            default: { NSLog (@"didn't get export status"); break;}
        }
    }];
    
    _isPlayBgm = YES;
}

//点击取消时回调
- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onRecordPcm:(NSData *)pcmData {
    if (_txLivePublisher) {
        [_txLivePublisher sendCustomPCMData:(unsigned char *)pcmData.bytes len:(int)pcmData.length];
    }}

@end
