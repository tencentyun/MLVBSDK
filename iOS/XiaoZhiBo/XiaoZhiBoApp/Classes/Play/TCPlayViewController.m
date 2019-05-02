//
//  PlayController.m
//  RTMPiOSDemo
//
//  Created by 蓝鲸 on 16/4/1.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "TCPlayViewController.h"
#import "TCPushViewController.h"
#import <mach/mach.h>
#import <UIImageView+WebCache.h>
#import "TCBaseAppDelegate.h"
#import "TCMsgModel.h"
#import "TCConstants.h"
#import "TCLoginModel.h"
#import "NSString+Common.h"
#import "TCSmallPlayer.h"
#import "UIView+Additions.h"
#import "HUDHelper.h"
#import <Masonry/Masonry.h>

#define RTMP_URL    @"请输入或扫二维码获取播放地址"
#define VIDEO_VIEW_WIDTH            100
#define VIDEO_VIEW_HEIGHT           150
#define VIDEO_VIEW_MARGIN_BOTTOM    56
#define VIDEO_VIEW_MARGIN_RIGHT     8

@implementation TCPlayViewController
{

    TX_Enum_PlayType     _playType;
    
    long long            _trackingTouchTS;
    BOOL                 _startSeek;
    BOOL                 _videoPause;
    BOOL                 _videoFinished;
    float                _sliderValue;
    BOOL                 _isLivePlay;
    BOOL                 _isInVC;
    NSString             *_rtmpUrl;
    
    UIView               *_videoParentView;

    BOOL                 _isNotifiedEnterGroup;
    BOOL                  _rotate;
    BOOL                 _isErrorAlert; //是否已经弹出了错误提示框，用于保证在同时收到多个错误通知时，只弹一个错误提示框
    
//    BOOL                _isResetVideoRecord;
    
    //link mic
    BOOL                    _isBeingLinkMic;
    BOOL                    _isWaitingResponse;
    
    UITextView *            _waitingNotice;
    UIButton*               _btnCamera;
    UIButton*               _btnLinkMic;
    
    NSMutableArray*         _playItems;         //小画面播放列表
    
    int                     _errorCode;
    NSString *              _errorMsg;
    
    uint64_t                _beginTime;
    uint64_t                _endTime;
}
-(id)initWithPlayInfo:(TCLiveInfo *)info  videoIsReady:(videoIsReadyBlock)videoIsReady
{
    self = [super init];
    if (self) {
        _liveInfo = info;
        _videoIsReady = videoIsReady;
        _videoPause   = NO;
        _videoFinished = YES;
        _isInVC       = NO;
        _log_switch   = NO;
        _errorCode    = 0;
        _errorMsg     = @"";
        
        if (self.liveInfo.type == TCLiveListItemType_Live) {
            _isLivePlay = YES;
        }else{
            _isLivePlay = NO;
        }
        
        if (self.liveInfo.type == TCLiveListItemType_Record) {
            _rtmpUrl      = self.liveInfo.hls_play_url;
        } else {
            _rtmpUrl      = self.liveInfo.playurl;
        }
        if ([_rtmpUrl hasPrefix:@"http:"]) {
            _rtmpUrl = [_rtmpUrl stringByReplacingOccurrencesOfString:@"http:" withString:@"https:"];
        }
        _rotate       = NO;
        _isNotifiedEnterGroup = NO;
        _isErrorAlert = NO;
//        _isResetVideoRecord = NO;
        
        //link mic
        _isBeingLinkMic = false;
        _isWaitingResponse = false;
        self.liveRoom = [MLVBLiveRoom sharedInstance];
        [self.liveRoom setCameraMuteImage:[UIImage imageNamed:@"pause_publish.jpg"]];
        self.liveRoom.delegate = self;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}


- (void)onAppWillResignActive:(NSNotification*)notification
{
    if (_isBeingLinkMic) {
    }
}

- (void)onAppDidBecomeActive:(NSNotification*)notification
{
    if (_isBeingLinkMic) {
    }
}

- (void)onAppDidEnterBackGround:(UIApplication*)app {
    if (_isBeingLinkMic) {
        
    }
}

- (void)onAppWillEnterForeground:(UIApplication*)app{
    if (_isBeingLinkMic) {
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [self startRtmp];
    _isInVC = YES;
    if (_errorCode != 0) {
        [self onError:_errorCode errMsg:_errorMsg extraInfo:nil];
        _errorCode = 0;
        _errorMsg  = @"";
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self stopRtmp];
    _isInVC = NO;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    //加载背景图
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
    
    [self initLogicView];
    _beginTime = [[NSDate date] timeIntervalSince1970];
}

- (void)viewDidDisappear:(BOOL)animated {
    _endTime = [[NSDate date] timeIntervalSince1970];
    [TCUtil report:xiaozhibo_live_play_duration userName:nil code:_endTime - _beginTime msg:@"直播播放时长"];
}

- (void)initLogicView {
    if (!_logicView) {
        CGFloat bottom = 0;
        if (@available(iOS 11, *)) {
            bottom = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
        }
        CGRect frame = self.view.frame;
        frame.size.height -= bottom;
        _logicView = [[TCPlayDecorateView alloc] initWithFrame:frame liveInfo:self.liveInfo withLinkMic: YES];
        _logicView.delegate = self;
        
        [self.view addSubview:_logicView];
        
        if (_liveInfo.type == TCLiveListItemType_Live) {
            if (_btnLinkMic == nil) {
                if (_logicView.btnShare != nil) {
                    int   icon_size = BOTTOM_BTN_ICON_WIDTH;
                    float startSpace = 15;
                    
                    float icon_count = 8;
                    float icon_center_interval = (_logicView.width - 2*startSpace - icon_size)/(icon_count - 1);
                    float icon_center_y = _logicView.height - icon_size/2 - startSpace;
                    
                    //Button: 发起连麦
                    _btnLinkMic = [UIButton buttonWithType:UIButtonTypeCustom];
                    _btnLinkMic.center = CGPointMake(_logicView.closeBtn.center.x - icon_center_interval, icon_center_y);
                    [_btnLinkMic setImage:[UIImage imageNamed:@"linkmic_on"] forState:UIControlStateNormal];
                    [_btnLinkMic addTarget:self action:@selector(clickBtnLinkMic:) forControlEvents:UIControlEventTouchUpInside];
                    [_logicView addSubview:_btnLinkMic];
                    [_btnLinkMic mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.right.equalTo(self->_logicView.closeBtn.mas_left).offset(-icon_center_interval*2-icon_size);
                        make.centerY.equalTo(self->_logicView.closeBtn);
                    }];
                    
                    
                    //Button: 前置后置摄像头切换
                    CGRect rectBtnLinkMic = _btnLinkMic.frame;
                    _btnCamera = [UIButton buttonWithType:UIButtonTypeCustom];
                    _btnCamera.center = CGPointMake(_btnLinkMic.center.x - icon_center_interval, icon_center_y);
                    _btnCamera.bounds = CGRectMake(0, 0, CGRectGetWidth(rectBtnLinkMic), CGRectGetHeight(rectBtnLinkMic));
                    [_btnCamera setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
                    [_btnCamera addTarget:self action:@selector(clickBtnCamera:) forControlEvents:UIControlEventTouchUpInside];
                    _btnCamera.hidden = YES;
                    [_logicView addSubview:_btnCamera];
                }
            }
            
            //初始化连麦播放小窗口
            if (_playItems == nil) {
                _playItems = [NSMutableArray new];
                [self initPlayItem:1];
                [self initPlayItem:2];
                [self initPlayItem:3];
            }
            
            //logicView不能被连麦小窗口挡住
            [self.logicView removeFromSuperview];
            [self.view addSubview:self.logicView];
            
            //初始化连麦播放小窗口里的logView
            for (TCSmallPlayer * item in _playItems) {
                if (item.logView == nil) {
                    UIView * logView = [[UIView alloc] initWithFrame:item.videoView.frame];
                    logView.backgroundColor = [UIColor clearColor];
                    logView.hidden = YES;
                    logView.backgroundColor = [UIColor whiteColor];
                    logView.alpha  = 0.5;
                    [self.view addSubview:logView];
                    item.logView = logView;
                }
            }
        }
    }
}

- (void)initRoomLogic {
    [_liveRoom enterRoom:self.liveInfo.groupid view:_videoParentView completion:^(int errCode, NSString *errMsg) {
        NSLog(@"enterRoom: errCode[%d] errMsg[%@]", errCode, errMsg);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (errCode == 0) {
                NSLog(@"连接成功");
                //先获取房间的成员列表
                [self->_liveRoom getAudienceList:self.liveInfo.groupid completion:^(int errCode, NSString *errMsg, NSArray<MLVBAudienceInfo *> *audienceInfoArray) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self->_logicView initAudienceList:audienceInfoArray];
                    });
                }];

                [self.liveRoom sendRoomCustomMsg:[@(TCMsgModelType_MemberEnterRoom) stringValue] msg:nil completion:nil];
                self->_isNotifiedEnterGroup = YES;
                [TCUtil report:xiaozhibo_live_play userName:nil code:-10001 msg:@"进入MLVBLiveRoom失败"];
            } else {
                NSLog(@"进入直播间失败");
                [TCUtil toastTip:[NSString stringWithFormat:@"%@%d", kErrorMsgRtmpPlayFailed, errCode] parentView:self.view];
                [self closeVCWithRefresh:YES popViewController:YES];
                [TCUtil report:xiaozhibo_live_play userName:nil code:10000 msg:@"进入MLVBLiveRoom成功"];
            }
        });
    }];
}

