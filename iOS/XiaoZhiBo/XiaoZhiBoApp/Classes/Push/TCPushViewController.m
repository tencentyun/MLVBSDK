//
//  PublishController.m
//  RTMPiOSDemo
//
//  Created by 蓝鲸 on 16/4/1.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "TCPushViewController.h"
#import "TCPlayViewController.h"
#import <Foundation/Foundation.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import <UIKit/UIKit.h>
#import <mach/mach.h>
#import "TCMsgModel.h"
#import "TCUserInfoModel.h"
#import "TCConstants.h"
#import "NSString+Common.h"
#import <CWStatusBarNotification/CWStatusBarNotification.h>
#import "TCSmallPlayer.h"
#import "UIView+Additions.h"
#import "TCLoginModel.h"

#if POD_PITU
#import "MCTip.h"
#import "MCCameraDynamicView.h"
#import "MaterialManager.h"

@interface TCPushViewController () <AVCaptureVideoDataOutputSampleBufferDelegate,UITextFieldDelegate, MPMediaPickerControllerDelegate, MCCameraDynamicDelegate, MLVBLiveRoomDelegate,TCPushDecorateDelegate>

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

@implementation TCPushViewController
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
    
    TCLiveInfo *_liveInfo;
    
    BOOL        _firstAppear;
    
    TCPushDecorateView *_logicView;
    UIView             *_videoParentView;
    
    CWStatusBarNotification *_notification;
    
    float _bgmVolume;
    float _micVolume;
    float _bgmPitch;
    
    //link mic
    NSString*               _sessionId;
    NSString*               _userIdRequest;
    NSMutableArray*         _playItems;
    BOOL                    _isSupprotHardware;
    uint64_t                _beginTime;
    uint64_t                _endTime;
}

- (instancetype)initWithPublishInfo:(TCLiveInfo *)liveInfo {
    if (self = [super init]) {
        _liveInfo = liveInfo;
        _platformType = TCSocialPlatformUnknown;
        
        //link mic
        _sessionId = [self getLinkMicSessionID];
        
        _playItems = [NSMutableArray array];
        
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
    if (_platformType >= 0) {
        [self startRtmp];
        _platformType = TCSocialPlatformUnknown;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] addObserver:self->_logicView
                                                     selector:@selector(keyboardFrameDidChange:)
                                                         name:UIKeyboardWillChangeFrameNotification
                                                       object:nil];
        });
        return;
    }
    [self.liveRoom resumeBGM];
}

- (void)onAppWillResignActive:(NSNotification*)notification
{
    _appIsInterrupt = YES;
}

- (void)onAppDidBecomeActive:(NSNotification*)notification
{
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
    _logicView = [[TCPushDecorateView alloc] initWithFrame:self.view.frame];
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
    if (_platformType >= 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [TCUtil shareDataWithPlatform:_platformType liveInfo:self->_liveInfo currentViewController:self];
            [[NSNotificationCenter defaultCenter] removeObserver:self->_logicView
                                                            name:UIKeyboardWillChangeFrameNotification
                                                          object:nil];
        });
        
    } else {
        [self startRtmp];
    }
    
    //link mic
    //初始化连麦播放小窗口
    [self initPlayItem: 1];
    [self initPlayItem: 2];
    [self initPlayItem: 3];
    
    //logicView不能被连麦小窗口挡住
    [self.view bringSubviewToFront:self.logicView];
    
    //初始化连麦播放小窗口里的logView
    for (TCSmallPlayer * item in _playItems) {
        UIView * logView = [[UIView alloc] initWithFrame:item.videoView.frame];
        logView.backgroundColor = [UIColor clearColor];
        logView.hidden = YES;
        logView.backgroundColor = [UIColor whiteColor];
        logView.alpha  = 0.5;
        [self.view addSubview:logView];
        item.logView = logView;
    }
    
    //初始化连麦播放小窗口里的踢人Button
    CGFloat width = self.view.size.width;
    CGFloat height = self.view.size.height;
    int index = 1;
    for (TCSmallPlayer* playItem in _playItems) {
        playItem.btnKickout = [[UIButton alloc] initWithFrame:CGRectMake(width - BOTTOM_BTN_ICON_WIDTH/2 - VIDEO_VIEW_MARGIN_RIGHT - 5, height - VIDEO_VIEW_MARGIN_BOTTOM - VIDEO_VIEW_HEIGHT * index + 5, BOTTOM_BTN_ICON_WIDTH/2, BOTTOM_BTN_ICON_WIDTH/2)];
        [playItem.btnKickout addTarget:self action:@selector(clickBtnKickout:) forControlEvents:UIControlEventTouchUpInside];
        [playItem.btnKickout setImage:[UIImage imageNamed:@"kickout"] forState:UIControlStateNormal];
        playItem.btnKickout.hidden = YES;
        [self.view addSubview:playItem.btnKickout];
        ++index;
    }
    
