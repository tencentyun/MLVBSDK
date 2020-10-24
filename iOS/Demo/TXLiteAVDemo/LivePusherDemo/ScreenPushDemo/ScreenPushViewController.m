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
#import "TXLivePush.h"
#import "AddressBarController.h"
#import "AppDelegate.h"
#import "SimpleIPC.h"

//#import "CWStatusBarNotification.h"

/**
 *InAppReplayKit2Pusher类只供录制本界面使用，示例SDK的自定义发送接口的使用方法。屏幕录制的示例代码在扩展中的SampleHandler里
 */
//@interface InAppReplayKit2Pusher  : NSObject<TXLivePushListener>
//@property (nonatomic, assign) BOOL isPushing;
//@property (nonatomic, assign) BOOL isStarting;
//
//+ (InAppReplayKit2Pusher *)sharedInstance;
//
//- (void)startPushWithUrl:(NSString *)pushUrl rotation:(NSString *)rotation resolution:(NSString *)resolution;
//- (void)stopPush;
//- (void)pausePush;
//- (void)resumePush;
//- (void)setCustomRotationAndResolution:(NSString*)rotation resolution:(NSString*)resolution;
//- (void)showRecodingStatus:(BOOL)isShow;
//
//@end

@interface ScreenPushViewController () <AddressBarControllerDelegate, ScanQRDelegate, TXVodPlayListener> {
    SimpleIPC *_ipc;
}
@property (nonatomic, retain) UISegmentedControl* rotateSelector;
@property (nonatomic, retain) UISegmentedControl* resolutionSelector;
@property (nonatomic, retain) UIButton* btnReplaykit;
@property (nonatomic, copy) NSString *playFlvUrl;
@property (nonatomic, retain) UIView* playerView;
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
    // Do any additional setup after loading the view.
    _ipc = [[SimpleIPC alloc] initWithPort:kReplayKitIPCPort];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReplayKit2RecordStop:) name:kCocoaNotificationNameReplayKit2Stop object:nil];

    [self initUI];
}

- (void)dealloc
{
#ifndef DISABLE_VOD
    [_vodPlayer stopPlay];
#endif
    [self _sendMessageToExtension:kDarvinNotificaiotnNamePushStop object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
//    [[InAppReplayKit2Pusher sharedInstance] stopPush];
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
    self.title = @"录屏直播";
    
    //    self.view.backgroundColor = UIColor.blackColor;
    [self.view setBackgroundImage:[UIImage imageNamed:@"background.jpg"]];
    
    HelpBtnUI(录屏直播)
    
    _addressBarController = [[AddressBarController alloc] initWithButtonOption:AddressBarButtonOptionNew | AddressBarButtonOptionQRScan];
    _addressBarController.qrPresentView = self.view;
    CGSize size = [[UIScreen mainScreen] bounds].size;
    int ICON_SIZE = (int) (size.width / 11);
    CGFloat topOffset = [UIApplication sharedApplication].statusBarFrame.size.height;
    topOffset += self.navigationController.navigationBar.height+5;
    _addressBarController.view.frame = CGRectMake(10, topOffset, self.view.width-20, ICON_SIZE);
    NSDictionary *dic = @{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont systemFontOfSize:15]};
    _addressBarController.view.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请地址扫描二维码或点New生成地址" attributes:dic];
    _addressBarController.delegate = self;
    [self.view addSubview:_addressBarController.view];
    
    NSArray* rotations = @[@"竖屏", @"横屏"];
    self.rotateSelector = [[UISegmentedControl alloc] initWithItems:rotations];
    self.rotateSelector.center = CGPointMake(self.view.center.x, _addressBarController.view.bottom + 60);
    self.rotateSelector.bounds = CGRectMake(0, 0, self.view.width - 100, 40);
    self.rotateSelector.tintColor = UIColor.whiteColor;
    self.rotateSelector.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.5];
    self.rotateSelector.selectedSegmentIndex = 0;
    [self.view addSubview:self.rotateSelector];
    [self.rotateSelector addTarget:self action:@selector(onSwitchRotation:) forControlEvents:UIControlEventValueChanged];
    
    NSArray* resolutions = @[@"超清", @"高清", @"标清"];
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
    [self.btnReplaykit  setTitle:@"开始推流" forState:UIControlStateNormal];
    [self.btnReplaykit  addTarget:self action:@selector(clickStartReplaykit:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnReplaykit];

    UILabel* labelTipTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, self.btnReplaykit.bottom + 20, 200, 15)];
    labelTipTitle.textAlignment = NSTextAlignmentLeft;
    labelTipTitle.text = @"屏幕录制操作说明:";
    labelTipTitle.textColor = UIColor.whiteColor;
    [labelTipTitle sizeToFit];
    [self.view addSubview:labelTipTitle];
    UILabel* labelTip = [[UILabel alloc] initWithFrame:CGRectMake(10, labelTipTitle.bottom - 12 , self.view.width - self.rotateSelector.left - 20, 100)];
    labelTip.numberOfLines = 3;
    labelTip.textAlignment = NSTextAlignmentLeft;
    labelTip.textColor = UIColor.whiteColor;
    labelTip.font = [UIFont systemFontOfSize:14];
    labelTip.text = @"      请先到控制中心长按启动屏幕录制(若无此项请从设置中的控制中心里添加)->选择视频云工具包启动后再回到此界面开始推流:";
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
    hub.label.text = @"地址获取中";
    [hub showAnimated:YES];
    __weak ScreenPushViewController* weakSelf = self;
    [TCHttpUtil asyncSendHttpRequest:@"get_test_pushurl" httpServerAddr:kHttpServerAddr HTTPMethod:@"GET" param:nil handler:^(int result, NSDictionary *resultDict) {
        if (result != 0)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
//                _hub = [MBProgressHUD HUDForView:weakSelf.view];
                hub.mode = MBProgressHUDModeText;
                hub.label.text = @"获取推流地址失败";
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
                                     c(@"低延时", accPlayUrl)];
            NSString* playUrls = [NSString stringWithFormat:@"rtmp播放地址:%@\n\nflv播放地址:%@\n\nhls播放地址:%@\n\n低延时播放地址:%@", rtmpPlayUrl, flvPlayUrl, hlsPlayUrl, accPlayUrl];
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = playUrls;
            weakSelf.playFlvUrl = flvPlayUrl;
            dispatch_async(dispatch_get_main_queue(), ^{
//                _hub = [MBProgressHUD HUDForView:weakSelf.view];
                hub.mode = MBProgressHUDModeText;
                hub.label.text = @"获取地址成功";
                hub.detailsLabel.text = @"播放地址已复制到剪贴板";
                [hub showAnimated:YES];
                [hub hideAnimated:YES afterDelay:2];
//                controller.qrString = accPlayUrl;
            });
        }
    }];
}

