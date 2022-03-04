//
//  TUIPusherSignalingHelper.m
//  TUIPusher
//
//  Created by gg on 2021/9/10.
//

#import "TUIPusherSignalingHelper.h"

NSString *const PUSHER_SIGNALING_KEY_VERSION = @"version";
NSString *const PUSHER_SIGNALING_KEY_BUSINESSID = @"businessID";
NSString *const PUSHER_SIGNALING_KEY_PLATFORM = @"platform";
NSString *const PUSHER_SIGNALING_KEY_EXTINFO = @"extInfo";
NSString *const PUSHER_SIGNALING_KEY_DATA = @"data";
NSString *const PUSHER_SIGNALING_KEY_DATA_CMD = @"cmd";
NSString *const PUSHER_SIGNALING_KEY_DATA_CMD_INFO = @"cmdInfo";
NSString *const PUSHER_SIGNALING_KEY_DATA_STREAMID = @"streamID";

int       const PUSHER_SIGNALING_VALUE_VERSION = 1;
NSString *const PUSHER_SIGNALING_VALUE_BUSINESSID = @"TUIPusher";
NSString *const PUSHER_SIGNALING_VALUE_PLATFORM = @"iOS";
NSString *const PUSHER_SIGNALING_VALUE_EXTINFO = @"extInfo";
NSString *const PUSHER_SIGNALING_VALUE_DATA_CMD_PK_REQ = @"pk_req";
NSString *const PUSHER_SIGNALING_VALUE_DATA_CMD_PK_RES = @"pk_res";
NSString *const PUSHER_SIGNALING_VALUE_DATA_CMD_PK_CANCEL = @"pk_cancel";
NSString *const PUSHER_SIGNALING_VALUE_DATA_CMD_PK_STOP_REQ = @"pk_stop_req";
NSString *const PUSHER_SIGNALING_VALUE_DATA_CMD_PK_STOP_RES = @"pk_stop_res";
NSString *const PUSHER_PLAYER_SIGNALING_VALUE_BUSINESSID = @"TUIPlayer";
NSString *const PUSHER_PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_REQ = @"link_req";
NSString *const PUSHER_PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_RES = @"link_res";
NSString *const PUSHER_PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_CANCEL = @"link_cancel";
NSString *const PUSHER_PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_STOP_REQ = @"link_stop_req";
NSString *const PUSHER_PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_STOP_RES = @"link_stop_res";
NSString *const PUSHER_PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_START_REQ = @"link_start_req";
NSString *const PUSHER_PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_START_RES = @"link_start_res";

@implementation TUIPusherSignalingHelper

+ (NSDictionary *)requestPkSignaling:(NSString *)streamId {
    NSMutableDictionary *res = [NSMutableDictionary dictionaryWithDictionary:[self makeSignalingHeader]];
    [res setObject:[self makeRequestPkData:streamId] forKey:PUSHER_SIGNALING_KEY_DATA];
    return res;
}

+ (NSDictionary *)acceptPkSignaling:(NSString *)streamId {
    NSMutableDictionary *res = [NSMutableDictionary dictionaryWithDictionary:[self makeSignalingHeader]];
    [res setObject:[self makeResponsePkData:streamId reason:@""] forKey:PUSHER_SIGNALING_KEY_DATA];
    return res;
}

+ (NSDictionary *)rejectPkSignaling:(int)reason {
    NSMutableDictionary *res = [NSMutableDictionary dictionaryWithDictionary:[self makeSignalingHeader]];
    [res setObject:[self makeResponsePkData:@"" reason:[NSString stringWithFormat:@"%d", reason]] forKey:PUSHER_SIGNALING_KEY_DATA];
    return res;
}

+ (NSDictionary *)stopPkReqSignaling {
    NSMutableDictionary *res = [NSMutableDictionary dictionaryWithDictionary:[self makeSignalingHeader]];
    [res setObject:[self makeStopPkReqData] forKey:PUSHER_SIGNALING_KEY_DATA];
    return res;
}

+ (NSDictionary *)stopPkResSignaling {
    NSMutableDictionary *res = [NSMutableDictionary dictionaryWithDictionary:[self makeSignalingHeader]];
    [res setObject:[self makeStopPkResData] forKey:PUSHER_SIGNALING_KEY_DATA];
    return res;
}

+ (NSDictionary *)cancelPkSignaling {
    NSMutableDictionary *res = [NSMutableDictionary dictionaryWithDictionary:[self makeSignalingHeader]];
    [res setObject:[self makeCancelPkData] forKey:PUSHER_SIGNALING_KEY_DATA];
    return res;
}