-(void)startLinkMic {
    if (_isBeingLinkMic || _isWaitingResponse) {
        return;
    }
    __weak __typeof(self) wself = self;
    [self.liveRoom requestJoinAnchor:@"" completion:^(int errCode, NSString *errMsg) {
        __strong __typeof(wself) self = wself;
        if (self == nil) {
            return;
        }
        if (self->_isWaitingResponse == NO || !self->_isInVC) {
            return;
        }
        self->_isWaitingResponse = NO;
        [self->_btnLinkMic setEnabled:YES];
        [self hideWaitingNotice];
        if (errCode == 0) {
            self->_isBeingLinkMic = YES;
            [self->_btnLinkMic setImage:[UIImage imageNamed:@"linkmic_off"] forState:UIControlStateNormal];
            [TCUtil toastTip:@"主播接受了您的连麦请求，开始连麦" parentView:self.view];
            
            //推流允许前后切换摄像头
            self->_btnCamera.hidden = NO;
            
            //查找空闲的TCSmallPlayer, 开始loading
            for (TCSmallPlayer * playItem in self->_playItems) {
                if (playItem.userID == nil || playItem.userID.length == 0) {
                    playItem.userID = self->_liveInfo.userid;
                    [self.liveRoom startLocalPreview:YES view:playItem.videoView];
                    [self.liveRoom setBeautyStyle:0 beautyLevel:5 whitenessLevel:0 ruddinessLevel:0];
                    break;
                }
            }
            
            //先取消上次delayStopLinkMic操作
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayStopLinkMic) object:nil];
            [self.liveRoom joinAnchor:^(int errCode, NSString *errMsg) {
                if (errCode != 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [TCUtil toastTip:errMsg parentView:self.view];
                        [self onKickoutJoinAnchor];
                    });
                    
                }
            }];
            
        }
        else {
            [TCUtil toastTip:errMsg parentView:self.view];
            self->_isBeingLinkMic = NO;
            self->_isWaitingResponse = NO;
            [self->_btnLinkMic setImage:[UIImage imageNamed:@"linkmic_on"] forState:UIControlStateNormal];
        }
    }];
    _isWaitingResponse = YES;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onWaitLinkMicResponseTimeOut) object:nil];
    [self performSelector:@selector(onWaitLinkMicResponseTimeOut) withObject:nil afterDelay:20];
    
    [_btnLinkMic setImage:[UIImage imageNamed:@"linkmic_off"] forState:UIControlStateNormal];
    [_btnLinkMic setEnabled:NO];
    
    [self showWaitingNotice:@"等待主播接受"];
}

