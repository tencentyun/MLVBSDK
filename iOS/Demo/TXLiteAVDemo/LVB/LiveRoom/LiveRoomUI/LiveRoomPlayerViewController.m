//
//  LiveRoomPlayerViewController.m
//  TXLiteAVDemo
//
//  Created by lijie on 2017/11/22.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "LiveRoomPlayerViewController.h"
#import "UIView+Additions.h"
#import "TXLiveSDKTypeDef.h"
#import <AVFoundation/AVFoundation.h>
#import "ColorMacro.h"
#import "LiveRoomMsgListTableView.h"
#import "LiveRoomAccPlayerView.h"

typedef NS_ENUM(NSInteger, LinkMicStatus) {
    LinkMicStatus_IDEL,          // 空闲状态
    LinkMicStatus_REQUESTING,    // 请求连麦过程中
    LinkMicStatus_BEING,         // 连麦中
};

@interface LiveRoomPlayerViewController () {
    UIView                   *_playerView;     // 大画面(大主播)
    UIView                   *_pusherView;     // 自己作为小主播时的推流画面
    NSMutableDictionary      *_playerViewDic;  // 其他小主播的画面，[userID, view]
//    NSMutableDictionary      *_playerItemDic;  // 小主播的loading画面，[userID, playerItem]
    
    UIButton                 *_btnChat;
    UIButton                 *_btnLinkMic;
    UIButton                 *_btnLog;
    
    LinkMicStatus            _linkMicStatus;   // 连麦状态
    
    BOOL                     _appIsInterrupt;
    BOOL                     _appIsInActive;
    BOOL                     _appIsBackground;
    
    UITextView               *_logView;
    UIView                   *_coverView;
    NSInteger                _log_switch;  // 0:隐藏log  1:显示SDK内部的log  2:显示业务层log
    
    // 消息列表展示和输入
    LiveRoomMsgListTableView *_msgListView;
    UIView                   *_msgInputView;
    UITextField              *_msgInputTextField;
    UIButton                 *_msgSendBtn;
    
    CGPoint                  _touchBeginLocation;
}
@end

