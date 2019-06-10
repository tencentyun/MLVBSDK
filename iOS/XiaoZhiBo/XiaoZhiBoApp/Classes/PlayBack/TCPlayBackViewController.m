/**
 * Module: TCPlayBackViewController
 *
 * Function: 视频回放
 */

#import "TCPlayBackViewController.h"
#import "TCAudienceViewController.h"
#import "TCAnchorViewController.h"
#import "TXLivePlayListener.h"
#import "TXLivePlayConfig.h"
#import <mach/mach.h>
#import <UIImageView+WebCache.h>
#import "TCMsgModel.h"
#import "TCGlobalConfig.h"
#import <Accelerate/Accelerate.h>
#import "TCAccountMgrModel.h"
#import "NSString+Common.h"
#import "TXVodPlayer.h"
#import "UIView+Additions.h"
#import "HUDHelper.h"

@interface TCPlayBackViewController () <UITextFieldDelegate, TXVodPlayListener,TCAudienceToolbarDelegate>

@end

@implementation TCPlayBackViewController
{
    TXVodPlayer *       _txVodPlayer;
    TXLivePlayConfig*    _config;
    
    long long            _trackingTouchTS;
    BOOL                 _startSeek;
    BOOL                 _videoPause;
    BOOL                 _videoFinished;
    BOOL                 _appIsInterrupt;
    float                _sliderValue;
    BOOL                 _isInVC;
    NSString             *_logMsg;
    NSString             *_rtmpUrl;
    
    UIView               *_videoParentView;
    
    BOOL                 _rotate;
    BOOL                 _isErrorAlert; //是否已经弹出了错误提示框，用于保证在同时收到多个错误通知时，只弹一个错误提示框
    uint64_t             _beginTime;
}

- (id)initWithPlayInfo:(TCRoomInfo *)info videoIsReady:(videoIsReadyBlock)videoIsReady {
    if (self = [super init]) {
        _liveInfo      = info;
        _videoIsReady  = videoIsReady;
        _videoPause    = NO;
        _videoFinished = YES;
        _isInVC        = NO;
        _log_switch    = NO;
        
        _rtmpUrl = self.liveInfo.hls_play_url;
        if (_rtmpUrl == nil || ![_rtmpUrl isKindOfClass:[NSString class]]) {
            _rtmpUrl = self.liveInfo.playurl;
        }
        
        if ([_rtmpUrl hasPrefix:@"http:"]) {
            _rtmpUrl = [_rtmpUrl stringByReplacingOccurrencesOfString:@"http:" withString:@"https:"];
        }
        _rotate       = NO;
        _txVodPlayer =[[TXVodPlayer alloc] init];
        _txVodPlayer.enableHWAcceleration = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioSessionEvent:) name:AVAudioSessionInterruptionNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidEnterBackGround:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        
        [self startPlay];
        _isErrorAlert = NO;
        
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];

    if (_videoPause && _txVodPlayer) {
        [_txVodPlayer resume];
        _videoPause =NO;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _isInVC = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (!_videoPause && _txVodPlayer) {
        [_txVodPlayer pause];
        _videoPause = YES;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*预加载UI*/
    UIImage *backImage =  self.liveInfo.userinfo.frontcoverImage;
    UIImage *clipImage = nil;
    if (backImage) {
        CGFloat backImageNewHeight = self.view.height;
        CGFloat backImageNewWidth = backImageNewHeight * backImage.size.width / backImage.size.height;
        UIImage *gsImage = [TCUtil gsImage:backImage withGsNumber:10];
        UIImage *scaleImage = [TCUtil scaleImage:gsImage scaleToSize:CGSizeMake(backImageNewWidth, backImageNewHeight)];
        clipImage = [TCUtil clipImage:scaleImage inRect:CGRectMake((backImageNewWidth - self.view.width)/2, (backImageNewHeight - self.view.height)/2, self.view.width, self.view.height)];
    }
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    backgroundImageView.image = clipImage;
    backgroundImageView.contentMode = UIViewContentModeScaleToFill;
    backgroundImageView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:backgroundImageView];
    
    //视频画面父view
    _videoParentView = [[UIView alloc] initWithFrame:self.view.frame];
    _videoParentView.tag = FULL_SCREEN_PLAY_VIDEO_VIEW;
    [self.view addSubview:_videoParentView];

    [self setVideoView];
    _beginTime = [[NSDate date] timeIntervalSince1970];
}

