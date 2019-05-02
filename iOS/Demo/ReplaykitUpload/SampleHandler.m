//
//  SampleHandler.m
//  ReplayKit2Upload
//
//  Created by rushanting on 2018/3/26.
//  Copyright © 2018年 Tencent. All rights reserved.
//


#import "SampleHandler.h"
#import "TXLiveSDKTypeDef.h"
#import "TXLivePush.h"
#import "TXLiveBase.h"
#import "ReplayKit2Define.h"
#import <VideoToolbox/VideoToolbox.h>
#import <Accelerate/Accelerate.h>
#import <UserNotifications/UserNotifications.h>
#import <ReplayKit/RPBroadcastExtension.h>

//  To handle samples with a subclass of RPBroadcastSampleHandler set the following in the extension's Info.plist file:
//  - RPBroadcastProcessMode should be set to RPBroadcastProcessModeSampleBuffer
//  - NSExtensionPrincipalClass should be set to this class
//#define KIsiPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

static TXLivePush *s_txLivePublisher;
static NSString *s_rtmpUrl;
static BOOL       s_landScape;   // 1 - 横屏；
static SampleHandler *s_delegate;   // retain delegate
static NSString* s_resolution;
static CMSampleBufferRef s_lastSampleBuffer;
static CGImagePropertyOrientation s_orientation = kCGImagePropertyOrientationUp;


@interface SampleHandler() <TXLivePushListener, TXLiveBaseDelegate>

-(void) onPushEvent:(int)EvtID withParam:(NSDictionary*)param;
-(void) onNetStatus:(NSDictionary*) param;

@end

@implementation SampleHandler {
    
}

- (NSDictionary *)jsonData2Dictionary:(NSString *)jsonData
{
    if (jsonData == nil) {
        return nil;
    }
    NSData *data = [jsonData dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (err) {
        NSLog(@"Json parse failed: %@", jsonData);
        return nil;
    }
    return dic;
}

- (instancetype) init {
    self = [super init];
    // 请参考 https://cloud.tencent.com/document/product/454/34750 获取License
    [TXLiveBase setLicenceURL:@"<#License URL#>" key:@"<#License Key#>"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReplayKit2PushStartNotification:) name:@"Cocoa_ReplayKit2_Push_Start" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReplayKit2PushStopNotification:) name:@"Cocoa_ReplayKit2_Push_Stop" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReplayKit2RotateChangeNotification:) name:@"Cocoa_ReplayKit2_Rotate_Change" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReplayKit2ResolutionChangeNotification:) name:@"Cocoa_ReplayKit2_Resolution_Change" object:nil];

    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    (__bridge const void *)(self),
                                    onDarwinReplayKit2PushStart,
                                    kDarvinNotificationNamePushStart,
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    (__bridge const void *)(self),
                                    onDarwinReplayKit2PushStop,
                                    kDarvinNotificaiotnNamePushStop,
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    (__bridge const void *)(self),
                                    onDarwinReplayKit2RotateChange,
                                    kDarvinNotificaiotnNameRotationChange,
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    (__bridge const void *)(self),
                                    onDarwinReplayKit2ResolutionChange,
                                    kDarvinNotificaiotnNameResolutionChange,
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);

    return self;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge const void *)(self), kDarvinNotificationNamePushStart, NULL);
    CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge const void *)(self), kDarvinNotificaiotnNamePushStop, NULL);
    CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge const void *)(self), kDarvinNotificaiotnNameRotationChange, NULL);
    CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge const void *)(self), kDarvinNotificaiotnNameResolutionChange, NULL);

    
}

static void onDarwinReplayKit2PushStart(CFNotificationCenterRef center,
                                        void *observer, CFStringRef name,
                                        const void *object, CFDictionaryRef
                                        userInfo)
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Cocoa_ReplayKit2_Push_Start" object:nil];
    });
}