#if POD_PITU
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(packageDownloadProgress:) name:kMC_NOTI_ONLINEMANAGER_PACKAGE_PROGRESS object:nil];
#endif
    
    [_logicView triggeValue];
    
}

- (void) initPlayItem: (int)index {
    CGFloat width = self.view.size.width;
    CGFloat height = self.view.size.height;
    
    TCSmallPlayer* playItem = [[TCSmallPlayer alloc] init];
    playItem.videoView = [[UIView alloc] initWithFrame:CGRectMake(width - VIDEO_VIEW_WIDTH - VIDEO_VIEW_MARGIN_RIGHT, height - VIDEO_VIEW_MARGIN_BOTTOM - VIDEO_VIEW_HEIGHT * index, VIDEO_VIEW_WIDTH, VIDEO_VIEW_HEIGHT)];
    [self.view addSubview:playItem.videoView];
    
    playItem.pending = false;
    [_playItems addObject:playItem];
    _beginTime = [[NSDate date] timeIntervalSince1970];
}

- (void)viewDidDisappear:(BOOL)animated {
    _endTime = [[NSDate date] timeIntervalSince1970];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_platformType >= 0) {
        [self startRtmp];
        _platformType = TCSocialPlatformUnknown;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] addObserver:self->_logicView
                                                     selector:@selector(keyboardFrameDidChange:)
                                                         name:UIKeyboardWillChangeFrameNotification
                                                       object:nil];
        });
    }
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

-(void)startRtmp{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"title":_liveInfo.title,
                                                                 @"frontcover":_liveInfo.userinfo.frontcover,
                                                                 @"location":_liveInfo.userinfo.location
                                                                 } options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *roomInfo = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    __weak typeof(self) weakSelf = self;
//    [self.liveRoom updateSelfUserInfo:_liveInfo.userinfo.nickname userAvatar:_liveInfo.userinfo.headpic];
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
                [TCUtil asyncSendHttpRequest:@"upload_room" token:[TCLoginModel sharedInstance].token params:params handler:^(int resultCode, NSString *message, NSDictionary *resultDict) {
                    if (resultCode != 200) {
                        NSLog(@"uploadRoom: errCode[%d] errMsg[%@]", errCode, errMsg);
                    }
                }];
            } else {
                if (errCode == -5) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"License校验失败"
                                                                                            message:@"请获取您的License后，在AppDelegate填写相关信息"
                                                                                     preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *action = [UIAlertAction actionWithTitle:@"去获取License"
                                                                         style:UIAlertActionStyleDefault
                                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                                           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://cloud.tencent.com/document/product/454/34750"]];
                                                                           [weakSelf.logicView closeVCWithError:errMsg Alert:YES Result:NO];
                                                                       }];
                        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                                               style:UIAlertActionStyleCancel
                                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                                 [weakSelf.logicView closeVCWithError:errMsg Alert:YES Result:NO];
                                                                             }];
                        [controller addAction:action];
                        [controller addAction:cancelAction];
                        [self presentViewController:controller animated:YES completion:nil];
                    });
                } else if (errCode != ROOM_ERR_CANCELED) {
                    [weakSelf.logicView closeVCWithError:[NSString stringWithFormat:@"%@%d", errMsg, errCode] Alert:YES Result:NO];
                }
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
- (void)onDebugLog:(NSString *)msg
{
    NSLog(@"onDebugLog:%@", msg);
}

