/**
 * Module:   PlayViewController
 *
 * Function: 使用LiteAVSDK完成直播播放
 */

#import "PlayViewController.h"
#import "V2TXLivePlayer.h"
#import "TXLivePlayer.h"
#import "AppDelegate.h"
#import "ScanQRController.h"
#import "AFNetworkReachabilityManager.h"
#import "UIView+Additions.h"
#import "UIImage+Additions.h"
#import "AddressBarController.h"
#import "TCHttpUtil.h"
#import "AppLocalized.h"
#import "NSString+Common.h"

#define PLAY_URL    @"LivePlayerDemo.PlayViewController.pleaseenterorscantheqrcode"
#define V2Log(_format_, ...) \
        NSLog(@"[%@ %p %s %d] %@", NSStringFromClass(self.class), self, __func__, __LINE__, [NSString stringWithFormat:_format_, ##__VA_ARGS__]);

#define CACHE_TIME_FAST             1.0f
#define CACHE_TIME_SMOOTH           5.0f

typedef NS_ENUM(NSInteger, ENUM_TYPE_CACHE_STRATEGY) {
    CACHE_STRATEGY_FAST           = 1,  // 极速
    CACHE_STRATEGY_SMOOTH         = 2,  // 流畅
    CACHE_STRATEGY_AUTO           = 3,  // 自动
};

@interface ToastTextView : UITextView
@property (nonatomic, strong) NSString *url;
@end

@interface PlayViewController() <
    V2TXLivePlayerObserver,
    AddressBarControllerDelegate,
    ScanQRDelegate,
    UITextFieldDelegate
    >
{
       
    AddressBarController *_addressBarController;  // 播放地址/二维码扫描 工具栏
    UIImageView          *_loadingImageView;      // 菊花
    UIView               *_videoView;             // 视频画面
    TX_Enum_PlayType     _playType;               // 播放类型
                
    UIButton             *_btnPlay;       // 开始/停止播放
    UIButton             *_btnLog;        // 显示日志
    UIButton             *_btnPortrait;   // 横屏/竖屏
    UIButton             *_btnRenderMode; // 渲染模式：(a) 图像铺满屏幕，不留黑边  (b) 图像适应屏幕，保持画面完整
    UIButton             *_btnStrategy;   // 播放缓存策略（延时调整）
    UIButton             *_btnRealtime;   // 低延时播放
    
    NSString             *_addressBeforeSwith; // 切换低延时前的地址
}

@property (nonatomic, strong) V2TXLivePlayer *player;
@property (nonatomic, strong) NSString *playUrl;

@end

@implementation PlayViewController

- (void)dealloc {
    [self stopPlay];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 创建播放器
    _player = [[V2TXLivePlayer alloc] init];
        
    // 界面布局
    [self initUI];
    if (@available(iOS 13.0, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)initUI {
    self.title = LivePlayerLocalize(@"LivePlayerDemo.PlayViewController.livestreamingplayer");
    [self.view setBackgroundImage:[UIImage imageNamed:@"background"]];
    
    int buttonCount = 4; // 底部一排按钮的数量
    CGSize size = [[UIScreen mainScreen] bounds].size;
    int ICON_WITH = size.width / (buttonCount + 1);
    ICON_WITH = MIN(ICON_WITH, 40); /// 最大40*40
    int ICON_HEIGHT = ICON_WITH;
    
    // 设置推流地址输入、二维码扫描工具栏
    _addressBarController = [[AddressBarController alloc] initWithButtonOption:AddressBarButtonOptionQRScan];
    _addressBarController.qrPresentView = self.view;
    CGFloat topOffset = [UIApplication sharedApplication].statusBarFrame.size.height;
    topOffset += (self.navigationController.navigationBar.height + 5);
    _addressBarController.view.frame = CGRectMake(10, topOffset, self.view.width-20, ICON_HEIGHT);
    NSDictionary *dic = @{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont systemFontOfSize:[NSString isCurrentLanguageEnglish] ? 13 : 15]};
    _addressBarController.view.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:LivePlayerLocalize(PLAY_URL) attributes:dic];
    _addressBarController.delegate = self;
    [self.view addSubview:_addressBarController.view];
    
    // 右上角Help按钮
    HelpBtnUI(直播播放器)
    
    // 创建底部的功能按钮
    float startSpace = 12;
    float centerInterVal = (size.width - 2 * startSpace - ICON_WITH) / (buttonCount - 1);
    float iconY = size.height - ICON_HEIGHT / 2 - 10;
    if (@available(iOS 11, *)) {
        iconY -= [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    }
    
    int index = 0;
    CGSize iconSize = CGSizeMake(ICON_WITH, ICON_HEIGHT);
    _btnPlay = [self createButton:@"start" action:@selector(clickPlay:)
                           center:CGPointMake(startSpace + ICON_WITH / 2 + centerInterVal*index++, iconY) size:iconSize];
    _btnLog = [self createButton:@"log" action:@selector(clickLog:)
                             center:CGPointMake(startSpace + ICON_WITH / 2 + centerInterVal*index++, iconY) size:iconSize];
    _btnPortrait = [self createButton:@"portrait" action:@selector(clickPortrait:)
                                center:CGPointMake(startSpace + ICON_WITH / 2 + centerInterVal*index++, iconY) size:iconSize];
    _btnRenderMode = [self createButton:@"fill" action:@selector(clickRenderMode:)
                          center:CGPointMake(startSpace + ICON_WITH / 2 + centerInterVal*index++, iconY) size:iconSize];
    
    // 菊花
    float width = 34;
    float height = 34;
    float offsetX = (self.view.frame.size.width - width) / 2;
    float offsetY = (self.view.frame.size.height - height) / 2;
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:[UIImage imageNamed:@"loading_image0.png"],[UIImage imageNamed:@"loading_image1.png"],[UIImage imageNamed:@"loading_image2.png"],[UIImage imageNamed:@"loading_image3.png"],[UIImage imageNamed:@"loading_image4.png"],[UIImage imageNamed:@"loading_image5.png"],[UIImage imageNamed:@"loading_image6.png"],[UIImage imageNamed:@"loading_image7.png"], nil];
    _loadingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(offsetX, offsetY, width, height)];
    _loadingImageView.animationImages = array;
    _loadingImageView.animationDuration = 1;
    _loadingImageView.hidden = YES;
    
    // 视频画面显示
    CGRect videoFrame = self.view.bounds;
    _videoView = [[UIView alloc] initWithFrame:CGRectMake(videoFrame.size.width, 0, videoFrame.size.width, videoFrame.size.height)];
    [self.view insertSubview:_videoView atIndex:0];
    
    // 默认播放地址
    _addressBarController.text = @"http://liteavapp.qcloud.com/live/liteavdemoplayerstreamid.flv";
}

- (UIButton *)createButton:(NSString*)icon action:(SEL)action center:(CGPoint)center size:(CGSize)size {
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.center = center;
    btn.bounds = CGRectMake(0, 0, size.width, size.height);
    btn.tag = 0; // 用这个来记录按钮的状态，默认0
    [btn setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    return btn;
}

#pragma mark - 控件响应函数

- (void)clickPlay:(UIButton *)btn {
    if (_btnPlay.tag == 0) {
        if (![self startPlay]) {
            return;
        }
        
        [_btnPlay setImage:[UIImage imageNamed:@"suspend"] forState:UIControlStateNormal];
        _btnPlay.tag = 1;
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        
    } else {
        [self stopPlay];
        
        [_btnPlay setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
        _btnPlay.tag = 0;
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    }
}

- (void)clickLog:(UIButton *)btn {
    if (_btnLog.tag == 0) {
        [_player showDebugView:YES];
        
        [_btnLog setImage:[UIImage imageNamed:@"log2"] forState:UIControlStateNormal];
        _btnLog.tag = 1;
        
    } else {
        [_player showDebugView:NO];

        [_btnLog setImage:[UIImage imageNamed:@"log"] forState:UIControlStateNormal];
        _btnLog.tag = 0;
    }
}

- (void)clickPortrait:(UIButton *)btn {
    if (_btnPortrait.tag == 1) {
        [_player setRenderRotation:V2TXLiveRotation0];
        
        [_btnPortrait setImage:[UIImage imageNamed:@"portrait"] forState:UIControlStateNormal];
        _btnPortrait.tag = 0;
        
    } else {
        [_player setRenderRotation:V2TXLiveRotation90];

        [_btnPortrait setImage:[UIImage imageNamed:@"landscape"] forState:UIControlStateNormal];
        _btnPortrait.tag = 1;
    }
}

- (void)clickRenderMode:(UIButton *)btn {
    if (_btnRenderMode.tag == 1) {
        [_player setRenderFillMode:V2TXLiveFillModeFit];
        
        [_btnRenderMode setImage:[UIImage imageNamed:@"fill"] forState:UIControlStateNormal];
        _btnRenderMode.tag = 0;
        
    } else {
        [_player setRenderFillMode:V2TXLiveFillModeFill];

        [_btnRenderMode setImage:[UIImage imageNamed:@"adjust"] forState:UIControlStateNormal];
        _btnRenderMode.tag = 1;
    }
}

- (void)clickRealtime:(UIButton *)btn {
    if (_btnRealtime.tag == 0) {
        [_btnRealtime setImage:[UIImage imageNamed:@"jisu_on"] forState:UIControlStateNormal];
        _btnRealtime.tag = 1;
        _addressBeforeSwith = _addressBarController.text;
        [self fetchAccURL];
        self.title = LivePlayerLocalize(@"LivePlayerDemo.PlayViewController.lowdelayplayback");

    } else {
        [_btnRealtime setImage:[UIImage imageNamed:@"jisu_off"] forState:UIControlStateNormal];
        _btnRealtime.tag = 0;
        _addressBarController.text = _addressBeforeSwith;
        self.title = LivePlayerLocalize(@"LivePlayerDemo.PlayViewController.livestreamingplayer");
    }
}

-(BOOL)checkPlayUrl:(NSString*)playUrl {
    BOOL isRealtime = _btnRealtime.tag;
    if (isRealtime) {
        _playType = PLAY_TYPE_LIVE_RTMP_ACC;
        if (!([playUrl containsString:@"txSecret"] || [playUrl containsString:@"txTime"])) {
            ToastTextView *toast = [self toastTip:LivePlayerLocalize(@"LivePlayerDemo.PlayViewController.lowdelaypullstreamaddress")];
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
        } else {
            [self toastTip:LivePlayerLocalize(@"LivePlayerDemo.PlayViewController.playaddressisnotlegal")];
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)startPlay {
    [_loadingImageView removeFromSuperview];
    NSString *playUrl = _addressBarController.text;
    if (![self checkPlayUrl:playUrl]) {
        return NO;
    }
    
    _videoView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [_player setObserver:self];
    [_player setRenderView:_videoView];
    [self.view addSubview:_loadingImageView];

    V2TXLiveCode ret = [_player startPlay:playUrl];
    if (ret != V2TXLIVE_OK) {
        NSLog(@"%@", LivePlayerLocalize(@"LivePlayerDemo.PlayViewController.playerstartfailed"));
        return NO;
    }
    
    // 播放参数初始化
    [_player showDebugView:(_btnLog.tag == 1)];
    [_player setRenderRotation:(_btnPortrait.tag == 0)?V2TXLiveRotation0:V2TXLiveRotation90];
    [_player setRenderFillMode:(_btnRenderMode.tag == 0)?V2TXLiveFillModeFit:V2TXLiveFillModeFill];
    
    [self startLoadingAnimation];
    _playUrl = playUrl;
    
    return YES;
}

- (void)stopPlay {
    [self stopLoadingAnimation];
    if (_player) {
        [_player setObserver:nil];
        [_player setRenderView:nil];
        [_player stopPlay];
    }
}

- (void)startLoadingAnimation {
    if (_loadingImageView != nil) {
        _loadingImageView.hidden = NO;
        [_loadingImageView startAnimating];
    }
}

- (void)stopLoadingAnimation {
    if (_loadingImageView != nil) {
        _loadingImageView.hidden = YES;
        [_loadingImageView stopAnimating];
    }
}

/// 检查网络
- (void)checkNet {
    BOOL isWifi = [AFNetworkReachabilityManager sharedManager].reachableViaWiFi;
    if (!isWifi) {
        __weak __typeof(self) weakSelf = self;
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            if (weakSelf.playUrl.length == 0) {
                return;
            }
            if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                               message:LivePlayerLocalize(@"LivePlayerDemo.PlayViewController.changewifitosee")
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:LivePlayerLocalize(@"LivePlayerDemo.PlayViewController.yes") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [alert dismissViewControllerAnimated:YES completion:nil];
                    
                    // 先停止，再重新播放
                    [weakSelf stopPlay];
                    [weakSelf startPlay];
                }]];
                [alert addAction:[UIAlertAction actionWithTitle:LivePlayerLocalize(@"LivePlayerDemo.PlayViewController.no") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    [alert dismissViewControllerAnimated:YES completion:nil];
                }]];
                [weakSelf presentViewController:alert animated:YES completion:nil];
            }
        }];
    }
}