static void onDarwinReplayKit2PushStop(CFNotificationCenterRef center,
                                       void *observer, CFStringRef name,
                                       const void *object, CFDictionaryRef
                                       userInfo)
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Cocoa_ReplayKit2_Push_Stop" object:nil];
}

static void onDarwinReplayKit2RotateChange(CFNotificationCenterRef center,
                                           void *observer, CFStringRef name,
                                           const void *object, CFDictionaryRef
                                           userInfo)
{
    //用剪贴板传值会有同步问题，加些延迟去避免。正式应用建议配置appgroup,使用NSUserDefault的方式传值
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Cocoa_ReplayKit2_Rotate_Change" object:nil];
    });
    
}

static void onDarwinReplayKit2ResolutionChange(CFNotificationCenterRef center,
                                           void *observer, CFStringRef name,
                                           const void *object, CFDictionaryRef
                                           userInfo)
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        [[NSNotificationCenter defaultCenter] postNotificationName:@"Cocoa_ReplayKit2_Resolution_Change" object:nil];
    });

}

- (void)handleReplayKit2PushStartNotification:(NSNotification*)noti
{
//    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kReplayKit2AppGroupId];
    
    UIPasteboard* pb = [UIPasteboard generalPasteboard];
    NSDictionary* defaults = [self jsonData2Dictionary:pb.string];
    
    s_rtmpUrl = [defaults objectForKey:kReplayKit2PushUrlKey];
    s_resolution = [defaults objectForKey:kReplayKit2ResolutionKey];
    if (s_resolution.length < 1) {
        s_resolution = kResolutionHD;
    }
    NSString* rotate = [defaults objectForKey:kReplayKit2RotateKey];
    if ([rotate isEqualToString:kReplayKit2Portrait]) {
        s_landScape = NO;
    }
    else {
        s_landScape = YES;
    }
//    [self sendLocalNotificationToHostAppWithTitle:@"腾讯云录屏推流" msg:[NSString stringWithFormat:@"推流地址:%@", s_rtmpUrl] userInfo:nil];
    [self start];
}

- (void)handleReplayKit2PushStopNotification:(NSNotification*)noti
{
    [self stop];
    [self sendLocalNotificationToHostAppWithTitle:@"腾讯云录屏推流" msg:@"推流已停止" userInfo:nil];
}

- (void)handleReplayKit2RotateChangeNotification:(NSNotification*)noti
{
//    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kReplayKit2AppGroupId];
    UIPasteboard* pb = [UIPasteboard generalPasteboard];
    NSDictionary* defaults = [self jsonData2Dictionary:pb.string];
    if (!defaults) {
        [self sendLocalNotificationToHostAppWithTitle:@"腾讯云录屏推流" msg:@"切换失败" userInfo:nil];
        return;
    }
    NSString* rotate = [defaults objectForKey:kReplayKit2RotateKey];
    if ([rotate isEqualToString:kReplayKit2Lanscape]) {
        s_landScape = YES;
    }
    else if ([rotate isEqualToString:kReplayKit2Portrait]) {
        s_landScape = NO;
    }
    else
        return;
    
    [self setCustomRotationAndResolution:rotate resolution:s_resolution];
//    [self sendLocalNotificationToHostAppWithTitle:@"腾讯云录屏推流" msg:s_landScape?@"切为横屏":@"切为竖屏" userInfo:nil];

}

- (void)handleReplayKit2ResolutionChangeNotification:(NSNotification*)noti
{
//    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kReplayKit2AppGroupId];

    UIPasteboard* pb = [UIPasteboard generalPasteboard];
    NSDictionary* defaults = [self jsonData2Dictionary:pb.string];
    if (!defaults)
        return;
    s_resolution = [defaults objectForKey:kReplayKit2ResolutionKey];
    if (s_resolution.length < 1) {
        return;
    }
//    [self sendLocalNotificationToHostAppWithTitle:@"腾讯云录屏推流" msg:s_resolution userInfo:nil];
    //test pausePush
//    if ([s_resolution isEqualToString:kResolutionSD]) {
//        [s_txLivePublisher pausePush];
//
//    }
//    if ([s_resolution isEqualToString:kResolutionHD]) {
//        [s_txLivePublisher resumePush];
//
//    }
//    return;
    [self setCustomRotationAndResolution:s_landScape?kReplayKit2Lanscape:kReplayKit2Portrait resolution:s_resolution];
}

