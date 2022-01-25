//
//  TRTCPusher.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by gg on 2020/9/7.
//

#import "TUIPusherStreamService.h"
#import "TUIPusherHeader.h"
#import "PusherLocalized.h"
#import "TUILogin.h"
#import "TUIPusherLinkURLUtils.h"

static const int kTC_COMPONENT_PUSHER = 11;
static const int kTC_FRAMEWORK_LIVE   = 4;

@interface TUIPusherStreamService () <V2TXLivePusherObserver, V2TXLivePlayerObserver>

@property (nonatomic, assign) BOOL isOpenedCamera;
@property (nonatomic, assign) BOOL isFrontCamera;

@property (nonatomic, strong, readwrite) V2TXLivePusher *pusher;
@property (nonatomic, strong) V2TXLivePlayer *player;
@property (nonatomic,  weak ) id <TUIPusherStreamServiceDelegate> delegate;
@end


@implementation TUIPusherStreamService

- (instancetype)initWithMode:(V2TXLiveMode)mode {
    self = [super init];
    if (self) {
        self.isFrontCamera = YES;
        self.pusher = [[V2TXLivePusher alloc] initWithLiveMode:mode];
        [self.pusher setObserver:self];
    }
    return self;
}

- (void)setDelegate:(id<TUIPusherStreamServiceDelegate>)delegate {
    _delegate = delegate;
}

- (BOOL)openCamera:(BOOL)frontCamera view:(UIView *)view {
    self.isFrontCamera = frontCamera;
    V2TXLiveCode res = [self.pusher startCamera:frontCamera];
    res += [self.pusher setRenderView:view];
    
    LOGD("【Pusher】start camera [%d]: %d", frontCamera, res);
    
    [[self.pusher getDeviceManager] enableCameraAutoFocus:YES];
    return res == V2TXLIVE_OK;
}

- (void)startCamera:(BOOL)frontCamera {
    LOGD("【Pusher】start camera");
    [self.pusher startCamera:frontCamera];
}

- (void)closeCamara {
    LOGD("【Pusher】close camera");
    [self.pusher stopCamera];
}

- (void)startVirtualCamera:(TXImage *)image {
    LOGD("【Pusher】start virtual camera");
    [self.pusher startVirtualCamera:image];
}

- (void)stopVirtualCamera {
    LOGD("【Pusher】stop virtual camera");
    [self.pusher stopVirtualCamera];
}

- (BOOL)startPush:(NSString *)url {
    V2TXLiveCode res = [self.pusher startMicrophone];
    [self setFramework];
    res += [self.pusher startPush:url];
    
    LOGD("【Pusher】start push: %d url:%s", res, url.UTF8String);
    
    [self.pusher setMixTranscodingConfig:nil];
    return res == V2TXLIVE_OK;
}

- (void)setFramework {
    NSDictionary *jsonDic = @{@"api": @"setFramework",
                              @"params":@{@"framework": @(kTC_FRAMEWORK_LIVE),
                                          @"component": @(kTC_COMPONENT_PUSHER)}};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [self.pusher setProperty:@"setFramework" value:jsonString];
}

- (void)stopPush {
    LOGD("【Pusher】stop push");
    [self closeCamara];
    [self.pusher stopPush];
}

- (BOOL)startPK:(NSString *)streamId view:(UIView *)pkView {
    V2TXLiveCode res = [self.player setRenderView:pkView];
    
    NSString *url = [TUIPusherLinkURLUtils generatePlayUrl:streamId];
    res += [self.player startPlay:url];
    
    V2TXLiveTranscodingConfig *config = [self createPKMixConfig:[TUILogin getUserID] remoteUserId:streamId remoteStreamId:streamId];
    res += [self.pusher setMixTranscodingConfig:config];
    
    LOGD("【Pusher】start pk: %d", res);
    
    return res == V2TXLIVE_OK;
}

- (void)stopPK {
    LOGD("【Pusher】stop pk");
    [self.player stopPlay];
    [self.pusher setMixTranscodingConfig:nil];
}

- (BOOL)startLinkMic:(NSString *)streamId view:(UIView *)view {
    V2TXLiveCode res = [self.player setRenderView:view];
    
    NSString *url = [TUIPusherLinkURLUtils generatePlayUrl:streamId];
    res += [self.player startPlay:url];
    
    V2TXLiveTranscodingConfig *config = [self createLinkMicMixConfig:[TUILogin getUserID] remoteUserId:streamId remoteStreamId:streamId];
    res += [self.pusher setMixTranscodingConfig:config];
    
    LOGD("【Pusher】start linkmic: %d", res);
    
    return res == V2TXLIVE_OK;
}

- (void)stopLinkMic {
    LOGD("【Pusher】stop linkmic");
    
    [self.player stopPlay];
    [self.pusher setMixTranscodingConfig:nil];
}

- (void)switchCamera:(BOOL)frontCamera {
    LOGD("【Pusher】switch camera: %d", frontCamera);
    
    [[self.pusher getDeviceManager] switchCamera:frontCamera];
}

- (void)setMirror:(BOOL)isMirror {
    LOGD("【Pusher】set mirror: %d", isMirror);
    
    [self.pusher setRenderMirror:isMirror ? V2TXLiveMirrorTypeEnable : V2TXLiveMirrorTypeDisable];
    [self.pusher setEncoderMirror:isMirror];
}

