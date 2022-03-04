//
//  TUIPlayerSignalingService.m
//  TUIPlayer
//
//  Created by gg on 2021/9/14.
//

#import "TUIPlayerSignalingService.h"
#import <ImSDK_Plus/ImSDK_Plus.h>
#import <TUICore/TUILogin.h>
#import "TUIPlayerSignalingHelper.h"
#import "TUIPlayerHeader.h"

static int const PlayerSignalingTimeout = 30;

@interface TUIPlayerSignalingService () <V2TIMSignalingListener>
@property (nonatomic, weak) id <TUIPlayerSignalingServiceDelegate> delegate;

@property (nonatomic, copy) NSString *currentInviteId;
@property (nonatomic, copy) NSString *currentInviteUserId;
@end

@implementation TUIPlayerSignalingService

- (BOOL)checkLoginStatus {
    return V2TIM_STATUS_LOGINED == [[V2TIMManager sharedInstance] getLoginStatus];
}

- (void)setDelegate:(id)delegate {
    _delegate = delegate;
}

- (BOOL)requestLinkMic:(NSString *)userId {
    NSDictionary *signaling = [TUIPlayerSignalingHelper requestLinkMicSignaling:[TUILogin getUserID]];
    NSString *jsonStr = [self dic2JsonStr:signaling];
    
    NSString *inviteId = [[V2TIMManager sharedInstance] invite:userId data:jsonStr onlineUserOnly:YES offlinePushInfo:nil timeout:PlayerSignalingTimeout succ:^{
        
    } fail:^(int code, NSString *desc) {
        if ([self.delegate respondsToSelector:@selector(onSignalingError:code:message:)]) {
            [self.delegate onSignalingError:PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_REQ code:code message:desc];
        }
    }];
    if (inviteId != nil) {
        self.currentInviteId = inviteId;
        self.currentInviteUserId = userId;
    }
    return inviteId != nil;
}

- (void)cancelRequestLinkMic {
    if (self.currentInviteId != nil) {
        NSDictionary *signaling = [TUIPlayerSignalingHelper cancelLinkMicSignaling];
        NSString *jsonStr = [self dic2JsonStr:signaling];
        [[V2TIMManager sharedInstance] cancel:self.currentInviteId data:jsonStr succ:^{
            
        } fail:^(int code, NSString *desc) {
            if ([self.delegate respondsToSelector:@selector(onSignalingError:code:message:)]) {
                [self.delegate onSignalingError:PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_CANCEL code:code message:desc];
            }
        }];
        self.currentInviteId = nil;
        self.currentInviteUserId = nil;
    }
}

- (void)sendStartLinkMic:(void (^)(BOOL))complete {
    if (self.currentInviteUserId != nil) {
        NSDictionary *signaling = [TUIPlayerSignalingHelper startLinkMicReqSignaling:[TUILogin getUserID]];
        NSString *jsonStr = [self dic2JsonStr:signaling];
        [[V2TIMManager sharedInstance] invite:self.currentInviteUserId data:jsonStr onlineUserOnly:YES offlinePushInfo:nil timeout:PlayerSignalingTimeout succ:^{
            if (complete) {
                complete(YES);
            }
        } fail:^(int code, NSString *desc) {
            if (complete) {
                complete(NO);
            }
        }];
    }
}

- (void)sendStopLinkMic {
    if (self.currentInviteUserId != nil) {
        NSDictionary *signaling = [TUIPlayerSignalingHelper stopLinkMicReqSignaling];
        NSString *jsonStr = [self dic2JsonStr:signaling];
        [[V2TIMManager sharedInstance] invite:self.currentInviteUserId data:jsonStr onlineUserOnly:YES offlinePushInfo:nil timeout:PlayerSignalingTimeout succ:^{
            
        } fail:^(int code, NSString *desc) {
            if ([self.delegate respondsToSelector:@selector(onSignalingError:code:message:)]) {
                [self.delegate onSignalingError:PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_STOP_REQ code:code message:desc];
            }
        }];
        self.currentInviteUserId = nil;
        if ([self.delegate respondsToSelector:@selector(onStopLinkMic:)]) {
            [self.delegate onStopLinkMic:PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_STOP_REQ];
        }
    }
}

- (NSString *)dic2JsonStr:(NSDictionary *)dic {
    NSError *err = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&err];
    if (err) {
        return @"";
    }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSDictionary *)jsonStr2Dic:(NSString *)str {
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (err) {
        return @{};
    }
    return res;
}

- (instancetype)init {
    if (self = [super init]) {
        [[V2TIMManager sharedInstance] addSignalingListener:self];
    }
    return self;
}

- (BOOL)validateSignalingHeader:(NSDictionary *)dic {
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    if ([dic.allKeys containsObject:PLAYER_SIGNALING_KEY_VERSION]) {
        int version = [dic[PLAYER_SIGNALING_KEY_VERSION] intValue];
        if (version != PLAYER_SIGNALING_VALUE_VERSION) {
            return NO;
        }
    }
    else {
        return NO;
    }
    if ([dic.allKeys containsObject:PLAYER_SIGNALING_KEY_BUSINESSID]) {
        NSString *businessId = dic[PLAYER_SIGNALING_KEY_BUSINESSID];
        if (![businessId isEqualToString:PLAYER_PUSHER_SIGNALING_VALUE_BUSINESSID] && ![businessId isEqualToString:PLAYER_SIGNALING_VALUE_BUSINESSID]) {
            return NO;
        }
    }
    else {
        return NO;
    }
    return YES;
}

