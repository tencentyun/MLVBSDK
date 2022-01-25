//
//  TUIPlayerPresenter.m
//  TUIPlayer
//
//  Created by gg on 2021/9/14.
//

#import "TUIPlayerPresenter.h"
#import "TUIPlayerStreamService.h"
#import "TUIPlayerSignalingService.h"
#import "TUIPlayerHeader.h"
#import "TUIPlayerKit.h"

@interface TUIPlayerPresenter () <TUIPlayerSignalingServiceDelegate, TUIPlayerStreamServiceDelegate>

@property (nonatomic, strong) TUIPlayerStreamService *streamService;
@property (nonatomic, strong) TUIPlayerSignalingService *signalingService;

@property (nonatomic, assign) BOOL isInLinkMic;

@end

@implementation TUIPlayerPresenter

- (NSInteger)startPlay:(NSString *)url atView:(nonnull UIView *)view {
    if (![self.signalingService checkLoginStatus]) {
        return V2TXLIVE_ERROR_FAILED;
    }
    return [self.streamService startPlay:url atView:view];
}

- (void)stopPlay {
    [self.streamService stopPlay];
}

- (void)pauseVideo {
    [self.streamService pauseVideo];
}

- (void)resumeVideo {
    [self.streamService resumeVideo];
}

- (void)pauseAudio {
    [self.streamService pauseAudio];
}

- (void)resumeAudio {
    [self.streamService resumeAudio];
}

- (BOOL)sendLinkMicRequest:(NSString *)userId {
    return [self.signalingService requestLinkMic:userId];
}

- (void)cancelLinkMicRequest {
    [self.signalingService cancelRequestLinkMic];
}

- (void)sendStopLinkMic {
    if (self.isInLinkMic) {
        [self.signalingService sendStopLinkMic];
    }
}

- (void)startLinkMicWithUser:(NSString *)remoteUserId atView:(UIView *)view complete:(nonnull void (^)(BOOL))complete {
    @weakify(self)
    [self.signalingService sendStartLinkMic:^(BOOL success) {
        @strongify(self)
        if (success) {
            self.isInLinkMic = YES;
            [self.streamService startLinkMic:remoteUserId view:view complete:complete];
        }
        else {
            if (complete) {
                complete(NO);
            }
        }
    }];
}

- (void)stopLinkMic {
    self.isInLinkMic = NO;
    [self.streamService stopLinkMic];
}

- (instancetype)init {
    if (self = [super init]) {
        self.isInLinkMic = NO;
    }
    return self;
}

#pragma mark - TUIPlayerSignalingServiceDelegate
- (void)onReceiveLinkMicInvite:(NSString *)inviter cmd:(NSString *)cmd streamId:(NSString *)streamId {
    if ([self.delegate respondsToSelector:@selector(onReceiveLinkMicInvite:cmd:streamId:)]) {
        [self.delegate onReceiveLinkMicInvite:inviter cmd:cmd streamId:streamId];
    }
}

- (void)onAcceptLinkMicInvite:(NSString *)cmd streamId:(NSString *)streamId {
    if ([self.delegate respondsToSelector:@selector(onAcceptLinkMicInvite:streamId:)]) {
        [self.delegate onAcceptLinkMicInvite:cmd streamId:streamId];
    }
}
- (void)onRejectLinkMicInvite:(NSString *)cmd reason:(int)reason {
    if ([self.delegate respondsToSelector:@selector(onRejectLinkMicInvite:reason:)]) {
        [self.delegate onRejectLinkMicInvite:cmd reason:reason];
    }
}

- (void)onStopLinkMic:(NSString *)cmd {
    if ([self.delegate respondsToSelector:@selector(onStopLinkMic:)]) {
        [self.delegate onStopLinkMic:cmd];
    }
}
- (void)onLinkMicInviteTimeout {
    if ([self.delegate respondsToSelector:@selector(onLinkMicInviteTimeout)]) {
        [self.delegate onLinkMicInviteTimeout];
    }
}

#pragma mark - TUIPlayerStreamServiceDelegate
- (void)onRemoteStopPush {
    if ([self.delegate respondsToSelector:@selector(onRemoteStopPush)]) {
        [self.delegate onRemoteStopPush];
    }
}

#pragma mark - Initialize

- (BOOL)checkPushUrl:(NSString *)url {
    if (!url || url.length <= 0) {
        return NO;
    }
    if (![url hasPrefix:@"trtc://"] && ![url hasPrefix:@"room://"] && ![url hasPrefix:@"mrtc://"]) {
        return NO;
    }
    return YES;
}

- (BOOL)checkLoginStatus {
    BOOL res = [self.signalingService checkLoginStatus];
    if (!res) {
        
    }
    return res;
}

- (TUIPlayerStreamService *)streamService {
    if (!_streamService) {
        _streamService = [[TUIPlayerStreamService alloc] init];
        _streamService.delegate = self;
    }
    return _streamService;
}

- (TUIPlayerSignalingService *)signalingService {
    if (!_signalingService) {
        _signalingService = [[TUIPlayerSignalingService alloc] init];
        [_signalingService setDelegate:self];
    }
    return _signalingService;
}
@end
