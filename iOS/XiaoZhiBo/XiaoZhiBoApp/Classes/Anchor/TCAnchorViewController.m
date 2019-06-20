/**
 * Module: TCAnchorViewController
 *
 * Function: 主播推流模块主控制器，里面承载了渲染view，逻辑view，以及推流相关逻辑，同时也是SDK层事件通知的接收者
 */

#import "TCAnchorViewController.h"
#import "TCAudienceViewController.h"
#import <Foundation/Foundation.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import <UIKit/UIKit.h>
#import <mach/mach.h>
#import "TCMsgModel.h"
#import "TCUserProfileModel.h"
#import "TCGlobalConfig.h"
#import "NSString+Common.h"
#import <CWStatusBarNotification/CWStatusBarNotification.h>
#import "TCStatusInfoView.h"
#import "TCAccountMgrModel.h"
#import "UIView+Additions.h"

#if POD_PITU
#import "MCTip.h"
#import "MCCameraDynamicView.h"
#import "MaterialManager.h"

@interface TCAnchorViewController () <
    AVCaptureVideoDataOutputSampleBufferDelegate,
    UITextFieldDelegate,
    MPMediaPickerControllerDelegate,
    MCCameraDynamicDelegate,
    MLVBLiveRoomDelegate,
    TCAnchorToolbarDelegate>

@property (nonatomic, strong) UIButton *filterBtn;
@property (nonatomic, assign) NSInteger currentFilterIndex;
@property (nonatomic, strong) MCCameraDynamicView *tmplBar;

@end

#endif

#define MAX_LINKMIC_MEMBER_SUPPORT  3

#define VIDEO_VIEW_WIDTH            100
#define VIDEO_VIEW_HEIGHT           150
#define VIDEO_VIEW_MARGIN_BOTTOM    56
#define VIDEO_VIEW_MARGIN_RIGHT     8

@implementation TCAnchorViewController
{
    BOOL _camera_switch;
    float  _beauty_level;
    float  _whitening_level;
    float  _ruddiness_level;
    float  _eye_level;
    float  _face_level;
    BOOL _torch_switch;
    
    NSString*       _testPath;
    BOOL            _isPreviewing;
    
    BOOL       _appIsInterrupt;
    
    TCRoomInfo *_liveInfo;
    
    BOOL        _firstAppear;
    
    TCAnchorToolbarView *_logicView;
    UIView             *_videoParentView;
    
    CWStatusBarNotification *_notification;
    
    float _bgmVolume;
    float _micVolume;
    float _bgmPitch;
    
    //link mic
    NSString*               _sessionId;
    NSString*               _userIdRequest;
    NSMutableArray*         _statusInfoViewArray;
    BOOL                    _isSupprotHardware;
    uint64_t                _beginTime;
    uint64_t                _endTime;
}

- (instancetype)initWithPublishInfo:(TCRoomInfo *)liveInfo {
    if (self = [super init]) {
        _liveInfo = liveInfo;
        
        //link mic
        _sessionId = [self getLinkMicSessionID];
        
        _statusInfoViewArray = [NSMutableArray array];
        
        _setLinkMemeber = [NSMutableSet set];
        
        _isSupprotHardware = ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0);
        
        _bgmVolume = 1.f;
        _micVolume = 1.f;
        _bgmPitch = 0.f;
        
        _camera_switch   = NO;
        _beauty_level    = 6.3;
        _whitening_level = 6.0;
        _ruddiness_level = 2.7;
        _torch_switch    = NO;
        _log_switch      = NO;
        _firstAppear     = YES;
        
        _notification = [CWStatusBarNotification new];
        _notification.notificationLabelBackgroundColor = [UIColor redColor];
        _notification.notificationLabelTextColor = [UIColor whiteColor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidEnterBackGround:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        
        _bgmVolume = 1.f;
        _micVolume = 1.f;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onAppDidEnterBackGround:(UIApplication*)app {
    // 暂停背景音乐
    [self.liveRoom pauseBGM];
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
    }];
}

- (void)onAppWillEnterForeground:(UIApplication*)app {
    [self.liveRoom resumeBGM];
}

- (void)onAppWillResignActive:(NSNotification*)notification {
    _appIsInterrupt = YES;
}

