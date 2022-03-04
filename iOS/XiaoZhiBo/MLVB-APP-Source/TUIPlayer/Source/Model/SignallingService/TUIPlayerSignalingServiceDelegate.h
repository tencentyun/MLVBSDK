//
//  TUIPlayerSignalingServiceDelegate.h
//  Pods
//
//  Created by gg on 2021/9/14.
//

#ifndef TUIPlayerSignalingServiceDelegate_h
#define TUIPlayerSignalingServiceDelegate_h

@protocol TUIPlayerSignalingServiceDelegate <NSObject>

- (void)onReceiveLinkMicInvite:(NSString *)inviter cmd:(NSString *)cmd streamId:(NSString *)streamId;

- (void)onAcceptLinkMicInvite:(NSString *)cmd streamId:(NSString *)streamId;
- (void)onRejectLinkMicInvite:(NSString *)cmd reason:(int)reason;

- (void)onStopLinkMic:(NSString *)cmd;
- (void)onLinkMicInviteTimeout;

- (void)onSignalingError:(NSString *)cmd code:(int)code message:(NSString *)msg;
@end

#endif /* TUIPlayerSignalingServiceDelegate_h */
