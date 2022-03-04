//
//  TUIPusherPresenter.m
//  Alamofire
//
//  Created by gg on 2021/9/13.
//

#import "TUIPusherPresenter.h"
#import "TUIPusherViewDelegate.h"
#import <TUICore/TUILogin.h>
#import "TUIPusherHeader.h"

@interface TUIPusherPresenter () <TUIPusherStreamServiceDelegate, TUIPusherSignalingServiceDelegate>

@property (nonatomic, strong) TUIPusherStreamService *streamService;
@property (nonatomic, strong) TUIPusherSignalingService *signalingService;

@property (nonatomic, assign) BOOL isInPK;
@property (nonatomic, assign) BOOL isInLinkMic;
@end

@implementation TUIPusherPresenter

- (V2TXLivePusher *)pusher {
    return self.streamService.pusher;
}

- (BOOL)checkPushUrl:(NSString *)url {
    if (!url || url.length <= 0) {
        return NO;
    }
    if (![url hasPrefix:@"trtc://"] && ![url hasPrefix:@"room://"] && ![url hasPrefix:@"mrtc://"] && ![url hasPrefix:@"rtmp://"]) {
        return NO;
    }
    return YES;
}

- (BOOL)checkLoginStatus {
    BOOL res = [self.signalingService checkLoginStatus];
    if (!res) {
        LOGE("【Pusher】not login");
    }
    return res;
}

- (NSString *)currentUserId {
    return [TUILogin getUserID];
}

- (void)switchCamera:(BOOL)isFrontCamera {
    self.isFrontCamera = isFrontCamera;
    [self.streamService switchCamera:isFrontCamera];
}

- (void)setMirror:(BOOL)isMirror {
    [self.streamService setMirror:isMirror];
}

- (void)setVideoResolution:(VideoResolution)resolution {
    [self.streamService setVideoResolution:resolution];
}

- (BOOL)start:(NSString *)url view:(nonnull UIView *)view {
    if (![self checkPushUrl:url]) {
        LOGD("【Pusher】invalid url: %@", url);
        if ([self.pusherViewDelegate respondsToSelector:@selector(onPushEvent:event:message:)]) {
            [self.pusherViewDelegate onPushEvent:self.pusherView event:TUIPUSHER_EVENT_URL_NOTSUPPORT message:@"Invalid url"];
        }
        return NO;
    }
    if (![self checkLoginStatus]) {
        if ([self.pusherViewDelegate respondsToSelector:@selector(onPushEvent:event:message:)]) {
            [self.pusherViewDelegate onPushEvent:self.pusherView event:TUIPUSHER_EVENT_NOT_LOGIN message:@"Check login status"];
        }
        return NO;
    }
    self.pushUrl = url;
    if (!_streamService) {
        V2TXLiveMode mode = [self getModeFromUrl:url];
        _streamService = [[TUIPusherStreamService alloc] initWithMode:mode];
        [_streamService setDelegate:self];
    }
    return [self.streamService openCamera:self.isFrontCamera view:view];
}

- (void)stop {
    [self stopPush];
}

- (BOOL)startPush:(NSString *)url {
    if (![self checkLoginStatus]) {
        return NO;
    }
    self.pushUrl = url;
    BOOL res = [self.streamService startPush:url];
    if (res) {
        if ([self.pusherViewDelegate respondsToSelector:@selector(onPushStarted:url:)]) {
            [self.pusherViewDelegate onPushStarted:self.pusherView url:url];
        }
    }
    return res;
}

- (void)stopPush {
    [self.streamService stopPush];
    if ([self.pusherViewDelegate respondsToSelector:@selector(onPushStoped:url:)]) {
        [self.pusherViewDelegate onPushStoped:self.pusherView url:self.pushUrl];
    }
}

- (void)startCamera:(BOOL)frontCamera {
    [self.streamService startCamera:frontCamera];
}

- (void)closeCamera {
    [self.streamService closeCamara];
}

- (void)startVirtualCamera:(UIImage *)image {
    [self.streamService startVirtualCamera:image];
}

- (void)stopVirtualCamera {
    [self.streamService stopVirtualCamera];
}

- (BOOL)startPKWithUser:(NSString *)remoteUserId atView:(UIView *)view {
    self.isInPK = YES;
    return [self.streamService startPK:remoteUserId view:view];
}

- (BOOL)sendPKRequest:(NSString *)userID {
    return [self.signalingService requestPK:userID];
}

- (void)cancelPKRequest {
    [self.signalingService cancelPKRequest];
}

- (void)acceptPK {
    [self.signalingService acceptPK:[TUILogin getUserID]];
}

- (void)rejectPK {
    TUIPusherRejectReason reason = TUIPusherRejectReasonNormal;
    if (self.isInPK || self.isInLinkMic) {
        reason = TUIPusherRejectReasonBusy;
    }
    [self.signalingService rejectPKWithReason:reason];
}

- (void)sendStopPK {
    [self.signalingService stopPK];
}

- (void)stopPK {
    self.isInPK = NO;
    [self.streamService stopPK];
}

- (void)acceptLinkMic {
    [self.signalingService acceptLinkMic:[TUILogin getUserID]];
}