- (void)onAppDidBecomeActive:(NSNotification*)notification {
    if (_appIsInterrupt) {
        _appIsInterrupt = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor* bgColor = [UIColor blackColor];
    [self.view setBackgroundColor:bgColor];
    
    //视频画面的父view
    _videoParentView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_videoParentView];
    
    //logicView
    _logicView = [[TCAnchorToolbarView alloc] initWithFrame:self.view.frame];
    _logicView.delegate = self;
    [_logicView setLiveInfo:_liveInfo];
    [self.view addSubview:_logicView];
    
    //liveRoom
    _liveRoom = [MLVBLiveRoom sharedInstance];
    [_liveRoom setCameraMuteImage:[UIImage imageNamed:@"pause_publish.jpg"]];
    _liveRoom.delegate = self;
    [_liveRoom startLocalPreview:YES view:_videoParentView];
    [_liveRoom setBeautyStyle:0 beautyLevel:_beauty_level whitenessLevel:_whitening_level ruddinessLevel:_ruddiness_level];
    [self.liveRoom setSpecialRatio:0.5];
        
    _liveInfo.timestamp = [[NSDate date] timeIntervalSince1970];
        [self startRtmp];
    
    //link mic
    //初始化连麦播放小窗口
    [self initStatusInfoView: 1];
    [self initStatusInfoView: 2];
    [self initStatusInfoView: 3];
    
    //logicView不能被连麦小窗口挡住
    [self.view bringSubviewToFront:self.logicView];
    
    //初始化连麦播放小窗口里的logView
    for (TCStatusInfoView * statusInfoView in _statusInfoViewArray) {
        UIView * logView = [[UIView alloc] initWithFrame:statusInfoView.videoView.frame];
        logView.backgroundColor = [UIColor clearColor];
        logView.hidden = YES;
        logView.backgroundColor = [UIColor whiteColor];
        logView.alpha  = 0.5;
        [self.view addSubview:logView];
        statusInfoView.logView = logView;
    }
    
    //初始化连麦播放小窗口里的踢人Button
    CGFloat width = self.view.size.width;
    CGFloat height = self.view.size.height;
    int index = 1;
    for (TCStatusInfoView* statusInfoView in _statusInfoViewArray) {
        statusInfoView.btnKickout = [[UIButton alloc] initWithFrame:CGRectMake(width - BOTTOM_BTN_ICON_WIDTH/2 - VIDEO_VIEW_MARGIN_RIGHT - 5, height - VIDEO_VIEW_MARGIN_BOTTOM - VIDEO_VIEW_HEIGHT * index + 5, BOTTOM_BTN_ICON_WIDTH/2, BOTTOM_BTN_ICON_WIDTH/2)];
        [statusInfoView.btnKickout addTarget:self action:@selector(clickBtnKickout:) forControlEvents:UIControlEventTouchUpInside];
        [statusInfoView.btnKickout setImage:[UIImage imageNamed:@"kickout"] forState:UIControlStateNormal];
        statusInfoView.btnKickout.hidden = YES;
        [self.view addSubview:statusInfoView.btnKickout];
        ++index;
    }
    
#if POD_PITU
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(packageDownloadProgress:) name:kMC_NOTI_ONLINEMANAGER_PACKAGE_PROGRESS object:nil];
#endif
    
    [_logicView triggeValue];
    
}

- (void)initStatusInfoView: (int)index {
    CGFloat width = self.view.size.width;
    CGFloat height = self.view.size.height;
    
    TCStatusInfoView* statusInfoView = [[TCStatusInfoView alloc] init];
    statusInfoView.videoView = [[UIView alloc] initWithFrame:CGRectMake(width - VIDEO_VIEW_WIDTH - VIDEO_VIEW_MARGIN_RIGHT, height - VIDEO_VIEW_MARGIN_BOTTOM - VIDEO_VIEW_HEIGHT * index, VIDEO_VIEW_WIDTH, VIDEO_VIEW_HEIGHT)];
    [self.view addSubview:statusInfoView.videoView];
    
    statusInfoView.pending = false;
    [_statusInfoViewArray addObject:statusInfoView];
    _beginTime = [[NSDate date] timeIntervalSince1970];
}

