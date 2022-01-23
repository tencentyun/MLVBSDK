//
//  TUIPlayerView.m
//  TUIPlayer
//
//  Created by gg on 2021/9/14.
//

#import "TUIPlayerView.h"
#import "Masonry.h"
#import "TUIPlayerPresenter.h"
#import "TUIPlayerHeader.h"
#import "PlayerLocalized.h"
#import "TUIPlayerContainerView.h"
#import "TUIPlayerLinkURLUtils.h"
#import "TUIConfig.h"
#import "UIView+TUIToast.h"
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, LinkMicBtnType) {
    LinkMicBtnTypeNormal,
    LinkMicBtnTypeCancel,
    LinkMicBtnTypeStop,
};

@interface TUIPlayerView () <TUIPlayerPresenterDelegate>

@property (nonatomic,  weak ) id <TUIPlayerViewDelegate> delegate;

@property (nonatomic, assign) TUIPlayerUIState playerUIState;

@property (nonatomic, strong) TUIPlayerPresenter *presenter;

@property (nonatomic,  weak ) UIView *remoteView;
@property (nonatomic,  weak ) UIView *localView;

@property (nonatomic, strong) UIButton *requestLinkMicBtn;

@property (nonatomic,  weak ) TUIPlayerContainerView *containerView;

@property (nonatomic,  copy ) NSString *currentGroupId;
@property (nonatomic,  copy ) NSString *streamId;
@property (nonatomic,  copy ) NSString *playUrl;
@end

@implementation TUIPlayerView {
    UIImage *_requestJoinAnchorImage;
    UIImage *_cancelJoinAnchorImage;
    UIImage *_stopJoinAnchorImage;
    BOOL isViewReady;
}

#pragma mark - Interface
- (void)setDelegate:(id<TUIPlayerViewDelegate>)delegate {
    _delegate = delegate;
}

- (void)updatePlayerUIState:(TUIPlayerUIState)state {
    _playerUIState = state;
    if (_containerView) {
        _containerView.hidden = state == TUIPLAYER_UISTATE_VIDEOONLY;
    }
}

- (NSInteger)startPlay:(NSString *)url {
    self.streamId = [TUIPlayerLinkURLUtils getStreamIdByPushUrl:url];
    LOGD("【Player】split stream id: %@", self.streamId);
    self.playUrl = url;
    NSInteger res = [self.presenter startPlay:url atView:self.remoteView];
    if (res == 0) {
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        if ([self.delegate respondsToSelector:@selector(onPlayStarted:url:)]) {
            [self.delegate onPlayStarted:self url:url];
        }
        if ([self.delegate respondsToSelector:@selector(onPlayEvent:event:message:)]) {
            [self.delegate onPlayEvent:self event:TUIPLAYER_EVENT_SUCCESS message:@"Start play success"];
        }
    } else if (res == -4) {
        // URL 不支持
        if ([self.delegate respondsToSelector:@selector(onPlayEvent:event:message:)]) {
            [self.delegate onPlayEvent:self event:TUIPLAYER_EVENT_URL_NOTSUPPORT message:@"URL no support"];
        }
    } else if (res == -5) {
        // License 无效
        if ([self.delegate respondsToSelector:@selector(onPlayEvent:event:message:)]) {
            [self.delegate onPlayEvent:self event:TUIPLAYER_EVENT_INVALID_LICENSE message:@"LICENSE invalid"];
        }
    } else {
        // 播放失败
        if ([self.delegate respondsToSelector:@selector(onPlayEvent:event:message:)]) {
            [self.delegate onPlayEvent:self event:TUIPLAYER_EVENT_FAILED message:@"Start play faild"];
        }
    }
    return res;
}

- (void)stopPlay {
    [self.presenter sendStopLinkMic];
    [self.presenter stopPlay];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)pauseVideo {
    [self.presenter pauseVideo];
}

- (void)resumeVideo {
    [self.presenter resumeVideo];
}

- (void)pauseAudio {
    [self.presenter pauseAudio];
}

- (void)resumeAudio {
    [self.presenter resumeAudio];
}

- (void)disableLinkMic {
    LOGD("【Player】disable linkmic");
    _requestLinkMicBtn = nil;
}