- (void)rejectLinkMic {
    TUIPusherRejectReason reason = TUIPusherRejectReasonNormal;
    if ([self isBusy]) {
        reason = TUIPusherRejectReasonBusy;
    }
    [self.signalingService rejectLinkMic:reason];
}

- (BOOL)startLinkMicWithUser:(NSString *)remoteUserId atView:(UIView *)view {
    self.isInLinkMic = YES;
    return [self.streamService startLinkMic:remoteUserId view:view];
}

- (void)sendStopLinkMic {
    [self.signalingService stopLinkMic];
}

- (void)stopLinkMic {
    self.isInLinkMic = NO;
    [self.streamService stopLinkMic];
}

- (BOOL)isBusy {
    return self.isInPK || self.isInLinkMic;
}

- (V2TXLiveMode)getModeFromUrl:(NSString *)url {
    if ([url hasPrefix:@"rtmp://"]) {
        return V2TXLiveMode_RTMP;
    }
    else return V2TXLiveMode_RTC;
}

#pragma mark - TUIPusherStreamServiceDelegate
- (void)onStreamServiceError:(V2TXLiveCode)code msg:(NSString *)msg {
    if ([self.pusherViewDelegate respondsToSelector:@selector(onPushEvent:event:message:)]) {
        if (code == V2TXLIVE_ERROR_INVALID_LICENSE) {
            [self.pusherViewDelegate onPushEvent:self.pusherView event:TUIPUSHER_EVENT_INVALID_LICENSE message:msg];
        }
        else {
            [self.pusherViewDelegate onPushEvent:self.pusherView event:TUIPUSHER_EVENT_FAILED message:msg];
        }
    }
}

#pragma mark - TUIPusherSignalingServiceDelegate
- (void)onSignalingError:(NSString *)cmd code:(int)code message:(NSString *)msg {
    if ([self.delegate respondsToSelector:@selector(onSignalingError:code:message:)]) {
        [self.delegate onSignalingError:cmd code:code message:msg];
    }
}

- (void)onReceivePKInvite:(NSString *)inviter cmd:(NSString *)cmd streamId:(NSString *)streamId {
    if ([self isBusy]) {
        [self rejectPK];
        return;
    }
    if ([self.delegate respondsToSelector:@selector(onReceivePKInvite:cmd:streamId:)]) {
        [self.delegate onReceivePKInvite:inviter cmd:cmd streamId:streamId];
    }
}
- (void)onAcceptPKInvite:(NSString *)cmd streamId:(NSString *)streamId {
    if ([self.delegate respondsToSelector:@selector(onAcceptPKInvite:streamId:)]) {
        [self.delegate onAcceptPKInvite:cmd streamId:streamId];
    }
}
- (void)onRejectPKInvite:(NSString *)cmd reason:(int)reason {
    if ([self.delegate respondsToSelector:@selector(onRejectPKInvite:reason:)]) {
        [self.delegate onRejectPKInvite:cmd reason:reason];
    }
}
- (void)onCancelPK:(NSString *)cmd {
    if ([self.delegate respondsToSelector:@selector(onCancelPK:)]) {
        [self.delegate onCancelPK:cmd];
    }
}
- (void)onStopPK:(NSString *)cmd {
    if (self.isInLinkMic) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(onStopPK:)]) {
        [self.delegate onStopPK:cmd];
    }
}
- (void)onPKInviteTimeout {
    if ([self.delegate respondsToSelector:@selector(onTimeoutPK)]) {
        [self.delegate onTimeoutPK];
    }
}

- (void)onReceiveLinkMicInvite:(NSString *)inviter cmd:(NSString *)cmd streamId:(NSString *)streamId {
    if ([self isBusy]) {
        [self rejectLinkMic];
        return;
    }
    if ([self.delegate respondsToSelector:@selector(onReceiveLinkMicInvite:cmd:streamId:)]) {
        [self.delegate onReceiveLinkMicInvite:inviter cmd:cmd streamId:streamId];
    }
}
- (void)onStartLinkMic:(NSString *)cmd streamId:(NSString *)streamId {
    if ([self.delegate respondsToSelector:@selector(onStartLinkMic:streamId:)]) {
        [self.delegate onStartLinkMic:cmd streamId:streamId];
    }
}
- (void)onCancelLinkMic:(NSString *)cmd {
    if ([self.delegate respondsToSelector:@selector(onCancelLinkMic:)]) {
        [self.delegate onCancelLinkMic:cmd];
    }
}
- (void)onStopLinkMic:(NSString *)cmd {
    if (self.isInPK) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(onStopLinkMic:)]) {
        [self.delegate onStopLinkMic:cmd];
    }
}
- (void)onLinkMicInviteTimeout {
    if ([self.delegate respondsToSelector:@selector(onTimeoutLinkMic)]) {
        [self.delegate onTimeoutLinkMic];
    }
}

#pragma mark - Initialize
- (instancetype)initWithPusherView:(TUIPusherView *)pusherView {
    if (self = [super init]) {
        self.isFrontCamera = YES;
        self.isMirror = NO;
        self.pusherView = pusherView;
        self.isInPK = NO;
        self.isInLinkMic = NO;
    }
    return self;
}

- (TUIPusherSignalingService *)signalingService {
    if (!_signalingService) {
        _signalingService = [[TUIPusherSignalingService alloc] init];
        [_signalingService setDelegate:self];
    }
    return _signalingService;
}
@end