-(void)stopLinkMic{
    // 关闭所有播放器
    for (TCSmallPlayer* playItem in _playItems) {
        [playItem stopLoading];
        [playItem stopPlay];
        if (playItem.anchor) {
            [self.liveRoom stopRemoteView:playItem.anchor];
        }
        [playItem emptyPlayInfo];
    }
    //    //结束连麦，允许录制小视频
    //    [self.logicView.btnRecord setEnabled:YES];
}

- (void)stopLocalPreview
{
    if (_isBeingLinkMic == YES) {
        //退出房间，先不切换流数据，延迟10s再切换，防止拉到CDN缓存的连麦过程中的图像
        [self.liveRoom quitJoinAnchor:^(int errCode, NSString *errMsg) {
        }];
        
        //关闭本地摄像头，停止推流
        for (TCSmallPlayer* playItem in _playItems) {
            if ([playItem.userID isEqualToString:_liveInfo.userid]) {
                [self.liveRoom stopLocalPreview];
                [playItem stopLoading];
                [playItem stopPlay];
                [playItem emptyPlayInfo];
            }
        }
        //UI重置
        [_btnLinkMic setImage:[UIImage imageNamed:@"linkmic_on"] forState:UIControlStateNormal];
        [_btnLinkMic setEnabled:YES];
        _btnCamera.hidden = YES;
        
        _isBeingLinkMic = NO;
        _isWaitingResponse = NO;
    }
}