- (void)initLogicView {
    if (_logicView) {
        return;
    }
    
    //逻辑View
    CGFloat bottom = 0;
    if (@available(iOS 11, *)) {
        bottom = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    }
    CGRect frame = self.view.frame;
    frame.size.height -= bottom;
    _logicView = [[TCAudienceToolbarView alloc] initWithFrame:frame liveInfo:self.liveInfo withLinkMic: NO];
    _logicView.delegate = self;

    [self.view addSubview:_logicView];
}

#pragma mark - Notification Handlers
//在低系统（如7.1.2）可能收不到这个回调，请在onAppDidEnterBackGround和onAppWillEnterForeground里面处理打断逻辑
- (void)onAudioSessionEvent:(NSNotification *) notification {
    NSDictionary *info = notification.userInfo;
    AVAudioSessionInterruptionType type = [info[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        if (_appIsInterrupt == NO) {
            if (!_videoPause) {
                [_txVodPlayer pause];
            }
            _appIsInterrupt = YES;
        }
    } else {
        AVAudioSessionInterruptionOptions options = [info[AVAudioSessionInterruptionOptionKey] unsignedIntegerValue];
        if (options == AVAudioSessionInterruptionOptionShouldResume) {
            if (_appIsInterrupt == YES) {
                if (!_videoPause) {
                    [_txVodPlayer resume];
                }
                _appIsInterrupt = NO;
            }
        }
    }
}

- (void)onAppDidEnterBackGround:(UIApplication*)app {
    if (_appIsInterrupt == NO) {
        if (!_videoPause) {
            [_txVodPlayer pause];
        }
        _appIsInterrupt = YES;
    }
}

- (void)onAppWillEnterForeground:(UIApplication*)app {
    if (_appIsInterrupt == YES) {
        if (!_videoPause) {
            [_txVodPlayer resume];
        }
        _appIsInterrupt = NO;
    }
}
#pragma mark RTMP LOGIC

- (BOOL)checkPlayUrl:(NSString*)playUrl {
    if ([playUrl hasPrefix:@"https:"] || [playUrl hasPrefix:@"http:"]) {
        if ([playUrl rangeOfString:@".flv"].length > 0) {
            
        } else if ([playUrl rangeOfString:@".m3u8"].length > 0){
            
        } else if ([playUrl rangeOfString:@".mp4"].length > 0){
            
        } else {
            [TCUtil toastTip:@"播放地址不合法，点播目前仅支持flv,hls,mp4播放方式!" parentView:self.view];
            return NO;
        }
        
    } else {
        [TCUtil toastTip:@"播放地址不合法，点播目前仅支持flv,hls,mp4播放方式!" parentView:self.view];
        return NO;
    }
    
    
    return YES;
}

- (void)clearLog {
    _logMsg = @"";
    [_logicView.statusView setText:@""];
    [_logicView.logViewEvt setText:@""];
}

- (void)setVideoView {
    [self clearLog];
    [_txVodPlayer setupVideoWidget:_videoParentView insertIndex:0];
    if (_rotate) {
        [_txVodPlayer setRenderRotation:HOME_ORIENTATION_RIGHT];
    }
}

- (BOOL)startPlay {
    if (![self checkPlayUrl:_rtmpUrl]) {
        return NO;
    }
    
    NSString* ver = [TXLiveBase getSDKVersionStr];
    _logMsg = [NSString stringWithFormat:@"rtmp sdk version: %@",ver];
    [_logicView.logViewEvt setText:_logMsg];
    
    if(_txVodPlayer != nil) {
        if (self.liveInfo.type == TCRoomListItemType_UGC) {
            TXVodPlayConfig *cfg = _txVodPlayer.config;
            if (cfg == nil) {
                cfg = [TXVodPlayConfig new];
            }
            cfg.cacheFolderPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/txcache"];
            cfg.maxCacheItems = 5;
            _txVodPlayer.config = cfg;
        }
        
        _txVodPlayer.vodDelegate = self;
        int result = [_txVodPlayer startPlay:_rtmpUrl];
        if (result == -1)
        {
            [self closeVCWithRefresh:YES popViewController:YES];
            return NO;
        }
        if (_rotate) {
            [_txVodPlayer setRenderRotation:HOME_ORIENTATION_RIGHT];
        }
        
        if( result != 0)
        {
            [TCUtil toastTip:[NSString stringWithFormat:@"%@%d", kErrorMsgRtmpPlayFailed, result] parentView:self.view];
            [self closeVCWithRefresh:YES popViewController:YES];
            return NO;
        }
        
        [_txVodPlayer setRenderMode:RENDER_MODE_FILL_EDGE];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
    _startSeek = NO;
    
    return YES;
}

- (BOOL)startVodPlay {
    [self setVideoView];
    return [self startPlay];
}

- (void)stopRtmp {
    if(_txVodPlayer != nil)
    {
        _txVodPlayer.vodDelegate = nil;
        [_txVodPlayer stopPlay];
        [_txVodPlayer removeVideoWidget];
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

#pragma mark - TCAudienceToolbarDelegate

- (void)closeVC:(BOOL)popViewController {
    [self closeVCWithRefresh:NO popViewController:popViewController];
}

- (void)closeVCWithRefresh:(BOOL)refresh popViewController: (BOOL)popViewController {
    [self stopRtmp];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (refresh) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.onPlayError) {
                self.onPlayError();
            }
        });
    }
    if (popViewController) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)clickScreen:(CGPoint)position {
    //todo
}