- (void)clickStartReplaykit:(UIButton*)btn
{
    if ([UIDevice currentDevice].systemVersion.floatValue < 11.0) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"腾讯云录屏推流" message:@"录屏只支持iOS11以上系统，请升级！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action1];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    if (self.addressBarController.text.length < 1) {
        NSString* message = @"请输入推流地址";
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"腾讯云录屏推流" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action1];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    NSString* btntitle = btn.currentTitle;
    BOOL isStart = [btntitle isEqualToString:@"开始推流"];
    
    if (isStart) {
        NSString* resolution = kResolutionFHD;
        if (self.resolutionSelector.selectedSegmentIndex == 1) {
            resolution = kResolutionHD;
        }
        else if (self.resolutionSelector.selectedSegmentIndex == 2) {
            resolution = kResolutionSD;
        }
        
        NSString* rotation = self.rotateSelector.selectedSegmentIndex == 0?kReplayKit2Portrait:kReplayKit2Lanscape;
        BOOL isCaptured = NO;
        if (@available(iOS 11, *)) {
            isCaptured = [UIScreen mainScreen].isCaptured;
        }
        if (!isCaptured) {
            NSString* message = @"请先到控制中心->长按启动屏幕录制";

            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"腾讯云录屏推流" message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                [[InAppReplayKit2Pusher  sharedInstance] startPushWithUrl:self.addressBarController.text rotation:rotation resolution:resolution];
//                [btn setTitle:@"结束推流" forState:UIControlStateNormal];
            }];
            UIAlertAction* action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:action1];
            [alert addAction:action2];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        else {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"腾讯云录屏推流" message:@"确定要开启屏幕录制推流?" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//              正式应用不建议合用剪贴板传值。建议配置appgroup，使用NSUserDefault的方式传值
//                NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kReplayKit2AppGroupId];
//                [defaults setObject:_rtcRoom.roomID forKey:kReplayKit2UserDefaultRoomidKey];
//                [defaults synchronize];
                NSMutableDictionary* dict = [NSMutableDictionary new];
                [dict setObject:self.addressBarController.text forKey:kReplayKit2PushUrlKey];
                [dict setObject:rotation forKey:kReplayKit2RotateKey];
                if (self.playFlvUrl)
                    [dict setObject:self.playFlvUrl forKey:@"flv播放地址"];

                [dict setObject:resolution forKey:kReplayKit2ResolutionKey];

                [self _sendMessageToExtension:kDarvinNotificationNamePushStart object:dict];

                [btn setTitle:@"结束推流" forState:UIControlStateNormal];
            }];
            UIAlertAction* action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
            
            [alert addAction:action1];
            [alert addAction:action2];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    else {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"腾讯云录屏推流" message:@"确定要关闭录屏推流?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kReplayKit2AppGroupId];
//            [defaults setObject:_rtcRoom.roomID forKey:kReplayKit2UserDefaultRoomidKey];
//            [defaults synchronize];
            [btn setTitle:@"开始推流" forState:UIControlStateNormal];
            
//            if ([InAppReplayKit2Pusher  sharedInstance].isPushing) {
//                [[InAppReplayKit2Pusher  sharedInstance] stopPush];
//                return;
//            }
            [self _sendMessageToExtension:kDarvinNotificaiotnNamePushStop object:@{}];
        }];
        UIAlertAction* action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
        
        [alert addAction:action1];
        [alert addAction:action2];
        [self presentViewController:alert animated:YES completion:nil];

    }
}