- (void)viewDidDisappear:(BOOL)animated {
    _endTime = [[NSDate date] timeIntervalSince1970];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
#if !TARGET_IPHONE_SIMULATOR
#if !POD_PITU
    if (!_firstAppear) {
        //是否有摄像头权限
        AVAuthorizationStatus statusVideo = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (statusVideo == AVAuthorizationStatusDenied) {
            [_logicView closeVCWithError:kErrorMsgOpenCameraFailed Alert:YES Result:NO];
            return;
        }
        
        if (!_isPreviewing) {
            [_liveRoom startLocalPreview:YES view:_videoParentView];
            _isPreviewing = YES;
        }
    } else {
        _firstAppear = NO;
    }
#endif
#endif
    
}

- (void)startRtmp{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"title":_liveInfo.title,
                                                                 @"frontcover":_liveInfo.userinfo.frontcover,
                                                                 @"location":_liveInfo.userinfo.location
                                                                 } options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *roomInfo = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    __weak typeof(self) weakSelf = self;
    [self.liveRoom createRoom:@"" roomInfo:roomInfo completion:^(int errCode, NSString *errMsg) {
        NSLog(@"createRoom: errCode[%d] errMsg[%@]", errCode, errMsg);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (errCode == 0) {
                [self.liveRoom setEyeScaleLevel:self->_eye_level];
                [self.liveRoom setFaceScaleLevel:self->_face_level];
                [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
                
                NSDictionary* params = @{@"userid": self->_liveInfo.userid,
                                         @"title": self->_liveInfo.title,
                                         @"frontcover" : self->_liveInfo.userinfo.frontcover,
                                         @"location" : self->_liveInfo.userinfo.location,
                                         };
                [TCUtil asyncSendHttpRequest:@"upload_room" token:[TCAccountMgrModel sharedInstance].token params:params handler:^(int resultCode, NSString *message, NSDictionary *resultDict) {
                    if (resultCode != 200) {
                        NSLog(@"uploadRoom: errCode[%d] errMsg[%@]", errCode, errMsg);
                    }
                }];
            } else if (errCode == 10036) {
                UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"您当前使用的云通讯账号未开通音视频聊天室功能，创建聊天室数量超过限额，请前往腾讯云官网开通【IM音视频聊天室】"
                                                                                    message:nil
                                                                             preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:@"去开通" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [weakSelf.logicView closeVCWithError:[NSString stringWithFormat:@"%@%d", errMsg, errCode] Alert:YES Result:NO];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://buy.cloud.tencent.com/avc"]];
                }];
                UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [weakSelf.logicView closeVCWithError:[NSString stringWithFormat:@"%@%d", errMsg, errCode] Alert:YES Result:NO];
                }];
                [controller addAction:action];
                [controller addAction:confirm];
                [self presentViewController:controller animated:YES completion:nil];
            } else {
                [weakSelf.logicView closeVCWithError:[NSString stringWithFormat:@"%@%d", errMsg, errCode] Alert:YES Result:NO];
            }
        });
    }];
}

- (void)stopRtmp {
    if (self.liveRoom) {
        [self.liveRoom stopLocalPreview];
        [self.liveRoom exitRoom:^(int errCode, NSString *errMsg) {
            NSLog(@"exitRoom: errCode[%d] errMsg[%@]", errCode, errMsg);
        }];
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

#pragma mark - MLVBLiveRoomDelegate
- (void)onDebugLog:(NSString *)msg {
    NSLog(@"onDebugLog:%@", msg);
}

- (void)onRoomDestroy:(NSString *)roomID {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"onRoomDestroy, roomID:%@", roomID);
        [self->_logicView closeVCWithError:kErrorMsgPushClosed Alert:YES Result:YES];
    });
    
}

- (void)onError:(int)errCode errMsg:(NSString *)errMsg extraInfo:(NSDictionary *)extraInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"onError:%d, %@", errCode, errMsg);
        if(errCode != 0){
            [self->_logicView closeVCWithError:errMsg Alert:YES Result:YES];
        }
    });
}

