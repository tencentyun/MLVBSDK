//
//  V2SimpleMainViewController.m
//  TXLiteAVDemo_Enterprise
//
//  Created by coddyliu on 2021/1/5.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "V2SimpleMainViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Masonry.h"
#import "MBProgressHUD.h"
#import "GenerateTestUserSig.h"
#import "V2TXLivePlayer.h"
#import "V2TXLivePusher.h"
#import "V2TXLiveCode.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]

#define V2LogSimple() \
        NSLog(@"[%@ %p %s %d]", NSStringFromClass(self.class), self, __func__, __LINE__);
#define V2Log(_format_, ...) \
        NSLog(@"[%@ %p %s %d] %@", NSStringFromClass(self.class), self, __func__, __LINE__, [NSString stringWithFormat:_format_, ##__VA_ARGS__]);

#pragma mark -- net
//错误码
#define kError_InvalidParam                  -10001
#define kError_ConvertJsonFailed             -10002
#define kError_HttpError                     -10003

@interface V2SimpleMainItemCell : UICollectionViewCell
@property (nonatomic, assign) BOOL isBusy;
@property (nonatomic, strong) void (^onAddBtnClick)(V2SimpleMainItemCell *cell);

///url 推流/拉流地址
- (void)startWithUrl:(NSString *)url;
- (void)stop;
@end

@interface V2SimpleMainItemPushCell : V2SimpleMainItemCell
@property (nonatomic, strong) V2TXLivePusher *pusher;
@end

@interface V2SimpleMainItemPlayCell : V2SimpleMainItemCell
@property (nonatomic, strong) V2TXLivePlayer *player;
@end

@interface V2SimpleMainViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *roomListCollection;
@property (nonatomic, strong) UIView *inputView;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UITextField *inputTextField;
@property (nonatomic, strong) UIButton *trtcButton;
@property (nonatomic, strong) UIButton *rtmpButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, weak) V2SimpleMainItemCell *curSelectedCell;
@property (nonatomic, strong) NSString *rtmpPushUrl;
@property (nonatomic, strong) NSString *trtcPushUrl;
@property (nonatomic, strong) NSDictionary *rtmpUrls;
@end

@implementation V2SimpleMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemWidth = ([UIScreen mainScreen].bounds.size.width - 40.0 - 5.0) / 2.0;
    layout.itemSize = CGSizeMake(itemWidth, itemWidth);
    layout.minimumLineSpacing = 5.0;
    layout.minimumInteritemSpacing = 5.0;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.sectionInset = UIEdgeInsetsMake(20, 20, 80, 20);
    _roomListCollection = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [_roomListCollection registerClass:[V2SimpleMainItemPlayCell class] forCellWithReuseIdentifier:@"V2SimpleMainItemPlayCell"];
    [_roomListCollection registerClass:[V2SimpleMainItemPushCell class] forCellWithReuseIdentifier:@"V2SimpleMainItemPushCell"];
    _roomListCollection.bounces = YES;
    _roomListCollection.delegate = self;
    _roomListCollection.dataSource = self;
    _roomListCollection.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:_roomListCollection];
    [self.roomListCollection mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(88);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    self.view.backgroundColor = [UIColor blueColor];
    self.title = @"超低延迟播放";
    
    self.inputView = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.inputView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    CGSize size = UIScreen.mainScreen.bounds.size;
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(size.width/4/2.0, (size.height-160)/2.0-80.0, size.width/4*3, 160)];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.clipsToBounds = YES;
    bgView.layer.cornerRadius = 4.0;
    [self.inputView addSubview:bgView];
    
    size.width = size.width/4*3;
    self.inputTextField = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, size.width-10, 40)];
    self.inputTextField.placeholder = @"请输入streamId";
    [bgView addSubview:self.inputTextField];

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(self.inputTextField.frame), size.width-10, 1)];
    line.backgroundColor = UIColorFromRGB(0x4C7A2D);
    [bgView addSubview:line];

    self.trtcButton = [[UIButton alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(line.frame) + 5, 100, 40)];
    [self.trtcButton setTitle:@"  TRTC" forState:UIControlStateNormal];
    [self.trtcButton setImage:[UIImage imageNamed:@"simple_ic_cb_circle_unselected"] forState:UIControlStateNormal];
    [self.trtcButton setImage:[UIImage imageNamed:@"simple_ic_cb_circle_selected"] forState:UIControlStateSelected];
    [self.trtcButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.trtcButton setTitleColor:UIColorFromRGB(0x4C7A2D) forState:UIControlStateSelected];
    [self.trtcButton addTarget:self action:@selector(onCheckBoxClick:) forControlEvents:UIControlEventTouchUpInside];
    self.trtcButton.selected = YES;
    [bgView addSubview:self.trtcButton];
    
    self.rtmpButton = [[UIButton alloc] initWithFrame:CGRectMake(120, CGRectGetMaxY(line.frame) + 5, 100, 40)];
    [self.rtmpButton setTitle:@"  RTMP" forState:UIControlStateNormal];
    [self.rtmpButton setImage:[UIImage imageNamed:@"simple_ic_cb_circle_unselected"] forState:UIControlStateNormal];
    [self.rtmpButton setImage:[UIImage imageNamed:@"simple_ic_cb_circle_selected"] forState:UIControlStateSelected];
    [self.rtmpButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.rtmpButton setTitleColor:UIColorFromRGB(0x4C7A2D) forState:UIControlStateSelected];
    [self.rtmpButton addTarget:self action:@selector(onCheckBoxClick:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:self.rtmpButton];
    
    self.startButton = [[UIButton alloc] initWithFrame:CGRectMake(bgView.frame.size.width-120, CGRectGetMaxY(self.rtmpButton.frame) + 5, 100, 40)];
    [self.startButton setTitle:@"开始推流" forState:UIControlStateNormal];
    [self.startButton setTitleColor:UIColorFromRGB(0x4C7A2D) forState:UIControlStateNormal];
    [self.startButton addTarget:self action:@selector(onStart:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:self.startButton];

    self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(self.startButton.frame.origin.x - 80, CGRectGetMaxY(self.rtmpButton.frame) + 5, 100, 40)];
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:UIColorFromRGB(0x4C7A2D) forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(onCancel:) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:self.cancelButton];

    [bgView addSubview:self.rtmpButton];

    self.bgView = bgView;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self.inputView addGestureRecognizer:tap];
    
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)onTap:(UIGestureRecognizer *)gesture {
    NSLog(@"onTap");
    if ([gesture.view isEqual:self.bgView]) {
        return;
    } else if (CGRectContainsPoint(self.bgView.frame, [gesture locationInView:self.inputView])) {
        return;
    }
    if (self.inputTextField.isFirstResponder) {
        [self.inputTextField resignFirstResponder];
    } else {
        [self.inputView removeFromSuperview];
    }
}

