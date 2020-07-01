//
//  SampleHandler.m
//  TXBroadcastUpload
//
//  Created by annidyfeng on 16/8/31.
//  Copyright © 2016年 annidy. All rights reserved.
//


#import "SampleHandler.h"
#import "TXLiveSDKTypeDef.h"
#import "TXLivePush.h"
#import "TXLiveBase.h"
#import <VideoToolbox/VideoToolbox.h>
#import "UIDevice-Hardware.h"
#import "TCUtil.h"
#import "TCPusherModel.h"


//  To handle samples with a subclass of RPBroadcastSampleHandler set the following in the extension's Info.plist file:
//  - RPBroadcastProcessMode should be set to RPBroadcastProcessModeSampleBuffer
//  - NSExtensionPrincipalClass should be set to this class

//#define TEST

static TXLivePush *s_txLivePublisher;
static NSString *s_rtmpUrl;
static dispatch_source_t s_audioTimer;
static int       s_landScape;   // 1 - 横屏；
static NSString *s_userid, *s_groupid;
static id s_lastVideoSampleBuffer;
static SampleHandler *s_delegate;   // retain delegate

static BOOL s_headPhoneIn;

#define NSLog MyLog

void MyLog(NSString *formatString, ...) {
    va_list args;
    va_start(args, formatString);
    NSString *contents = [[NSString alloc] initWithFormat:formatString arguments:args];
    va_end(args);
    NSData *now = [NSData new];
    const char *logstr = [contents UTF8String];
    if (logstr)
    printf(logstr);
}

static BOOL CheckIphone5() {
    static BOOL is5;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *m = [[UIDevice new] modelName];
        if ([m containsString:@"iPhone 5"] ||
            [m containsString:@"iPhone 4"]) {
            is5 = YES;
        } else {
            is5 = NO;
        }
    });
    return is5;
}

@interface SampleHandler() <TXLivePushListener, TXLiveBaseDelegate>

-(void) onPushEvent:(int)EvtID withParam:(NSDictionary*)param;
-(void) onNetStatus:(NSDictionary*) param;

@end

@implementation SampleHandler {
    
}