@implementation LiveRoomPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _playerViewDic = [[NSMutableDictionary alloc] init];
//    _playerItemDic = [[NSMutableDictionary alloc] init];
    
    _appIsInterrupt = NO;
    _appIsInActive = NO;
    _appIsBackground = NO;
    
    [self initUI];
    [self initRoomLogic];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidEnterBackGround:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameDidChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (_liveRoom) {
        [_liveRoom exitRoom:^(int errCode, NSString *errMsg) {
            NSLog(@"exitRoom: errCode[%d] errMsg[%@]", errCode, errMsg);
        }];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initUI {
    self.title = [NSString stringWithFormat:@"%@(%@)", _roomName, _userName];;
    [self.view setBackgroundColor:UIColorFromRGB(0x333333)];
    
    CGSize size = [[UIScreen mainScreen] bounds].size;
    int ICON_SIZE = size.width / 10;
    
    float startSpace = 30;
    float centerInterVal = (size.width - 2 * startSpace - ICON_SIZE) / 2;
    float iconY = size.height - ICON_SIZE / 2 - 10;
    if (@available(iOS 11, *)) {
        CGFloat bottomInset = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
        iconY -= bottomInset;
    }
    
    // 聊天
    _btnChat = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnChat.center = CGPointMake(startSpace + ICON_SIZE/2, iconY);
    _btnChat.bounds = CGRectMake(0, 0, ICON_SIZE, ICON_SIZE);
    [_btnChat setImage:[UIImage imageNamed:@"comment"] forState:UIControlStateNormal];
    [_btnChat addTarget:self action:@selector(clickChat:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnChat];
    
    // 请求连麦按钮
    _linkMicStatus = LinkMicStatus_IDEL;
    _btnLinkMic = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnLinkMic.center = CGPointMake(startSpace + ICON_SIZE/2 + centerInterVal * 1, iconY);
    _btnLinkMic.bounds = CGRectMake(0, 0, ICON_SIZE, ICON_SIZE);
    [_btnLinkMic setImage:[UIImage imageNamed:@"linkmic_start"] forState:UIControlStateNormal];
    [_btnLinkMic addTarget:self action:@selector(clickLinkMic:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnLinkMic];
    
    // log按钮
    _btnLog = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnLog.center = CGPointMake(startSpace + ICON_SIZE/2 + centerInterVal * 2, iconY);
    _btnLog.bounds = CGRectMake(0, 0, ICON_SIZE, ICON_SIZE);
    [_btnLog setImage:[UIImage imageNamed:@"log"] forState:UIControlStateNormal];
    [_btnLog addTarget:self action:@selector(clickLog:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnLog];
    
    // LOG界面
    _log_switch = 0;
    _logView = [[UITextView alloc] initWithFrame:CGRectMake(0, 80*kScaleY, size.width, size.height - 150*kScaleY)];
    _logView.backgroundColor = [UIColor clearColor];
    _logView.alpha = 1;
    _logView.textColor = [UIColor whiteColor];
    _logView.editable = NO;
    _logView.hidden = YES;
    [self.view addSubview:_logView];
    
    // 半透明浮层，用于方便查看log
    _coverView = [[UIView alloc] init];
    _coverView.frame = _logView.frame;
    _coverView.backgroundColor = [UIColor whiteColor];
    _coverView.alpha = 0.5;
    _coverView.hidden = YES;
    [self.view addSubview:_coverView];
    [self.view sendSubviewToBack:_coverView];
    
    // 消息列表展示和输入
    _msgListView = [[LiveRoomMsgListTableView alloc] initWithFrame:CGRectMake(10, self.view.height/3, 300, self.view.height/2) style:UITableViewStyleGrouped];
    _msgListView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_msgListView];
    
    _msgInputView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height, self.view.width, 50)];
    _msgInputView.backgroundColor = [UIColor clearColor];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, _msgInputView.height)];
    _msgInputTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, _msgInputView.width - 80, _msgInputView.height)];
    _msgInputTextField.backgroundColor = UIColorFromRGB(0xfdfdfd);
    _msgInputTextField.returnKeyType = UIReturnKeySend;
    _msgInputTextField.placeholder = @"输入文字内容";
    _msgInputTextField.delegate = self;
    _msgInputTextField.leftView = paddingView;
    _msgInputTextField.leftViewMode = UITextFieldViewModeAlways;
    _msgInputTextField.textColor = [UIColor blackColor];
    _msgInputTextField.font = [UIFont systemFontOfSize:14];
    
    _msgSendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _msgSendBtn.frame = CGRectMake(_msgInputView.width - 80, 0, 80, _msgInputView.height);
    [_msgSendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [_msgSendBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [_msgSendBtn setTitleColor:UIColorFromRGB(0x05a764) forState:UIControlStateNormal];
    [_msgSendBtn setBackgroundColor:UIColorFromRGB(0xfdfdfd)];
    [_msgSendBtn addTarget:self action:@selector(clickSend:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *vertical_line = [[UIView alloc] initWithFrame:CGRectMake(_msgSendBtn.left - 1, 6, 1, _msgInputView.height - 12)];
    vertical_line.backgroundColor = UIColorFromRGB(0xd8d8d8);
    
    [_msgInputView addSubview:_msgInputTextField];
    [_msgInputView addSubview:vertical_line];
    [_msgInputView addSubview:_msgSendBtn];
    [self.view addSubview:_msgInputView];
    
    // 播放大主播画面
    _playerView = [[UIView alloc] initWithFrame:self.view.frame];
    [_playerView setBackgroundColor:UIColorFromRGB(0x262626)];
    [self.view insertSubview:_playerView atIndex:0];
    
    // 自己作为小主播时的推流画面
    _pusherView = [[UIView alloc] initWithFrame:CGRectZero];
    [_pusherView setBackgroundColor:UIColorFromRGB(0x262626)];
    [self.view addSubview:_pusherView];
    _pusherView.hidden = YES;
}

- (void)relayout {
    // 重新布局自己的推流画面和其他小主播画面
    int index = 1;
    int originX = self.view.width - 110;
    int originY = self.view.height - 250;
    int videoViewWidth = 100;
    int videoViewHeight = 150;
    int spacing = 3;
    _pusherView.frame = CGRectMake(originX, originY, videoViewWidth, videoViewHeight);
    
    for (id userID in _playerViewDic) {
        UIView *playerView = [_playerViewDic objectForKey:userID];
        playerView.frame = CGRectMake(originX, originY - (spacing+videoViewHeight) * index, videoViewWidth, videoViewHeight);
        ++ index;
    }
}

- (void)initRoomLogic {
    [_liveRoom enterRoom:_roomID view:_playerView completion:^(int errCode, NSString *errMsg) {
        NSLog(@"enterRoom: errCode[%d] errMsg[%@]", errCode, errMsg);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (errCode == 0) {
                [self appendSystemMsg:@"连接成功"];
                
            } else {
                [self alertTips:@"进入直播间失败" msg:errMsg completion:^{
                    [self.navigationController popViewControllerAnimated:YES];
                }];
            }
        });
    }];
}

// 聊天
- (void)clickChat:(UIButton *)btn {
    [_msgInputTextField becomeFirstResponder];
}

- (void)clickLinkMic:(UIButton *)btn {
    if (_linkMicStatus == LinkMicStatus_IDEL) {  // 空闲状态
        _linkMicStatus = LinkMicStatus_REQUESTING;   // 请求连麦中
        
        [_liveRoom requestJoinAnchor:@"" completion:^(int errCode, NSString *errMsg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (errCode == 0) {
                    self->_pusherView.hidden = NO;
                    [self->_liveRoom startLocalPreview:YES view:self->_pusherView];
                    [self relayout];
                    
                    self->_linkMicStatus = LinkMicStatus_BEING;  // 连麦中
                    [btn setImage:[UIImage imageNamed:@"linkmic_stop"] forState:UIControlStateNormal];
                    
                    [self->_liveRoom joinAnchor:^(int errCode, NSString *errMsg) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (errCode != 0) {
                                [self alertTips:@"提示" msg:errMsg completion:^{
                                    [self onKickoutJoinAnchor];
                                }];
                            }
                        });
                        
                    }];
                    
                } else {
                    self->_linkMicStatus = LinkMicStatus_IDEL;  // 空闲状态
                    [self alertTips:@"提示" msg:errMsg completion:nil];
                }
            });
        }];
        
    } else if (_linkMicStatus == LinkMicStatus_BEING) {  // 连麦中
        [self onKickoutJoinAnchor];
    }
}