#pragma mark - V2TXLivePlayerObserver

- (void)onAudioPlayStatusUpdate:(id<V2TXLivePlayer>)player status:(V2TXLivePlayStatus)status reason:(V2TXLiveStatusChangeReason)reason extraInfo:(NSDictionary *)extraInfo {
    switch (status) {
        case V2TXLivePlayStatusPlaying:
            //self.hasRecvFirstFrame = YES;
            [self stopLoadingAnimation];
            break;
        case V2TXLivePlayStatusLoading:
            [self startLoadingAnimation];
            break;
        case V2TXLivePlayStatusStopped:
            [self clickPlay:_btnPlay];
            break;
        default:
            break;
    }
}

- (void)onVideoPlayStatusUpdate:(id<V2TXLivePlayer>)player status:(V2TXLivePlayStatus)status reason:(V2TXLiveStatusChangeReason)reason extraInfo:(NSDictionary *)extraInfo {
    switch (status) {
        case V2TXLivePlayStatusPlaying:
            //self.hasRecvFirstFrame = YES;
            [self stopLoadingAnimation];
            if (reason == V2TXLiveStatusChangeReasonBufferingEnd) {
                [self checkNet];
            }
            break;
        case V2TXLivePlayStatusLoading:
            [self startLoadingAnimation];
            break;
        default:
            break;
    }
}