- (instancetype) init {
    self = [super init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(routeChanged:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)routeChanged:(NSNotification *)notification {
    NSInteger routeChangeReason = [notification.userInfo[AVAudioSessionRouteChangeReasonKey] integerValue];
    if (routeChangeReason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        s_headPhoneIn = NO;
    }
    if (routeChangeReason == AVAudioSessionRouteChangeReasonNewDeviceAvailable) {
        s_headPhoneIn = YES;
    }
}

- (void)checkHeadphone {
    AVAudioSession *session = [AVAudioSession sharedInstance];
    for (AVAudioSessionPortDescription *dp in session.currentRoute.outputs) {
        if ([dp.portType isEqualToString:AVAudioSessionPortHeadphones]) {
            s_headPhoneIn = YES;
            return;
        }
    }
    s_headPhoneIn = NO;
}

- (void) initRtmp {
    if (s_txLivePublisher) {
        [s_txLivePublisher stopPush];
    }
    
    TXLivePushConfig* config = [[TXLivePushConfig alloc] init];
    config.customModeType |= CUSTOM_MODE_VIDEO_CAPTURE;
    config.videoBitratePIN   = 1000;
    config.enableAutoBitrate = NO;
    config.videoFPS = 20;
    // 5的手机硬编不稳定    
    if (CheckIphone5()) {
        config.enableHWAcceleration = NO;
        config.autoSampleBufferSize = NO;
        if (s_landScape) {
            config.sampleBufferSize = CGSizeMake(640, 360);
        } else {
            config.sampleBufferSize = CGSizeMake(360, 640);
        }
    } else {
        config.autoSampleBufferSize = NO;
        
        if (s_landScape)
            config.sampleBufferSize = CGSizeMake(960, 544);
        else
            config.sampleBufferSize = CGSizeMake(544, 960);
    }
    
    config.customModeType |= CUSTOM_MODE_AUDIO_CAPTURE;
    config.audioSampleRate = AUDIO_SAMPLE_RATE_44100;
    config.audioChannels   = 1;
    
    s_txLivePublisher = [[TXLivePush alloc] initWithConfig:config];
    [s_txLivePublisher startPush:s_rtmpUrl];
    s_delegate = self;
    s_txLivePublisher.delegate = s_delegate;
    [TXLiveBase sharedInstance].delegate = s_delegate;
    [self checkHeadphone];
}

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    // User has requested to start the broadcast. Setup info from the UI extension will be supplied.
    NSString *url = (NSString *)setupInfo[@"endpointURL"];
    if (!url || ![url isKindOfClass:[NSString class]]) {
        NSLog(@"broadcastStartedWithSetupInfo 地址非法");
        return;
    }
    NSLog(@"broadcastStartedWithSetupInfo %@", setupInfo);
    [self resume];
    [self stop];
    s_userid = (NSString *)setupInfo[@"userID"];
    s_groupid = (NSString *)setupInfo[@"groupID"];
    s_rtmpUrl = url;
    s_landScape = [(NSNumber *)setupInfo[@"rotate"] boolValue];
    [self start];
}

- (void)broadcastPaused {
    // User has requested to pause the broadcast. Samples will stop being delivered.
    NSLog(@"broadcastPaused");
    [self pause];
}

- (void)broadcastResumed {
    // User has requested to resume the broadcast. Samples delivery will resume.
    NSLog(@"broadcastResumed");
    [self resume];
}

- (void)broadcastFinished {
    // User has requested to finish the broadcast.
    NSLog(@"broadcastFinished");
    [self resume];
    [self stop];
 }


- (void)pause {
    [s_txLivePublisher setSendAudioSampleBufferMuted:YES];
}

- (void)resume {
    [s_txLivePublisher setSendAudioSampleBufferMuted:NO];
}

- (void)stop {
    s_rtmpUrl = nil;
    
    if (s_txLivePublisher) {
        [s_txLivePublisher stopPush];
        s_txLivePublisher = nil;
    }
    
    [self changeLiveStatus:s_userid status:TCLiveStatus_Offline handler:^(int errCode) {
        NSLog(@"changeLiveStatus offline code:%d", errCode);
    }];
    
    s_lastVideoSampleBuffer = nil;
    s_delegate = nil;
}

- (void)start {
    if (s_rtmpUrl == nil) return;
    [self initRtmp];
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
  
    if (s_txLivePublisher == nil) {
        return;
    }
    s_headPhoneIn = 1;
    switch (sampleBufferType) {
        case RPSampleBufferTypeVideo:
            // Handle audio sample buffer
        {
            [s_txLivePublisher sendVideoSampleBuffer:sampleBuffer];
            s_lastVideoSampleBuffer = (__bridge id)sampleBuffer;
            return;
        }
            break;
        case RPSampleBufferTypeAudioApp:
            // Handle audio sample buffer for app audio
            if (s_headPhoneIn) {
                if (CMSampleBufferDataIsReady(sampleBuffer) != NO) {
                    [s_txLivePublisher sendAudioSampleBuffer:sampleBuffer withType:sampleBufferType];
                    CMTime  audioCaptureTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
                    
//                    NSLog(@"App %f", CMTimeGetSeconds(audioCaptureTime));
//                    CMTime  duration = CMSampleBufferGetDuration(sampleBuffer);
                } else {
                    NSAssert(0, @"wft");
                }
            }
            break;
        case RPSampleBufferTypeAudioMic:
            // Handle audio sample buffer for mic audio
            if (CMSampleBufferDataIsReady(sampleBuffer) != NO) {
                [s_txLivePublisher sendAudioSampleBuffer:sampleBuffer withType:sampleBufferType];
//                [s_txLivePublisher sendAudioSampleBuffer:sampleBuffer];
                CMTime  audioCaptureTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
                NSLog(@"Mic %f", CMTimeGetSeconds(audioCaptureTime));
//                CMTime  duration = CMSampleBufferGetDuration(sampleBuffer);
            } else {
                NSAssert(0, @"wft");
            }
            break;
            
        default:
            break;
    }
}

-(void) onPushEvent:(int)EvtID withParam:(NSDictionary*)param {
 //   NSLog(@"onPushEvent %d", EvtID);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (EvtID == PUSH_ERR_NET_DISCONNECT) {
            [self initRtmp];
            if (s_lastVideoSampleBuffer) { // fix bug: pause status no video data come
                [s_txLivePublisher sendVideoSampleBuffer:(__bridge_retained CMSampleBufferRef)s_lastVideoSampleBuffer];
            }
        } else if(EvtID == PUSH_WARNING_HW_ACCELERATION_FAIL){
            
        } else if (EvtID == PUSH_EVT_PUSH_BEGIN) {
            //该事件表示推流成功，可以通知业务server将该流置为上线状态
            [self changeLiveStatus:s_userid status:TCLiveStatus_Online handler:^(int errCode) {
                NSLog(@"changeLiveStatus online code:%d", errCode);
            }];
        }
    });
}

-(void) onNetStatus:(NSDictionary*) param {
    
}

- (void)onLog:(NSString *)log LogLevel:(int)level WhichModule:(NSString *)module {
    const char *logstr = [log UTF8String];
 //   NSLog(log);
}

// HTTP 登录 相关

- (void) changeLiveStatus:(NSString*)userId status:(TCLiveStatus)status handler:(PusherMgrCompleteHandler)handler
{
    if (userId == nil)
    {
        NSLog(@"changeLiveStatus failed，userid 为空");
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(kError_InvalidParam);
        });
        return;
    }
    
    NSDictionary* dictParam = @{@"Action" : @"ChangeStatus", @"userid" : TC_PROTECT_STR(userId), @"status" : @(status)};
    [TCUtil asyncSendHttpRequest:dictParam handler:^(int result, NSDictionary *resultDict) {
        handler(result);
    }];
}

@end
