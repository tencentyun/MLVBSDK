/**
 * Module:   PlayViewController
 *
 * Function: 使用LiteAVSDK完成直播播放
 */

#import "PlayViewController.h"
#import "TXLivePlayer.h"
#import "AppDelegate.h"
#import "ScanQRController.h"
#import "AFNetworkReachabilityManager.h"
#import "UIView+Additions.h"
#import "UIImage+Additions.h"
#import "AddressBarController.h"
#import "TCHttpUtil.h"

#define PLAY_URL    @"请输入或扫二维码获取播放地址"

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
    TXLivePlayListener,
    AddressBarControllerDelegate,
    ScanQRDelegate,
    UITextFieldDelegate
    >
{
       
    AddressBarController *_addressBarController;  // 播放地址/二维码扫描 工具栏
    UIImageView          *_loadingImageView;      // 菊花
    UIView               *_videoView;             // 视频画面
    TX_Enum_PlayType     _playType;               // 播放类型
        
    UIView               *_cacheStrategyView;     // 延时调整选项面板
    UIButton             *_radioBtnFast;          // 急速
    UIButton             *_radioBtnSmooth;        // 流畅
    UIButton             *_radioBtnAuto;          // 自动
        
    UIButton             *_btnPlay;       // 开始/停止播放
    UIButton             *_btnLog;        // 显示日志
    UIButton             *_btnHW;         // 开启硬件加速
    UIButton             *_btnPortrait;   // 横屏/竖屏
    UIButton             *_btnRenderMode; // 渲染模式：(a) 图像铺满屏幕，不留黑边  (b) 图像适应屏幕，保持画面完整
    UIButton             *_btnStrategy;   // 播放缓存策略（延时调整）
    UIButton             *_btnRealtime;   // 低延时播放
    
    NSString             *_addressBeforeSwith; // 切换低延时前的地址
}

@property (nonatomic, strong) TXLivePlayer *player;
@property (nonatomic, strong) NSString *playUrl;

@end

@implementation PlayViewController