- (void)onReplayKit2RecordStop:(NSNotification*)noti
{
    [_btnReplaykit setTitle:@"开始推流" forState:UIControlStateNormal];
}

- (void)onSwitchRotation:(UISegmentedControl*)segment
{
    //建议使用正式的appgroup的NSUserDefaults方式传值
    //            NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kReplayKit2AppGroupId];
    //            [defaults setObject:self.rotateSelector.selectedSegmentIndex == 0?kReplayKit2Portrait:kReplayKit2Lanscape forKey:kReplayKit2RotateKey];
    //            [defaults synchronize];
    NSString* rotation = self.rotateSelector.selectedSegmentIndex == 0?kReplayKit2Portrait:kReplayKit2Lanscape;
//    if ([InAppReplayKit2Pusher  sharedInstance].isPushing) {
//        NSString* resolution = kResolutionFHD;
//        if (self.resolutionSelector.selectedSegmentIndex == 1) {
//            resolution = kResolutionHD;
//        }
//        else if (self.resolutionSelector.selectedSegmentIndex == 2) {
//            resolution = kResolutionSD;
//        }
//        [[InAppReplayKit2Pusher  sharedInstance] setCustomRotationAndResolution:rotation resolution:resolution];
//        return;
//    }
    [self _sendMessageToExtension:kDarvinNotificaiotnNameRotationChange
                           object:@{kReplayKit2RotateKey: rotation}];
}

- (void)onSwitchresolution:(UISegmentedControl*)segment
{

    NSString* resolution = kResolutionFHD;
    if (self.resolutionSelector.selectedSegmentIndex == 1) {
        resolution = kResolutionHD;
    }
    else if (self.resolutionSelector.selectedSegmentIndex == 2) {
        resolution = kResolutionSD;
    }
//    if ([InAppReplayKit2Pusher  sharedInstance].isPushing) {
//        NSString* rotation = self.rotateSelector.selectedSegmentIndex == 0?kReplayKit2Portrait:kReplayKit2Lanscape;
//        [[InAppReplayKit2Pusher  sharedInstance] setCustomRotationAndResolution:rotation resolution:resolution];
//        return;
//    }
    NSMutableDictionary* dict = [NSMutableDictionary new];
    [dict setObject:resolution forKey:kReplayKit2ResolutionKey];

    [self _sendMessageToExtension:kDarvinNotificaiotnNameResolutionChange
                           object:dict];
}

- (void)_sendMessageToExtension:(CFStringRef)message object:(NSDictionary *)object {
    if (object) {
#if kReplayKitUseAppGroup
        NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kReplayKit2AppGroupId];
        [defaults setValuesForKeysWithDictionary:object];
        [defaults synchronize];
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), message, NULL, nil, YES);
#else
//        UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:@"TXLiteAV" create:YES];
//        NSString* transString = [self dictionary2JsonString:object];
//        if (!transString)
//            return;
//        pasteboard.string = transString;
        [_ipc sendCmd:(__bridge NSString *)message info:object];
#endif
    }
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

@end