- (IBAction)onCheckBoxClick:(UIButton *)sender {
    sender.selected = YES;
    if ([sender isEqual:self.trtcButton]) {
        self.rtmpButton.selected = NO;
        if ([self.curSelectedCell isKindOfClass:[V2SimpleMainItemPushCell class]]) {
            self.inputTextField.text = self.trtcPushUrl;
        }
    } else {
        if ([self.curSelectedCell isKindOfClass:[V2SimpleMainItemPushCell class]]) {
            self.inputTextField.text = self.rtmpPushUrl;
        }
        self.trtcButton.selected = NO;
    }
}

- (IBAction)onCancel:(UIButton *)sender {
    [self.inputView removeFromSuperview];
}

- (IBAction)onStart:(UIButton *)sender {
    if (self.inputTextField.text.length == 0) {
        return;
    }
    [self.inputView removeFromSuperview];
    NSString *streamId = self.inputTextField.text;
    if (self.trtcButton.selected) {
        /// 生成 trtc 地址
        self.trtcPushUrl = streamId;
        NSString *userId = [self randomId];
        NSString *userSig = [GenerateTestUserSig genTestUserSig:userId];
        if ([self.curSelectedCell isKindOfClass:[V2SimpleMainItemPushCell class]]) {
            streamId = [NSString stringWithFormat:@"trtc://cloud.tencent.com/push/%@?sdkappid=%d&userid=%@&usersig=%@&appscene=live",
                        streamId, SDKAPPID, userId, userSig];
        } else if ([self.curSelectedCell isKindOfClass:[V2SimpleMainItemPlayCell class]]) {
            streamId = [NSString stringWithFormat:@"trtc://cloud.tencent.com/play/%@?sdkappid=%d&userid=%@&usersig=%@&appscene=live",
                        streamId, SDKAPPID, userId, userSig];
        }
    } else {
        NSLog(@"++++++++++++++++++++++RTMP URLs:++++++++++++++++++++++++");
        NSLog(@"%@\n", self.rtmpUrls);
        NSLog(@"+++++++++++++++++++++RTMP URLs end++++++++++++++++++++++");
    }
    [self.curSelectedCell startWithUrl:streamId];
}

