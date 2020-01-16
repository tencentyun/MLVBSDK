
//
//  PlayViewController.m
//  RTMPiOSDemo
//
//  Created by 蓝鲸 on 16/4/1.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "PlayViewController.h"
#import "ScanQRController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <mach/mach.h>
#import "AppLogMgr.h"
#import "AFNetworkReachabilityManager.h"
#import "UIView+Additions.h"
#import "UIImage+Additions.h"
#import "TCHttpUtil.h"
#import "ZipArchive.h"
#import "AddressBarController.h"
#import "AppDelegate.h"
#import "TXLiveBase.h"

static NSString * const LIVE_URL = @"http://5815.liveplay.myqcloud.com/live/5815_89aad37e06ff11e892905cb9018cf0d4_900.flv";

#define TEST_MUTE   0

#define RTMP_URL    @"请输入或扫二维码获取播放地址"//请输入或扫二维码获取播放地址"

@interface ToastTextView : UITextView
@property (nonatomic) NSString *url;
@end

@implementation ToastTextView

- (void)setUrl:(NSString *)url {
    _url = url;
    
    NSRange r = [self.text rangeOfString:url];
    if (r.location != NSNotFound) {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:self.text];
        [str addAttribute:NSLinkAttributeName value:url range:r];
        self.attributedText = str;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject]; //assume just 1 touch
    if(touch.tapCount == 1) {
        //single tap occurred
        if (self.url) {
            UIApplication *myApp = [UIApplication sharedApplication];
            if ([myApp canOpenURL:[NSURL URLWithString:self.url]]) {
                [myApp openURL:[NSURL URLWithString:self.url]];
            }
        }
    }
}

@end


typedef NS_ENUM(NSInteger, ENUM_TYPE_CACHE_STRATEGY)
{
    CACHE_STRATEGY_FAST           = 1,  //极速
    CACHE_STRATEGY_SMOOTH         = 2,  //流畅
    CACHE_STRATEGY_AUTO           = 3,  //自动
};

#define CACHE_TIME_FAST             1.0f
#define CACHE_TIME_SMOOTH           5.0f

#define CACHE_TIME_AUTO_MIN         5.0f
#define CACHE_TIME_AUTO_MAX         10.0f

//#define PLAY_RECORD

#ifdef PLAY_RECORD
#import "LiveRecordPreviewViewController.h"
#endif

@interface PlayViewController ()<
AddressBarControllerDelegate,
UITextFieldDelegate,
#if defined(PLAY_RECORD) && !defined(DISABLE_LIVERECORD)
TXLiveRecordListener,
#endif
TXLivePlayListener,
//TXVideoPublishListener,
TXVideoCustomProcessDelegate,
ScanQRDelegate
>
@property (strong, nonatomic) AddressBarController *addressBarController;
@end

@implementation PlayViewController
{
    BOOL        _bHWDec;
    UISlider*   _playProgress;
    UISlider*   _playableProgress;
    UILabel*    _playDuration;
    UILabel*    _playStart;
    UIButton*   _btnPlayMode;
    UIButton*   _btnHWDec;
    UIButton*   _btnMute;
    long long   _trackingTouchTS;
    BOOL        _startSeek;
    BOOL        _videoPause;
    CGRect      _videoWidgetFrame; //改变videoWidget的frame时候记得对其重新进行赋值
    UIImageView * _loadingImageView;
    BOOL        _appIsInterrupt;
    float       _sliderValue;
    TX_Enum_PlayType _playType;
    long long	_startPlayTS;
    UIView *    mVideoContainer;
    NSString    *_playUrl;
    UIButton    *_btnRecordVideo;
    UIButton    *_btnRealTime;
    UILabel     *_labProgress;
    BOOL                _recordStart;
    float               _recordProgress;
//    TXPublishParam       *_publishParam;
//    TXUGCPublish         *_videoPublish;
    BOOL                _enableCache;
}

- (void)viewDidLoad {
    _recordStart = NO;
    _recordProgress = 0.f;
    
    [super viewDidLoad];
    [self initUI];
    
//    _videoPublish = [[TXUGCPublish alloc] init];
//    _videoPublish.delegate = self;
}

- (void)statusBarOrientationChanged:(NSNotification *)note  {
//    CGRect frame = self.view.frame;
//    switch ([[UIDevice currentDevice] orientation]) {
//        case UIDeviceOrientationPortrait:        //activity竖屏模式，竖屏推流
//        {
//            mVideoContainer.frame = CGRectMake(0, 0,frame.size.width,frame.size.width*9/16);
//        }
//            break;
//        case UIDeviceOrientationLandscapeRight:   //activity横屏模式，home在左横屏推流
//        {
//            mVideoContainer.frame = CGRectMake(0, 0,frame.size.width,frame.size.height);
//        }
//            break;
//        case UIDeviceOrientationLandscapeLeft:   //activity横屏模式，home在左横屏推流
//        {
//            mVideoContainer.frame = CGRectMake(0, 0,frame.size.width,frame.size.height);
//        }
//            break;
//        default:
//            break;
//    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)initUI {
    HelpBtnUI(直播播放器)
    for (UIView *view in self.view.subviews) {
        [view removeFromSuperview];
    }
//    self.wantsFullScreenLayout = YES;
    _videoWidgetFrame = [UIScreen mainScreen].bounds;
    
    [self.view setBackgroundImage:[UIImage imageNamed:@"background.jpg"]];
    
    // remove all subview
    for (UIView *view in [self.view subviews]) {
        [view removeFromSuperview];
    }
    
    CGSize size = [[UIScreen mainScreen] bounds].size;
    
    int icon_size = 46;
    
    CGFloat txtWidth = size.width- 25 - icon_size;
    int rightBtnNum = 1;
    if (_isRealtime) {
        txtWidth = size.width - 25 - icon_size * 2 - 15;
        rightBtnNum = 2;
    }
    CGFloat y = [UIApplication sharedApplication].statusBarFrame.size.height;
    y += self.navigationController.navigationBar.height+5;

    AddressBarButtonOption option = AddressBarButtonOptionQRScan;
    if (_isRealtime) {
        option |= AddressBarButtonOptionNew;
    }
    _addressBarController = [[AddressBarController alloc] initWithButtonOption: option];
    _addressBarController.delegate = self;
    _addressBarController.qrPresentView = self.view;
    _addressBarController.view.frame = CGRectMake(10, y, self.view.width-20, icon_size);
    _addressBarController.view.textField.placeholder = RTMP_URL;
    [self.view addSubview:_addressBarController.view];
    
    int icon_length = 8;
    if (self.isRealtime)
        icon_length = 7;
    
    int icon_gap = (size.width - icon_size*(icon_length-1))/icon_length;
    int hh = [[UIScreen mainScreen] bounds].size.height - icon_size - 50;
    _playStart = [[UILabel alloc]init];
    _playStart.frame = CGRectMake(20, hh, 50, 30);
    [_playStart setText:@"00:00"];
    [_playStart setTextColor:[UIColor whiteColor]];
    _playStart.hidden = YES;
    [self.view addSubview:_playStart];
    
    _playDuration = [[UILabel alloc]init];
    _playDuration.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width-70, hh, 50, 30);
    [_playDuration setText:@"00:00"];
    [_playDuration setTextColor:[UIColor whiteColor]];
    _playDuration.hidden = YES;
    [self.view addSubview:_playDuration];

    _playableProgress=[[UISlider alloc]initWithFrame:CGRectMake(70, hh-1, [[UIScreen mainScreen] bounds].size.width-132, 30)];
    _playableProgress.maximumValue = 0;
    _playableProgress.minimumValue = 0;
    _playableProgress.value = 0;
    [_playableProgress setThumbImage:[UIImage imageWithColor:[UIColor clearColor] size:CGSizeMake(20, 10)] forState:UIControlStateNormal];
    [_playableProgress setMaximumTrackTintColor:[UIColor clearColor]];
    _playableProgress.userInteractionEnabled = NO;
    _playableProgress.hidden = YES;
    
    [self.view addSubview:_playableProgress];
    
    _playProgress=[[UISlider alloc]initWithFrame:CGRectMake(70, hh, [[UIScreen mainScreen] bounds].size.width-140, 30)];
    _playProgress.maximumValue = 0;
    _playProgress.minimumValue = 0;
    _playProgress.value = 0;
    _playProgress.continuous = NO;