- (void)clickPlayVod {
    if (!_videoFinished) {
        if (_videoPause) {
            [_txVodPlayer resume];
            [_logicView.playBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        } else {
            [_txVodPlayer pause];
            [_logicView.playBtn setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        }
        _videoPause = !_videoPause;
    }
    else {
        [self startVodPlay];
        [_logicView.playBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
}

- (void)onSeek:(UISlider *)slider {
    [_txVodPlayer seek:_sliderValue];
    _trackingTouchTS = [[NSDate date]timeIntervalSince1970]*1000;
    _startSeek = NO;
}

- (void)onSeekBegin:(UISlider *)slider {
    _startSeek = YES;
}

- (void)onDrag:(UISlider *)slider {
    float progress = slider.value;
    int intProgress = progress + 0.5;
    _logicView.playLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",(int)intProgress / 3600,(int)(intProgress / 60), (int)(intProgress % 60)];
    _sliderValue = slider.value;
}

- (void)clickLog:(UIButton*)btn {
    if (_log_switch == YES) {
        _logicView.statusView.hidden = YES;
        _logicView.logViewEvt.hidden = YES;
        [btn setImage:[UIImage imageNamed:@"log"] forState:UIControlStateNormal];
        _logicView.cover.hidden = YES;
        _log_switch = NO;
    }
    else {
        _logicView.statusView.hidden = NO;
        _logicView.logViewEvt.hidden = NO;
        [btn setImage:[UIImage imageNamed:@"log2"] forState:UIControlStateNormal];
        _logicView.cover.alpha = 0.5;
        _logicView.cover.hidden = NO;
        _log_switch = YES;
    }
    
}

#pragma mark - TXLivePlayListener

- (void)appendLog:(NSString *)evt time:(NSDate *)date mills:(int)mil {
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"hh:mm:ss";
    NSString* time = [format stringFromDate:date];
    NSString* log = [NSString stringWithFormat:@"[%@.%-3.3d] %@", time, mil, evt];
    if (_logMsg == nil) {
        _logMsg = @"";
    }
    _logMsg = [NSString stringWithFormat:@"%@\n%@", _logMsg, log];
    [_logicView.logViewEvt setText:_logMsg];
}

#pragma mark - TXVodPlayListener
- (void)onPlayEvent:(TXVodPlayer *)player event:(int)EvtID withParam:(NSDictionary*)param {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _processPlayEvent:EvtID withParam:param];
    });
}

- (void)_processPlayEvent:(int)EvtID withParam:(NSDictionary*)dict {
    if (EvtID == PLAY_EVT_RCV_FIRST_I_FRAME) {
        if (!_isInVC) {
            self.videoIsReady();
        }
        _videoFinished = NO;
    } else if (EvtID == PLAY_EVT_PLAY_BEGIN) {
        _videoFinished = NO;
    } else if (EvtID == PLAY_EVT_PLAY_PROGRESS) {
        if (_startSeek) return;
        // 避免滑动进度条松开的瞬间可能出现滑动条瞬间跳到上一个位置
        long long curTs = [[NSDate date]timeIntervalSince1970]*1000;
        if (llabs(curTs - _trackingTouchTS) < 500) {
            return;
        }
        _trackingTouchTS = curTs;
        
        float progress = [dict[EVT_PLAY_PROGRESS] floatValue];
        int intProgress = progress + 0.5;
        _logicView.playLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",(int)(intProgress / 3600), (int)(intProgress / 60), (int)(intProgress % 60)];
        [_logicView.playProgress setValue:progress];
        
        float duration = [dict[EVT_PLAY_DURATION] floatValue];
        int intDuration = duration + 0.5;
        if (duration > 0 && _logicView.playProgress.maximumValue != duration) {
            [_logicView.playProgress setMaximumValue:duration];
            _logicView.playDuration.text = [NSString stringWithFormat:@"%02d:%02d:%02d",(int)(intDuration / 3600), (int)(intDuration / 60 % 60), (int)(intDuration % 60)];
        }
        return ;
    } else if (EvtID == PLAY_ERR_NET_DISCONNECT || EvtID == PLAY_EVT_PLAY_END) {
        [self stopRtmp];
        _videoPause  = NO;
        _videoFinished = YES;
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        [_logicView.playProgress setValue:0];
        _logicView.playLabel.text = @"00:00:00";
        
        [_logicView.playBtn setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        
    } else if (EvtID == PLAY_EVT_PLAY_LOADING){
        
    }
    
    NSLog(@"evt:%d,%@", EvtID, dict);
    long long time = [(NSNumber*)[dict valueForKey:EVT_TIME] longLongValue];
    int mil = time % 1000;
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:time/1000];
    NSString* Msg = (NSString*)[dict valueForKey:EVT_MSG];
    [self appendLog:Msg time:date mills:mil];
    [self initLogicView];
}


- (void)onNetStatus:(TXVodPlayer *)player withParam:(NSDictionary*)param {
    NSDictionary* dict = param;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        int netspeed  = [(NSNumber*)[dict valueForKey:NET_STATUS_NET_SPEED] intValue];
        int vbitrate  = [(NSNumber*)[dict valueForKey:NET_STATUS_VIDEO_BITRATE] intValue];
        int abitrate  = [(NSNumber*)[dict valueForKey:NET_STATUS_AUDIO_BITRATE] intValue];
        int cachesize = [(NSNumber*)[dict valueForKey:NET_STATUS_VIDEO_CACHE] intValue];
        int dropsize  = 0;// [(NSNumber*)[dict valueForKey:NET_STATUS_VIDEO_DROP] intValue];
        int jitter    = [(NSNumber*)[dict valueForKey:NET_STATUS_NET_JITTER] intValue];
        int fps       = [(NSNumber*)[dict valueForKey:NET_STATUS_VIDEO_FPS] intValue];
        int width     = [(NSNumber*)[dict valueForKey:NET_STATUS_VIDEO_WIDTH] intValue];
        int height    = [(NSNumber*)[dict valueForKey:NET_STATUS_VIDEO_HEIGHT] intValue];
        float cpu_usage = [(NSNumber*)[dict valueForKey:NET_STATUS_CPU_USAGE] floatValue];
        NSString *serverIP = [dict valueForKey:NET_STATUS_SERVER_IP];
        int codecCacheSize = 0;// [(NSNumber*)[dict valueForKey:NET_STATUS_AUDIO_CACHE] intValue];
        int nCodecDropCnt =  0;// [(NSNumber*)[dict valueForKey:NET_STATUS_AUDIO_DROP] intValue];
        
        NSString* log = [NSString stringWithFormat:@"CPU:%.1f%%\tRES:%d*%d\tSPD:%dkb/s\nJITT:%d\tFPS:%d\tARA:%dkb/s\nQUE:%d|%d\tDRP:%d|%d\tVRA:%dkb/s\nSVR:%@\t",
                         cpu_usage*100,
                         width,
                         height,
                         netspeed,
                         jitter,
                         fps,
                         abitrate,
                         codecCacheSize,
                         cachesize,
                         nCodecDropCnt,
                         dropsize,
                         vbitrate,
                         serverIP?:@""];
        [self->_logicView.statusView setText:log];
        if (width > height && !self->_rotate) {
            [self->_txVodPlayer setRenderRotation:HOME_ORIENTATION_RIGHT];
            self->_rotate = YES;
        }
    });
}


- (void)onRecvGroupDeleteMsg {
    [self closeVC:NO];
    if (!_isErrorAlert) {
        _isErrorAlert = YES;
        [HUDHelper alert:kErrorMsgLiveStopped cancel:@"确定" action:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}

- (void)clickRecord:(UIButton *)button {
    
}

@end

