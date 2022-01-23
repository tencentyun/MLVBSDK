//
//  TUIPusherView.m
//  TUIPusher
//
//  Created by gg on 2021/9/7.
//

#import "TUIPusherView.h"
#import "Masonry.h"
#import "TUIPusherPresenter.h"
#import "TUIPusherCountdownView.h"
#import "TUIPusherView+Private.h"
#import "TUIPusherSignalingHelper.h"
#import "PusherLocalized.h"
#import "TUIPusherRenderView.h"
#import "TUIDefine.h"
#import "TUICore.h"
#import "UIColor+TUIHexColor.h"
#import "TUIPusherHeader.h"
#import "TUIConfig.h"

typedef enum : NSUInteger {
    TUIPusherViewTypePreview, // 预览
    TUIPusherViewTypePushing, // 推流中
} TUIPusherViewType;

@interface TUIPusherView ()

@property (nonatomic, strong) TUIPusherPresenter *presenter;

@property (nonatomic,  copy ) NSString *currentGroupId;

/// 视频渲染图层
@property (nonatomic, strong) TUIPusherRenderView *renderView;

@property (nonatomic, strong) UIButton *switchCameraBtn;
@property (nonatomic,  weak ) TUIPusherCountdownView *countdownView;
@property (nonatomic,  weak ) UIButton *startBtn;
@property (nonatomic,  weak ) id <TUIPusherViewDelegate> delegate;

@property (nonatomic, assign) TUIPusherViewType viewType;

#pragma mark - Widgets
@property (nonatomic, strong) UIButton *sendBtn;
@property (nonatomic, strong) UIView   *inputView;
@property (nonatomic, strong) UIView   *barrageView;

@property (nonatomic, strong) UIButton *beautyBtn;
@property (nonatomic, strong) UIView   *beautyView;

@property (nonatomic, strong) UIButton *audioEffectBtn;
@property (nonatomic, strong) UIView   *audioEffectView;

@property (nonatomic, strong) UIView   *giftPlayView;

@end

@implementation TUIPusherView {
    BOOL hasSwitchedCamera;
}

#pragma mark - Interface

- (void)setDelegate:(id<TUIPusherViewDelegate>)delegate {
    _delegate = delegate;
    [self.renderView setDelegate:delegate];
}

- (BOOL)start:(NSString *)url {
    BOOL res = [self.renderView start:url];
    if (!res) {
        return res;
    }
    [self activeWidgets:self.presenter.pusher groupId:self.currentGroupId];
    [self setViewType:TUIPusherViewTypePreview];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    return res;
}

- (void)stop {
    [self.presenter sendStopPK];
    [self.presenter sendStopLinkMic];
    [self.renderView stop];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)setGroupId:(NSString *)groupId {
    self.currentGroupId = groupId;
    [self activeWidgets:self.presenter.pusher groupId:self.currentGroupId];
}

- (void)setMirror:(BOOL)isMirror {
    [self.renderView setMirror:isMirror];
}

- (void)switchCamera:(BOOL)isFrontCamera {
    if (hasSwitchedCamera) {
        if (self.presenter.isFrontCamera == isFrontCamera) {
            isFrontCamera = !isFrontCamera;
            LOGD("【Pusher】fix front camera: %d", isFrontCamera);
        }
    }
    [self.renderView switchCamera:isFrontCamera];
}

- (void)setVideoResolution:(TUIPusherVideoResolution)resolution {
    VideoResolution realResolution = VIDEO_RES_360;
    switch (resolution) {
        case TUIPUSHER_VIDEO_RES_360:
            realResolution = VIDEO_RES_360;
            break;
        case TUIPUSHER_VIDEO_RES_540:
            realResolution = VIDEO_RES_540;
            break;
        case TUIPUSHER_VIDEO_RES_720:
            realResolution = VIDEO_RES_720;
            break;
        case TUIPUSHER_VIDEO_RES_1080:
            realResolution = VIDEO_RES_1080;
            break;
        default:
            break;
    }
    [self.renderView setVideoResolution:realResolution];
}