- (void)setGroupId:(NSString *)groupId {
    self.currentGroupId = groupId;
    
    LOGD("【Player】set group id: %@", groupId);
    
    if (isViewReady) {
        if (self.containerView.superview) {
            [self.containerView removeFromSuperview];
        }
        TUIPlayerContainerView *containerView = [[TUIPlayerContainerView alloc] initWithFrame:CGRectZero groupId:self.currentGroupId];
        containerView.hidden = _playerUIState == TUIPLAYER_UISTATE_VIDEOONLY;
        [containerView setLinkMicBtn:self.requestLinkMicBtn];
        [self addSubview:containerView];
        self.containerView = containerView;
        [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
}

#pragma mark - TUIPlayerSignalingServiceDelegate
- (void)onReceiveLinkMicInvite:(NSString *)inviter cmd:(NSString *)cmd streamId:(NSString *)streamId {
    
}

- (void)onAcceptLinkMicInvite:(NSString *)cmd streamId:(NSString *)streamId {
    @weakify(self)
    [self.presenter startLinkMicWithUser:streamId atView:self.localView complete:^(BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self)
            [self setRequestLinkMicBtnStatus:LinkMicBtnTypeStop];
        });
    }];
}
- (void)onRejectLinkMicInvite:(NSString *)cmd reason:(int)reason {
    [self setRequestLinkMicBtnStatus:LinkMicBtnTypeNormal];
    if ([self.delegate respondsToSelector:@selector(onRejectJoinAnchorResponse:reason:)]) {
        [self.delegate onRejectJoinAnchorResponse:self reason:reason];
    }
}

- (void)onStartLinkMic:(NSString *)cmd streamId:(NSString *)streamId {
    [self setRequestLinkMicBtnStatus:LinkMicBtnTypeStop];
}
- (void)onStopLinkMic:(NSString *)cmd {
    [self.presenter stopLinkMic];
    [self setRequestLinkMicBtnStatus:LinkMicBtnTypeNormal];
    if ([self.delegate respondsToSelector:@selector(onPlayEvent:event:message:)]) {
        [self.delegate onPlayEvent:self event:TUIPLAYER_EVENT_LINKMIC_STOP message:@"LinkMic stop"];
    }
}
- (void)onLinkMicInviteTimeout {
    [self makeToast:PlayerLocalize(@"TUIPlayer.Link.Request.timeout")];
    [self setRequestLinkMicBtnStatus:LinkMicBtnTypeNormal];
}

- (void)onRemoteStopPush {
    [self stopPlay];
    if ([self.delegate respondsToSelector:@selector(onPlayStoped:url:)]) {
        [self.delegate onPlayStoped:self url:self.playUrl];
    }
}

- (void)onSignalingError:(NSString *)cmd code:(int)code message:(NSString *)msg {
    LOGE("【Player】Signaling error: cmd:%@, code:%d, msg:%@", cmd, code, msg);
    // 连麦错误回调
    if ([self.delegate respondsToSelector:@selector(onPlayEvent:event:message:)]) {
        NSString *errorMsg = [NSString stringWithFormat:@"LinkMic error code: %@ msg: %@", @(code), msg];
        [self.delegate onPlayEvent:self event:TUIPLAYER_EVENT_FAILED message:errorMsg];
    }
}


#pragma mark - Private

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        isViewReady = NO;
        _requestJoinAnchorImage = [UIImage imageNamed:@"player_linkmic" inBundle:PlayerBundle() compatibleWithTraitCollection:nil];
        _cancelJoinAnchorImage = [UIImage imageNamed:@"player_cancelLinkmic" inBundle:PlayerBundle() compatibleWithTraitCollection:nil];
        _stopJoinAnchorImage = [UIImage imageNamed:@"player_cancelLinkmic" inBundle:PlayerBundle() compatibleWithTraitCollection:nil];
        [self setupUI];
        [[TUIConfig defaultConfig] setSceneOptimizParams:@"TUIPlayer"];
    }
    return self;
}