// 设置log显示
- (void)clickLog:(UIButton *)btn {
    switch (_log_switch) {
        case 0:
            _log_switch = 1;
            [_liveRoom showVideoDebugLog:YES];
            _logView.hidden = YES;
            _coverView.hidden = YES;
            [btn setImage:[UIImage imageNamed:@"log2"] forState:UIControlStateNormal];
            break;
        case 1:
            _log_switch = 2;
            [_liveRoom showVideoDebugLog:NO];
            _logView.hidden = NO;
            _coverView.hidden = NO;
            [self.view bringSubviewToFront:_logView];
            [btn setImage:[UIImage imageNamed:@"log2"] forState:UIControlStateNormal];
            break;
        case 2:
            _log_switch = 0;
            [_liveRoom showVideoDebugLog:NO];
            _logView.hidden = YES;
            _coverView.hidden = YES;
            [btn setImage:[UIImage imageNamed:@"log"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

// 发送消息
- (void)clickSend:(UIButton *)btn {
    [self textFieldShouldReturn:_msgInputTextField];
}

// 监听键盘高度变化
- (void)keyboardFrameDidChange:(NSNotification *)notice {
    NSDictionary * userInfo = notice.userInfo;
    NSValue * endFrameValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect endFrame = endFrameValue.CGRectValue;
    [UIView animateWithDuration:0.25 animations:^{
        if (endFrame.origin.y == self.view.height) {
            self->_msgInputView.y = endFrame.origin.y;
        } else {
            self->_msgInputView.y =  endFrame.origin.y - _msgInputView.height;
        }
    }];
}

- (void)appendLog:(NSString *)msg {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"hh:mm:ss";
    NSString *time = [format stringFromDate:[NSDate date]];
    NSString *log = [NSString stringWithFormat:@"[%@] %@", time, msg];
    NSString *logMsg = [NSString stringWithFormat:@"%@\n%@", _logView.text, log];
    [_logView setText:logMsg];
}

- (void)appendSystemMsg:(NSString *)msg {
    LiveRoomMsgModel *msgMode = [[LiveRoomMsgModel alloc] init];
    msgMode.type = LiveRoomMsgModeTypeSystem;
    msgMode.userMsg = msg;
    [_msgListView appendMsg:msgMode];
}

#pragma mark - LiveRoomListener

- (void)onRoomDestroy:(NSString *)roomID {
    [self alertTips:@"提示" msg:@"直播间已被解散" completion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)onDebugLog:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self appendLog:msg];
    });
}

- (void)onRecvRoomTextMsg:(NSString *)roomID userID:(NSString *)userID userName:(NSString *)userName userAvatar:(NSString *)userAvatar message:(NSString *)message {
    LiveRoomMsgModel *msgMode = [[LiveRoomMsgModel alloc] init];
    msgMode.type = LiveRoomMsgModeTypeOther;
    msgMode.time = [[NSDate date] timeIntervalSince1970];
    msgMode.userName = userName;
    msgMode.userMsg = message;
    
    [_msgListView appendMsg:msgMode];
}

- (LiveRoomAccPlayerView *)accPlayerViewForUID:(NSString *)uid {
    LiveRoomAccPlayerView *view = _playerViewDic[uid];
    if (view == nil) {
        view = [[LiveRoomAccPlayerView alloc] initWithFrame:self.view.bounds];
        [view setBackgroundColor:UIColorFromRGB(0x262626)];
        _playerViewDic[uid] = view;
    }
    return view;
}

- (void)removeAccViewForUID:(NSString *)uid {
    LiveRoomAccPlayerView *view = _playerViewDic[uid];
    if (view) {
        [view removeFromSuperview];
        [_playerViewDic removeObjectForKey:uid];
    }
}
/**
   获取房间pusher列表的回调通知
 */
- (void)onGetPusherList:(NSArray<MLVBAnchorInfo *> *)pusherInfoArray {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 播放其他小主播的画面
        for (MLVBAnchorInfo *anchorInfo in pusherInfoArray) {
            LiveRoomAccPlayerView *playerView = [self accPlayerViewForUID:anchorInfo.userID];
            [self.view addSubview:playerView];
            
            // 重新布局
            [self relayout];
            
            [self->_liveRoom startRemoteView:anchorInfo view:playerView onPlayBegin:^{
                playerView.loading = NO;
            } onPlayError:^(int errCode, NSString *errMsg) {
                [self onAnchorExit:anchorInfo];
            } playEvent:nil];
            
            //LOG
            [self appendLog:[NSString stringWithFormat:@"播放: userID[%@] userName[%@] accelerateURL[%@]", anchorInfo.userID, anchorInfo.userName, anchorInfo.accelerateURL]];
        }
    });
}