- (void)setVideoResolution:(VideoResolution)resolution {
    V2TXLiveVideoResolution realResolution = V2TXLiveVideoResolution480x360;
    switch (resolution) {
        case VIDEO_RES_360:
            realResolution = V2TXLiveVideoResolution480x360;
            break;
        case VIDEO_RES_540:
            realResolution = V2TXLiveVideoResolution960x540;
            break;
        case VIDEO_RES_720:
            realResolution = V2TXLiveVideoResolution1280x720;
            break;
        case VIDEO_RES_1080:
            realResolution = V2TXLiveVideoResolution1920x1080;
            break;
        default:
            break;
    }
    LOGD("【Pusher】set video resolution: %d", resolution);
    V2TXLiveVideoEncoderParam *param = [[V2TXLiveVideoEncoderParam alloc] initWith:realResolution];
//    param.videoResolutionMode = V2TXLiveVideoResolutionModePortrait;
    [self.pusher setVideoQuality:param];
}

- (V2TXLiveTranscodingConfig *)createLinkMicMixConfig:(NSString *)mStreamId remoteUserId:(NSString *)remoteUserId remoteStreamId:(NSString *)remoteStreamId {
    V2TXLiveTranscodingConfig *config = [[V2TXLiveTranscodingConfig alloc] init];
    config.videoWidth      = 360;
    config.videoHeight     = 640;
    config.videoBitrate    = 900;
    config.videoFramerate  = 15;
    config.videoGOP        = 2;
    config.backgroundColor = 0x000000;
    config.backgroundImage = nil;
    config.audioSampleRate = 48000;
    config.audioBitrate    = 64;
    config.audioChannels   = 1;
    config.outputStreamId  = nil;
    
    V2TXLiveMixStream *mixStream = [[V2TXLiveMixStream alloc] init];
    mixStream.userId = [TUILogin getUserID];
    mixStream.streamId = mStreamId;
    mixStream.x = 0;
    mixStream.y = 0;
    mixStream.width = 360;
    mixStream.height = 640;
    mixStream.zOrder = 0;
    mixStream.inputType = V2TXLiveMixInputTypeAudioVideo;
    
    V2TXLiveMixStream *remote = [[V2TXLiveMixStream alloc] init];
    remote.userId = remoteUserId;
    remote.streamId = remoteStreamId;
    remote.x      = 225;
    remote.y      = 100;
    remote.width  = 90;
    remote.height = 160;
    remote.zOrder = 1;
    remote.inputType = V2TXLiveMixInputTypeAudioVideo;
    
    config.mixStreams = @[mixStream, remote];
    return config;
}

- (V2TXLiveTranscodingConfig *)createPKMixConfig:(NSString *)mStreamId remoteUserId:(NSString *)remoteUserId remoteStreamId:(NSString *)remoteStreamId {
    V2TXLiveTranscodingConfig *config = [[V2TXLiveTranscodingConfig alloc] init];
    config.videoWidth = 360;
    config.videoHeight = 640;
    config.videoBitrate = 900;
    config.videoFramerate = 15;
    config.videoGOP = 2;
    config.backgroundColor = 0x000000;
    config.backgroundImage = nil;
    config.audioSampleRate = 48000;
    config.audioBitrate = 64;
    config.audioChannels = 1;
    config.outputStreamId = nil;

    V2TXLiveMixStream *mixStream = [[V2TXLiveMixStream alloc] init];
    mixStream.userId = [TUILogin getUserID];
    mixStream.streamId = mStreamId;
    mixStream.x = 0;
    mixStream.y = 0.5 * 320;
    mixStream.width = 180;
    mixStream.height = 320;
    mixStream.zOrder = 0;
    mixStream.inputType = V2TXLiveMixInputTypeAudioVideo;
    
    V2TXLiveMixStream *remote = [[V2TXLiveMixStream alloc] init];
    remote.userId = remoteUserId;
    remote.streamId = remoteStreamId;
    remote.x = 180;
    remote.y = 0.5 * 320;
    remote.width = 180;
    remote.height = 320;
    remote.zOrder = 1;
    remote.inputType = V2TXLiveMixInputTypeAudioVideo;
    config.mixStreams = @[mixStream, remote];
    
    return config;
}

- (V2TXLivePlayer *)player {
    if (!_player) {
        _player = [[V2TXLivePlayer alloc] init];
        [_player setObserver:self];
    }
    return _player;
}

#pragma mark - V2TXLivePusherObserver
- (void)onError:(V2TXLiveCode)code message:(NSString *)msg extraInfo:(NSDictionary *)extraInfo {
    if ([self.delegate respondsToSelector:@selector(onStreamServiceError:msg:)]) {
        [self.delegate onStreamServiceError:code msg:msg];
    }
}

- (void)onPushStatusUpdate:(V2TXLivePushStatus)status message:(NSString *)msg extraInfo:(NSDictionary *)extraInfo {
    
}

#pragma mark - V2TXLivePlayerObserver
- (void)onConnected:(id<V2TXLivePlayer>)player extraInfo:(NSDictionary *)extraInfo {
    
}

@end
