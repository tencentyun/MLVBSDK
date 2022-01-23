//
//  TUIPusherRenderView.m
//  TUIPusher
//
//  Created by gg on 2021/10/12.
//

#import "TUIPusherRenderView.h"
#import "TUIPusherCountdownView.h"
#import "Masonry.h"
#import "TUIPusherHeader.h"
#import "PusherLocalized.h"
#import "UIView+TUIToast.h"
#import <AVFoundation/AVFoundation.h>

typedef enum : NSUInteger {
    TUIPusherRenderViewTypePush,
    TUIPusherRenderViewTypePK,
    TUIPusherRenderViewTypeLink,
} TUIPusherRenderViewType;

typedef enum : NSUInteger {
    TUIPUSHER_VIDEO_RES_360 = 1,
    TUIPUSHER_VIDEO_RES_540,
    TUIPUSHER_VIDEO_RES_720,
    TUIPUSHER_VIDEO_RES_1080,
} TUIPusherVideoResolution;

@interface TUIPusherRenderView () <TUIPusherPresenterDelegate>
@property (nonatomic, strong) UIView *previewView;
@property (nonatomic, strong) UIView *remoteView;
@property (nonatomic,  weak ) UIButton *closeLinkMicBtn;
@property (nonatomic,  weak ) UIImageView *pkImageView;

@property (nonatomic, strong) TUIPusherPresenter *presenter;

@property (nonatomic,  weak ) id <TUIPusherViewDelegate> delegate;

@property (nonatomic, assign) BOOL isMirror;
@property (nonatomic,  copy ) NSString *pushUrl;
@end

@implementation TUIPusherRenderView {
    BOOL isViewReady;
}

- (instancetype)initWithFrame:(CGRect)frame presenter:(nonnull TUIPusherPresenter *)presenter {
    if (self = [super initWithFrame:frame]) {
        self.presenter = presenter;
        self.presenter.delegate = self;
        [self setupUI];
        isViewReady = NO;
    }
    return self;
}

#pragma mark - Interface

- (void)setDelegate:(id<TUIPusherViewDelegate>)delegate {
    _delegate = delegate;
    self.presenter.pusherViewDelegate = delegate;
}

- (BOOL)start:(NSString *)url {
    self.pushUrl = url;
    if (![self authorization]) {
        [[self getTopiestWindow] makeToast:PusherLocalize(@"Demo.Pusher.Authorization")];
        return NO;
    }
    return [self.presenter start:url view:self.previewView];
}

- (void)stop {
    [self.presenter stop];
}

- (void)setMirror:(BOOL)isMirror {
    [self.presenter setMirror:isMirror];
}

- (void)switchCamera:(BOOL)isFrontCamera {
    [self.presenter switchCamera:isFrontCamera];
}

- (void)setVideoResolution:(VideoResolution)resolution {
    [self.presenter setVideoResolution:resolution];
}

- (BOOL)sendPKRequest:(NSString *)userID {
    return [self.presenter sendPKRequest:userID];
}

- (void)cancelPKRequest {
    [self.presenter cancelPKRequest];
}

- (void)stopPK {
    [self.presenter sendStopPK];
}

- (void)stopJoinAnchor {
    [self.presenter sendStopLinkMic];
}

#pragma mark - Private
- (UIWindow *)getTopiestWindow {
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        if (CGSizeEqualToSize(window.bounds.size, UIScreen.mainScreen.bounds.size)) {
            return window;
        }
    }
    return nil;
}
- (BOOL)authorizationVideo {
    AVAuthorizationStatus video = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (video) {
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted: {
            return NO;
        } break;
        default:
            break;
    }
    return YES;
}
- (BOOL)authorizationAudio {
    AVAuthorizationStatus audio = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (audio) {
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted: {
            return NO;
        } break;
        default:
            break;
    }
    return YES;
}
- (BOOL)authorization {
    return [self authorizationVideo] && [self authorizationAudio];
}