- (void)onAnchorEnter:(MLVBAnchorInfo *)anchor {
    NSString* userID = anchor.userID;
    NSString* strPlayUrl = anchor.accelerateURL;
    if (userID == nil || strPlayUrl == nil) {
        return;
    }
    
    DebugLog(@"onReceiveMemberJoinNotify: userID = %@ playUrl = %@", userID, strPlayUrl);
    
    if ([_setLinkMemeber containsObject:userID] == NO) {
        return;
    }
    
    TCStatusInfoView * statusInfoView = [self getStatusInfoViewFrom:userID];
    if (statusInfoView == nil) {
        return;
    }
    statusInfoView.anchor = anchor;
    __weak typeof(self) weakSelf = self;
    [self.liveRoom startRemoteView:anchor view:statusInfoView.videoView onPlayBegin:^{
        statusInfoView.pending = NO;
        statusInfoView.btnKickout.hidden = NO;
        [statusInfoView stopLoading];
    } onPlayError:^(int errCode, NSString *errMsg) {
        [weakSelf.setLinkMemeber removeObject:userID];
        [statusInfoView stopPlay];
        [statusInfoView emptyPlayInfo];
        if (errMsg != nil && errMsg.length > 0) {
            [TCUtil toastTip:errMsg parentView:weakSelf.view];
        }
    } playEvent:nil];
}

- (void)onAnchorExit:(MLVBAnchorInfo *)anchorInfo {
    NSString* userID = anchorInfo.userID;
    TCStatusInfoView* statusInfoView = [self getStatusInfoViewFrom:userID];
    if (statusInfoView == nil) {
        DebugLog(@"onReceiveMemberExitNotify: invalid notify");
        return;
    }
    
    //混流：减少一路
    [self.liveRoom stopRemoteView:anchorInfo];
    [statusInfoView stopPlay];
    [statusInfoView emptyPlayInfo];
    [_setLinkMemeber removeObject:userID];
}


- (void)onRequestJoinAnchor:(MLVBAnchorInfo *)anchorInfo reason:(NSString *)reason {
    NSString *userID = anchorInfo.userID;

    if ([_setLinkMemeber count] >= MAX_LINKMIC_MEMBER_SUPPORT) {
        [TCUtil toastTip:@"主播端连麦人数超过最大限制" parentView:self.view];
        [self.liveRoom responseJoinAnchor:userID agree:NO reason:@"主播端连麦人数超过最大限制"];
    }
    else if (_userIdRequest.length > 0) {
        if (![_userIdRequest isEqualToString:userID]) {
            [TCUtil toastTip:@"请稍后，主播正在处理其它人的连麦请求" parentView:self.view];
            [self.liveRoom responseJoinAnchor:userID agree:NO reason:@"请稍后，主播正在处理其它人的连麦请求"];
        }
    }
    else {
        TCStatusInfoView * statusInfoView = [self getStatusInfoViewFrom:userID];
        if (statusInfoView){
            [self.liveRoom kickoutJoinAnchor:statusInfoView.userID];
            [_setLinkMemeber removeObject:statusInfoView.userID];
            [statusInfoView stopLoading];
            [statusInfoView stopPlay];
            [statusInfoView emptyPlayInfo];
        }
        _userIdRequest = userID;
        UIAlertView* _alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"%@向您发起连麦请求", userID]  delegate:self cancelButtonTitle:@"拒绝" otherButtonTitles:@"接受", nil];
        
        [_alertView show];
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleTimeOutRequest:) object:_alertView];
        [self performSelector:@selector(handleTimeOutRequest:) withObject:_alertView afterDelay:20];
    }
}

- (void)onRecvRoomTextMsg:(NSString *)roomID userID:(NSString *)userID userName:(NSString *)userName userAvatar:(NSString *)userAvatar message:(NSString *)message {
    IMUserAble* info = [IMUserAble new];
    info.imUserId = userID;
    info.imUserName = userName.length > 0? userName : userID;
    info.imUserIconUrl = userAvatar;
    info.cmdType = TCMsgModelType_NormalMsg;
    [_logicView handleIMMessage:info msgText:message];
}

- (void)onRecvRoomCustomMsg:(NSString *)roomID userID:(NSString *)userID userName:(NSString *)userName userAvatar:(NSString *)userAvatar cmd:(NSString *)cmd message:(NSString *)message {
    IMUserAble* info = [IMUserAble new];
    info.imUserId = userID;
    info.imUserName = userName.length > 0? userName : userID;
    info.imUserIconUrl = userAvatar;
    info.cmdType = [cmd integerValue];
    [_logicView handleIMMessage:info msgText:message];
}