- (void)dealloc {
    [self stopPlay];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 创建播放器
    _player = [[TXLivePlayer alloc] init];
    
    TXLivePlayConfig* config = _player.config;
    // 开启 flvSessionKey 数据回调
    //config.flvSessionKey = @"X-Tlive-SpanId";
    // 允许接收消息
    config.enableMessage = YES;
    [_player setConfig:config];
    
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
    self.title = @"直播播放器";
    [self.view setBackgroundImage:[UIImage imageNamed:@"background"]];
    
    int buttonCount = 7; // 底部一排按钮的数量
    CGSize size = [[UIScreen mainScreen] bounds].size;
    int ICON_SIZE = size.width / (buttonCount + 1);
    
    // 设置推流地址输入、二维码扫描工具栏
    _addressBarController = [[AddressBarController alloc] initWithButtonOption:AddressBarButtonOptionQRScan];
    _addressBarController.qrPresentView = self.view;
    CGFloat topOffset = [UIApplication sharedApplication].statusBarFrame.size.height;
    topOffset += (self.navigationController.navigationBar.height + 5);
    _addressBarController.view.frame = CGRectMake(10, topOffset, self.view.width-20, ICON_SIZE);
    NSDictionary *dic = @{NSForegroundColorAttributeName:[UIColor blackColor], NSFontAttributeName:[UIFont systemFontOfSize:15]};
    _addressBarController.view.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:PLAY_URL attributes:dic];
    _addressBarController.delegate = self;
    [self.view addSubview:_addressBarController.view];
    
    // 右上角Help按钮
    HelpBtnUI(直播播放器)
    
    // 创建底部的功能按钮
    float startSpace = 12;
    float centerInterVal = (size.width - 2 * startSpace - ICON_SIZE) / (buttonCount - 1);
    float iconY = size.height - ICON_SIZE / 2 - 10;
    if (@available(iOS 11, *)) {
        iconY -= [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    }
    
    _btnPlay = [self createButton:@"start" action:@selector(clickPlay:)
                           center:CGPointMake(startSpace + ICON_SIZE / 2, iconY) size:ICON_SIZE];
    _btnLog = [self createButton:@"log" action:@selector(clickLog:)
                             center:CGPointMake(startSpace + ICON_SIZE / 2 + centerInterVal, iconY) size:ICON_SIZE];
    _btnHW = [self createButton:@"quick2" action:@selector(clickHW:)
                                center:CGPointMake(startSpace + ICON_SIZE / 2 + centerInterVal * 2, iconY) size:ICON_SIZE];
    _btnPortrait = [self createButton:@"portrait" action:@selector(clickPortrait:)
                                center:CGPointMake(startSpace + ICON_SIZE / 2 + centerInterVal * 3, iconY) size:ICON_SIZE];
    _btnRenderMode = [self createButton:@"fill" action:@selector(clickRenderMode:)
                          center:CGPointMake(startSpace + ICON_SIZE / 2 + centerInterVal * 4, iconY) size:ICON_SIZE];
    _btnStrategy = [self createButton:@"cache_time" action:@selector(clickStrategy:)
                          center:CGPointMake(startSpace + ICON_SIZE / 2 + centerInterVal * 5, iconY) size:ICON_SIZE];
    _btnRealtime = [self createButton:@"jisu_off" action:@selector(clickRealtime:)
                              center:CGPointMake(startSpace + ICON_SIZE / 2 + centerInterVal * 6, iconY) size:ICON_SIZE];
    
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
    
    // 延时调整选项面板
    [self addCacheStrategyView];
    [self setCacheStrategy:CACHE_STRATEGY_AUTO];  // 默认自动
    
    // 视频画面显示
    CGRect videoFrame = self.view.bounds;
    _videoView = [[UIView alloc] initWithFrame:CGRectMake(videoFrame.size.width, 0, videoFrame.size.width, videoFrame.size.height)];
    [self.view insertSubview:_videoView atIndex:0];
    
    // 默认播放地址
    _addressBarController.text = @"http://liteavapp.qcloud.com/live/liteavdemoplayerstreamid.flv";
}

- (UIButton *)createButton:(NSString*)icon action:(SEL)action center:(CGPoint)center size:(int)size {
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.center = center;
    btn.bounds = CGRectMake(0, 0, size, size);
    btn.tag = 0; // 用这个来记录按钮的状态，默认0
    [btn setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    return btn;
}

- (void)addCacheStrategyView {
    CGSize size = [[UIScreen mainScreen] bounds].size;
    UIView *sView = [[UIView alloc]init];
    
    sView.frame = CGRectMake(0, size.height - 120, size.width, 120);
    [sView setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *title= [[UILabel alloc]init];
    title.frame = CGRectMake(0, 0, size.width, 50);
    [title setText:@"延迟调整"];
    title.textAlignment = NSTextAlignmentCenter;
    [title setFont:[UIFont fontWithName:@"" size:14]];
    
    [sView addSubview:title];
    
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
    
    _radioBtnAuto = [UIButton buttonWithType:UIButtonTypeCustom];
    _radioBtnAuto.frame = CGRectMake(size.width - 10 - width2, 60, width2, 40);
    [_radioBtnAuto setTitle:@"自动" forState:UIControlStateNormal];
    [_radioBtnAuto addTarget:self action:@selector(onAdjustAuto:) forControlEvents:UIControlEventTouchUpInside];
    
    [sView addSubview:_radioBtnFast];
    [sView addSubview:_radioBtnSmooth];
    [sView addSubview:_radioBtnAuto];
    sView.hidden = YES;
    
    _cacheStrategyView = sView;
    [self.view addSubview:_cacheStrategyView];
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
        [_player setLogViewMargin:UIEdgeInsetsMake(120, 10, 60, 10)];
        [_player showVideoDebugLog:YES];
        
        [_btnLog setImage:[UIImage imageNamed:@"log2"] forState:UIControlStateNormal];
        _btnLog.tag = 1;
        
    } else {
        [_player setLogViewMargin:UIEdgeInsetsMake(120, 10, 60, 10)];
        [_player showVideoDebugLog:NO];
        
        [_btnLog setImage:[UIImage imageNamed:@"log"] forState:UIControlStateNormal];
        _btnLog.tag = 0;
    }
}

- (void)clickHW:(UIButton *)btn {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
        [self toastTip:@"iOS 版本低于8.0，不支持硬件加速."];
        return;
    }
    
    if (_btnPlay.tag == 1) {
        [_player stopPlay];
    }
    
    _player.enableHWAcceleration = !_player.enableHWAcceleration;
    BOOL isHW = _player.enableHWAcceleration;
    [_btnHW setImage:[UIImage imageNamed:(isHW ? @"quick" : @"quick2")] forState:UIControlStateNormal];
    
    if (_btnPlay.tag == 1) {
        if (isHW) {
            [self toastTip:@"切换为硬解码. 重启播放流程"];
        }
        else {
            [self toastTip:@"切换为软解码. 重启播放流程"];
        }
        
        [self startPlay];
    }
}