- (void)onRoomDestroy:(NSString *)roomID
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"onRoomDestroy, roomID:%@", roomID);
        [self->_logicView closeVCWithError:kErrorMsgPushClosed Alert:YES Result:YES];
    });
    
}

- (void)onError:(int)errCode errMsg:(NSString *)errMsg extraInfo:(NSDictionary *)extraInfo
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"onError:%d, %@", errCode, errMsg);
        if(errCode != 0){
            [self->_logicView closeVCWithError:errMsg Alert:YES Result:YES];
        }
    });
}

- (void)onAnchorEnter:(MLVBAnchorInfo *)anchor
{
    NSString* userID = anchor.userID;
    NSString* strPlayUrl = anchor.accelerateURL;
    if (userID == nil || strPlayUrl == nil) {
        return;
    }
    
    DebugLog(@"onReceiveMemberJoinNotify: userID = %@ playUrl = %@", userID, strPlayUrl);
    
    if ([_setLinkMemeber containsObject:userID] == NO) {
        return;
    }
    
    TCSmallPlayer * item = [self getPlayItemByUserID:userID];
    if (item == nil) {
        return;
    }
    item.anchor = anchor;
    __weak typeof(self) weakSelf = self;
    [self.liveRoom startRemoteView:anchor view:item.videoView onPlayBegin:^{
        item.pending = NO;
        item.btnKickout.hidden = NO;
        [item stopLoading];
    } onPlayError:^(int errCode, NSString *errMsg) {
        [weakSelf.setLinkMemeber removeObject:userID];
        [item stopPlay];
        [item emptyPlayInfo];
        if (errMsg != nil && errMsg.length > 0) {
            [TCUtil toastTip:errMsg parentView:weakSelf.view];
        }
    } playEvent:nil];
}

- (void)onAnchorExit:(MLVBAnchorInfo *)anchorInfo
{
    NSString* userID = anchorInfo.userID;
    TCSmallPlayer* playItem = [self getPlayItemByUserID:userID];
    if (playItem == nil) {
        DebugLog(@"onReceiveMemberExitNotify: invalid notify");
        return;
    }
    
    //混流：减少一路
    [self.liveRoom stopRemoteView:anchorInfo];
    [playItem stopPlay];
    [playItem emptyPlayInfo];
    [_setLinkMemeber removeObject:userID];
}