#pragma mark- LinkMic Func
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (_userIdRequest != nil && _userIdRequest.length > 0) {
        if (buttonIndex == 0) {
            //拒绝连麦
            [self.liveRoom responseJoinAnchor:_userIdRequest agree:NO reason:@"主播拒绝了您的连麦请求"];
        }
        else if (buttonIndex == 1) {
            //接受连麦
            [self.liveRoom responseJoinAnchor:_userIdRequest agree:YES reason:nil];
            //查找空闲的TCLinkMicSmallPlayer, 开始loading
            for (TCStatusInfoView * statusInfoView in _statusInfoViewArray) {
                if (statusInfoView.userID == nil || statusInfoView.userID.length == 0) {
                    statusInfoView.pending = YES;
                    statusInfoView.userID = _userIdRequest;
                    [statusInfoView startLoading];
                    break;
                }
            }
            
            //设置超时逻辑
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onLinkMicTimeOut:) object:_userIdRequest];
            [self performSelector:@selector(onLinkMicTimeOut:) withObject:_userIdRequest afterDelay:20];
            
            //加入连麦成员列表
            [_setLinkMemeber addObject:_userIdRequest];
        }
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleTimeOutRequest:) object:alertView];
    _userIdRequest = @"";
}

- (void)onLinkMicTimeOut:(NSString*)userID {
    if (userID) {
        TCStatusInfoView* statusInfoView = [self getStatusInfoViewFrom:userID];
        if (statusInfoView && statusInfoView.pending == YES){
            [self.liveRoom kickoutJoinAnchor:statusInfoView.userID];
            [_setLinkMemeber removeObject:userID];
            [statusInfoView stopPlay];
            [statusInfoView emptyPlayInfo];
            [TCUtil toastTip: [NSString stringWithFormat: @"%@连麦超时", userID] parentView:self.view];
        }
    }
}

- (void)handleTimeOutRequest:(UIAlertView*)alertView {
    _userIdRequest = @"";
    if (alertView) {
        [alertView dismissWithClickedButtonIndex:0 animated:NO];
    }
}

- (NSString*) getLinkMicSessionID {
    //说明：
    //1.sessionID是混流依据，sessionID相同的流，后台混流Server会混为一路视频流；因此，sessionID必须全局唯一
    
    //2.直播码频道ID理论上是全局唯一的，使用直播码作为sessionID是最为合适的
    //NSString* strSessionID = [TCLinkMicModel getStreamIDByStreamUrl:self.rtmpUrl];
    
    //3.直播码是字符串，混流Server目前只支持64位数字表示的sessionID，暂时按照下面这种方式生成sessionID
    //  待混流Server改造完成后，再使用直播码作为sessionID
    
    UInt64 timeStamp = [[NSDate date] timeIntervalSince1970] * 1000;
    
    UInt64 sessionID = ((UInt64)3891 << 48 | timeStamp); // 3891是bizid, timeStamp是当前毫秒值
    
    return [NSString stringWithFormat:@"%llu", sessionID];
}

- (TCStatusInfoView *)getStatusInfoViewFrom:(NSString*)userID {
    if (userID) {
        for (TCStatusInfoView* statusInfoView in _statusInfoViewArray) {
            if ([userID isEqualToString:statusInfoView.userID]) {
                return statusInfoView;
            }
        }
    }
    return nil;
}

- (void)clickBtnKickout:(UIButton *)btn {
    for (TCStatusInfoView* statusInfoView in _statusInfoViewArray) {
        if (statusInfoView.btnKickout == btn) {
            [self.liveRoom kickoutJoinAnchor:statusInfoView.userID];
            [_setLinkMemeber removeObject:statusInfoView.userID];
            [statusInfoView stopPlay];
            [statusInfoView emptyPlayInfo];
            break;
        }
    }
}

#pragma mark -  TCAnchorToolbarDelegate

- (void)closeRTMP {
    for (TCStatusInfoView* statusInfoView in _statusInfoViewArray) {
        [statusInfoView stopPlay];
    }
    [self stopRtmp];
}

- (void)closeVC {
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)clickScreen:(UITapGestureRecognizer *)gestureRecognizer {
    _logicView.vBeauty.hidden = YES;
    _logicView.vMusicPanel.hidden = YES;
    
    //手动聚焦
    CGPoint touchLocation = [gestureRecognizer locationInView:_videoParentView];;
    [self.liveRoom setFocusPosition:touchLocation];
}

