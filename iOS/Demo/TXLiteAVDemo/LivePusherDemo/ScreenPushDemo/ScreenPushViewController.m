//
//  ScreenPushViewController.m
//  TXLiteAVDemo
//
//  Created by rushanting on 2018/5/24.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "ScreenPushViewController.h"
#import "UIView+Additions.h"
#import "MBProgressHUD.h"
#import "TCHttpUtil.h"
#import "ScanQRController.h"
#import "ReplayKit2Define.h"
#ifndef DISABLE_VOD
#import "TXVodPlayer.h"
#endif
#import "V2TXLivePusher.h"
#import "AddressBarController.h"
#import "AppDelegate.h"
#import "AppLocalized.h"
#import "NSString+Common.h"
#import <UserNotifications/UserNotifications.h>

@interface ScreenPushViewController () <AddressBarControllerDelegate, ScanQRDelegate, TXVodPlayListener, V2TXLivePusherObserver>
@property (nonatomic, retain) UISegmentedControl* rotateSelector;
@property (nonatomic, retain) UISegmentedControl* resolutionSelector;
@property (nonatomic, retain) UIButton* btnReplaykit;
@property (nonatomic, copy) NSString *playFlvUrl;
@property (nonatomic, retain) UIView* playerView;
@property (nonatomic, strong) V2TXLivePusher *livePusher;
#ifndef DISABLE_VOD
@property (nonatomic, retain) TXVodPlayer* vodPlayer;
#endif
@property (nonatomic, retain) UIButton* playBtn;
@property (nonatomic, retain) UIButton* fullScreenBtn;
@property (nonatomic, strong) AddressBarController *addressBarController;

@end

@implementation ScreenPushViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)dealloc
{
    [self.livePusher stopPush];
#ifndef DISABLE_VOD
    [_vodPlayer stopPlay];
#endif
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}