//    _playProgress.maximumTrackTintColor = UIColor.clearColor;
    [_playProgress addTarget:self action:@selector(onSeek:) forControlEvents:(UIControlEventValueChanged)];
    [_playProgress addTarget:self action:@selector(onSeekBegin:) forControlEvents:(UIControlEventTouchDown)];
    [_playProgress addTarget:self action:@selector(onDrag:) forControlEvents:UIControlEventTouchDragInside];
    _playProgress.hidden = YES;

    [self.view addSubview:_playProgress];
    
    int btn_index = 0;
    _play_switch = NO;
    _btnPlay = [self createBottomBtnIndex:btn_index++ Icon:@"start" Action:@selector(clickPlay:) Gap:icon_gap Size:icon_size];

    if(_playType == PLAY_TYPE_LIVE_RTMP || _playType == PLAY_TYPE_LIVE_FLV)
    {
        _btnMute = [self createBottomBtnIndexEx:5 Icon:@"mic" Action:@selector(clickMute:) Gap:icon_gap Size:icon_size];
        _btnMute.hidden = YES;
    }
    
    
    if (self.isLivePlay) {
        _btnClose = nil;
    } else {
        _btnClose = [self createBottomBtnIndex:btn_index++ Icon:@"close" Action:@selector(clickClose:) Gap:icon_gap Size:icon_size];
    }

    _log_switch = NO;
    [self createBottomBtnIndex:btn_index++ Icon:@"log" Action:@selector(clickLog:) Gap:icon_gap Size:icon_size];

    _bHWDec = NO;
    _btnHWDec = [self createBottomBtnIndex:btn_index++ Icon:@"quick2" Action:@selector(onClickHardware:) Gap:icon_gap Size:icon_size];

    _screenPortrait = NO;
    [self createBottomBtnIndex:btn_index++ Icon:@"portrait" Action:@selector(clickScreenOrientation:) Gap:icon_gap Size:icon_size];

    _renderFillScreen = NO;
    [self createBottomBtnIndex:btn_index++ Icon:@"fill" Action:@selector(clickRenderMode:) Gap:icon_gap Size:icon_size];
    
    _txLivePlayer = [[TXLivePlayer alloc] init];
#if defined(PLAY_RECORD) && !defined(DISABLE_LIVERECORD)
    _txLivePlayer.recordDelegate = self;