- (void)sendLocalNotificationToHostAppWithTitle:(NSString*)title msg:(NSString*)msg userInfo:(NSDictionary*)userInfo
{
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString localizedUserNotificationStringForKey:title arguments:nil];
    content.body = [NSString localizedUserNotificationStringForKey:msg  arguments:nil];
    content.sound = [UNNotificationSound defaultSound];
    content.userInfo = userInfo;
    
    // 在 设定时间 后推送本地推送
    UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger
                                                  triggerWithTimeInterval:0.1f repeats:NO];
    
    UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:@"ReplayKit2Demo"
                                                                          content:content trigger:trigger];
    
    //添加推送成功后的处理！
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        
    }];
}

- (void) initLivePublisher {
    @synchronized(self) {
        if (s_txLivePublisher) {
            [s_txLivePublisher stopPush];
        }
        
        TXLivePushConfig* config = [[TXLivePushConfig alloc] init];
        config.customModeType |= CUSTOM_MODE_VIDEO_CAPTURE;
        config.enableAutoBitrate = YES;
        config.autoSampleBufferSize = NO;
        config.enableHWAcceleration = YES;
        
        
        config.customModeType |= CUSTOM_MODE_AUDIO_CAPTURE;
        config.audioSampleRate = AUDIO_SAMPLE_RATE_44100;
        config.audioChannels   = 1;
        
//        config.pauseFps = 10;
//        config.pauseTime = 3600;
//        config.pauseImg = [UIImage imageNamed:@"pause_publish.jpg"];
        
        s_txLivePublisher = [[TXLivePush alloc] initWithConfig:config];
        [self setCustomRotationAndResolution:s_landScape?kReplayKit2Lanscape:kReplayKit2Portrait resolution:s_resolution];
        [s_txLivePublisher startPush:s_rtmpUrl];
        s_delegate = self;
        s_txLivePublisher.delegate = s_delegate;
        [TXLiveBase sharedInstance].delegate = s_delegate;
        if (s_lastSampleBuffer) {
            [s_txLivePublisher sendVideoSampleBuffer:s_lastSampleBuffer];
        }
    }
//    [self sendLocalNotificationToHostAppWithTitle:@"腾讯云录屏推流" msg:@"推流启动" userInfo:nil];
}