- (void)initUI
{
    //主界面排版
    self.title = LivePlayerLocalize(@"LivePusherDemo.ScreenPush.recordthelivescreen");
    
    //    self.view.backgroundColor = UIColor.blackColor;
    [self.view setBackgroundImage:[UIImage imageNamed:@"background.jpg"]];
    
    HelpBtnUI(录屏直播)
    
    _addressBarController = [[AddressBarController alloc] initWithButtonOption:AddressBarButtonOptionNew | AddressBarButtonOptionQRScan];
    _addressBarController.qrPresentView = self.view;
    CGSize size = [[UIScreen mainScreen] bounds].size;
    int ICON_SIZE = (int) (size.width / 8);
    CGFloat topOffset = [UIApplication sharedApplication].statusBarFrame.size.height;
    topOffset += self.navigationController.navigationBar.height+5;
    _addressBarController.view.frame = CGRectMake(10, topOffset, self.view.width-20, ICON_SIZE);
    
    NSDictionary *dic = @{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont systemFontOfSize:[NSString isCurrentLanguageEnglish] ? 11 : 15]};
    _addressBarController.view.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:LivePlayerLocalize(@"LivePusherDemo.ScreenPush.scantheqrcodeorclick") attributes:dic];
    _addressBarController.delegate = self;
    [self.view addSubview:_addressBarController.view];
    
    NSArray* rotations = @[LivePlayerLocalize(@"LivePusherDemo.ScreenPush.verticalscreen"),LivePlayerLocalize(@"LivePusherDemo.ScreenPush.landscape")];
    self.rotateSelector = [[UISegmentedControl alloc] initWithItems:rotations];
    self.rotateSelector.center = CGPointMake(self.view.center.x, _addressBarController.view.bottom + 60);
    self.rotateSelector.bounds = CGRectMake(0, 0, self.view.width - 100, 40);
    self.rotateSelector.tintColor = UIColor.whiteColor;
    self.rotateSelector.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.5];
    self.rotateSelector.selectedSegmentIndex = 0;
    [self.view addSubview:self.rotateSelector];
    [self.rotateSelector addTarget:self action:@selector(onSwitchRotation:) forControlEvents:UIControlEventValueChanged];
    
    NSArray* resolutions = @[LivePlayerLocalize(@"LivePusherDemo.PushSetting.superclear"), LivePlayerLocalize(@"LivePusherDemo.PushSetting.hd"), LivePlayerLocalize(@"LivePusherDemo.PushSetting.standarddefinition")];
    self.resolutionSelector = [[UISegmentedControl alloc] initWithItems:resolutions];
    self.resolutionSelector.center = CGPointMake(self.view.center.x, self.rotateSelector.bottom + 50);
    self.resolutionSelector.bounds = CGRectMake(0, 0, self.view.width - 100, 40);
    self.resolutionSelector.tintColor = UIColor.whiteColor;
    self.resolutionSelector.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.5];
    self.resolutionSelector.selectedSegmentIndex = 0;
    [self.resolutionSelector addTarget:self action:@selector(onSwitchresolution:) forControlEvents:UIControlEventValueChanged];

    [self.view addSubview:self.resolutionSelector];
    
    self.btnReplaykit = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnReplaykit .center = CGPointMake(self.view.center.x, self.resolutionSelector.bottom + 60);
    self.btnReplaykit .bounds = CGRectMake(0, 0, 100, 50);
    self.btnReplaykit.backgroundColor = UIColor.lightTextColor;
    self.btnReplaykit.layer.cornerRadius = 5;
    [self.btnReplaykit  setTitle:LivePlayerLocalize(@"LivePusherDemo.ScreenPush.startpushstream") forState:UIControlStateNormal];
    [self.btnReplaykit  addTarget:self action:@selector(clickStartReplaykit:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnReplaykit];

    UILabel* labelTipTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, self.btnReplaykit.bottom + 20, 200, 15)];
    labelTipTitle.textAlignment = NSTextAlignmentLeft;
    labelTipTitle.text = LivePlayerLocalize(@"LivePusherDemo.ScreenPush.instructionsforscreenrecording");
    labelTipTitle.textColor = UIColor.whiteColor;
    [labelTipTitle sizeToFit];
    [self.view addSubview:labelTipTitle];
    UILabel* labelTip = [[UILabel alloc] initWithFrame:CGRectMake(10, labelTipTitle.bottom - 12 , self.view.width - self.rotateSelector.left - 20, 100)];
    labelTip.numberOfLines = 3;
    labelTip.textAlignment = NSTextAlignmentLeft;
    labelTip.textColor = UIColor.whiteColor;
    labelTip.font = [UIFont systemFontOfSize:14];
    labelTip.text = LivePlayerLocalize(@"LivePusherDemo.ScreenPush.gotothecontrolcenterandlongpressthestartscreen");
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelTip.text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:6.f];//设置行间距
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, labelTip.text.length)];
    labelTip.attributedText = attributedString;
    [self.view addSubview:labelTip];
    
    _playerView = [UIView new];
    _playerView.bounds = CGRectMake(0, 0, self.view.width, self.view.width * 9 / 16);
    _playerView.center = CGPointMake(self.view.center.x, self.view.bottom - self.view.width * 9 / 16 / 2);
    [self.view addSubview:_playerView];
    
    _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playBtn setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
    [_playBtn addTarget:self action:@selector(onPlayBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    _playBtn.center = CGPointMake(_playerView.width / 2, _playerView.height / 2);
    _playBtn.bounds = CGRectMake(0, 0, 40, 40);
    [_playerView addSubview:_playBtn];
    
    _fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_fullScreenBtn setImage:[UIImage imageNamed:@"player_fullscreen"] forState:UIControlStateNormal];
    _fullScreenBtn.frame = CGRectMake(_playerView.width - 40, _playerView.height - 40, 40, 40);
    [_fullScreenBtn addTarget:self action:@selector(onFullScreenClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_playerView addSubview:_fullScreenBtn];
#ifndef DISABLE_VOD
    //播放演示视频
    _vodPlayer = [TXVodPlayer new];
    [_vodPlayer setIsAutoPlay:YES];
    [_vodPlayer setupVideoWidget:_playerView insertIndex:0];
    [_vodPlayer startPlay:@"http://1252463788.vod2.myqcloud.com/95576ef5vodtransgzp1252463788/1bfa444e7447398156520498412/v.f30.mp4"];
    _vodPlayer.vodDelegate = self;
#endif
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)onPlayBtnClicked:(UIButton*)button
{
#ifndef DISABLE_VOD

    if (_vodPlayer.isPlaying) {
        [_playBtn setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
        [_vodPlayer pause];
    }
    else {
        [_playBtn setImage:[UIImage imageNamed:@"suspend"] forState:UIControlStateNormal];
        [_vodPlayer resume];
    }
#endif

}

- (void)onFullScreenClicked:(UIButton*)button
{
#ifndef DISABLE_VOD

    if (_playerView.height != self.view.height) {
        _playerView.frame = self.view.bounds;
        [_vodPlayer setRenderRotation:HOME_ORIENTATION_RIGHT];
        _playBtn.center = self.view.center;
        _fullScreenBtn.frame = CGRectMake(_playerView.width - 40, _playerView.height - 40, 40, 40);
        _playBtn.transform = CGAffineTransformMakeRotation(M_PI / 2);
    }
    else {
        _playerView.bounds = CGRectMake(0, 0, self.view.width, self.view.width * 9 / 16);
        _playerView.center = CGPointMake(self.view.center.x, self.view.bottom - self.view.width * 9 / 16 / 2);
        _fullScreenBtn.frame = CGRectMake(_playerView.width - 40, _playerView.height - 40, 40, 40);
        _playBtn.center = CGPointMake(_playerView.width / 2, _playerView.height / 2);
        _playBtn.bounds = CGRectMake(0, 0, 40, 40);
        _playBtn.transform = CGAffineTransformIdentity;
        [_vodPlayer setRenderRotation:HOME_ORIENTATION_DOWN];
    }
#endif

}

- (void)addressBarControllerTapScanQR:(AddressBarController *)controller {

    ScanQRController *vc = [[ScanQRController alloc] init];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:NO];
}

- (void)addressBarControllerTapCreateURL:(AddressBarController *)controller
{

    MBProgressHUD* hub = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hub.mode = MBProgressHUDModeIndeterminate;
    hub.label.text = LivePlayerLocalize(@"LivePusherDemo.ScreenPush.addressinprocess");
    [hub showAnimated:YES];
    __weak ScreenPushViewController* weakSelf = self;
    [TCHttpUtil asyncSendHttpRequest:@"get_test_pushurl" httpServerAddr:kHttpServerAddr HTTPMethod:@"GET" param:nil handler:^(int result, NSDictionary *resultDict) {
        if (result != 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                hub.mode = MBProgressHUDModeText;
                hub.label.text = LivePlayerLocalize(@"LivePusherDemo.ScreenPush.failedtogetpushstreamaddress");
                [hub showAnimated:YES];
                [hub hideAnimated:YES afterDelay:2];
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
                                     c(LivePlayerLocalize(@"LivePusherDemo.CameraPush.lowlatency"), accPlayUrl)];
            
            NSString* playUrls = LocalizeReplaceFourCharacter(LivePlayerLocalize(@"LivePusherDemo.CameraPush.rtmpaddressxxflvaddressyyhlsaddresszz"), [NSString stringWithFormat:@"%@",rtmpPlayUrl], [NSString stringWithFormat:@"%@",flvPlayUrl], [NSString stringWithFormat:@"%@",hlsPlayUrl], [NSString stringWithFormat:@"%@",accPlayUrl]);
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = playUrls;
            weakSelf.playFlvUrl = flvPlayUrl;
            dispatch_async(dispatch_get_main_queue(), ^{
                hub.mode = MBProgressHUDModeText;
                hub.label.text = LivePlayerLocalize(@"LivePusherDemo.CameraPush.getaddresssuccess");
                hub.detailsLabel.text = LivePlayerLocalize(@"LivePusherDemo.CameraPush.playbackaddresshasbeencopiedtotheclipboard");
                [hub showAnimated:YES];
                [hub hideAnimated:YES afterDelay:2];
            });
        }
    }];
}

