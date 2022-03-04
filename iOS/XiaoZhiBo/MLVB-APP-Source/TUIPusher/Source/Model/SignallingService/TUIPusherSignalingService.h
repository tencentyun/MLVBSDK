//
//  TUIPusherSignalingService.h
//  Pods
//
//  Created by gg on 2021/9/8.
//

#import <Foundation/Foundation.h>
#import "TUIPusherSignalingServiceDelegate.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    TUIPusherRejectReasonNormal = 1,
    TUIPusherRejectReasonBusy = 2,
} TUIPusherRejectReason;

@interface TUIPusherSignalingService : NSObject

- (void)setDelegate:(id<TUIPusherSignalingServiceDelegate>)delegate;

- (BOOL)checkLoginStatus;

- (BOOL)requestPK:(NSString *)userId;
- (void)cancelPKRequest;
- (void)acceptPK:(NSString *)streamId;
- (void)rejectPKWithReason:(TUIPusherRejectReason)reason;
- (void)stopPK;

- (void)acceptLinkMic:(NSString *)streamId;
- (void)rejectLinkMic:(TUIPusherRejectReason)reason;
- (void)stopLinkMic;
@end

NS_ASSUME_NONNULL_END