//@interface InAppReplayKit2Pusher()
//@property (nonatomic) TXLivePush* livePusher;
//@end
//
//@implementation InAppReplayKit2Pusher  {
//    CWStatusBarNotification *_notification;
//}
//
//
//+ (InAppReplayKit2Pusher *)sharedInstance
//{
//    static InAppReplayKit2Pusher * s_instance = nil;
//    static dispatch_once_t onceToken ;
//    dispatch_once(&onceToken, ^{
//        s_instance = [[InAppReplayKit2Pusher  alloc] init] ;
//    });
//
//    return s_instance ;
//}
//
//- (id)init
//{
//    if (self = [super init]) {
//        _notification = [CWStatusBarNotification new];
//        _notification.notificationLabelBackgroundColor = [UIColor redColor];
//        _notification.notificationLabelTextColor = [UIColor whiteColor];
//
//
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
//    }
//    return self;
//}
//
//- (void)onAppWillResignActive:(NSNotification *)notification
//{
//    if(@available(iOS 11.0, *)) {
//        [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
//        if (_isPushing) {
//            [self pausePush];
//        }
//    }
//}
//
//- (void)onAppDidBecomeActive:(NSNotification *)notification
//{
//    if(@available(iOS 11.0, *)) {
//        if (_isPushing) {
//            [self resumePush];
//        }
//    }
//}
//
//- (void)startPushWithUrl:(NSString *)pushUrl rotation:(NSString *)rotation resolution:(NSString *)resolution;
//{
//    if (_livePusher)
//        [_livePusher stopPush];
//
//    //使用自定义音视频发送接口时的初始化
//    TXLivePushConfig* pushConfigs = [[TXLivePushConfig alloc] init];
//    pushConfigs.customModeType |= CUSTOM_MODE_VIDEO_CAPTURE; //自定义视频
//    pushConfigs.enableAutoBitrate = YES;
//    pushConfigs.autoSampleBufferSize = NO;
//    pushConfigs.enableHWAcceleration = YES;
//
//    pushConfigs.customModeType |=  CUSTOM_MODE_AUDIO_CAPTURE; //自定义音频
//    pushConfigs.audioSampleRate = AUDIO_SAMPLE_RATE_44100;
//    pushConfigs.audioChannels = 1;
//    pushConfigs.pauseImg = [UIImage imageNamed:@"pause_publish.jpg"];
//    _livePusher = [[TXLivePush alloc] initWithConfig:pushConfigs];
//    _livePusher.delegate = self;
//    [self setCustomRotationAndResolution:rotation resolution:resolution];
//    [_livePusher startPush:pushUrl];
//    _isStarting = NO;
//    [self startInAppScreenCapture];
//    _isPushing = YES;
//
//}
//
//- (void)startInAppScreenCapture
//{
//    if(@available(iOS 11.0, *)) {
//        if (_isStarting)
//            return;
//        _isStarting = YES;
//        __weak __typeof(self) weakSelf = self;
//        [[RPScreenRecorder sharedRecorder] setMicrophoneEnabled:YES];
//        //仅竖屏
//        [[RPScreenRecorder sharedRecorder] startCaptureWithHandler:^(CMSampleBufferRef  _Nonnull sampleBuffer, RPSampleBufferType bufferType, NSError * _Nullable error) {
//            if (error == nil) {
//                switch (bufferType) {
//                    case RPSampleBufferTypeVideo:
//                        if(CMSampleBufferIsValid(sampleBuffer)){
//                            [weakSelf.livePusher sendVideoSampleBuffer:sampleBuffer];
//                        }
//                        else {
//                            NSLog(@"video samplebuffer is invalid");
//                        }
//                        break;
//
//                    case RPSampleBufferTypeAudioApp:
//                        if(CMSampleBufferDataIsReady(sampleBuffer)){
//                            [weakSelf.livePusher sendAudioSampleBuffer:sampleBuffer withType:RPSampleBufferTypeAudioApp];
//                        }
//                        break;
//
//                    case RPSampleBufferTypeAudioMic:
//                        if(CMSampleBufferDataIsReady(sampleBuffer)){
//                            [weakSelf.livePusher sendAudioSampleBuffer:sampleBuffer withType:RPSampleBufferTypeAudioMic];
//                        }
//                        break;
//
//                    default:
//                        break;
//                }
//            }
//            else{
//                NSLog(@"push buffer error : %@", error);
//            }
//        } completionHandler:^(NSError * _Nullable error) {
//            if (error) {
//                NSLog(@"push buffer fail : %@", error);
////                [self stopInAppScreenCapture];
//            }
//            else {
//                NSLog(@"startCapture completion");
//                // [_notification displayNotificationWithMessage:@"界面采集已启动。注:只采集本界面" forDuration:5];
//                //                触发一次UI变化，否则replaykit可能无数据采集
//                _isStarting = NO;
//
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [_notification displayNotificationWithMessage:@"界面采集已启动。注:只采集本界面" forDuration:1];
//                });
//            }
//        }];
//        //        [[RPScreenRecorder sharedRecorder] setMicrophoneEnabled:YES];
//
//    }
//}
//
//- (void)stopPush
//{
//    [self stopInAppScreenCapture];
//    [_livePusher stopPush];
//    _livePusher.delegate = nil;
//    _livePusher = nil;
//    _isPushing = NO;
//    [_notification dismissNotification];
//
//}
//
//- (void)stopInAppScreenCapture
//{
//    if(@available(iOS 11.0, *)) {
//        [[RPScreenRecorder sharedRecorder] stopCaptureWithHandler:^(NSError * _Nullable error) {
//            if (error) {
//                NSLog(@"stop screen push error %@", error);
//            }
//            else{
//                NSLog(@"stop screen push");
//            }
//        }];
//    }
//}
//
//- (void)pausePush
//{
//    [_livePusher pausePush];
//    [self stopInAppScreenCapture];
//}
//
//- (void)resumePush
//{
//    [self startInAppScreenCapture];
//    [_livePusher resumePush];
//}
//
//- (void)setCustomRotationAndResolution:(NSString *)rotation resolution:(NSString *)resolution
//{
//    TXLivePushConfig* config = _livePusher.config;
//    CGSize screenSize = [[UIScreen mainScreen] currentMode].size;
//    config.homeOrientation = HOME_ORIENTATION_DOWN;
//
//    if ([resolution isEqualToString:kResolutionSD]) {
//        config.sampleBufferSize = CGSizeMake(368, (uint)(360 * screenSize.height / screenSize.width));
//        config.videoBitrateMin = 400;
//        config.videoBitratePIN = 800;
//        config.videoBitrateMax = 1200;
//        config.videoFPS = 20;
//    }
//    else if ([resolution isEqualToString:kResolutionFHD]) {
//        config.sampleBufferSize = CGSizeMake(720, (uint)(720 * screenSize.height / screenSize.width)); //建议不超过720P
//        config.videoBitrateMin = 1200;
//        config.videoBitratePIN = 1800;
//        config.videoBitrateMax = 2400;
//        config.videoFPS = 30;
//
//    }
//    else {
//        config.sampleBufferSize = CGSizeMake(544, (uint)(540 * screenSize.height / screenSize.width));
//        config.videoBitrateMin = 800;
//        config.videoBitratePIN = 1400;
//        config.videoBitrateMax = 1800;
//        config.videoFPS = 24;
//    }
//
//    if ([rotation isEqualToString:kReplayKit2Lanscape]) {
//        config.sampleBufferSize = CGSizeMake(config.sampleBufferSize.height, config.sampleBufferSize.width);
//        config.homeOrientation = HOME_ORIENTATION_RIGHT;
//    }
//    [_livePusher setConfig:config];
//}
//
//- (void)showRecodingStatus:(BOOL)isShow
//{
//    if (isShow) {
//        if (!_notification.notificationIsShowing)
//            [_notification displayNotificationWithMessage:@"App录屏推流中" completion:nil];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self showRecodingStatus:_isPushing];
//        });
//    }
//    else {
//        [_notification dismissNotification];
//    }
//}
//
//
//- (void)onPushEvent:(int)EvtID withParam:(NSDictionary *)param; {
//    if (EvtID == PUSH_ERR_NET_DISCONNECT) {
//        [self stopPush];
//        [_notification displayNotificationWithMessage:@"推流失败，请换个姿势再试一次" completion:nil];
//    }
//    else if (EvtID == PUSH_EVT_PUSH_BEGIN) {
//        //        [_notification dismissNotification];
//        [_notification displayNotificationWithMessage:@"连接服务器成功，开始推流" forDuration:3];
//        [self showRecodingStatus:YES];
//    } else if (EvtID == PUSH_WARNING_NET_BUSY) {
//        [_notification displayNotificationWithMessage:@"您当前的网络环境不佳，请尽快更换网络保证正常直播" forDuration:5];
//    }
//}
//
//- (void)onNetStatus:(NSDictionary *)param
//{
//
//}

//@end