- (void)clickStartReplaykit:(UIButton*)btn
{
    if ([UIDevice currentDevice].systemVersion.floatValue < 11.0) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:LivePlayerLocalize(@"LivePusherDemo.ScreenPush.tencentcloudpushstream") message:LivePlayerLocalize(@"LivePusherDemo.ScreenPush.systempleaseupgrade") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action1 = [UIAlertAction actionWithTitle:LivePlayerLocalize(@"LiveLinkMicDemoOld.RoomList.determine") style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action1];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    if (self.addressBarController.text.length < 1) {
        NSString* message = LivePlayerLocalize(@"LivePusherDemo.ScreenPush.enterpushaddress");
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:LivePlayerLocalize(@"LivePusherDemo.ScreenPush.tencentcloudpushstream") message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action1 = [UIAlertAction actionWithTitle:LivePlayerLocalize(@"LiveLinkMicDemoOld.RoomList.determine") style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action1];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    NSString* btntitle = btn.currentTitle;
    BOOL isStart = [btntitle isEqualToString:LivePlayerLocalize(@"LivePusherDemo.ScreenPush.startpushstream")];
    
    if (isStart) {
        BOOL isCaptured = NO;
        if (@available(iOS 11, *)) {
            isCaptured = [UIScreen mainScreen].isCaptured;
        }
        if (!isCaptured) {
            NSString* message = LivePlayerLocalize(@"LivePusherDemo.ScreenPush.gotothecontrolcenter");

            UIAlertController* alert = [UIAlertController alertControllerWithTitle:LivePlayerLocalize(@"LivePusherDemo.ScreenPush.tencentcloudpushstream") message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* action1 = [UIAlertAction actionWithTitle:LivePlayerLocalize(@"LiveLinkMicDemoOld.RoomList.determine") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            UIAlertAction* action2 = [UIAlertAction actionWithTitle:LivePlayerLocalize(@"LivePusherDemo.PushSetting.cancel") style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:action1];
            [alert addAction:action2];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        else {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:LivePlayerLocalize(@"LivePusherDemo.ScreenPush.tencentcloudpushstream") message:LivePlayerLocalize(@"LivePusherDemo.ScreenPush.turnonscreenrecordingpushstreams") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* action1 = [UIAlertAction actionWithTitle:LivePlayerLocalize(@"LiveLinkMicDemoOld.RoomList.determine") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                V2TXLiveMode mode = V2TXLiveMode_RTMP;
                if ([self.addressBarController.text.lowercaseString hasPrefix:@"trtc://"]) {
                    mode = V2TXLiveMode_RTC;
                }
                self.livePusher = [[V2TXLivePusher alloc] initWithLiveMode:mode];
                [self.livePusher setObserver:self];
                if (@available(iOS 11.0, *)) {
                    [self.livePusher startScreenCapture:kReplayKit2AppGroupId];
                }
                [self refreshResolutionAndRotation];
                [[self.livePusher getDeviceManager] setSystemVolumeType:TXSystemVolumeTypeMedia];
                [self.livePusher startMicrophone];
                [self.livePusher startPush:self.addressBarController.text];
                [btn setTitle:LivePlayerLocalize(@"LivePusherDemo.ScreenPush.pushoverflow") forState:UIControlStateNormal];
            }];
            UIAlertAction *action2 = [UIAlertAction actionWithTitle:LivePlayerLocalize(@"LivePusherDemo.PushSetting.cancel") style:UIAlertActionStyleDefault handler:nil];
            
            [alert addAction:action1];
            [alert addAction:action2];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:LivePlayerLocalize(@"LivePusherDemo.ScreenPush.tencentcloudpushstream") message:LivePlayerLocalize(@"LivePusherDemo.ScreenPush.closescreenpushstream") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action1 = [UIAlertAction actionWithTitle:LivePlayerLocalize(@"LiveLinkMicDemoOld.RoomList.determine") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.livePusher stopPush];
            [btn setTitle:LivePlayerLocalize(@"LivePusherDemo.ScreenPush.startpushstream") forState:UIControlStateNormal];
        }];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:LivePlayerLocalize(@"LivePusherDemo.PushSetting.cancel") style:UIAlertActionStyleDefault handler:nil];
        
        [alert addAction:action1];
        [alert addAction:action2];
        [self presentViewController:alert animated:YES completion:nil];
    }
}


- (void)onReplayKit2RecordStop:(NSNotification*)noti
{
    [_btnReplaykit setTitle:LivePlayerLocalize(@"LivePusherDemo.ScreenPush.startpushstream") forState:UIControlStateNormal];
}

- (void)onSwitchRotation:(UISegmentedControl*)segment
{
    [self refreshResolutionAndRotation];
}

- (void)onSwitchresolution:(UISegmentedControl*)segment
{
    [self refreshResolutionAndRotation];
}

- (void)refreshResolutionAndRotation
{
    V2TXLiveVideoResolution resolution = V2TXLiveVideoResolution960x540;
    if (2 == self.resolutionSelector.selectedSegmentIndex) {
        resolution = V2TXLiveVideoResolution640x360;
    } else if (1 == self.resolutionSelector.selectedSegmentIndex) {
        resolution = V2TXLiveVideoResolution960x540;
    } else {
        resolution = V2TXLiveVideoResolution1280x720;
    }
    V2TXLiveVideoResolutionMode resMode = V2TXLiveVideoResolutionModePortrait;
    if (self.rotateSelector.selectedSegmentIndex) {
        resMode = V2TXLiveVideoResolutionModeLandscape;
    }
    [self.livePusher setVideoQuality:resolution resolutionMode:resMode];
}

#ifndef DISABLE_VOD
#pragma mark - VodDelegate
- (void) onPlayEvent:(TXVodPlayer *)player event:(int)EvtID withParam:(NSDictionary*)param
{
    if (EvtID == PLAY_EVT_PLAY_END) {
        [_playBtn setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
        [_vodPlayer pause];
    }
    else if (EvtID == PLAY_EVT_RCV_FIRST_I_FRAME) {
        [_vodPlayer pause];
    }
}

-(void) onNetStatus:(TXVodPlayer *)player withParam:(NSDictionary*)param {
}
#endif

#pragma mark -- V2TXLivePusherObserver
- (void)onError:(V2TXLiveCode)code
        message:(NSString *)msg
      extraInfo:(NSDictionary *)extraInfo {
    if (code == V2TXLIVE_ERROR_REQUEST_TIMEOUT) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self onScreenCaptureStoped:0];
        });
    }
}