- (void) initPlayItem: (int)index {
    CGFloat width = self.view.size.width;
    CGFloat height = self.view.size.height;
    
    TCSmallPlayer* playItem = [[TCSmallPlayer alloc] init];
    playItem.videoView = [[UIView alloc] initWithFrame:CGRectMake(width - VIDEO_VIEW_WIDTH - VIDEO_VIEW_MARGIN_RIGHT, height - VIDEO_VIEW_MARGIN_BOTTOM - VIDEO_VIEW_HEIGHT * index, VIDEO_VIEW_WIDTH, VIDEO_VIEW_HEIGHT)];
    [self.view addSubview:playItem.videoView];
    [_playItems addObject:playItem];
}


-(void)handleLinkMicFailed:(NSString*)message {
    [TCUtil toastTip:message parentView:self.view];
    //关闭摄像头，停止推流，退出房间
    [self stopLocalPreview];
    //关闭所有播放器
    [self stopLinkMic];
    //重新从CDN开始拉流
    [self startRtmp];
}

-(void) onWaitLinkMicResponseTimeOut {
    if (_isWaitingResponse == YES) {
        _isWaitingResponse = NO;
        [_btnLinkMic setImage:[UIImage imageNamed:@"linkmic_on"] forState:UIControlStateNormal];
        [_btnLinkMic setEnabled:YES];
        [self hideWaitingNotice];
        [TCUtil toastTip:@"连麦请求超时，主播没有做出回应" parentView:self.view];
    }
}

-(void) showWaitingNotice: (NSString*)notice {
    CGRect frameRC = [[UIScreen mainScreen] bounds];
    frameRC.origin.y = frameRC.size.height - 110;
    frameRC.size.height -= 110;
    if (_waitingNotice == nil) {
        _waitingNotice = [[UITextView alloc] init];
        _waitingNotice.editable = NO;
        _waitingNotice.selectable = NO;
        
        frameRC.size.height = [TCUtil heightForString:_waitingNotice andWidth:frameRC.size.width];
        _waitingNotice.frame = frameRC;
        _waitingNotice.backgroundColor = [UIColor whiteColor];
        _waitingNotice.alpha = 0.5;
        
        [self.view addSubview:_waitingNotice];
    }
    
    _waitingNotice.text = notice;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 500 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^(){
        [self freshWaitingNotice:notice withIndex: [NSNumber numberWithLong:0]];
    });
}

-(void) freshWaitingNotice:(NSString*) notice withIndex: (NSNumber*)numIndex {
    if (_waitingNotice) {
        long index = [numIndex longValue];
        ++index;
        index = index % 4;
        
        NSString * text = notice;
        for (long i = 0; i < index; ++i) {
            text = [NSString stringWithFormat:@"%@.....", text];
        }
        [_waitingNotice setText:text];
        
        numIndex = [NSNumber numberWithLong:index];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 500 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^(){
            [self freshWaitingNotice:notice withIndex: numIndex];
        });
    }
}