- (void)setViewType:(TUIPusherRenderViewType)type {
    switch (type) {
        case TUIPusherRenderViewTypePush: {
            [self.previewView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
            [self.remoteView mas_remakeConstraints:^(MASConstraintMaker *make) {
                if (@available(iOS 11.0, *)) {
                    make.top.equalTo(self.mas_safeAreaLayoutGuideTop).offset(160);
                } else {
                    make.top.equalTo(self).offset(160);
                }
                make.trailing.equalTo(self).offset(-10);
                make.size.mas_equalTo(CGSizeMake(100, 150));
            }];
        } break;
        case TUIPusherRenderViewTypePK: {
            [self.previewView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.leading.equalTo(self);
                make.size.equalTo(self).multipliedBy(0.5);
            }];
            [self.remoteView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.trailing.equalTo(self);
                make.size.equalTo(self).multipliedBy(0.5);
            }];
        } break;
        default:
            break;
    }
    BOOL pkIconHidden = type != TUIPusherRenderViewTypePK;
    if (pkIconHidden) {
        self.pkImageView.hidden = pkIconHidden;
    }
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (!pkIconHidden) {
            self.pkImageView.hidden = pkIconHidden;
        }
    }];
}

- (void)setPushUrl:(NSString *)pushUrl {
    _pushUrl = pushUrl;
    self.presenter.pushUrl = pushUrl;
}

- (void)setupUI {
    
    UIView *localView = [[UIView alloc] initWithFrame:self.bounds];
    [self addSubview:localView];
    self.previewView = localView;
    [localView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    UIView *remoteView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:remoteView];
    self.remoteView = remoteView;
    [remoteView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.mas_safeAreaLayoutGuideTop).offset(160);
        } else {
            make.top.equalTo(self).offset(160);
        }
        make.trailing.equalTo(self).offset(-10);
        make.size.mas_equalTo(CGSizeMake(100, 150));
    }];
    
    UIButton *closeLinkMicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeLinkMicBtn setImage:[UIImage imageNamed:@"pusher_close" inBundle:PusherBundle() compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    closeLinkMicBtn.hidden = YES;
    [closeLinkMicBtn addTarget:self action:@selector(closeLinkMicBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeLinkMicBtn];
    self.closeLinkMicBtn = closeLinkMicBtn;
    [closeLinkMicBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(remoteView.mas_trailing);
        make.centerY.equalTo(remoteView.mas_top);
    }];
    
    UIImageView *pkImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pusher_pk" inBundle:PusherBundle() compatibleWithTraitCollection:nil]];
    [self addSubview:pkImageView];
    pkImageView.hidden = YES;
    self.pkImageView = pkImageView;
    [pkImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.remoteView.mas_leading);
        make.bottom.equalTo(self.remoteView);
    }];
}

- (void)closeLinkMicBtnClick {
    [self stopJoinAnchor];
}

- (void)startPK:(NSString *)streamId {
    [self.presenter startPKWithUser:streamId atView:self.remoteView];
    [self setViewType:TUIPusherRenderViewTypePK];
    if ([self.delegate respondsToSelector:@selector(onStartPK:)]) {
        [self.delegate onStartPK:self.pusherView];
    }
}

- (void)showAlert:(NSString *)title completion:(void(^)(void))completion {
    
}

#pragma mark - TUIPusherPresenterDelegate
- (void)onStreamServiceError:(V2TXLiveCode)code msg:(NSString *)msg {
    if ([self.delegate respondsToSelector:@selector(onPushEvent:event:message:)]) {
        if (code == V2TXLIVE_ERROR_INVALID_LICENSE) {
            [self.delegate onPushEvent:self.pusherView event:TUIPUSHER_EVENT_INVALID_LICENSE message:msg];
        }
        else {
            [self.delegate onPushEvent:self.pusherView event:TUIPUSHER_EVENT_FAILED message:msg];
        }
    }
}