+ (NSDictionary *)acceptLinkMicSignaling:(NSString *)streamId {
    NSMutableDictionary *res = [NSMutableDictionary dictionaryWithDictionary:[self makeSignalingHeader]];
    [res setObject:[self makeAcceptLinkMicSignaling:streamId] forKey:PUSHER_SIGNALING_KEY_DATA];
    return res;
}

+ (NSDictionary *)rejectLinkMicSignaling:(int)reason {
    NSMutableDictionary *res = [NSMutableDictionary dictionaryWithDictionary:[self makeSignalingHeader]];
    [res setObject:[self makeRejectLinkMicSignaling:[NSString stringWithFormat:@"%d", reason]] forKey:PUSHER_SIGNALING_KEY_DATA];
    return res;
}

+ (NSDictionary *)stopLinkMicReqSignaling {
    NSMutableDictionary *res = [NSMutableDictionary dictionaryWithDictionary:[self makeSignalingHeader]];
    [res setObject:[self makeStopLinkMicReqSignaling] forKey:PUSHER_SIGNALING_KEY_DATA];
    return res;
}

+ (NSDictionary *)stopLinkMicResSignaling {
    NSMutableDictionary *res = [NSMutableDictionary dictionaryWithDictionary:[self makeSignalingHeader]];
    [res setObject:[self makeStopLinkMicResSignaling] forKey:PUSHER_SIGNALING_KEY_DATA];
    return res;
}

+ (NSDictionary *)startLinkMicResSignaling {
    NSMutableDictionary *res = [NSMutableDictionary dictionaryWithDictionary:[self makeSignalingHeader]];
    [res setObject:[self makeStartLinkMicResSignaling] forKey:PUSHER_SIGNALING_KEY_DATA];
    return res;
}

#pragma mark - Private

+ (NSDictionary *)makeStartLinkMicResSignaling {
    return @{
        PUSHER_SIGNALING_KEY_DATA_CMD : PUSHER_PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_START_RES
    };
}

+ (NSDictionary *)makeStopLinkMicReqSignaling {
    return @{
        PUSHER_SIGNALING_KEY_DATA_CMD : PUSHER_PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_STOP_REQ
    };
}

+ (NSDictionary *)makeStopLinkMicResSignaling {
    return @{
        PUSHER_SIGNALING_KEY_DATA_CMD : PUSHER_PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_STOP_RES
    };
}

+ (NSDictionary *)makeRejectLinkMicSignaling:(NSString *)reason {
    return @{
        PUSHER_SIGNALING_KEY_DATA_CMD : PUSHER_PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_RES,
        PUSHER_SIGNALING_KEY_DATA_CMD_INFO : reason
    };
}

+ (NSDictionary *)makeAcceptLinkMicSignaling:(NSString *)streamId {
    return @{
        PUSHER_SIGNALING_KEY_DATA_CMD : PUSHER_PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_RES,
        PUSHER_SIGNALING_KEY_DATA_STREAMID : streamId
    };
}

+ (NSDictionary *)makeCancelPkData {
    return @{
        PUSHER_SIGNALING_KEY_DATA_CMD : PUSHER_SIGNALING_VALUE_DATA_CMD_PK_CANCEL
    };
}

+ (NSDictionary *)makeStopPkReqData {
    return @{
        PUSHER_SIGNALING_KEY_DATA_CMD : PUSHER_SIGNALING_VALUE_DATA_CMD_PK_STOP_REQ,
    };
}

+ (NSDictionary *)makeStopPkResData {
    return @{
        PUSHER_SIGNALING_KEY_DATA_CMD : PUSHER_SIGNALING_VALUE_DATA_CMD_PK_STOP_RES,
    };
}

+ (NSDictionary *)makeResponsePkData:(NSString *)streamId reason:(NSString *)reason {
    return @{
        PUSHER_SIGNALING_KEY_DATA_CMD : PUSHER_SIGNALING_VALUE_DATA_CMD_PK_RES,
        PUSHER_SIGNALING_KEY_DATA_STREAMID : streamId,
        PUSHER_SIGNALING_KEY_DATA_CMD_INFO : reason
    };
}

+ (NSDictionary *)makeRequestPkData:(NSString *)streamId {
    return @{
        PUSHER_SIGNALING_KEY_DATA_CMD : PUSHER_SIGNALING_VALUE_DATA_CMD_PK_REQ,
        PUSHER_SIGNALING_KEY_DATA_STREAMID : streamId
    };
}

+ (NSDictionary *)makeSignalingHeader {
    return @{
        PUSHER_SIGNALING_KEY_VERSION : @(PUSHER_SIGNALING_VALUE_VERSION),
        PUSHER_SIGNALING_KEY_BUSINESSID : PUSHER_SIGNALING_VALUE_BUSINESSID,
        PUSHER_SIGNALING_KEY_PLATFORM : PUSHER_SIGNALING_VALUE_PLATFORM,
    };
}

@end
