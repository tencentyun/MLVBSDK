//
//  TUIPusherSignallingServiceDelegate.h
//  Pods
//
//  Created by gg on 2021/9/8.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TUIPusherSignalingServiceDelegate <NSObject>

@optional
- (void)onSignalingError:(NSString *)cmd code:(int)code message:(NSString *)msg;

- (void)onReceivePKInvite:(NSString *)inviter cmd:(NSString *)cmd streamId:(NSString *)streamId;
- (void)onAcceptPKInvite:(NSString *)cmd streamId:(NSString *)streamId;
- (void)onRejectPKInvite:(NSString *)cmd reason:(int)reason;
- (void)onCancelPK:(NSString *)cmd;
- (void)onStopPK:(NSString *)cmd;
- (void)onPKInviteTimeout;

- (void)onReceiveLinkMicInvite:(NSString *)inviter cmd:(NSString *)cmd streamId:(NSString *)streamId;
- (void)onStartLinkMic:(NSString *)cmd streamId:(NSString *)streamId;
- (void)onCancelLinkMic:(NSString *)cmd;
- (void)onStopLinkMic:(NSString *)cmd;
- (void)onLinkMicInviteTimeout;
@end

NS_ASSUME_NONNULL_END