- (void)setupUI {
    UIView *remoteView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:remoteView];
    self.remoteView = remoteView;
    [remoteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    UIView *localView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:localView];
    self.localView = localView;
    [localView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.mas_safeAreaLayoutGuideTop).offset(160);
        } else {
            make.top.equalTo(self).offset(160);
        }
        make.trailing.equalTo(self).offset(-10);
        make.size.mas_equalTo(CGSizeMake(100, 150));
    }];
    
    self.requestLinkMicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.requestLinkMicBtn addTarget:self action:@selector(linkMicBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self setRequestLinkMicBtnStatus:LinkMicBtnTypeNormal];
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    
    if (isViewReady) {
        return;
    }
    isViewReady = YES;
    
    TUIPlayerContainerView *containerView = [[TUIPlayerContainerView alloc] initWithFrame:CGRectZero groupId:self.currentGroupId];
    containerView.hidden = _playerUIState == TUIPLAYER_UISTATE_VIDEOONLY;
    [containerView setLinkMicBtn:self.requestLinkMicBtn];
    [self addSubview:containerView];
    self.containerView = containerView;
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)setRequestLinkMicBtnStatus:(LinkMicBtnType)type {
    switch (type) {
        case LinkMicBtnTypeNormal:
            [self.requestLinkMicBtn setImage:_requestJoinAnchorImage forState:UIControlStateNormal];
            self.requestLinkMicBtn.tag = 1;
            break;
        case LinkMicBtnTypeCancel:
            [self.requestLinkMicBtn setImage:_cancelJoinAnchorImage forState:UIControlStateNormal];
            self.requestLinkMicBtn.tag = 2;
            break;
        case LinkMicBtnTypeStop:
            [self.requestLinkMicBtn setImage:_stopJoinAnchorImage forState:UIControlStateNormal];
            self.requestLinkMicBtn.tag = 3;
            break;
        default:
            break;
    }
}

- (void)linkMicBtnClick:(UIButton *)btn {
    if (btn.tag == 1) {
        // 1. 连麦请求前检查相机权限
        BOOL videoGranted = [self checkLinkMicAuthorizationWithMediaType:AVMediaTypeVideo];
        if (videoGranted == NO) {
            LOGD("【Player】linkMic: unGet Video authorization");
            return;
        }
        // 2. 连麦请求前检查麦克风权限
        BOOL audioGranted = [self checkLinkMicAuthorizationWithMediaType:AVMediaTypeAudio];
        if (audioGranted == NO) {
            LOGD("【Player】linkMic: unGet Audio authorization");
            return;
        }
    }
    switch (btn.tag) {
        case 1: // request
            [self setRequestLinkMicBtnStatus:LinkMicBtnTypeCancel];
            [self.presenter sendLinkMicRequest:self.streamId];
            LOGD("【Player】send linkmic req");
            // 发起请求连麦标记为连麦开始事件
            if ([self.delegate respondsToSelector:@selector(onPlayEvent:event:message:)]) {
                [self.delegate onPlayEvent:self event:TUIPLAYER_EVENT_LINKMIC_START message:@"LinkMic start request"];
            }
            break;
        case 2: // cancel
            [self setRequestLinkMicBtnStatus:LinkMicBtnTypeNormal];
            [self.presenter cancelLinkMicRequest];
            LOGD("【Player】cancel linkmic req");
            // 取消请求连麦标记为连麦结束事件
            if ([self.delegate respondsToSelector:@selector(onPlayEvent:event:message:)]) {
                [self.delegate onPlayEvent:self event:TUIPLAYER_EVENT_LINKMIC_STOP message:@"LinkMic cancel"];
            }
            break;
        case 3: // stop
            [self setRequestLinkMicBtnStatus:LinkMicBtnTypeNormal];
            [self.presenter sendStopLinkMic];
            LOGD("【Player】send stop linkmic req");
            // 结束请求连麦标记为连麦结束事件
            if ([self.delegate respondsToSelector:@selector(onPlayEvent:event:message:)]) {
                [self.delegate onPlayEvent:self event:TUIPLAYER_EVENT_LINKMIC_STOP message:@"LinkMic stop"];
            }
            break;
        default:
            break;
    }
}

/// 检查连麦相关权限
/// @param mediaType AVMediaTypeVideo 相机权限 AVMediaTypeAudio麦克风权限
- (BOOL)checkLinkMicAuthorizationWithMediaType:(AVMediaType)mediaType {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
                    
        }];
    } else if (status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted) {
        if (mediaType == AVMediaTypeVideo) {
            [self makeToast:PlayerLocalize(@"TUIPlayer.Link.Authorization.camera")];
        }
        if (mediaType == AVMediaTypeAudio) {
            [self makeToast:PlayerLocalize(@"TUIPlayer.Link.Authorization.microphone")];
        }
    }
    return status == AVAuthorizationStatusAuthorized;
}

- (TUIPlayerPresenter *)presenter {
    if (!_presenter) {
        _presenter = [[TUIPlayerPresenter alloc] init];
        _presenter.delegate = self;
    }
    return _presenter;
}

@end