- (BOOL)sendPKRequest:(NSString *)userID {
    LOGD("【Pusher】send pk: %@", userID);
    return [self.renderView sendPKRequest:userID];
}

- (void)cancelPKRequest {
    LOGD("【Pusher】cancel pk");
    [self.renderView cancelPKRequest];
}

- (void)stopPK {
    LOGD("【Pusher】stop pk");
    [self.renderView stopPK];
}

- (void)stopJoinAnchor {
    LOGD("【Pusher】stop join anchor");
    [self.renderView stopJoinAnchor];
}

#pragma mark - Private
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        hasSwitchedCamera = NO;
        self.presenter = [[TUIPusherPresenter alloc] initWithPusherView:self];
        [self setupUI];
        [self setBottomBtnHidden:YES];
        [[TUIConfig defaultConfig] setSceneOptimizParams:@"TUIPusher"];
        [self addApplicationObserver];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setViewType:(TUIPusherViewType)viewType {
    _viewType = viewType;
    switch (viewType) {
        case TUIPusherViewTypePreview: {
            self.switchCameraBtn.hidden = NO;
            self.beautyBtn.hidden = NO;
            [self.beautyBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.trailing.equalTo(self.startBtn.mas_leading).offset(-20);
                make.centerY.equalTo(self.startBtn);
                make.width.height.mas_equalTo(44);
            }];
            
        } break;
        case TUIPusherViewTypePushing: {
            self.switchCameraBtn.hidden = YES;
            self.beautyBtn.hidden = NO;
            CGFloat width = UIScreen.mainScreen.bounds.size.width;
            [self.beautyBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.mas_leading).offset(width * 0.5 * (5.0 / 6.0));
                make.width.height.mas_equalTo(44);
                if (@available(iOS 11.0, *)) {
                    make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-10);
                } else {
                    make.bottom.equalTo(self).offset(-10);
                }
            }];
        } break;
        default:
            break;
    }
    [self layoutIfNeeded];
}

- (void)setBottomBtnHidden:(BOOL)hidden {
    self.sendBtn.hidden = hidden;
    self.audioEffectBtn.hidden = hidden;
    self.beautyBtn.hidden = hidden;
}

- (void)setupUI {
    TUIPusherRenderView *renderView = [[TUIPusherRenderView alloc] initWithFrame:self.bounds presenter:self.presenter];
    [self addSubview:renderView];
    self.renderView = renderView;
    [renderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [startBtn setTitle:@"开始推流" forState:UIControlStateNormal];
    [startBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [startBtn setBackgroundColor:[UIColor colorWithHex:@"006EFF"]];
    startBtn.layer.cornerRadius = 25;
    startBtn.clipsToBounds = YES;
    [startBtn addTarget:self action:@selector(startBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:startBtn];
    self.startBtn = startBtn;
    [startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-40);
        } else {
            make.bottom.equalTo(self).offset(-40);
        }
        make.height.mas_equalTo(50);
        make.width.equalTo(self).multipliedBy(0.4);
    }];
    
    TUIPusherCountdownView *countdown = [[TUIPusherCountdownView alloc] initWithFrame:CGRectZero];
    [self addSubview:countdown];
    self.countdownView = countdown;
    [countdown mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    UIButton *switchCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    switchCameraBtn.hidden = YES;
    [switchCameraBtn setImage:[UIImage imageNamed:@"pusher_camera" inBundle:PusherBundle() compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [switchCameraBtn addTarget:self action:@selector(switchCameraBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:switchCameraBtn];
    self.switchCameraBtn = switchCameraBtn;
    [switchCameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.startBtn.mas_trailing).offset(20);
        make.centerY.equalTo(self.startBtn);
        make.width.height.mas_equalTo(44);
    }];
}

- (void)startBtnClick:(UIButton *)btn {
    if (self.countdownView.isInCountdown) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(onClickStartPushButton:url:responseCallback:)]) {
        @weakify(self)
        self.startBtn.userInteractionEnabled = NO;
        [self.delegate onClickStartPushButton:self url:self.presenter.pushUrl responseCallback:^(BOOL isAgree) {
            @strongify(self)
            if (isAgree) {
                [self startAction];
            }
            self.startBtn.userInteractionEnabled = YES;
        }];
    }
    else {
        [self startAction];
    }
}