#pragma mark - V2TIMSignalingListener
- (void)onReceiveNewInvitation:(NSString *)inviteID inviter:(NSString *)inviter groupID:(NSString *)groupID inviteeList:(NSArray<NSString *> *)inviteeList data:(NSString *)data {
    LOGD("【Player】recv invitation: [%@] %@", inviter, data);
    NSDictionary *dic = [self jsonStr2Dic:data];
    if (![self validateSignalingHeader:dic]) {
        return;
    }
    if (![dic.allKeys containsObject:PLAYER_SIGNALING_KEY_DATA]) {
        return;
    }
    NSDictionary *dataDic = dic[PLAYER_SIGNALING_KEY_DATA];
    if (![dataDic.allKeys containsObject:PLAYER_SIGNALING_KEY_DATA_CMD]) {
        return;
    }
    NSString *cmd = dataDic[PLAYER_SIGNALING_KEY_DATA_CMD];
    if ([cmd isEqualToString:PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_STOP_REQ]) {
        if ([self.delegate respondsToSelector:@selector(onStopLinkMic:)]) {
            [self.delegate onStopLinkMic:cmd];
        }
        
        NSDictionary *signaling = [TUIPlayerSignalingHelper stopLinkMicReqSignaling];
        NSString *jsonStr = [self dic2JsonStr:signaling];
        [[V2TIMManager sharedInstance] accept:inviteID data:jsonStr succ:nil fail:nil];
    }
    else {
        NSString *streamId = dataDic[PLAYER_SIGNALING_KEY_DATA_STREAMID];
        if ([self.delegate respondsToSelector:@selector(onReceiveLinkMicInvite:cmd:streamId:)]) {
            [self.delegate onReceiveLinkMicInvite:inviter cmd:cmd streamId:streamId];
        }
    }
}

- (void)onInviteeAccepted:(NSString *)inviteID invitee:(NSString *)invitee data:(NSString *)data {
    LOGD("【Player】invite accept: [%@] %@", invitee, data);
    if ([invitee isEqualToString:[TUILogin getUserID]]) {
        return;
    }
    NSDictionary *dic = [self jsonStr2Dic:data];
    if (![self validateSignalingHeader:dic]) {
        return;
    }
    if (![dic.allKeys containsObject:PLAYER_SIGNALING_KEY_DATA]) {
        return;
    }
    NSDictionary *dataDic = dic[PLAYER_SIGNALING_KEY_DATA];
    if (![dataDic.allKeys containsObject:PLAYER_SIGNALING_KEY_DATA_CMD]) {
        return;
    }
    NSString *cmd = dataDic[PLAYER_SIGNALING_KEY_DATA_CMD];
    NSString *streamId = dataDic[PLAYER_SIGNALING_KEY_DATA_STREAMID];
    if ([cmd isEqualToString:PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_RES]) {
        self.currentInviteId = nil;
        if ([self.delegate respondsToSelector:@selector(onAcceptLinkMicInvite:streamId:)]) {
            [self.delegate onAcceptLinkMicInvite:cmd streamId:streamId];
        }
    }
}

-(void)onInviteeRejected:(NSString *)inviteID invitee:(NSString *)invitee data:(NSString *)data {
    LOGD("【Player】invite reject: [%@] %@", invitee, data);
    if ([invitee isEqualToString:[TUILogin getUserID]]) {
        return;
    }
    NSDictionary *dic = [self jsonStr2Dic:data];
    if (![self validateSignalingHeader:dic]) {
        return;
    }
    if (![dic.allKeys containsObject:PLAYER_SIGNALING_KEY_DATA]) {
        return;
    }
    NSDictionary *dataDic = dic[PLAYER_SIGNALING_KEY_DATA];
    if (![dataDic.allKeys containsObject:PLAYER_SIGNALING_KEY_DATA_CMD]) {
        return;
    }
    NSString *cmd = dataDic[PLAYER_SIGNALING_KEY_DATA_CMD];
    NSString *reason = nil;
    if ([dataDic.allKeys containsObject:PLAYER_SIGNALING_KEY_DATA_CMD_INFO]) {
        reason = dataDic[PLAYER_SIGNALING_KEY_DATA_CMD_INFO];
        if (reason.length != 1) {
            reason = nil;
        }
        else {
            int value = [reason intValue];
            if (value != TUIPlayerRejectReasonNormal && value != TUIPlayerRejectReasonBusy) {
                reason = nil;
            }
        }
    }
    if ([cmd isEqualToString:PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_RES] && reason != nil) {
        self.currentInviteId = nil;
        if ([self.delegate respondsToSelector:@selector(onRejectLinkMicInvite:reason:)]) {
            [self.delegate onRejectLinkMicInvite:cmd reason:[reason intValue]];
        }
    }
}

-(void)onInvitationTimeout:(NSString *)inviteID inviteeList:(NSArray<NSString *> *)inviteeList {
    LOGD("【Player】invite timeout: %@", inviteeList);
    if (self.currentInviteId != nil && [inviteID isEqualToString:self.currentInviteId]) {
        self.currentInviteId = nil;
        self.currentInviteUserId = nil;
        if ([self.delegate respondsToSelector:@selector(onLinkMicInviteTimeout)]) {
            [self.delegate onLinkMicInviteTimeout];
        }
    }
}
@end