- (void)clickCamera:(UIButton *)button {
    _camera_switch = !_camera_switch;
#if POD_PITU
    [self.liveRoom setMirror:!_camera_switch];
#endif
    [self.liveRoom switchCamera];
}

- (void)clickBeauty:(UIButton *)button {
    _logicView.vBeauty.hidden = NO;
}

- (void)clickMusic:(UIButton *)button {
    _logicView.vMusicPanel.hidden = NO;
}

- (void)clickTorch:(UIButton *)button {
    _torch_switch = !_torch_switch;
    [self.liveRoom enableTorch:_torch_switch];
    
    if (_torch_switch == YES) {
        [_logicView.btnTorch setImage:[UIImage imageNamed:@"flash_hover"] forState:UIControlStateNormal];
    }
    else {
        [_logicView.btnTorch setImage:[UIImage imageNamed:@"flash"] forState:UIControlStateNormal];
    }
}

- (void)clickLog:(UIButton *)button {
    for (TCStatusInfoView * statusInfoView in _statusInfoViewArray) {
        [statusInfoView showLogView:self.log_switch];
    }
    _log_switch = !_log_switch;
    [self.liveRoom showVideoDebugLog:_log_switch];
}

- (void)clickMusicSelect:(UIButton *)button {
    //创建播放器控制器
    MPMediaPickerController *mpc = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
    mpc.delegate = self;
    mpc.editing = YES;
    [self presentViewController:mpc animated:YES completion:nil];
}

- (void)clickMusicClose:(UIButton *)button {
    _logicView.vMusicPanel.hidden = YES;
    [self.liveRoom stopBGM];
}

- (void)clickVolumeSwitch:(UIButton *)button {
    // todo
}

- (void)sliderValueChange:(UISlider *)obj {
    if (obj.tag == 0) { //美颜
        _beauty_level = obj.value;
        [self.liveRoom setBeautyStyle:0 beautyLevel:_beauty_level whitenessLevel:_whitening_level ruddinessLevel:_ruddiness_level];
    } else if (obj.tag == 1) { //美白
        _whitening_level = obj.value;
        [self.liveRoom setBeautyStyle:0 beautyLevel:_beauty_level whitenessLevel:_whitening_level ruddinessLevel:_ruddiness_level];
    } else if (obj.tag == 2) { //大眼
        _eye_level = obj.value;
        [self.liveRoom setEyeScaleLevel:_eye_level];
    } else if (obj.tag == 3) { //瘦脸
        _face_level = obj.value;
        [self.liveRoom setFaceVLevel:_face_level];
    } else if (obj.tag == 4) {// 背景音乐音量
        _bgmVolume = obj.value/obj.maximumValue;
        [self.liveRoom setBGMVolume:(obj.value/obj.maximumValue)];
    } else if (obj.tag == 5) { // 麦克风音量
        _micVolume = obj.value/obj.maximumValue;
        [self.liveRoom setMicVolume:(obj.value/obj.maximumValue)];
    } else if (obj.tag == 6) { // bgm变调
        _bgmPitch =  obj.value/obj.maximumValue*2-1;
        [self.liveRoom setBGMPitch:_bgmPitch];
    }
}

- (void)sliderValueChangeEx:(UISlider*)obj {
    // todo
}

- (void)selectEffect:(NSInteger)index {
    [self.liveRoom setReverbType:index];
}

- (void)selectEffect2:(NSInteger)index {
    [self.liveRoom setVoiceChangerType:index];
}

#pragma mark - 特效设置
#if POD_PITU
//#warning step 1.3 切换动效素材
- (void)motionTmplSelected:(NSString *)materialID {
    if (materialID == nil) {
        [MCTip hideText];
    }
    if ([MaterialManager isOnlinePackage:materialID]) {
        [self.liveRoom selectMotionTmpl:materialID inDir:[MaterialManager packageDownloadDir]];
    } else {
        NSString *localPackageDir = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Resource"];
        [self.liveRoom selectMotionTmpl:materialID inDir:localPackageDir];
    }
}