-(void) hideWaitingNotice {
    if (_waitingNotice) {
        [_waitingNotice removeFromSuperview];
        _waitingNotice = nil;
    }
}

#pragma mark - liveroom listener
- (void)onDebugLog:(NSString *)msg
{
    NSLog(@"onDebugMsg:%@", msg);
}

- (void)onRoomDestroy:(NSString *)roomID
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"onRoomDestroy, roomID:%@", roomID);
        [UIAlertView bk_showAlertViewWithTitle:@"大主播关闭直播间" message:nil cancelButtonTitle:@"确定" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            [self closeVCWithRefresh:YES popViewController:YES];
        }];
    });
}

- (void)onError:(int)errCode errMsg:(NSString *)errMsg extraInfo:(NSDictionary *)extraInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"onError:%d, %@", errCode, errMsg);
        if(errCode != 0){
            if (self->_isInVC) {
                [UIAlertView bk_showAlertViewWithTitle:errMsg message:nil cancelButtonTitle:@"确定" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    [self closeVCWithRefresh:YES popViewController:YES];
                }];
            }else{
                self->_errorCode = errCode;
                self->_errorMsg = errMsg;
            }
        }
    });
}

- (void)onAnchorEnter:(MLVBAnchorInfo *)pusherInfo
{
    NSString* joinerID = pusherInfo.userID;
    if (joinerID && [joinerID isEqualToString:_liveInfo.userid]) {
        return;
    }
    
    [self startPlayVideoStream:pusherInfo];
}

- (void)onAnchorExit:(MLVBAnchorInfo *)pusherInfo
{
    NSString* exiterID = pusherInfo.userID;
    if (exiterID && [exiterID isEqualToString:_liveInfo.userid]) {
        return;
    }
    
    [self stopPlayVideoStream:exiterID];
}

- (void)onKickoutJoinAnchor
{
    [TCUtil toastTip:@"不好意思，您被主播踢开" parentView:self.view];
    [self stopLocalPreview];
    //延迟10S 重新从CDN拉流播放，原因是CDN有缓冲数据，如果立刻拉CDN流，可能拉到连麦缓存的视频数据
    [self performSelector:@selector(delayStopLinkMic) withObject:nil afterDelay:10];
}

- (void)onRecvRoomTextMsg:(NSString *)roomID userID:(NSString *)userID userName:(NSString *)userName userAvatar:(NSString *)userAvatar message:(NSString *)message
{
    IMUserAble* info = [IMUserAble new];
    info.imUserId = userID;
    info.imUserName = userName.length > 0? userName : userID;
    info.imUserIconUrl = userAvatar;
    info.cmdType = TCMsgModelType_NormalMsg;
    [_logicView handleIMMessage:info msgText:message];
}

- (void)onRecvRoomCustomMsg:(NSString *)roomID userID:(NSString *)userID userName:(NSString *)userName userAvatar:(NSString *)userAvatar cmd:(NSString *)cmd message:(NSString *)message
{
    IMUserAble* info = [IMUserAble new];
    info.imUserId = userID;
    info.imUserName = userName.length > 0? userName : userID;
    info.imUserIconUrl = userAvatar;
    info.cmdType = [cmd integerValue];
    [_logicView handleIMMessage:info msgText:message];
}

#pragma mark- MiscFunc
-(TCSmallPlayer*) getPlayItemByUserID:(NSString*)userID {
    if (userID) {
        for (TCSmallPlayer* playItem in _playItems) {
            if ([userID isEqualToString:playItem.userID]) {
                return playItem;
            }
        }
    }
    return nil;
}

-(TCSmallPlayer*) getPlayItemByStreamUrl:(NSString*)streamUrl {
    if (streamUrl) {
        for (TCSmallPlayer* playItem in _playItems) {
            if ([streamUrl isEqualToString:playItem.playUrl]) {
                return playItem;
            }
        }
    }
    return nil;
}