- (void)switchCameraBtnClick {
    hasSwitchedCamera = YES;
    [self.presenter switchCamera:!self.presenter.isFrontCamera];
}

- (void)startAction {
    if (self.countdownView.isInCountdown) {
        return;
    }
    @weakify(self)
    self.countdownView.willDismiss = ^{
        @strongify(self)
        [self.presenter startPush:self.presenter.pushUrl];
        [self setViewType:TUIPusherViewTypePushing];
        [self setBottomBtnHidden:NO];
    };
    [self setBottomBtnHidden:YES];
    self.startBtn.hidden = YES;
    self.switchCameraBtn.hidden = YES;
    [self.countdownView start];
}

#pragma mark - Private Interface
- (void)resetStartButton:(__kindof UIView *)startBtn {
    LOGD("【Pusher】reset start btn");
    if (_startBtn && self.startBtn.superview != nil) {
        [self.startBtn removeFromSuperview];
    }
    [self addSubview:startBtn];
    self.startBtn = startBtn;
    if ([startBtn isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)startBtn;
        [btn addTarget:self action:@selector(startBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startBtnClick:)];
        [startBtn addGestureRecognizer:tap];
    }
    [startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-40);
        } else {
            make.bottom.equalTo(self).offset(-40);
        }
        make.size.mas_equalTo(CGSizeMake(100, 50));
    }];
}

- (void)resetCountdownView:(__kindof UIView *)countdownView {
    LOGD("【Pusher】reset countdown view");
    if (_countdownView && self.countdownView.superview != nil) {
        [self.countdownView removeFromSuperview];
    }
    [self addSubview:countdownView];
    self.countdownView = countdownView;
    [countdownView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
}

#pragma mark - Widgets
- (void)activeWidgets:(V2TXLivePusher *)pusher groupId:(NSString *)groupId {
    
    CGFloat width = UIScreen.mainScreen.bounds.size.width;
    
    if (!_sendBtn && [self loadBarrageView:groupId]) {
        
        LOGD("【Pusher】load barrage");
        
        [self addSubview:self.sendBtn];
        [self.sendBtn addTarget:self action:@selector(sendBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_leading).offset(width * 0.5 * (1.0 / 6.0));
            make.width.height.mas_equalTo(44);
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-10);
            } else {
                make.bottom.equalTo(self).offset(-10);
            }
        }];
        
        [self addSubview:self.barrageView];
        [self addSubview:self.inputView];
        [self.inputView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    else {
        [self bringSubviewToFront:self.barrageView];
        [self bringSubviewToFront:self.inputView];
    }
    
    // GiftPlay
    if (!_giftPlayView && [self loadGiftPlayView:groupId]) {
        
        LOGD("【Pusher】load gift");
        
        [self addSubview:self.giftPlayView];
    }
    else {
        [self bringSubviewToFront:self.giftPlayView];
    }
    
    if (!_audioEffectBtn && [self loadAudioEffectView:[pusher getAudioEffectManager]]) {
        
        LOGD("【Pusher】load audio effect");
        
        [self addSubview:self.audioEffectBtn];
        [self.audioEffectBtn addTarget:self action:@selector(audioEffectBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.audioEffectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_leading).offset(width * 0.5 * 0.5);
            make.width.height.mas_equalTo(44);
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-10);
            } else {
                make.bottom.equalTo(self).offset(-10);
            }
        }];
        
        [self addSubview:self.audioEffectView];
        [self.audioEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    else {
        [self bringSubviewToFront:self.audioEffectView];
    }
    
    if (!_beautyBtn && [self loadBeautyView:[pusher getBeautyManager]]) {
        
        LOGD("【Pusher】load beauty");
        
        [self addSubview:self.beautyBtn];
        [self.beautyBtn addTarget:self action:@selector(beautyBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self.beautyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_leading).offset(width * 0.5 * (5.0 / 6.0));
            make.width.height.mas_equalTo(44);
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-10);
            } else {
                make.bottom.equalTo(self).offset(-10);
            }
        }];
        
        [self addSubview:self.beautyView];
        [self.beautyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    else {
        [self bringSubviewToFront:self.beautyView];
    }
    
    if (self.viewType == TUIPusherViewTypePreview) {
        self.sendBtn.hidden = YES;
        self.audioEffectBtn.hidden = YES;
        self.beautyBtn.hidden = YES;
    }
}