/**
   新的pusher加入直播(连麦)
 */
- (void)onAnchorEnter:(MLVBAnchorInfo *)anchorInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        LiveRoomAccPlayerView *playerView = [self accPlayerViewForUID:anchorInfo.userID];
        [self.view addSubview:playerView];
        
        // 重新布局
        [self relayout];
        
        [self->_liveRoom startRemoteView:anchorInfo view:playerView onPlayBegin:^{
            playerView.loading = NO;
        } onPlayError:^(int errCode, NSString *errMsg) {
            [self onAnchorExit:anchorInfo];
        } playEvent:nil];
    });
}

/**
   pusher退出直播(连麦)的通知
 */
- (void)onAnchorExit:(MLVBAnchorInfo *)anchorInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeAccViewForUID:anchorInfo.userID];
        [self relayout];
    });
}

/**
   小主播收到被大主播踢出连麦的通知
 */
- (void)onKickoutJoinAnchor {
    // UI及状态
    _pusherView.hidden = YES;
    [_btnLinkMic setImage:[UIImage imageNamed:@"linkmic_start"] forState:UIControlStateNormal];
    _linkMicStatus = LinkMicStatus_IDEL;
    
    // 关闭本地推流和预览，并退出pusher房间
    [_liveRoom stopLocalPreview];
    [_liveRoom quitJoinAnchor:^(int errCode, NSString *errMsg) {
        
    }];
    
    // 关闭播放器画面
    for (id userID in _playerViewDic) {
        UIView *playerView = [_playerViewDic objectForKey:userID];
        [playerView removeFromSuperview];
    }
    [_playerViewDic removeAllObjects];
}