#endif
    
    if (!self.isLivePlay) {
        _btnCacheStrategy = nil;
    } else {
        if (!self.isRealtime) {
            _btnCacheStrategy = [self createBottomBtnIndex:btn_index++ Icon:@"cache_time" Action:@selector(onAdjustCacheStrategy:) Gap:icon_gap Size:icon_size];
            [self setCacheStrategy:CACHE_STRATEGY_AUTO];
        }
//        _helpBtn = [self createBottomBtnIndex:btn_index++ Icon:@"help.png" Action:@selector(onHelpBtnClicked) Gap:icon_gap Size:icon_size];
    }

    if (!self.isLivePlay) {
        [self createBottomBtnIndex:btn_index++ Icon:@"cache2" Action:@selector(cacheEnable:) Gap:icon_gap Size:icon_size];
    }
    
    if (self.isLivePlay) {
//        _btnRecordVideo = [self createBottomBtnIndex:btn_index++ Icon:@"video_press" Action:@selector(clickRecord) Gap:icon_gap Size:icon_size];
//        [self.view addSubview:_btnRecordVideo];
//
//        _labProgress = [[UILabel alloc]init];
//        _labProgress.frame = CGRectMake(_btnRecordVideo.left, _btnRecordVideo.top - 30 , 50, 30);
//        [_labProgress setText:@""];
//        [_labProgress setTextColor:[UIColor redColor]];
//        [self.view addSubview:_labProgress];
        _btnRealTime = [self createBottomBtnIndex:btn_index++ Icon:@"jisu_off" Action:@selector(clickReal:) Gap:icon_gap Size:icon_size];
        [self.view addSubview:_btnRealTime];
    }
    
    _videoPause = NO;
    _trackingTouchTS = 0;
    
    if (!self.isLivePlay) {
        _playStart.hidden = NO;
        _playDuration.hidden = NO;
        _playProgress.hidden = NO;
        _playableProgress.hidden = NO;
    } else {
        _playStart.hidden = YES;
        _playDuration.hidden = YES;
        _playProgress.hidden = YES;
        _playableProgress.hidden = YES;
    }
    
    //loading imageview
    float width = 34;
    float height = 34;
    float offsetX = (self.view.frame.size.width - width) / 2;
    float offsetY = (self.view.frame.size.height - height) / 2;
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:[UIImage imageNamed:@"loading_image0.png"],[UIImage imageNamed:@"loading_image1.png"],[UIImage imageNamed:@"loading_image2.png"],[UIImage imageNamed:@"loading_image3.png"],[UIImage imageNamed:@"loading_image4.png"],[UIImage imageNamed:@"loading_image5.png"],[UIImage imageNamed:@"loading_image6.png"],[UIImage imageNamed:@"loading_image7.png"], nil];
    _loadingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(offsetX, offsetY, width, height)];
    _loadingImageView.animationImages = array;
    _loadingImageView.animationDuration = 1;
    _loadingImageView.hidden = YES;
    
    _vCacheStrategy = [[UIView alloc]init];
    _vCacheStrategy.frame = CGRectMake(0, size.height-120, size.width, 120);
    [_vCacheStrategy setBackgroundColor:[UIColor whiteColor]];
    
    UILabel* title= [[UILabel alloc]init];
    title.frame = CGRectMake(0, 0, size.width, 50);
    [title setText:@"延迟调整"];
    title.textAlignment = NSTextAlignmentCenter;
    [title setFont:[UIFont fontWithName:@"" size:14]];
    
    [_vCacheStrategy addSubview:title];
    
    int gap = 30;
    int width2 = (size.width - gap*2 - 20) / 3;
    _radioBtnFast = [UIButton buttonWithType:UIButtonTypeCustom];
    _radioBtnFast.frame = CGRectMake(10, 60, width2, 40);
    [_radioBtnFast setTitle:@"极速" forState:UIControlStateNormal];
    [_radioBtnFast addTarget:self action:@selector(onAdjustFast:) forControlEvents:UIControlEventTouchUpInside];
    
    _radioBtnSmooth = [UIButton buttonWithType:UIButtonTypeCustom];
    _radioBtnSmooth.frame = CGRectMake(10 + gap + width2, 60, width2, 40);
    [_radioBtnSmooth setTitle:@"流畅" forState:UIControlStateNormal];
    [_radioBtnSmooth addTarget:self action:@selector(onAdjustSmooth:) forControlEvents:UIControlEventTouchUpInside];
    
    _radioBtnAUTO = [UIButton buttonWithType:UIButtonTypeCustom];
    _radioBtnAUTO.frame = CGRectMake(size.width - 10 - width2, 60, width2, 40);
    [_radioBtnAUTO setTitle:@"自动" forState:UIControlStateNormal];
    [_radioBtnAUTO addTarget:self action:@selector(onAdjustAuto:) forControlEvents:UIControlEventTouchUpInside];
    
    [_vCacheStrategy addSubview:_radioBtnFast];
    [_vCacheStrategy addSubview:_radioBtnSmooth];
    [_vCacheStrategy addSubview:_radioBtnAUTO];
    _vCacheStrategy.hidden = YES;
    [self.view addSubview:_vCacheStrategy];
    
    CGRect VideoFrame = self.view.bounds;
    mVideoContainer = [[UIView alloc] initWithFrame:CGRectMake(VideoFrame.size.width, 0, VideoFrame.size.width, VideoFrame.size.height)];
    [self.view insertSubview:mVideoContainer atIndex:0];
    mVideoContainer.center = self.view.center;
//    mVideoContainer.backgroundColor = UIColor.lightTextColor;
    if (self.isLivePlay) {
        self.title = @"直播播放器";
        if (self.isRealtime) {
            self.title = @"低延时播放";
        } else {
//            self.addressBarController.text = @"rtmp://live.hkstv.hk.lxdns.com/live/hks";
            self.addressBarController.text = LIVE_URL;
        }
    } else {
        self.title = @"点播播放器";
        self.addressBarController.text = @"http://200024424.vod.myqcloud.com/200024424_709ae516bdf811e6ad39991f76a4df69.f20.mp4";
    }
}

- (void)_updateTitle {
    if (self.isLivePlay) {
        self.title = self.isRealtime ? @"低延时播放" : @"直播播放器";
    } else {
        self.title = @"点播播放器";
    }
}