- (BOOL)loadBeautyView:(TXBeautyManager *)beautyManager {
    
    if (beautyManager == nil) {
        return NO;
    }
    
    NSDictionary *beautyExtensionInfo = [TUICore getExtensionInfo:TUICore_TUIBeautyExtension_Extension param:@{}];
    if (beautyExtensionInfo != nil && [beautyExtensionInfo isKindOfClass:[NSDictionary class]]) {
        UIButton *btn = beautyExtensionInfo[TUICore_TUIBeautyExtension_Extension_View];
        if (btn != nil && [btn isKindOfClass:[UIButton class]]) {
            self.beautyBtn = btn;
        }
    }
    
    NSDictionary *beautyViewInfo = [TUICore getExtensionInfo:TUICore_TUIBeautyExtension_BeautyView param:@{TUICore_TUIBeautyExtension_BeautyView_BeautyManager : beautyManager}];
    if (beautyViewInfo != nil && [beautyViewInfo isKindOfClass:[NSDictionary class]]) {
        UIView *beautyView = beautyViewInfo[TUICore_TUIBeautyExtension_BeautyView_View];
        if (beautyView != nil && [beautyView isKindOfClass:[UIView class]]) {
            self.beautyView = beautyView;
        }
    }
    return self.beautyBtn != nil;
}

- (void)beautyBtnClick {
    self.beautyView.hidden = NO;
}

- (BOOL)loadBarrageView:(NSString *)groupId {
    
    if (groupId == nil) {
        return NO;
    }
    
    NSDictionary *sendBtnInfo =  [TUICore getExtensionInfo:TUICore_TUIBarrageExtension_GetEnterBtn param:nil];
    if (sendBtnInfo != nil && [sendBtnInfo isKindOfClass:[NSDictionary class]]) {
        UIButton *btn = sendBtnInfo[TUICore_TUIBarrageExtension_GetEnterBtn];
        if (btn != nil && [btn isKindOfClass:[UIButton class]]) {
            self.sendBtn = btn;
        }
    }
    CGFloat width = UIScreen.mainScreen.bounds.size.width;
    CGFloat height = UIScreen.mainScreen.bounds.size.height;
    NSDictionary *inputViewInfo = [TUICore getExtensionInfo:TUICore_TUIBarrageExtension_GetTUIBarrageSendView param:@{@"frame":NSStringFromCGRect(UIScreen.mainScreen.bounds),@"groupId":groupId}];
    if (inputViewInfo != nil && [inputViewInfo isKindOfClass:[NSDictionary class]]) {
        UIView *inputView = inputViewInfo[TUICore_TUIBarrageExtension_GetTUIBarrageSendView];
        if (inputView != nil && [inputView isKindOfClass:[UIView class]]) {
            self.inputView = inputView;
        }
    }
    
    NSDictionary *barrageViewInfo = [TUICore getExtensionInfo:TUICore_TUIBarrageExtension_TUIBarrageDisplayView param:@{@"frame":NSStringFromCGRect(CGRectMake(20, height-300 - 120, width-20*2, 300)),@"groupId":groupId}];
    if (barrageViewInfo != nil && [barrageViewInfo isKindOfClass:[NSDictionary class]]) {
        UIView *barrageView = barrageViewInfo[TUICore_TUIBarrageExtension_TUIBarrageDisplayView];
        if (barrageView != nil && [barrageView isKindOfClass:[UIView class]]) {
            self.barrageView = barrageView;
        }
    }
    
    return self.sendBtn != nil;
}