- (void)onPlayoutVolumeUpdate:(id<V2TXLivePlayer>)player
                       volume:(NSInteger)volume {
    V2Log(@"volume:%ld", volume);
}

- (void)onError:(id<V2TXLivePlayer>)player
           code:(V2TXLiveCode)code
        message:(NSString *)msg
      extraInfo:(NSDictionary *)extraInfo {
    [self stopPlay];
    V2Log(@"code:%ld msg:%@ extraInfo:%@", (long)code, msg, extraInfo);
}

- (void)onWarning:(id<V2TXLivePlayer>)player code:(V2TXLiveCode)code message:(NSString *)msg extraInfo:(NSDictionary *)extraInfo {
    V2Log(@"code:%ld msg:%@ extraInfo:%@", (long)code, msg, extraInfo);
}

- (void)onSnapshotComplete:(id<V2TXLivePlayer>)player image:(TXImage *)image {
    V2Log(@"image:%@", image);
}

- (void)onNetStatus:(NSDictionary *)param {
    
}

#pragma mark - AddressBarControllerDelegate

- (void)addressBarControllerTapScanQR:(AddressBarController *)controller {
    if (_btnPlay.tag == 1) {
        [self clickPlay:_btnPlay];
    }
    
    ScanQRController* vc = [[ScanQRController alloc] init];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:NO];
}