- (void)packageDownloadProgress:(NSNotification *)notification {
    if ([[notification object] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *progressDic = [notification object];
        CGFloat progress = [progressDic[kMC_USERINFO_ONLINEMANAGER_PACKAGE_PROGRESS] floatValue];
        if (progress <= 0.f) {
            [MCTip showText:@"素材下载失败" inView:self.view afterDelay:2.f];
        }
    }
}
#endif

- (void)greenSelected:(NSURL *)mid {
    NSLog(@"green %@", mid);
    [self.liveRoom setGreenScreenFile:mid];
}

- (void)filterSelected:(int)index {
    NSString* lookupFileName = @"";
    
    switch (index) {
        case FilterType_None:
            break;
        case FilterType_biaozhun:
            lookupFileName = @"filter_biaozhun";
            break;
        case FilterType_yinghong:
            lookupFileName = @"filter_yinghong";
            break;
        case FilterType_yunshang:
            lookupFileName = @"filter_yunshang";
            break;
        case FilterType_chunzhen:
            lookupFileName = @"filter_chunzhen";
            break;
        case FilterType_bailan:
            lookupFileName = @"filter_bailan";
            break;
        case FilterType_yuanqi:
            lookupFileName = @"filter_yuanqi";
            break;
        case FilterType_chaotuo:
            lookupFileName = @"filter_chaotuo";
            break;
        case FilterType_xiangfen:
            lookupFileName = @"filter_xiangfen";
            break;
        case FilterType_white:
            lookupFileName = @"filter_white";
            break;
        case FilterType_langman:
            lookupFileName = @"filter_langman";
            break;
        case FilterType_qingxin:
            lookupFileName = @"filter_qingxin";
            break;
        case FilterType_weimei:
            lookupFileName = @"filter_weimei";
            break;
        case FilterType_fennen:
            lookupFileName = @"filter_fennen";
            break;
        case FilterType_huaijiu:
            lookupFileName = @"filter_huaijiu";
            break;
        case FilterType_landiao:
            lookupFileName = @"filter_landiao";
            break;
        case FilterType_qingliang:
            lookupFileName = @"filter_qingliang";
            break;
        case FilterType_rixi:
            lookupFileName = @"filter_rixi";
            break;
        default:
            break;
    }
    UIImage *image = [UIImage imageNamed:lookupFileName];
    if (index != FilterType_None && image != nil) {
        [self.liveRoom setFilter:image];
//        if (index >= 1 && index <= 8) {
//            [self.liveRoom setSpecialRatio:0.7];
//        }
//        else {
//            [self.liveRoom setSpecialRatio:0.4];
//        }
    } else {
        [self.liveRoom setFilter:nil];
    }
}

#pragma mark - BGM
//选中后调用
- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection{
    NSArray *items = mediaItemCollection.items;
    MPMediaItem *item = [items objectAtIndex:0];
    
    NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
    NSLog(@"MPMediaItemPropertyAssetURL = %@", url);
    
    if (mediaPicker.editing) {
        mediaPicker.editing = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.liveRoom stopBGM];
            [self saveAssetURLToFile: url];
        });
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

//点击取消时回调
- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 将AssetURL(音乐)导出到app的文件夹并播放
- (void)saveAssetURLToFile:(NSURL *)assetURL {
    AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:songAsset presetName:AVAssetExportPresetAppleM4A];
    NSLog (@"created exporter. supportedFileTypes: %@", exporter.supportedFileTypes);
    exporter.outputFileType = @"com.apple.m4a-audio";
    
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *exportFile = [docDir stringByAppendingPathComponent:@"exported.m4a"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportFile]) {
        [[NSFileManager defaultManager] removeItemAtPath:exportFile error:nil];
    }
    exporter.outputURL = [NSURL fileURLWithPath:exportFile];
    
    __weak __typeof(self) weakSelf = self;
    // do the export
    [exporter exportAsynchronouslyWithCompletionHandler:^{
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
                    __strong __typeof(weakSelf) self = weakSelf;
                    if (self == nil) {
                        return;
                    }
                    // _logicView.vMusicPanel.hidden = NO;   // 暂时不加这两个按钮
                    [self.liveRoom playBGM:exportFile];
                    [self.liveRoom setBGMVolume:self->_bgmVolume];
                    [self.liveRoom setMicVolume:self->_micVolume];
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
}

@end