- (void)onSignalingError:(NSString *)cmd code:(int)code message:(NSString *)msg {
    LOGE("【Pusher】Signaling error: cmd:%@, code:%d, msg:%@", cmd, code, msg);
    if ([self.delegate respondsToSelector:@selector(onPushEvent:event:message:)]) {
        [self.delegate onPushEvent:self.pusherView event:TUIPUSHER_EVENT_FAILED message:msg];
    }
}
- (void)onReceivePKInvite:(NSString *)inviter cmd:(NSString *)cmd streamId:(NSString *)streamId {
    self.presenter.remoteStreamId = streamId;
    if ([self.delegate respondsToSelector:@selector(onReceivePKRequest:userId:responseCallback:)]) {
        @weakify(self)
        [self.delegate onReceivePKRequest:self.pusherView userId:inviter responseCallback:^(BOOL isAgree) {
            @strongify(self)
            if (isAgree) {
                [self.presenter acceptPK];
                [self.presenter startPKWithUser:self.presenter.remoteStreamId atView:self.remoteView];
                [self setViewType:TUIPusherRenderViewTypePK];
                if ([self.delegate respondsToSelector:@selector(onStartPK:)]) {
                    [self.delegate onStartPK:self.pusherView];
                }
            }
            else {
                [self.presenter rejectPK];
            }
        }];
    }
}
- (void)onAcceptPKInvite:(NSString *)cmd streamId:(NSString *)streamId {
    [self startPK:streamId];
}
- (void)onRejectPKInvite:(NSString *)cmd reason:(int)reason {
    if ([self.delegate respondsToSelector:@selector(onRejectPKResponse:reason:)]) {
        [self.delegate onRejectPKResponse:self.pusherView reason:reason];
    }
}
- (void)onCancelPK:(NSString *)cmd {
    if ([self.delegate respondsToSelector:@selector(onCancelPKRequest:)]) {
        [self.delegate onCancelPKRequest:self.pusherView];
    }
}
- (void)onStopPK:(NSString *)cmd {
    [self.presenter stopPK];
    [self setViewType:TUIPusherRenderViewTypePush];
    if ([self.delegate respondsToSelector:@selector(onStopPK:)]) {
        [self.delegate onStopPK:self.pusherView];
    }
}
- (void)onTimeoutPK {
    if ([self.delegate respondsToSelector:@selector(onPKTimeout:)]) {
        [self.delegate onPKTimeout:self.pusherView];
    }
}

- (void)onReceiveLinkMicInvite:(NSString *)inviter cmd:(NSString *)cmd streamId:(NSString *)streamId {
    if ([self.delegate respondsToSelector:@selector(onReceiveJoinAnchorRequest:userId:responseCallback:)]) {
        [self.delegate onReceiveJoinAnchorRequest:self.pusherView userId:inviter responseCallback:^(BOOL isAgree) {
            if (isAgree) {
                [self.presenter acceptLinkMic];
            }
            else {
                [self.presenter rejectLinkMic];
            }
        }];
    }
}
- (void)onStartLinkMic:(NSString *)cmd streamId:(NSString *)streamId {
    self.closeLinkMicBtn.hidden = NO;
    [self.presenter startLinkMicWithUser:streamId atView:self.remoteView];
    [self setViewType:TUIPusherRenderViewTypeLink];
    if ([self.delegate respondsToSelector:@selector(onStartJoinAnchor:)]) {
        [self.delegate onStartJoinAnchor:self.pusherView];
    }
}
- (void)onCancelLinkMic:(NSString *)cmd {
    if ([self.delegate respondsToSelector:@selector(onCancelJoinAnchorRequest:)]) {
        [self.delegate onCancelJoinAnchorRequest:self.pusherView];
    }
}
- (void)onStopLinkMic:(NSString *)cmd {
    self.closeLinkMicBtn.hidden = YES;
    [self.presenter stopLinkMic];
    [self setViewType:TUIPusherRenderViewTypePush];
    if ([self.delegate respondsToSelector:@selector(onStopJoinAnchor:)]) {
        [self.delegate onStopJoinAnchor:self.pusherView];
    }
}
- (void)onTimeoutLinkMic {
    if ([self.delegate respondsToSelector:@selector(onJoinAnchorTimeout:)]) {
        [self.delegate onJoinAnchorTimeout:self.pusherView];
    }
}
@end