- (void)clickPortrait:(UIButton *)btn {
    if (_btnPortrait.tag == 1) {
        [_player setRenderRotation:HOME_ORIENTATION_DOWN];
        
        [_btnPortrait setImage:[UIImage imageNamed:@"portrait"] forState:UIControlStateNormal];
        _btnPortrait.tag = 0;
        
    } else {
        [_player setRenderRotation:HOME_ORIENTATION_RIGHT];
        
        [_btnPortrait setImage:[UIImage imageNamed:@"landscape"] forState:UIControlStateNormal];
        _btnPortrait.tag = 1;
    }
}

- (void)clickRenderMode:(UIButton *)btn {
    if (_btnRenderMode.tag == 1) {
        [_player setRenderMode:RENDER_MODE_FILL_EDGE];
        
        [_btnRenderMode setImage:[UIImage imageNamed:@"fill"] forState:UIControlStateNormal];
        _btnRenderMode.tag = 0;
        
    } else {
        [_player setRenderMode:RENDER_MODE_FILL_SCREEN];
        
        [_btnRenderMode setImage:[UIImage imageNamed:@"adjust"] forState:UIControlStateNormal];
        _btnRenderMode.tag = 1;
    }
}

- (void)clickStrategy:(UIButton *)btn {
    _cacheStrategyView.hidden = NO;
    NSInteger cacheStrategy = _btnStrategy.tag;
    switch (cacheStrategy) {
        case CACHE_STRATEGY_FAST:
            [_radioBtnFast setBackgroundImage:[UIImage imageNamed:@"black"] forState:UIControlStateNormal];
            [_radioBtnFast setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_radioBtnSmooth setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnSmooth setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnAuto setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnAuto setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            break;
            
        case CACHE_STRATEGY_SMOOTH:
            [_radioBtnFast setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnFast setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnSmooth setBackgroundImage:[UIImage imageNamed:@"black"] forState:UIControlStateNormal];
            [_radioBtnSmooth setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_radioBtnAuto setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnAuto setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            break;
            
        case CACHE_STRATEGY_AUTO:
            [_radioBtnFast setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnFast setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnSmooth setBackgroundImage:[UIImage imageNamed:@"white"] forState:UIControlStateNormal];
            [_radioBtnSmooth setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_radioBtnAuto setBackgroundImage:[UIImage imageNamed:@"black"] forState:UIControlStateNormal];
            [_radioBtnAuto setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

- (void)clickRealtime:(UIButton *)btn {
    if (_btnRealtime.tag == 0) {
        [_btnRealtime setImage:[UIImage imageNamed:@"jisu_on"] forState:UIControlStateNormal];
        _btnRealtime.tag = 1;
        _addressBeforeSwith = _addressBarController.text;
        [self fetchAccURL];
        self.title = @"低延时播放";

    } else {
        [_btnRealtime setImage:[UIImage imageNamed:@"jisu_off"] forState:UIControlStateNormal];
        _btnRealtime.tag = 0;
        _addressBarController.text = _addressBeforeSwith;
        self.title = @"直播播放器";
    }
}

-(BOOL)checkPlayUrl:(NSString*)playUrl {
    BOOL isRealtime = _btnRealtime.tag;
    if (isRealtime) {
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
    
    return YES;
}

- (BOOL)startPlay {
    CGRect frame = CGRectMake(self.view.bounds.size.width, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    _videoView.frame = frame;
    [_loadingImageView removeFromSuperview];
    
    NSString *playUrl = _addressBarController.text;
    
    if (![self checkPlayUrl:playUrl]) {
        return NO;
    }
    
    [_player setDelegate:self];
    [_player setupVideoWidget:CGRectZero containView:_videoView insertIndex:0];
    
    
    int ret = [_player startPlay:playUrl type:_playType];
    
    frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [UIView animateWithDuration:0.4 animations:^{
        _videoView.frame = frame;
    } completion:^(BOOL finished) {
        [self.view addSubview:_loadingImageView];
    }];

    if (ret != 0) {
        NSLog(@"播放器启动失败");
        return NO;
    }
    
    // 播放参数初始化
    if (_btnLog.tag == 0) {
        [_player showVideoDebugLog:NO];
    } else {
        [_player showVideoDebugLog:YES];
    }
    if (_btnPortrait.tag == 0) {
        [_player setRenderRotation:HOME_ORIENTATION_DOWN];
    } else {
        [_player setRenderRotation:HOME_ORIENTATION_RIGHT];
    }
    if (_btnRenderMode.tag == 0) {
        [_player setRenderMode:RENDER_MODE_FILL_EDGE];
    } else {
        [_player setRenderMode:RENDER_MODE_FILL_SCREEN];
    }
    
    [self startLoadingAnimation];
    _playUrl = playUrl;
    
    return YES;
}

- (void)stopPlay {
    [self stopLoadingAnimation];
    if (_player) {
        [_player setDelegate:nil];
        [_player removeVideoWidget];
        [_player stopPlay];
    }
}

// 设置缓冲策略
- (void)setCacheStrategy:(NSInteger)cacheStrategy {
    if (_btnStrategy.tag == cacheStrategy) {
        return;
    }
    _btnStrategy.tag = cacheStrategy;
    
    TXLivePlayConfig *config = _player.config;
    switch (cacheStrategy) {
        case CACHE_STRATEGY_FAST:
            config.bAutoAdjustCacheTime = YES;
            config.minAutoAdjustCacheTime = CACHE_TIME_FAST;
            config.maxAutoAdjustCacheTime = CACHE_TIME_FAST;
            [_player setConfig:config];
            break;
            
        case CACHE_STRATEGY_SMOOTH:
            config.bAutoAdjustCacheTime = NO;
            config.minAutoAdjustCacheTime = CACHE_TIME_SMOOTH;
            config.maxAutoAdjustCacheTime = CACHE_TIME_SMOOTH;
            [_player setConfig:config];
            break;
            
        case CACHE_STRATEGY_AUTO:
            config.bAutoAdjustCacheTime = YES;
            config.minAutoAdjustCacheTime = CACHE_TIME_FAST;
            config.maxAutoAdjustCacheTime = CACHE_TIME_SMOOTH;
            [_player setConfig:config];
            break;
            
        default:
            break;
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

- (void)onAdjustFast:(UIButton *)btn {
    _cacheStrategyView.hidden = YES;
    [self setCacheStrategy:CACHE_STRATEGY_FAST];
}

- (void)onAdjustSmooth:(UIButton *)btn {
    _cacheStrategyView.hidden = YES;
    [self setCacheStrategy:CACHE_STRATEGY_SMOOTH];
}

- (void)onAdjustAuto:(UIButton *)btn {
    _cacheStrategyView.hidden = YES;
    [self setCacheStrategy:CACHE_STRATEGY_AUTO];
}

#pragma mark - TXLivePlayListener

- (void)onPlayEvent:(int)EvtID withParam:(NSDictionary *)param {
    NSDictionary *dict = param;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (EvtID == PLAY_EVT_PLAY_BEGIN) {
            [self stopLoadingAnimation];
            
        } else if (EvtID == PLAY_ERR_NET_DISCONNECT || EvtID == PLAY_EVT_PLAY_END) {
            // 断开连接时，模拟点击一次关闭播放
            [self clickPlay:_btnPlay];
            
            if (EvtID == PLAY_ERR_NET_DISCONNECT) {
                NSString *msg = (NSString*)[dict valueForKey:EVT_MSG];
                [self toastTip:msg];
            }
            
        } else if (EvtID == PLAY_EVT_PLAY_LOADING){
            [self startLoadingAnimation];
            
        } else if (EvtID == PLAY_EVT_CONNECT_SUCC) {
            BOOL isWifi = [AFNetworkReachabilityManager sharedManager].reachableViaWiFi;
            if (!isWifi) {
                __weak __typeof(self) weakSelf = self;
                [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
                    if (weakSelf.playUrl.length == 0) {
                        return;
                    }
                    if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
                                                                                       message:@"您要切换到Wifi再观看吗?"
                                                                                preferredStyle:UIAlertControllerStyleAlert];
                        [alert addAction:[UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [alert dismissViewControllerAnimated:YES completion:nil];
                            
                            // 先停止，再重新播放
                            [weakSelf stopPlay];
                            [weakSelf startPlay];
                        }]];
                        [alert addAction:[UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                            [alert dismissViewControllerAnimated:YES completion:nil];
                        }]];
                        [weakSelf presentViewController:alert animated:YES completion:nil];
                    }
                }];
            }
        }
        else if (EvtID == PLAY_EVT_GET_MESSAGE) {
            NSData *msgData = param[@"EVT_GET_MSG"];
            NSString *msg = [[NSString alloc] initWithData:msgData encoding:NSUTF8StringEncoding];
            [self toastTip:msg];
        }
        /*
         7.2 新增
        else if (EvtID == PLAY_EVT_GET_FLVSESSIONKEY) {
            //NSString *Msg = (NSString*)[dict valueForKey:EVT_MSG];
            //[self toastTip:[NSString stringWithFormat:@"event PLAY_EVT_GET_FLVSESSIONKEY: %@", Msg]];
        }
         */
    });
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
    _cacheStrategyView.hidden = YES;
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
    return sizeToFit.height + 10;
}

- (ToastTextView *)toastTip:(NSString*)toastInfo {
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

- (void)fetchAccURL {
    __weak __typeof(self) wself = self;
    [TCHttpUtil asyncSendHttpRequest:@"get_test_rtmpaccurl" httpServerAddr:kHttpServerAddr HTTPMethod:@"GET" param:nil handler:^(int result, NSDictionary *resultDict) {
        __strong __typeof(wself) self = wself;
        if (self == nil) {
            return;
        }
        if (result != 0) {
            [self toastTip:@"获取低延时播放地址失败"];
        } else if (self->_btnRealtime.tag) {
            NSString* playUrl = nil;
            if (resultDict)
            {
                playUrl = resultDict[@"url_rtmpacc"];
            }
            self->_addressBarController.text = playUrl;
            [self toastTip:@"测试地址的影像来自在线UTC时间的录屏推流，推流工具采用移动直播 Windows SDK + VCam"];
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