- (NSString *)randomId {
    return [NSString stringWithFormat:@"%@", @(arc4random() % 100000)];
}

- (void)generateRTMPPushUrl {
    __weak __typeof(self) weakSelf = self;
    [self.class asyncSendHttpRequest:@"get_test_pushurl" httpServerAddr:@"https://lvb.qcloud.com/weapp/utils" HTTPMethod:@"GET" param:nil handler:^(int result, NSDictionary *resultDict) {
        __strong __typeof(self) strongSelf = weakSelf;
        NSError *error = nil;
        if (result != 0 || resultDict == nil) {
            error = [NSError errorWithDomain:@"com.net.error.lppush" code:result userInfo:resultDict];
            V2Log(@"reqeust RTMP URLs faild:%@", error);
        } else {
            strongSelf.rtmpPushUrl = resultDict[@"url_push"];
            strongSelf.rtmpUrls = resultDict;
            //@"url_play_acc" @"url_play_flv" @"url_play_hls" @"url_play_rtmp" @"url_push"
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong __typeof(self) strongSelf = weakSelf;
                if (strongSelf.rtmpButton.selected && strongSelf.inputTextField.text.length == 0) {
                    strongSelf.inputTextField.text = strongSelf.rtmpPushUrl;
                }
            });
        }
    }];
}

#pragma mark - net
+ (void)asyncSendHttpRequest:(NSString*)request
              httpServerAddr:(NSString *)httpServerAddr
                  HTTPMethod:(NSString *)HTTPMethod
                       param:(NSDictionary *)param
                     handler:(void (^)(int result, NSDictionary* resultDict))handler {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString* strUrl = @"";
        strUrl = [NSString stringWithFormat:@"%@/%@", httpServerAddr, request];
        NSURL *URL = [NSURL URLWithString:strUrl];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
        
        [request setHTTPMethod:HTTPMethod];
        [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        [request setTimeoutInterval:30];
        for (NSString *key in param.allKeys) {
            [request setValue:param[key] forHTTPHeaderField:key];
        }
        
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error != nil)
            {
                NSLog(@"internalSendRequest failed，NSURLSessionDataTask return error code:%ld, des:%@", [error code], [error description]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(kError_HttpError, nil);
                });
            }
            else
            {
                NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSDictionary* resultDict = [self jsonData2Dictionary:responseString];
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(0, resultDict);
                });
            }
        }];
        
        [task resume];
    });
}

+ (NSDictionary *)jsonData2Dictionary:(NSString *)jsonData
{
    if (jsonData == nil) {
        return nil;
    }
    NSData *data = [jsonData dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (err) {
        NSLog(@"Json parse failed: %@", jsonData);
        return nil;
    }
    return dic;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 6;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    V2SimpleMainItemCell *cell = nil;
    if (indexPath.row == 0) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"V2SimpleMainItemPushCell" forIndexPath:indexPath];
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"V2SimpleMainItemPlayCell" forIndexPath:indexPath];
    }
    __weak __typeof(self) weakSelf = self;
    [cell setOnAddBtnClick:^(V2SimpleMainItemCell * _Nonnull cell) {
        __strong __typeof(self) strongSelf = weakSelf;
        strongSelf.curSelectedCell = cell;
        BOOL isPush = [cell isKindOfClass:[V2SimpleMainItemPushCell class]];
        if (isPush && !strongSelf.rtmpPushUrl) {
            [strongSelf generateRTMPPushUrl];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong __typeof(self) strongSelf = weakSelf;
            if (strongSelf.view.window) {
                [strongSelf.startButton setTitle:isPush?@"开始推流":@"开始拉流" forState:UIControlStateNormal];
                [strongSelf.view.window addSubview:strongSelf.inputView];
            }
        });
    }];
    return cell;
}

@end

@interface V2SimpleMainItemCell ()
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) UIButton *addButton;