- (void)sendBtnClick {
    self.inputView.hidden = NO;
}

- (BOOL)loadAudioEffectView:(TXAudioEffectManager *)audioEffectManager {
    
    if (audioEffectManager == nil) {
        return NO;
    }
    
    NSDictionary *extensionInfo = (id)[TUICore getExtensionInfo:TUICore_TUIAudioEffectViewExtension_Extension param:@{}];
    if (extensionInfo != nil && [extensionInfo isKindOfClass:[NSDictionary class]]) {
        UIButton *btn = (id)extensionInfo[TUICore_TUIAudioEffectViewExtension_Extension_View];
        if (btn != nil && [btn isKindOfClass:[UIButton class]]) {
            self.audioEffectBtn = btn;
        }
    }
    
    NSDictionary *audioEffectViewInfo = (id)[TUICore getExtensionInfo:TUICore_TUIAudioEffectViewExtension_AudioEffectView param:@{TUICore_TUIAudioEffectViewExtension_AudioEffectView_AudioEffectManager : audioEffectManager}];
    if (audioEffectViewInfo != nil && [audioEffectViewInfo isKindOfClass:[NSDictionary class]]) {
        UIView *audioEffectView = audioEffectViewInfo[TUICore_TUIAudioEffectViewExtension_AudioEffectView_View];
        if (audioEffectView != nil && [audioEffectView isKindOfClass:[UIView class]]) {
            self.audioEffectView = audioEffectView;
        }
    }
    
    return self.audioEffectBtn != nil;
}

- (void)audioEffectBtnClick {
    self.audioEffectView.hidden = NO;
}

#pragma mark - giftPlayView
- (BOOL)loadGiftPlayView:(NSString *)groupId{
    if (groupId == nil || ![groupId isKindOfClass:[NSString class]]) {
        return NO;
    }
    NSDictionary *giftPlayInfo = (id)[TUICore getExtensionInfo:TUICore_TUIGiftExtension_GetTUIGiftPlayView param:@{@"frame":NSStringFromCGRect(UIScreen.mainScreen.bounds),@"groupId":groupId}];
    if (giftPlayInfo != nil && [giftPlayInfo isKindOfClass:[NSDictionary class]]) {
        UIView *giftView = giftPlayInfo[TUICore_TUIGiftExtension_GetTUIGiftPlayView];
        if (giftView != nil && [giftView isKindOfClass:[UIView class]]) {
            self.giftPlayView = giftView;
        }
    }
    return self.giftPlayView != nil;
}

#pragma mark - 应用前后台切换监听
- (void)addApplicationObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

/// app进入后台-开启图片推流
- (void)appDidEnterBackground {
    TXImage *image = [TXImage imageNamed:@"pusher_placeholder" inBundle:PusherBundle() compatibleWithTraitCollection:nil];
    // startVirtualCamera，startCamera，startScreenCapture，同一 Pusher 实例下，仅有一个能上行，三者为覆盖关系。例如先调用 startCamera，后调用 startVirtualCamera。此时表现为暂停摄像头推流，开启图片推流
    [self.presenter startVirtualCamera:image];
}

/// app进入前台-恢复摄像头推流
- (void)appDidBecomeActive {
    // startVirtualCamera，startCamera，startScreenCapture，同一 Pusher 实例下，仅有一个能上行，三者为覆盖关系。例如先调用 startCamera，后调用 startVirtualCamera。此时表现为暂停摄像头推流，开启图片推流
    [self.presenter startCamera:self.presenter.isFrontCamera];
}
@end
