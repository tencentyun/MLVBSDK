//
//  TUIPlayerSignalingService.h
//  TUIPlayer
//
//  Created by gg on 2021/9/14.
//

#import <Foundation/Foundation.h>
#import "TUIPlayerSignalingServiceDelegate.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    TUIPlayerRejectReasonNormal = 1,
    TUIPlayerRejectReasonBusy = 2,
} TUIPlayerRejectReason;

@interface TUIPlayerSignalingService : NSObject

- (BOOL)checkLoginStatus;

- (void)setDelegate:(id <TUIPlayerSignalingServiceDelegate>)delegate;

- (BOOL)requestLinkMic:(NSString *)userId;

- (void)cancelRequestLinkMic;

- (void)sendStartLinkMic:(void (^) (BOOL success))complete;

- (void)sendStopLinkMic;

@end

NS_ASSUME_NONNULL_END