-(void) startPlayVideoStream: (MLVBAnchorInfo*)anchor {
    NSString* userID = anchor.userID;
    NSString* playUrl = anchor.accelerateURL;
    if (userID == nil || userID.length == 0 || playUrl == nil || playUrl.length == 0) {
        return;
    }
    
    BOOL bExist = NO;
    for (TCSmallPlayer * item in _playItems) {
        if ([userID isEqualToString:item.userID] /* || [playUrl isEqualToString:item.playUrl]*/) {
            bExist = YES;
            break;
        }
    }
    if (bExist == YES) {
        return;
    }
    
    for (TCSmallPlayer * playItem in _playItems) {
        if (playItem.userID == nil || playItem.userID.length == 0) {
            playItem.userID = userID;
            playItem.anchor = anchor;
            [playItem startLoading];
            [playItem startPlay:playUrl];
            __weak typeof(self) weakSelf = self;
            [self.liveRoom startRemoteView:anchor view:playItem.videoView onPlayBegin:^{
                [playItem stopLoading];
            } onPlayError:^(int errCode, NSString *errMsg) {
                [weakSelf onAnchorExit:anchor];
            } playEvent:nil];
            break;
        }
    }
}

-(void) stopPlayVideoStream: (NSString*)userID {
    TCSmallPlayer * playItem = [self getPlayItemByUserID:userID];
    if (playItem) {
        [playItem stopLoading];
        [playItem stopPlay];
        [self.liveRoom stopRemoteView:playItem.anchor];
        [playItem emptyPlayInfo];
    }
}

-(UIView*) findFullScreenVideoView {
    for (id view in self.view.subviews) {
        if ([view isKindOfClass:[UIView class]] && ((UIView*)view).tag == FULL_SCREEN_PLAY_VIDEO_VIEW) {
            return (UIView*)view;
        }
    }
    return nil;
}


-(void)clickBtnCamera:(UIButton *)button {
    if (_isBeingLinkMic) {
        [self.liveRoom switchCamera];
    }
}

-(void)delayStopLinkMic{
    //关闭所有播放器
    [self stopLinkMic];
    //重新从CDN拉流播放
    [self startRtmp];
}

#pragma mark RTMP LOGIC

-(BOOL)checkPlayUrl:(NSString*)playUrl {
    if (!([playUrl hasPrefix:@"http:"] || [playUrl hasPrefix:@"https:"] || [playUrl hasPrefix:@"rtmp:"] )) {
        [TCUtil toastTip:@"播放地址不合法，目前仅支持rtmp,flv,hls,mp4播放方式!" parentView:self.view];
        return NO;
    }
    if (_isLivePlay) {
        if ([playUrl hasPrefix:@"rtmp:"]) {
            _playType = PLAY_TYPE_LIVE_RTMP;
        } else if (([playUrl hasPrefix:@"https:"] || [playUrl hasPrefix:@"http:"]) && [playUrl rangeOfString:@".flv"].length > 0) {
            _playType = PLAY_TYPE_LIVE_FLV;
        } else{
            [TCUtil toastTip:@"播放地址不合法，直播目前仅支持rtmp,flv播放方式!" parentView:self.view];
            return NO;
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
                [TCUtil toastTip:@"播放地址不合法，点播目前仅支持flv,hls,mp4播放方式!" parentView:self.view];
                return NO;
            }
            
        } else {
            [TCUtil toastTip:@"播放地址不合法，点播目前仅支持flv,hls,mp4播放方式!" parentView:self.view];
            return NO;
        }
    }
    
    return YES;
}

-(BOOL)startPlay {
    if (![self checkPlayUrl:_rtmpUrl]) {
        return NO;
    }
    [self initRoomLogic];
    return YES;
}

-(BOOL)startRtmp{
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    return [self startPlay];
}