- (UIButton*)createBottomBtnIndex:(int)index Icon:(NSString*)icon Action:(SEL)action Gap:(int)gap Size:(int)size
{
    CGFloat offset = 0;
    if (@available(iOS 11, *)) {
        offset = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    }
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake((index+1)*gap + index*size, [[UIScreen mainScreen] bounds].size.height - size - 10 - offset, size, size);
    [btn setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    return btn;
}

- (UIButton*)createBottomBtnIndexEx:(int)index Icon:(NSString*)icon Action:(SEL)action Gap:(int)gap Size:(int)size
{
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake((index+1)*gap + index*size, [[UIScreen mainScreen] bounds].size.height - 2*(size + 10), size, size);
    [btn setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    return btn;
}

//在低系统（如7.1.2）可能收不到这个回调，请在onAppDidEnterBackGround和onAppWillEnterForeground里面处理打断逻辑
- (void) onAudioSessionEvent: (NSNotification *) notification
{
    NSDictionary *info = notification.userInfo;
    AVAudioSessionInterruptionType type = [info[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        if (_play_switch == YES && _appIsInterrupt == NO) {
//            if ([self isVODType:_playType]) {
//                if (!_videoPause) {
//                    [_txLivePlayer pause];
//                }
//            }
            _appIsInterrupt = YES;
        }
    }else{
        AVAudioSessionInterruptionOptions options = [info[AVAudioSessionInterruptionOptionKey] unsignedIntegerValue];
        if (options == AVAudioSessionInterruptionOptionShouldResume) {
            // 收到该事件不能调用resume，因为此时可能还在后台
            /*
            if (_play_switch == YES && _appIsInterrupt == YES) {
                if ([self isVODType:_playType]) {
                    if (!_videoPause) {
                        [_txLivePlayer resume];
                    }
                }
                _appIsInterrupt = NO;
            }
             */
        }
    }
}

- (void)onAppDidEnterBackGround:(UIApplication*)app {
    if (_play_switch == YES) {
        if ([self isVODType:_playType]) {
            if (!_videoPause) {
                [_txLivePlayer pause];
            }
        }
    }
}

- (void)onAppWillEnterForeground:(UIApplication*)app {
    if (_play_switch == YES) {
        if ([self isVODType:_playType]) {
            if (!_videoPause) {
                [_txLivePlayer resume];
            }
        }
    }
}

- (void)onAppDidBecomeActive:(UIApplication*)app {
    if (_play_switch == YES && _appIsInterrupt == YES) {
        if ([self isVODType:_playType]) {
            if (!_videoPause) {
                [_txLivePlayer resume];
            }
        }
        _appIsInterrupt = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (_play_switch == YES) {
        [self stopRtmp];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioSessionEvent:) name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidEnterBackGround:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma -- example code bellow
- (void)clearLog {
    _tipsMsg = @"";

    _startTime = [[NSDate date]timeIntervalSince1970]*1000;
    _lastTime = _startTime;
}

- (void)setIsRealtime:(BOOL)isRealtime
{
    if (_isRealtime == isRealtime) return;
    _isRealtime = isRealtime;
    [self _updateTitle];
}

-(BOOL)isVODType:(int)playType {
    if (playType == PLAY_TYPE_VOD_FLV || playType == PLAY_TYPE_VOD_HLS || playType == PLAY_TYPE_VOD_MP4 || playType == PLAY_TYPE_LOCAL_VIDEO) {
        return YES;
    }
    return NO;
}

-(BOOL)checkPlayUrl:(NSString*)playUrl {
    if (self.isLivePlay) {
        if (self.isRealtime) {
            _playType = PLAY_TYPE_LIVE_RTMP_ACC;
            if (!([playUrl containsString:@"txSecret"] || [playUrl containsString:@"txTime"])) {
                ToastTextView *toast = [self toastTip:@"低延时拉流地址需要防盗链签名，详情参考 https://cloud.tencent.com/document/product/454/7880#RealTimePlay"];
                toast.url = @"https://cloud.tencent.com/document/product/454/7880#RealTimePlay";
                return NO;
            }
    
        }
        else {
            if ([playUrl hasPrefix:@"rtmp:"]) {
                _playType = PLAY_TYPE_LIVE_RTMP;
            } else if (([playUrl hasPrefix:@"https:"] || [playUrl hasPrefix:@"http:"]) && ([playUrl rangeOfString:@".flv"].length > 0)) {
                _playType = PLAY_TYPE_LIVE_FLV;
            } else if (([playUrl hasPrefix:@"https:"] || [playUrl hasPrefix:@"http:"]) && [playUrl rangeOfString:@".m3u8"].length > 0) {
                _playType = PLAY_TYPE_VOD_HLS;
            } else{
                [self toastTip:@"播放地址不合法，直播目前仅支持rtmp,flv播放方式!"];
                return NO;
            }
        }
    } else {
        if ([playUrl hasPrefix:@"https:"] || [playUrl hasPrefix:@"http:"]) {
            if ([playUrl rangeOfString:@".flv"].length > 0) {
                _playType = PLAY_TYPE_VOD_FLV;
            } else if ([playUrl rangeOfString:@".m3u8"].length > 0){
                _playType= PLAY_TYPE_VOD_HLS;
            } else if ([playUrl rangeOfString:@".mp4"].length > 0){
                _playType= PLAY_TYPE_VOD_MP4;
            } else {
                [self toastTip:@"播放地址不合法，点播目前仅支持flv,hls,mp4播放方式!"];
                return NO;
            }
            
        } else {
            _playType = PLAY_TYPE_LOCAL_VIDEO;
        }
    }
    
    return YES;
}
-(BOOL)startRtmp{
    CGRect frame = CGRectMake(self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    mVideoContainer.frame = frame;
    [_loadingImageView removeFromSuperview];
    NSString* playUrl = self.addressBarController.text;
    
    if (![self checkPlayUrl:playUrl]) {
        return NO;
    }
    
//    [self clearLog];
    
    // arvinwu add. 增加播放按钮事件的时间打印。
    unsigned long long recordTime = [[NSDate date] timeIntervalSince1970]*1000;
    int mil = recordTime%1000;
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"hh:mm:ss";
    NSString* time = [format stringFromDate:[NSDate date]];
    NSString* log = [NSString stringWithFormat:@"[%@.%-3.3d] 点击播放按钮", time, mil];
    
    NSString *ver = [TXLiveBase getSDKVersionStr];
    _logMsg = [NSString stringWithFormat:@"liteav sdk version: %@\n%@", ver, log];
//    [_logViewEvt setText:_logMsg];

    
    if(_txLivePlayer != nil)
    {
        _txLivePlayer.delegate = self;
//        _txLivePlayer.recordDelegate = self;
//        _txLivePlayer.videoProcessDelegate = self;
        if (self.isLivePlay) {
            [_txLivePlayer setupVideoWidget:CGRectMake(0, 0, 0, 0) containView:mVideoContainer insertIndex:0];
        }
        
        if (_config == nil)
        {
            _config = [[TXLivePlayConfig alloc] init];
        }
        
        if (_enableCache) {
            _config.cacheFolderPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            _config.maxCacheItems = 2;
            
        } else {
            _config.cacheFolderPath = nil;
        }
        _config.playerPixelFormatType = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
//        _config.headers = @{@"Referer": @"qcloud.com"};
        [_txLivePlayer setConfig:_config];
        
        //设置播放器缓存策略
        //这里将播放器的策略设置为自动调整，调整的范围设定为1到4s，您也可以通过setCacheTime将播放器策略设置为采用
        //固定缓存时间。如果您什么都不调用，播放器将采用默认的策略（默认策略为自动调整，调整范围为1到4s）
        //[_txLivePlayer setCacheTime:5];
        //[_txLivePlayer setMinCacheTime:1];
        //[_txLivePlayer setMaxCacheTime:4];
//        _txLivePlayer.isAutoPlay = NO;
//        [_txLivePlayer setRate:1.5];
//        [_txLivePlayer setMute:YES];
//        NSURL *MyURL = [[NSBundle mainBundle]
//                        URLForResource: @"goodluck" withExtension:@"mp4"];
//        int result = [_txLivePlayer startPlay:[MyURL relativePath] type:PLAY_TYPE_LOCAL_VIDEO];
        int result = [_txLivePlayer startPlay:playUrl type:_playType];
        [_txLivePlayer showVideoDebugLog:_log_switch];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
            [UIView animateWithDuration:0.4 animations:^{
                mVideoContainer.frame = frame;
            } completion:^(BOOL finished) {
                [self.view addSubview:_loadingImageView];
            }];
//        });


        if( result != 0)
        {
            NSLog(@"播放器启动失败");
            return NO;
        }
        
        if (_screenPortrait) {
            [_txLivePlayer setRenderRotation:HOME_ORIENTATION_RIGHT];
        } else {
            [_txLivePlayer setRenderRotation:HOME_ORIENTATION_DOWN];
        }
        if (_renderFillScreen) {
            [_txLivePlayer setRenderMode:RENDER_MODE_FILL_SCREEN];
        } else {
            [_txLivePlayer setRenderMode:RENDER_MODE_FILL_EDGE];
        }
        
        [self startLoadingAnimation];
        
        _videoPause = NO;
        [_btnPlay setImage:[UIImage imageNamed:@"suspend"] forState:UIControlStateNormal];
    }
    [self startLoadingAnimation];
    _startPlayTS = [[NSDate date]timeIntervalSince1970]*1000;
    
    _playUrl = playUrl;
    
    return YES;
}


- (void)stopRtmp{
    _playUrl = @"";
    [self stopLoadingAnimation];
    if(_txLivePlayer != nil)
    {
        [_txLivePlayer stopPlay];
        [_btnMute setImage:[UIImage imageNamed:@"mic"] forState:UIControlStateNormal];
        [_btnMute setHighlighted:NO];
        [_txLivePlayer removeVideoWidget];
        _txLivePlayer.delegate = nil;
    }
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:nil];
}

#pragma - ui event response.
- (void) clickPlay:(UIButton*) sender {
    //-[UIApplication setIdleTimerDisabled:]用于控制自动锁屏，SDK内部并无修改系统锁屏的逻辑
    if (_play_switch == YES)
    {
        if ([self isVODType:_playType]) {
            if (_videoPause) {
                [_txLivePlayer resume];
                [sender setImage:[UIImage imageNamed:@"suspend"] forState:UIControlStateNormal];
                [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            } else {
                [_txLivePlayer pause];
                [sender setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
                [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            }
            _videoPause = !_videoPause;
            
            
        } else {
            _play_switch = NO;
            [self stopRtmp];
            [sender setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
        }
        
    }
    else
    {
        if (![self startRtmp]) {
            return;
        }
        
        [sender setImage:[UIImage imageNamed:@"suspend"] forState:UIControlStateNormal];
        _play_switch = YES;
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
#if defined(PLAY_RECORD) && !defined(DISABLE_LIVERECORD)
    if (_recordStart) {
        _recordStart = !_recordStart;
        [_btnRecordVideo setImage:[UIImage imageNamed:@"video_press"] forState:UIControlStateNormal];
        _labProgress.text = @"";
        [_txLivePlayer stopRecord];
    }
#endif
}

- (void)clickRecord
{
#if defined(PLAY_RECORD) && !defined(DISABLE_LIVERECORD)
    if (!_play_switch) return;
    _recordStart = !_recordStart;
    if (!_recordStart) {
        [_btnRecordVideo setImage:[UIImage imageNamed:@"video_press"] forState:UIControlStateNormal];
        _labProgress.text = @"";
        [_txLivePlayer stopRecord];
    } else {
        [_btnRecordVideo setImage:[UIImage imageNamed:@"suspend"] forState:UIControlStateNormal];
        [self performSelector:@selector(startRecord) withObject:nil afterDelay:1.0];
    }
#endif
}

-(void)startRecord{
#if defined(PLAY_RECORD) && !defined(DISABLE_LIVERECORD)
    [_txLivePlayer startRecord:RECORD_TYPE_STREAM_SOURCE];
#endif
}

#if defined(PLAY_RECORD) && !defined(DISABLE_LIVERECORD)
#pragma mark - TXLiveRecordListener
-(void) onRecordProgress:(NSInteger)milliSecond
{
    _labProgress.text = [NSString stringWithFormat:@"%.2f",milliSecond / 1000.0];
}

-(void) onRecordComplete:(TXRecordResult*)result
{
    if(result == nil || result.retCode != 0)
    {
        NSLog(@"Error, record failed:%ld %@", (long)result.retCode, result.descMsg);
        [self toastTip:[NSString stringWithFormat:@"录制失败!![%ld]", (long)result.retCode]];
        return;
    }
    LiveRecordPreviewViewController* vc = [[LiveRecordPreviewViewController alloc] initWithCoverImage:result.coverImage videoPath:result.videoPath renderMode:RENDER_MODE_FILL_EDGE isFromRecord:NO];
    if (_play_switch){
        [self clickClose:nil];
    }
    [self.navigationController presentViewController:vc animated:YES completion:^{
        //to do
    }];
}
#endif

- (void)clickClose:(UIButton*)sender {
    if (_play_switch) {
        _play_switch = NO;
        [self stopRtmp];
        [_btnPlay setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
        _playStart.text = @"00:00";
        [_playDuration setText:@"00:00"];
        [_playProgress setValue:0];
        [_playProgress setMaximumValue:0];
        [_playableProgress setValue:0];
        [_playableProgress setMaximumValue:0];
        
        [_btnRecordVideo setImage:[UIImage imageNamed:@"video_press"] forState:UIControlStateNormal];
        _labProgress.text = @"";
    }
}

- (void) clickLog:(UIButton*) sender {
    if (_log_switch) {
        [sender setImage:[UIImage imageNamed:@"log"] forState:UIControlStateNormal];
    } else {
        [sender setImage:[UIImage imageNamed:@"log2"] forState:UIControlStateNormal];
        
    }
    _log_switch = !_log_switch;
    [_txLivePlayer setLogViewMargin:UIEdgeInsetsMake(120, 10, 60, 10)];
    [_txLivePlayer showVideoDebugLog:_log_switch];
    
//    if (_log_switch == YES)
//    {
//        _statusView.hidden = YES;
//        _logViewEvt.hidden = YES;
//        [sender setImage:[UIImage imageNamed:@"log"] forState:UIControlStateNormal];
//        _cover.hidden = YES;
//        _log_switch = NO;
//    }
//    else
//    {
//        _statusView.hidden = NO;
//        _logViewEvt.hidden = NO;
//        [sender setImage:[UIImage imageNamed:@"log2"] forState:UIControlStateNormal];
//        _cover.hidden = NO;
//        _log_switch = YES;
//    }
    
    [_txLivePlayer snapshot:^(UIImage *img) {
        img = img;
    }];
}

- (void) clickScreenOrientation:(UIButton*) sender {
    _screenPortrait = !_screenPortrait;
    
    if (_screenPortrait) {
        [sender setImage:[UIImage imageNamed:@"landscape"] forState:UIControlStateNormal];
        [_txLivePlayer setRenderRotation:HOME_ORIENTATION_RIGHT];
    } else {
        [sender setImage:[UIImage imageNamed:@"portrait"] forState:UIControlStateNormal];
        [_txLivePlayer setRenderRotation:HOME_ORIENTATION_DOWN];
    }
}

- (void) clickRenderMode:(UIButton*) sender {
    _renderFillScreen = !_renderFillScreen;
    
    if (_renderFillScreen) {
        [sender setImage:[UIImage imageNamed:@"adjust"] forState:UIControlStateNormal];
        [_txLivePlayer setRenderMode:RENDER_MODE_FILL_SCREEN];
    } else {
        [sender setImage:[UIImage imageNamed:@"fill"] forState:UIControlStateNormal];
        [_txLivePlayer setRenderMode:RENDER_MODE_FILL_EDGE];
    }
}

- (void)onHelpBtnClicked
{
    NSURL* helpURL = nil;
    if (_isRealtime) {
        helpURL = [NSURL URLWithString:@"https://cloud.tencent.com/document/product/454/7880#RealTimePlay"];
    } else {
        helpURL = [NSURL URLWithString:@"https://cloud.tencent.com/document/product/454/7880"];
    }
    
    UIApplication* myApp = [UIApplication sharedApplication];
    if ([myApp canOpenURL:helpURL]) {
        [myApp openURL:helpURL];
    }
}

- (void)clickMute:(UIButton*)sender
{
    if (sender.isSelected) {
        [_txLivePlayer setMute:NO];
        [sender setSelected:NO];
        [sender setImage:[UIImage imageNamed:@"mic"] forState:UIControlStateNormal];
    }
    else {
        [_txLivePlayer setMute:YES];
        [sender setSelected:YES];
        [sender setImage:[UIImage imageNamed:@"vodplay"] forState:UIControlStateNormal];
    }
}

- (void) setCacheStrategy:(NSInteger) nCacheStrategy
{
    if (_btnCacheStrategy == nil || _cacheStrategy == nCacheStrategy)    return;
    
    if (_config == nil)
    {
        _config = [[TXLivePlayConfig alloc] init];
    }
    
    _cacheStrategy = nCacheStrategy;
    switch (_cacheStrategy) {
        case CACHE_STRATEGY_FAST:
            _config.bAutoAdjustCacheTime = YES;
            _config.minAutoAdjustCacheTime = CACHE_TIME_FAST;
            _config.maxAutoAdjustCacheTime = CACHE_TIME_FAST;
            [_txLivePlayer setConfig:_config];
            break;
            
        case CACHE_STRATEGY_SMOOTH:
            _config.bAutoAdjustCacheTime = NO;
            _config.minAutoAdjustCacheTime = CACHE_TIME_SMOOTH;
            _config.maxAutoAdjustCacheTime = CACHE_TIME_SMOOTH;
            [_txLivePlayer setConfig:_config];
            break;
            
        case CACHE_STRATEGY_AUTO:
            _config.bAutoAdjustCacheTime = YES;
            _config.minAutoAdjustCacheTime = CACHE_TIME_FAST;
            _config.maxAutoAdjustCacheTime = CACHE_TIME_SMOOTH;
            [_txLivePlayer setConfig:_config];
            break;
            
        default:
            break;
    }
}

- (void) onAdjustCacheStrategy:(UIButton*) sender
{
#if TEST_MUTE
    static BOOL flag = YES;
    [_txLivePlayer setMute:flag];
    flag = !flag;
#else
    _vCacheStrategy.hidden = NO;
    switch (_cacheStrategy) {
        case CACHE_STRATEGY_FAST:
            [_radioBtnFast setBackgroundImage:[UIImage imageNamed:@"black"] forState:UIControlStateNormal];
            [_radioBtnFast setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_radioBtnSmooth setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnSmooth setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnAUTO setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnAUTO setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            break;
            
        case CACHE_STRATEGY_SMOOTH:
            [_radioBtnFast setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnFast setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnSmooth setBackgroundImage:[UIImage imageNamed:@"black"] forState:UIControlStateNormal];
            [_radioBtnSmooth setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_radioBtnAUTO setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnAUTO setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            break;
            
        case CACHE_STRATEGY_AUTO:
            [_radioBtnFast setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnFast setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnSmooth setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnSmooth setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnAUTO setBackgroundImage:[UIImage imageNamed:@"black"] forState:UIControlStateNormal];
            [_radioBtnAUTO setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
#endif
}

- (void) onAdjustFast:(UIButton*) sender
{
    _vCacheStrategy.hidden = YES;
    [self setCacheStrategy:CACHE_STRATEGY_FAST];
}

- (void) onAdjustSmooth:(UIButton*) sender
{
    _vCacheStrategy.hidden = YES;
    [self setCacheStrategy:CACHE_STRATEGY_SMOOTH];
}

- (void) onAdjustAuto:(UIButton*) sender
{
    _vCacheStrategy.hidden = YES;
    [self setCacheStrategy:CACHE_STRATEGY_AUTO];
}

- (void) onClickHardware:(UIButton*) sender {
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        [self toastTip:@"iOS 版本低于8.0，不支持硬件加速."];
        return;
    }
    
    if (_play_switch == YES)
    {
        [self stopRtmp];
    }

    _txLivePlayer.enableHWAcceleration = !_bHWDec;
    
    _bHWDec = _txLivePlayer.enableHWAcceleration;
    
    if(_bHWDec)
    {
        [sender setImage:[UIImage imageNamed:@"quick"] forState:UIControlStateNormal];
    }
    else
    {
        [sender setImage:[UIImage imageNamed:@"quick2"] forState:UIControlStateNormal];
    }
    
    if (_play_switch == YES) {
        if (_bHWDec) {
            
            [self toastTip:@"切换为硬解码. 重启播放流程"];
        }
        else
        {
            [self toastTip:@"切换为软解码. 重启播放流程"];
            
        }

        [self startRtmp];
    }

}

- (void)addressBarControllerTapScanQR:(AddressBarController *)controller {
    [self stopRtmp];
    _play_switch = NO;
    [_btnPlay setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
    ScanQRController* vc = [[ScanQRController alloc] init];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:NO];
}

- (void)addressBarControllerTapCreateURL:(AddressBarController *)controller {
    __weak PlayViewController* weakSelf = self;
    if (_isRealtime) {
        [TCHttpUtil asyncSendHttpRequest:@"get_test_rtmpaccurl" httpServerAddr:kHttpServerAddr HTTPMethod:@"GET" param:nil handler:^(int result, NSDictionary *resultDict) {
            if (result != 0) {
                [weakSelf toastTip:@"获取低延时播放地址失败"];
            }
            else {
                NSString* playUrl = nil;
                if (resultDict)
                {
                    playUrl = resultDict[@"url_rtmpacc"];
                }
                controller.text = playUrl;
                [weakSelf toastTip:@"测试地址的影像来自在线UTC时间的录屏推流，推流工具采用移动直播 Windows SDK + VCam"];
            }
        }];
    }
}

#pragma -- UISlider - play seek
-(void)onSeek:(UISlider *)slider{
#ifndef DISABLE_VOD
    [_txLivePlayer seek:_sliderValue];
#endif
    _trackingTouchTS = [[NSDate date]timeIntervalSince1970]*1000;
    _startSeek = NO;
    NSLog(@"vod seek drag end");
}

-(void)onSeekBegin:(UISlider *)slider{
    _startSeek = YES;
    NSLog(@"vod seek drag begin");
}

-(void)onDrag:(UISlider *)slider {
    float progress = slider.value;
    int intProgress = progress + 0.5;
    _playStart.text = [NSString stringWithFormat:@"%02d:%02d",(int)(intProgress / 60), (int)(intProgress % 60)];
    _sliderValue = slider.value;
}

#pragma -- UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    _vCacheStrategy.hidden = YES;
}


#pragma mark -- ScanQRDelegate
- (void)onScanResult:(NSString *)result
{
    self.addressBarController.text = result;
}

- (void)cacheEnable:(id)sender {
    _enableCache = !_enableCache;
    if (_enableCache) {
        [sender setImage:[UIImage imageNamed:@"cache"] forState:UIControlStateNormal];
    } else {
        [sender setImage:[UIImage imageNamed:@"cache2"] forState:UIControlStateNormal];
    }
}
- (void)clickReal:(UIButton *)sender {
    self.isRealtime = !self.isRealtime;
    if (self.isRealtime) {
        [sender setImage:[UIImage imageNamed:@"jisu_on"] forState:UIControlStateNormal];
        [self addressBarControllerTapCreateURL:_addressBarController];
    } else {
        [sender setImage:[UIImage imageNamed:@"jisu_off"] forState:UIControlStateNormal];
        self.addressBarController.text = LIVE_URL;
    }
}
/**
 @method 获取指定宽度width的字符串在UITextView上的高度
 @param textView 待计算的UITextView
 @param width 限制字符串显示区域的宽度
 @result float 返回的高度
 */
- (float) heightForString:(UITextView *)textView andWidth:(float)width{
    CGSize sizeToFit = [textView sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    return sizeToFit.height + 10;
}

- (ToastTextView *) toastTip:(NSString*)toastInfo
{
    CGRect frameRC = [[UIScreen mainScreen] bounds];
    frameRC.origin.y = frameRC.size.height - 110;
    frameRC.size.height -= 110;
    __block ToastTextView * toastView = [[ToastTextView alloc] init];
    
    toastView.editable = NO;
    toastView.selectable = NO;
    
    frameRC.size.height = [self heightForString:toastView andWidth:frameRC.size.width];
    
    toastView.frame = frameRC;
    
    toastView.text = toastInfo;
    toastView.backgroundColor = [UIColor whiteColor];
    toastView.alpha = 0.5;
    
    [self.view addSubview:toastView];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(){
        [toastView removeFromSuperview];
        toastView = nil;
    });
    return toastView;
}

#pragma ###TXLivePlayListener

-(void) onPlayEvent:(int)EvtID withParam:(NSDictionary*)param
{
    NSDictionary* dict = param;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (EvtID == PLAY_EVT_RCV_FIRST_I_FRAME) {
//            _publishParam = nil;
        }
        
        if (EvtID == PLAY_EVT_PLAY_BEGIN) {
            [self stopLoadingAnimation];
            long long playDelay = [[NSDate date]timeIntervalSince1970]*1000 - _startPlayTS;
            AppDemoLog(@"AutoMonitor:PlayFirstRender,cost=%lld", playDelay);
        } else if (EvtID == PLAY_EVT_PLAY_PROGRESS) {
            if (_startSeek) {
                return;
            }
            // 避免滑动进度条松开的瞬间可能出现滑动条瞬间跳到上一个位置
            long long curTs = [[NSDate date]timeIntervalSince1970]*1000;
            if (llabs(curTs - _trackingTouchTS) < 500) {
                return;
            }
            _trackingTouchTS = curTs;
            
            float progress = [dict[EVT_PLAY_PROGRESS] floatValue];
            float duration = [dict[EVT_PLAY_DURATION] floatValue];
            
            int intProgress = progress + 0.5;
            _playStart.text = [NSString stringWithFormat:@"%02d:%02d", (int)(intProgress / 60), (int)(intProgress % 60)];
            [_playProgress setValue:progress];
            
            int intDuration = duration + 0.5;
            if (duration > 0 && _playProgress.maximumValue != duration) {
                [_playProgress setMaximumValue:duration];
                [_playableProgress setMaximumValue:duration];
                _playDuration.text = [NSString stringWithFormat:@"%02d:%02d", (int)(intDuration / 60), (int)(intDuration % 60)];
            }
            
            [_playableProgress setValue:[dict[EVT_PLAYABLE_DURATION] floatValue]];
            return ;
        } else if (EvtID == PLAY_ERR_NET_DISCONNECT || EvtID == PLAY_EVT_PLAY_END) {
            [self stopRtmp];
            _play_switch = NO;
            [_btnPlay setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            [_playProgress setValue:0];
             _playStart.text = @"00:00";
            _videoPause = NO;
            
            if (EvtID == PLAY_ERR_NET_DISCONNECT) {
                NSString* Msg = (NSString*)[dict valueForKey:EVT_MSG];
                [self toastTip:Msg];
            }
            
        } else if (EvtID == PLAY_EVT_PLAY_LOADING){
            [self startLoadingAnimation];
        }
        else if (EvtID == PLAY_EVT_CONNECT_SUCC) {
            BOOL isWifi = [AFNetworkReachabilityManager sharedManager].reachableViaWiFi;
            if (!isWifi) {
                __weak __typeof(self) weakSelf = self;
                [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
                    if (_playUrl.length == 0) {
                        return;
                    }
                    if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                                       message:@"您要切换到Wifi再观看吗?"
                                                                                preferredStyle:UIAlertControllerStyleAlert];
                        [alert addAction:[UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [alert dismissViewControllerAnimated:YES completion:nil];
                            [weakSelf stopRtmp];
                            [weakSelf startRtmp];
                        }]];
                        [alert addAction:[UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                            [alert dismissViewControllerAnimated:YES completion:nil];
                        }]];
                        [weakSelf presentViewController:alert animated:YES completion:nil];
                    }
                }];
            }
        }else if (EvtID == PLAY_EVT_CHANGE_ROTATION) {
            return;
        }
//        NSLog(@"evt:%d,%@", EvtID, dict);
        long long time = [(NSNumber*)[dict valueForKey:EVT_TIME] longLongValue];
        int mil = time % 1000;
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:time/1000];
        NSString* Msg = (NSString*)[dict valueForKey:EVT_MSG];
    });
}

-(void) onNetStatus:(NSDictionary*) param
{
    NSDictionary* dict = param;

    dispatch_async(dispatch_get_main_queue(), ^{
        int netspeed  = [(NSNumber*)[dict valueForKey:NET_STATUS_NET_SPEED] intValue];
        int vbitrate  = [(NSNumber*)[dict valueForKey:NET_STATUS_VIDEO_BITRATE] intValue];
        int abitrate  = [(NSNumber*)[dict valueForKey:NET_STATUS_AUDIO_BITRATE] intValue];
        int cachesize = [(NSNumber*)[dict valueForKey:NET_STATUS_CACHE_SIZE] intValue];
        int dropsize  = [(NSNumber*)[dict valueForKey:NET_STATUS_DROP_SIZE] intValue];
        int jitter    = [(NSNumber*)[dict valueForKey:NET_STATUS_NET_JITTER] intValue];
        int fps       = [(NSNumber*)[dict valueForKey:NET_STATUS_VIDEO_FPS] intValue];
        int width     = [(NSNumber*)[dict valueForKey:NET_STATUS_VIDEO_WIDTH] intValue];
        int height    = [(NSNumber*)[dict valueForKey:NET_STATUS_VIDEO_HEIGHT] intValue];
        float cpu_usage = [(NSNumber*)[dict valueForKey:NET_STATUS_CPU_USAGE] floatValue];
        float cpu_app_usage = [(NSNumber*)[dict valueForKey:NET_STATUS_CPU_USAGE_D] floatValue];
        NSString *serverIP = [dict valueForKey:NET_STATUS_SERVER_IP];
        int codecCacheSize = [(NSNumber*)[dict valueForKey:NET_STATUS_CODEC_CACHE] intValue];
        int nCodecDropCnt = [(NSNumber*)[dict valueForKey:NET_STATUS_CODEC_DROP_CNT] intValue];
        int nCahcedSize = [(NSNumber*)[dict valueForKey:NET_STATUS_CACHE_SIZE] intValue]/1000;
        int nSetVideoBitrate = [(NSNumber *) [dict valueForKey:NET_STATUS_SET_VIDEO_BITRATE] intValue];
        int videoCacheSize = [(NSNumber *) [dict valueForKey:NET_STATUS_VIDEO_CACHE_SIZE] intValue];
        int vDecCacheSize = [(NSNumber *) [dict valueForKey:NET_STATUS_V_DEC_CACHE_SIZE] intValue];
        int playInterval = [(NSNumber *) [dict valueForKey:NET_STATUS_AV_PLAY_INTERVAL] intValue];
        int avRecvInterval = [(NSNumber *) [dict valueForKey:NET_STATUS_AV_RECV_INTERVAL] intValue];
        float audioPlaySpeed = [(NSNumber *) [dict valueForKey:NET_STATUS_AUDIO_PLAY_SPEED] floatValue];
        NSString * audioInfo = [dict valueForKey:NET_STATUS_AUDIO_INFO];
        int videoGop = (int)([(NSNumber *) [dict valueForKey:NET_STATUS_VIDEO_GOP] doubleValue]+0.5f);
        NSString* log = [NSString stringWithFormat:@"CPU:%.1f%%|%.1f%%\tRES:%d*%d\tSPD:%dkb/s\nJITT:%d\tFPS:%d\tGOP:%ds\tARA:%dkb/s\nQUE:%d|%d,%d,%d|%d,%d,%0.1f\tVRA:%dkb/s\nSVR:%@\tAUDIO:%@",
                        cpu_app_usage*100,
                         cpu_usage*100,
                         width,
                         height,
                         netspeed,
                         jitter,
                         fps,
                         videoGop,
                         abitrate,
                         codecCacheSize,
                         cachesize,
                         videoCacheSize,
                         vDecCacheSize,
                         avRecvInterval,
                         playInterval,
                         audioPlaySpeed,
                         vbitrate,
                         serverIP,
                         audioInfo];
        AppDemoLogOnlyFile(@"Current status, VideoBitrate:%d, AudioBitrate:%d, FPS:%d, RES:%d*%d, netspeed:%d", vbitrate, abitrate, fps, width, height, netspeed);
    });
}

-(void) startLoadingAnimation
{
    if (_loadingImageView != nil) {
        _loadingImageView.hidden = NO;
        [_loadingImageView startAnimating];
    }
}

-(void) stopLoadingAnimation
{
    if (_loadingImageView != nil) {
        _loadingImageView.hidden = YES;
        [_loadingImageView stopAnimating];
    }
}

- (BOOL)onPlayerPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    return NO;
}
@end