- (void)setCustomRotationAndResolution:(NSString *)rotation resolution:(NSString *)resolution
{
    @synchronized(self) {
        TXLivePushConfig* config = s_txLivePublisher.config;
        CGSize screenSize = [[UIScreen mainScreen] currentMode].size;
        config.homeOrientation = HOME_ORIENTATION_DOWN;
        config.autoSampleBufferSize = NO;

        //分辨率与码率根据业务需要设置，注意分辨率的16字节对齐
        if ([resolution isEqualToString:kResolutionSD]) {
            uint32_t hight = (uint)(360 * screenSize.height / screenSize.width);
            hight = hight + (16 - hight % 16);
            config.sampleBufferSize = CGSizeMake(368, hight);
            config.videoBitrateMin = 400;
            config.videoBitratePIN = 800;
            config.videoBitrateMax = 1200;
            config.videoFPS = 20;
        }
        else if ([resolution isEqualToString:kResolutionFHD]) {
    //        config.sampleBufferSize = CGSizeMake(1088, (uint)(1080 * screenSize.height / screenSize.width)); //建议不超过720P
    //        config.videoResolution = VIDEO_RESOLUTION_TYPE_720_1280;
            uint32_t hight = (uint)(720 * screenSize.height / screenSize.width);
            hight = hight + (16 - hight % 16);
//            config.autoSampleBufferSize = YES;
            config.sampleBufferSize = CGSizeMake(720, hight);
            config.videoBitrateMin = 1600;
            config.videoBitratePIN = 2400;
            config.videoBitrateMax = 3000;
//            config.videoFPS = 30;
            config.videoFPS = 48;

        }
        else {
            uint32_t hight = (uint)(540 * screenSize.height / screenSize.width);
            hight = hight + (16 - hight % 16);
            config.sampleBufferSize = CGSizeMake(544, hight);
            config.videoBitrateMin = 800;
            config.videoBitratePIN = 1400;
            config.videoBitrateMax = 1800;
            config.videoFPS = 24;
        }

        if ([rotation isEqualToString:kReplayKit2Lanscape]) {
            config.sampleBufferSize = CGSizeMake(config.sampleBufferSize.height, config.sampleBufferSize.width);
            config.homeOrientation = HOME_ORIENTATION_RIGHT;
        }
        [s_txLivePublisher setConfig:config];
        if (s_lastSampleBuffer && s_txLivePublisher.isPublishing) {
            [s_txLivePublisher sendVideoSampleBuffer:s_lastSampleBuffer];
        }
    }
}


- (void)resetHomeOritation:(CGImagePropertyOrientation)orientation
{
    
    TXLivePushConfig* config = s_txLivePublisher.config;
    TX_Enum_Type_HomeOrientation oldOrientation = s_txLivePublisher.config.homeOrientation;
    TX_Enum_Type_HomeOrientation newOrientation = HOME_ORIENTATION_DOWN;
    if (orientation == kCGImagePropertyOrientationLeft) {
        newOrientation = HOME_ORIENTATION_LEFT;
    }
    else if (orientation == kCGImagePropertyOrientationRight) {
        newOrientation = HOME_ORIENTATION_RIGHT;
    }
    
    if (oldOrientation == newOrientation)
        return;
    
    config.homeOrientation = newOrientation;
    if ((oldOrientation == HOME_ORIENTATION_DOWN && newOrientation != HOME_ORIENTATION_DOWN) || (oldOrientation != HOME_ORIENTATION_DOWN && newOrientation == HOME_ORIENTATION_DOWN)) {
        config.sampleBufferSize = CGSizeMake(config.sampleBufferSize.height, config.sampleBufferSize.width);
    }
    [s_txLivePublisher setConfig:config];
    if (s_lastSampleBuffer) {
        [s_txLivePublisher sendVideoSampleBuffer:s_lastSampleBuffer];
    }
}

- (void)pause {
    [s_txLivePublisher setSendAudioSampleBufferMuted:YES];
}

- (void)resume {
    [s_txLivePublisher setSendAudioSampleBufferMuted:NO];
}

- (void)stop {
    @synchronized(self) {
        s_rtmpUrl = nil;
        
        if (s_txLivePublisher) {
            [s_txLivePublisher stopPush];
            s_txLivePublisher = nil;
        }
        if (s_lastSampleBuffer) {
            CFRelease(s_lastSampleBuffer);
            s_lastSampleBuffer = NULL;
        }
        s_delegate = nil;
    }
}

- (void)start {
    if (s_rtmpUrl == nil) return;
    [self initLivePublisher];
}

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    [self sendLocalNotificationToHostAppWithTitle:@"腾讯云录屏推流" msg:@"录屏已开始，请从这里点击回到Demo->直播->录屏推流->设置推流URL与横竖屏和清晰度" userInfo:@{kReplayKit2UploadingKey: kReplayKit2Uploading}];
}