- (void)stopRtmp{
    if (self.liveRoom) {
        [self.liveRoom exitRoom:^(int errCode, NSString *errMsg) {
            NSLog(@"exitRoom: errCode[%d] errMsg[%@]", errCode, errMsg);
        }];
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

#pragma mark - UI EVENT
-(void)closeVC:(BOOL)popViewController{
    [self stopLocalPreview];
    [self stopLinkMic];
    [self closeVCWithRefresh:NO popViewController:popViewController];
    [self hideWaitingNotice];
    [TCUtil dismissShareDialog];
}

- (void)closeVCWithRefresh:(BOOL)refresh popViewController: (BOOL)popViewController {
    [self stopRtmp];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.liveInfo) {
        if (_isNotifiedEnterGroup){
            [self.liveRoom sendRoomCustomMsg:[@(TCMsgModelType_MemberQuitRoom) stringValue] msg:nil completion:nil];
        }
    }
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

-(void)clickBtnLinkMic:(UIButton *)button {
    if (_isBeingLinkMic == NO) {
        //检查麦克风权限
        AVAuthorizationStatus statusAudio = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        if (statusAudio == AVAuthorizationStatusDenied) {
            [TCUtil toastTip:@"获取麦克风权限失败，请前往隐私-麦克风设置里面打开应用权限" parentView:self.view];
            return;
        }
        
        //是否有摄像头权限
        AVAuthorizationStatus statusVideo = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (statusVideo == AVAuthorizationStatusDenied) {
            [TCUtil toastTip:@"获取摄像头权限失败，请前往隐私-相机设置里面打开应用权限" parentView:self.view];
            return;
        }
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
            [TCUtil toastTip:@"系统不支持硬编码， 启动连麦失败" parentView:self.view];
            return;
        }
        
        [self startLinkMic];
    }
    else {
        [self stopLocalPreview];
        [self performSelector:@selector(delayStopLinkMic) withObject:nil afterDelay:10];
    }
}


-(void)clickPlayVod{
    if (!_videoFinished) {
        if (_playType == PLAY_TYPE_VOD_FLV || _playType == PLAY_TYPE_VOD_HLS || _playType == PLAY_TYPE_VOD_MP4) {
            if (_videoPause) {
                NSAssert(NO, @"");
//                [self.liveRoom resume];
                [_logicView.playBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
                [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            } else {
                NSAssert(NO, @"");
//                [self.liveRoom pause];
                [_logicView.playBtn setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
                [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            }
            _videoPause = !_videoPause;
        }
    }
    else {
        [self startRtmp];
        [_logicView.playBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
}

- (void)clickScreen:(CGPoint)position
{
    [self.liveRoom setFocusPosition:position];
}

- (void)clickLog:(UIButton*)btn {
    for (TCSmallPlayer * item in _playItems) {
        [item showLogView:self.log_switch];
    }
    if (_log_switch == YES)
    {
        [btn setImage:[UIImage imageNamed:@"log"] forState:UIControlStateNormal];
        _logicView.cover.hidden = YES;
        _log_switch = NO;
    }
    else
    {
        [btn setImage:[UIImage imageNamed:@"log2"] forState:UIControlStateNormal];
        _logicView.cover.alpha = 0.5;
        _logicView.cover.hidden = NO;
        _log_switch = YES;
    }
    [self.liveRoom showVideoDebugLog:_log_switch];
}

#pragma -- UISlider - play seek
-(void)onSeek:(UISlider *)slider{
//    [self.liveRoom seek:_sliderValue];
    _trackingTouchTS = [[NSDate date]timeIntervalSince1970]*1000;
    _startSeek = NO;
}

-(void)onSeekBegin:(UISlider *)slider{
    _startSeek = YES;
}

-(void)onDrag:(UISlider *)slider {
    float progress = slider.value;
    int intProgress = progress + 0.5;
    _logicView.playLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",(int)intProgress / 3600,(int)(intProgress / 60), (int)(intProgress % 60)];
    _sliderValue = slider.value;
}

- (void)clickShare:(UIButton *)button {
    [TCUtil shareLive:self.liveInfo currentViewController:self];
}

-(void)onRecvGroupDeleteMsg {
    [self closeVC:NO];
    if (!_isErrorAlert) {
        _isErrorAlert = YES;
        [HUDHelper alert:kErrorMsgLiveStopped cancel:@"确定" action:^{
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
}

@end