@property (nonatomic, strong) UIButton *switchCameraBtn;
@property (nonatomic, strong) UIButton *muteVideoBtn;
@property (nonatomic, strong) UIButton *muteAudioBtn;
@property (nonatomic, strong) UIButton *closeBtn;

@property (nonatomic, strong) TXView *videoView;

@end

@implementation V2SimpleMainItemCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self constructSubViews];
        [self configSubViews];
    }
    return self;
}

- (NSArray *)showButtons {
    return @[];
}

- (void)constructSubViews {
    self.addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
    [self.contentView addSubview:self.addButton];
    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    [self.addButton addTarget:self action:@selector(onAddClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.switchCameraBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [self.switchCameraBtn addTarget:self action:@selector(swichCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self.switchCameraBtn setImage:[UIImage imageNamed:@"camera_b2"] forState:UIControlStateNormal];
    [self.switchCameraBtn setImage:[UIImage imageNamed:@"camera_b"] forState:UIControlStateSelected];

    self.muteVideoBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [self.muteVideoBtn addTarget:self action:@selector(muteVideo:) forControlEvents:UIControlEventTouchUpInside];
    [self.muteVideoBtn setImage:[UIImage imageNamed:@"rtc_remote_video_on"] forState:UIControlStateNormal];
    [self.muteVideoBtn setImage:[UIImage imageNamed:@"rtc_remote_video_off"] forState:UIControlStateSelected];

    self.muteAudioBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [self.muteAudioBtn addTarget:self action:@selector(muteAudio:) forControlEvents:UIControlEventTouchUpInside];
    [self.muteAudioBtn setImage:[UIImage imageNamed:@"mute_b"] forState:UIControlStateNormal];
    [self.muteAudioBtn setImage:[UIImage imageNamed:@"mute_b2"] forState:UIControlStateSelected];
    
    self.closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35.0, 35.0)];
    [self.closeBtn addTarget:self action:@selector(onClose:) forControlEvents:UIControlEventTouchUpInside];
    [self.closeBtn setImage:[UIImage imageNamed:@"rtc_player_close"] forState:UIControlStateNormal];
    [self.contentView addSubview:self.closeBtn];
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView);
        make.top.equalTo(self.contentView);
        make.width.height.mas_equalTo(35.0);
    }];
    
    /// layout buttons
    CGFloat horizonOffset = 10;
    CGFloat bottomOffset = 10;
    NSArray *buttons = [self showButtons];
    UIButton *preButton = nil;
    CGFloat offset = (buttons.count == 4)?0:(8.0);
    for (UIButton *button in buttons) {
        [self.contentView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView).offset(-bottomOffset);
            if ([button isEqual:buttons.firstObject]) {
                make.left.mas_equalTo(@(horizonOffset + offset));
            } else if ([button isEqual:buttons.lastObject]) {
                make.right.equalTo(self.contentView.mas_right).offset(-horizonOffset -offset);
                make.left.equalTo(preButton.mas_right).offset(offset);
                make.width.equalTo(preButton);
            } else {
                make.left.equalTo(preButton.mas_right).offset(offset);
                make.width.equalTo(preButton);
            }
            make.height.equalTo(button.mas_width);
        }];
        preButton = button;
    }
    
    self.videoView = [[TXView alloc] initWithFrame:self.contentView.bounds];
    [self.contentView insertSubview:self.videoView atIndex:0];
}

- (void)configSubViews {
    self.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1.0];
    [self updateAllButtons];
}

- (void)updateAllButtons {
    self.addButton.hidden = self.isBusy;
    self.closeBtn.hidden = !self.isBusy;
    for (UIButton *button in [self showButtons]) {
        button.hidden = !self.isBusy;
    }
}

- (IBAction)onClose:(UIButton *)sender {
}

- (IBAction)onAddClick:(UIButton *)sender {
    sender.hidden = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateAllButtons];
    });
}
- (void)muteVideo:(UIButton *)sender {
}
- (void)swichCamera:(UIButton *)sender {
}
- (void)muteAudio:(UIButton *)sender {
}

- (void)showText:(NSString *)text withDetailText:(NSString *)detail {
    MBProgressHUD *hud = [MBProgressHUD HUDForView:[UIApplication sharedApplication].delegate.window];
    if (hud == nil) {
        hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].delegate.window animated:YES];
    }
    hud.mode = MBProgressHUDModeText;
    hud.label.text = text;
    hud.detailsLabel.text = detail;
    [hud showAnimated:YES];
    [hud hideAnimated:YES afterDelay:1];
}