- (void)onRequestJoinAnchor:(MLVBAnchorInfo *)anchorInfo reason:(NSString *)reason
{
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
        TCSmallPlayer * item = [self getPlayItemByUserID:userID];
        if (item){
            [self.liveRoom kickoutJoinAnchor:item.userID];
            [_setLinkMemeber removeObject:item.userID];
            [item stopLoading];
            [item stopPlay];
            [item emptyPlayInfo];
        }
        _userIdRequest = userID;
        UIAlertView* _alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"%@向您发起连麦请求", userID]  delegate:self cancelButtonTitle:@"拒绝" otherButtonTitles:@"接受", nil];
        
        [_alertView show];
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleTimeOutRequest:) object:_alertView];
        [self performSelector:@selector(handleTimeOutRequest:) withObject:_alertView afterDelay:20];
    }
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
            for (TCSmallPlayer * playItem in _playItems) {
                if (playItem.userID == nil || playItem.userID.length == 0) {
                    playItem.pending = YES;
                    playItem.userID = _userIdRequest;
                    [playItem startLoading];
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

-(void) onLinkMicTimeOut:(NSString*)userID {
    if (userID) {
        TCSmallPlayer* playItem = [self getPlayItemByUserID:userID];
        if (playItem && playItem.pending == YES){
            [self.liveRoom kickoutJoinAnchor:playItem.userID];
            [_setLinkMemeber removeObject:userID];
            [playItem stopPlay];
            [playItem emptyPlayInfo];
            [TCUtil toastTip: [NSString stringWithFormat: @"%@连麦超时", userID] parentView:self.view];
        }
    }
}

-(void) handleTimeOutRequest:(UIAlertView*)alertView {
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

#pragma mark -  UI EVENT

-(void)closeVC{
    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)closeRTMP {
    for (TCSmallPlayer* playItem in _playItems) {
        [playItem stopPlay];
    }
    [self stopRtmp];
}

- (void) clickBtnKickout:(UIButton *)btn {
    for (TCSmallPlayer* playItem in _playItems) {
        if (playItem.btnKickout == btn) {
            [self.liveRoom kickoutJoinAnchor:playItem.userID];
            [_setLinkMemeber removeObject:playItem.userID];
            [playItem stopPlay];
            [playItem emptyPlayInfo];
            break;
        }
    }
}

-(void)clickScreen:(UITapGestureRecognizer *)gestureRecognizer{
    _logicView.vBeauty.hidden = YES;
    _logicView.vMusicPanel.hidden = YES;
    
    //手动聚焦
    CGPoint touchLocation = [gestureRecognizer locationInView:_videoParentView];;
    [self.liveRoom setFocusPosition:touchLocation];
}

-(void) clickCamera:(UIButton*) btn
{
    _camera_switch = !_camera_switch;
#if POD_PITU
    [self.liveRoom setMirror:!_camera_switch];
#endif
    [self.liveRoom switchCamera];
}

-(void) clickBeauty:(UIButton*) btn
{
    _logicView.vBeauty.hidden = NO;
}

- (void)clickMusicSelect:(UIButton *)btn {
    //创建播放器控制器
    MPMediaPickerController *mpc = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
    mpc.delegate = self;
    mpc.editing = YES;
    [self presentViewController:mpc animated:YES completion:nil];
}

- (void)clickMusic:(UIButton *)button {
    _logicView.vMusicPanel.hidden = NO;
}

- (void)clickMusicClose:(UIButton *)button {
    _logicView.vMusicPanel.hidden = YES;
    [self.liveRoom stopBGM];
}

-(void) clickLog:(UIButton*) btn
{
    for (TCSmallPlayer * item in _playItems) {
        [item showLogView:self.log_switch];
    }
    _log_switch = !_log_switch;
    [self.liveRoom showVideoDebugLog:_log_switch];
}

-(void) clickTorch:(UIButton*) btn
{
    _torch_switch = !_torch_switch;
    [self.liveRoom enableTorch:_torch_switch];
    
    if (_torch_switch == YES) {
        [_logicView.btnTorch setImage:[UIImage imageNamed:@"flash_hover"] forState:UIControlStateNormal];
    }
    else{
        [_logicView.btnTorch setImage:[UIImage imageNamed:@"flash"] forState:UIControlStateNormal];
    }
}

-(void) sliderValueChange:(UISlider*) obj
{
    // todo
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

-(void) sliderValueChangeEx:(UISlider*) obj
{
    //to do
}

-(void)selectEffect:(NSInteger)index
{
    [self.liveRoom setReverbType:index];
}

-(void)selectEffect2:(NSInteger)index
{
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
                    // _logicView.vMusicPanel.hidden = NO;   // 暂时不加这两个按钮
                    [self.liveRoom playBGM:exportFile];
                    [self.liveRoom setBGMVolume:_bgmVolume];
                    [self.liveRoom setMicVolume:_micVolume];
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