#pragma mark - ScanQRDelegate

- (void)onScanResult:(NSString *)result {
    _addressBarController.text = result;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - 辅助函数

/**
 * @method 获取指定宽度width的字符串在UITextView上的高度
 * @param textView 待计算的UITextView
 * @param width 限制字符串显示区域的宽度
 * @return 返回的高度
 */
- (float)heightForString:(UITextView *)textView andWidth:(float)width{
    CGSize sizeToFit = [textView sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    return sizeToFit.height + 30;
}

- (ToastTextView *)toastTip:(NSString*)toastInfo {
    CGRect frameRC = [[UIScreen mainScreen] bounds];
    frameRC.origin.y = frameRC.size.height - 150;
    frameRC.size.height -= 150;
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

- (void)fetchAccURL {
    __weak __typeof(self) wself = self;
    [TCHttpUtil asyncSendHttpRequest:@"get_test_rtmpaccurl" httpServerAddr:kHttpServerAddr HTTPMethod:@"GET" param:nil handler:^(int result, NSDictionary *resultDict) {
        __strong __typeof(wself) self = wself;
        if (self == nil) {
            return;
        }
        if (result != 0) {
            [self toastTip:LivePlayerLocalize(@"LivePlayerDemo.PlayViewController.failedtogetlowdelayplaybackaddress")];
        } else if (self->_btnRealtime.tag) {
            NSString* playUrl = nil;
            if (resultDict)
            {
                playUrl = resultDict[@"url_rtmpacc"];
            }
            self->_addressBarController.text = playUrl;
            [self toastTip:LivePlayerLocalize(@"LivePlayerDemo.PlayViewController.testaddressfromonline")];
        }
    }];
}
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

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
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