@end

@implementation V2SimpleMainItemPushCell

- (NSArray *)showButtons {
    return @[self.switchCameraBtn, self.muteVideoBtn, self.muteAudioBtn];
}

- (void)configSubViews {
    [super configSubViews];
    self.switchCameraBtn.selected = YES;
    [self.addButton setTitle:@" + Pusher" forState:UIControlStateNormal];
}

- (BOOL)isBusy {
    return self.pusher.isPushing;
}

- (IBAction)onClose:(UIButton *)sender {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateAllButtons];
    });
    [self.pusher stopMicrophone];
    [self.pusher stopCamera];
    [self.pusher stopPush];
    /// 恢复默认值
    for (UIButton *button in [self showButtons]) {
        button.selected = NO;
    }
    self.switchCameraBtn.selected = YES;
}

- (IBAction)onAddClick:(UIButton *)sender {
    [super onAddClick:sender];
    self.onAddBtnClick(self);
}

- (void)startWithUrl:(NSString *)url {
    if (self.pusher.isPushing) {
        return;
    }
    if ([url hasPrefix:@"trtc://"]) {
        self.pusher = [[V2TXLivePusher alloc] initWithLiveMode:V2TXLiveMode_RTC];
    } else {
        self.pusher = [[V2TXLivePusher alloc] initWithLiveMode:V2TXLiveMode_RTMP];
    }

    self.addButton.hidden = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateAllButtons];
    });
    self.url = url;
    if (!self.muteVideoBtn.selected) {
        [self.pusher startCamera:self.pusher.getDeviceManager.isFrontCamera];
    }
    if (!self.muteAudioBtn.selected) {
        [self.pusher startMicrophone];
    }
    [self.pusher setRenderView:self.videoView];
    V2TXLiveCode result = [self.pusher startPush:url];
    if (result == V2TXLIVE_OK) {
        
    } else {
        [self.pusher stopCamera];
        [self.pusher stopMicrophone];
    }
}

- (void)muteVideo:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.pusher stopCamera];
    } else {
        [self.pusher startCamera:self.pusher.getDeviceManager.isFrontCamera];
    }
}

- (void)muteAudio:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.pusher stopMicrophone];
    } else {
        [self.pusher startMicrophone];
    }
}

- (void)swichCamera:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.pusher.getDeviceManager switchCamera:sender.selected];
}

@end

@implementation V2SimpleMainItemPlayCell

- (NSArray *)showButtons {
    return @[self.muteVideoBtn, self.muteAudioBtn];
}

- (void)configSubViews {
    [super configSubViews];
    [self.addButton setTitle:@" + Player" forState:UIControlStateNormal];
}

- (BOOL)isBusy {
    return self.player.isPlaying;
}

- (IBAction)onAddClick:(UIButton *)sender {
    [super onAddClick:sender];
    self.onAddBtnClick(self);
}

- (IBAction)onClose:(UIButton *)sender {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateAllButtons];
    });
    [self.player stopPlay];
    /// 恢复默认值
    for (UIButton *button in [self showButtons]) {
        button.selected = NO;
    }
}

- (V2TXLivePlayer *)player {
    if (!_player) {
        _player = [[V2TXLivePlayer alloc] init];
    }
    return _player;
}

- (void)startWithUrl:(NSString *)url {
    self.addButton.hidden = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateAllButtons];
    });
    self.url = url;    
    if (!self.muteVideoBtn.selected) {
        [self.player resumeVideo];
    }
    if (!self.muteAudioBtn.selected) {
        [self.player resumeAudio];
    }
    [self.player setRenderView:self.videoView];
    V2TXLiveCode result = [self.player startPlay:url];
    if (result == V2TXLIVE_ERROR_REFUSED) {
        [self showText:@"faild." withDetailText:@"You maybe in playing or pushing in this rtc room now."];
    } else if (result == V2TXLIVE_ERROR_INVALID_PARAMETER) {
        [self showText:@"faild." withDetailText:@"Parameter error."];
    }
}

- (void)muteVideo:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.player pauseVideo];
    } else {
        [self.player resumeVideo];
    }
}

- (void)muteAudio:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.player pauseAudio];
    } else {
        [self.player resumeAudio];
    }
}

@end