#pragma mark - ScanQRDelegate
- (void)onScanResult:(NSString *)result {
    self.addressBarController.text = result;
}

#pragma mark - tool func
- (NSString *)dictionary2JsonString:(NSDictionary *)dict
{
    // 转成Json数据
    if ([NSJSONSerialization isValidJSONObject:dict])
    {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
        if(error)
        {
            NSLog(@"[%@] Post Json Error", [self class]);
        }
        NSString* jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return jsonString;
    }
    else
    {
        NSLog(@"[%@] Post Json is not valid", [self class]);
    }
    return nil;
}

#pragma mark - TXLivePushListener
- (void)onPushEvent:(int)EvtID withParam:(NSDictionary *)param {
    NSLog(@"onPushEvent %d", EvtID);
}

- (void)onNetStatus:(NSDictionary *)param {
}

- (void)onScreenCaptureStarted {
}

- (void)onScreenCapturePaused:(int)reason {
}

- (void)onScreenCaptureResumed:(int)reason {
}

- (void)onScreenCaptureStoped:(int)reason {
    [self.livePusher stopPush];
    [_btnReplaykit setTitle:LivePlayerLocalize(@"LivePusherDemo.ScreenPush.startpushstream") forState:UIControlStateNormal];
}

#pragma mark - localNotification
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


@end