- (void)onError:(int)errCode errMsg:(NSString *)errMsg extraInfo:(NSDictionary *)extraInfo {
    [self alertTips:@"提示" msg:errMsg completion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}


- (void)alertTips:(NSString *)title msg:(NSString *)msg completion:(void(^)())completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (completion) {
                completion();
            }
        }]];
        
        [self.navigationController presentViewController:alertController animated:YES completion:nil];
    });
}

#pragma NSNotification

- (void)handleInterruption:(NSNotification *)notification {
    AVAudioSessionInterruptionType type = [notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue];
    if (AVAudioSessionInterruptionTypeBegan == type) {
        _appIsInterrupt = YES;
        if (_liveRoom) {
        }
    }
    if (AVAudioSessionInterruptionTypeEnded == type) {
        _appIsInterrupt = NO;
        if (!_appIsBackground && !_appIsInActive && !_appIsInterrupt) {
            if (_liveRoom) {
            }
        }
    }
}

- (void)onAppWillResignActive:(NSNotification*)notification {
    _appIsInActive = YES;
    if (_liveRoom) {
    }
}

- (void)onAppDidBecomeActive:(NSNotification*)notification {
    _appIsInActive = NO;
    if (!_appIsBackground && !_appIsInActive && !_appIsInterrupt) {
        if (_liveRoom) {
        }
    }
}

- (void)onAppDidEnterBackGround:(NSNotification *)notification {
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        
    }];
    
    _appIsBackground = YES;
    if (_liveRoom) {
    }
}

- (void)onAppWillEnterForeground:(NSNotification *)notification {
    _appIsBackground = NO;
    if (!_appIsBackground && !_appIsInActive && !_appIsInterrupt) {
        if (_liveRoom) {
        }
    }
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    _msgInputTextField.text = @"";
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    _msgInputTextField.text = textField.text;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *textMsg = [textField.text stringByTrimmingCharactersInSet:[NSMutableCharacterSet whitespaceCharacterSet]];
    if (textMsg.length <= 0) {
        textField.text = @"";
        [self alertTips:@"提示" msg:@"消息不能为空" completion:nil];
        return YES;
    }
    
    LiveRoomMsgModel *msgMode = [[LiveRoomMsgModel alloc] init];
    msgMode.type = LiveRoomMsgModeTypeOther;
    msgMode.time = [[NSDate date] timeIntervalSince1970];
    msgMode.userName = _userName;
    msgMode.userMsg = textMsg;
    
    [_msgListView appendMsg:msgMode];
    
    _msgInputTextField.text = @"";
    [_msgInputTextField resignFirstResponder];
    
    // 发送
    [_liveRoom sendRoomTextMsg:textMsg completion:nil];
    
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_msgInputTextField resignFirstResponder];
    
    _touchBeginLocation = [[[event allTouches] anyObject] locationInView:self.view];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint location = [[[event allTouches] anyObject] locationInView:self.view];
    [self endMove:location.x - _touchBeginLocation.x];
}

// 滑动隐藏UI控件
- (void)endMove:(CGFloat)moveX {
    // 目前只需要隐藏消息列表控件
    [UIView animateWithDuration:0.2 animations:^{
        if (moveX > 10) {
            for (UIView *view in self.view.subviews) {
                if (![view isEqual:self->_msgListView]) {
                    continue;
                }
                
                CGRect rect = view.frame;
                if (rect.origin.x >= 0 && rect.origin.x < [UIScreen mainScreen].bounds.size.width) {
                    rect = CGRectOffset(rect, self.view.width, 0);
                    view.frame = rect;
                }
            }
            
        } else if (moveX < -10) {
            for (UIView *view in self.view.subviews) {
                if (![view isEqual:self->_msgListView]) {
                    continue;
                }
                
                CGRect rect = view.frame;
                if (rect.origin.x >= [UIScreen mainScreen].bounds.size.width) {
                    rect = CGRectOffset(rect, -self.view.width, 0);
                    view.frame = rect;
                }
            }
        }
    }];
}

@end