- (void)broadcastPaused {
    // User has requested to pause the broadcast. Samples will stop being delivered.
    NSLog(@"broadcastPaused");
    [self pause];
    [self sendLocalNotificationToHostAppWithTitle:@"腾讯云录屏推流" msg:@"录屏已暂停" userInfo:nil];
}

- (void)broadcastResumed {
    // User has requested to resume the broadcast. Samples delivery will resume.
    NSLog(@"broadcastResumed");
    [self resume];
    [self sendLocalNotificationToHostAppWithTitle:@"腾讯云录屏推流" msg:@"录屏已恢复" userInfo:nil];
}

- (void)broadcastFinished {
    // User has requested to finish the broadcast.
    NSLog(@"broadcastFinished");
    [self sendLocalNotificationToHostAppWithTitle:@"腾讯云录屏推流" msg:@"录屏已结束" userInfo:@{kReplayKit2UploadingKey: kReplayKit2Stop}];
    [self stop];
}


- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    @synchronized(self) {

        switch (sampleBufferType) {
            case RPSampleBufferTypeVideo:
                // Handle audio sample buffer
            {
                
                if (!CMSampleBufferIsValid(sampleBuffer))
                    return;
                
                //11.1以上支持自动旋转
#ifdef __IPHONE_11_1
                if (UIDevice.currentDevice.systemVersion.floatValue > 11.1) {
                    CGImagePropertyOrientation oritation = ((__bridge NSNumber*)CMGetAttachment(sampleBuffer, (__bridge CFStringRef)RPVideoSampleOrientationKey , NULL)).unsignedIntValue;
                    if (oritation != s_orientation) {
                        s_orientation = oritation;
                        [self resetHomeOritation:oritation];
                    }
                }
#endif

                //保存一帧在startPush时发送,防止推流启动后或切换横竖屏因无画面数据而推流不成功
                if (s_lastSampleBuffer) {
                    CFRelease(s_lastSampleBuffer);
                }
                s_lastSampleBuffer = sampleBuffer;
                CFRetain(s_lastSampleBuffer);
                
                [s_txLivePublisher sendVideoSampleBuffer:sampleBuffer];
//                NSLog(@"videoPTS:%.2f", CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer)));
            }
                break;
            case RPSampleBufferTypeAudioApp:
                // Handle audio sample buffer for app audio
                //            if (s_headPhoneIn || s_isMicEnable == Mic_Disable) {
                if (CMSampleBufferDataIsReady(sampleBuffer) != NO) {
                    [s_txLivePublisher sendAudioSampleBuffer:sampleBuffer withType:sampleBufferType];
                }
                NSLog(@"AppPTS:%.2f", CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer)));

                break;
            case RPSampleBufferTypeAudioMic:
                // Handle audio sample buffer for mic audio
                if (CMSampleBufferDataIsReady(sampleBuffer) != NO) {
                    [s_txLivePublisher sendAudioSampleBuffer:sampleBuffer withType:sampleBufferType];
                }
                NSLog(@"MicPTS:%.2f", CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer)));

                break;
                
            default:
                break;
        }
    }
}


-(void) onPushEvent:(int)EvtID withParam:(NSDictionary*)param {
    NSLog(@"onPushEvent %d", EvtID);
    if (EvtID == PUSH_ERR_NET_DISCONNECT) {
        [self sendLocalNotificationToHostAppWithTitle:@"腾讯云录屏推流" msg:@"推流失败!请换个姿势再来一次" userInfo:nil];
    }  else if (EvtID == PUSH_EVT_PUSH_BEGIN) {
        [self sendLocalNotificationToHostAppWithTitle:@"腾讯云录屏推流" msg:@"连接成功！开始推流" userInfo:nil];
    } else if (EvtID == PUSH_WARNING_NET_BUSY) {
        [self sendLocalNotificationToHostAppWithTitle:@"腾讯云录屏推流" msg:@"网络上行带宽不足" userInfo:nil];
    }
}

-(void) onNetStatus:(NSDictionary*) param {
    
}


@end
