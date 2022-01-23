//
//  TUIPlayerSignalingHelper.m
//  TUIPlayer
//
//  Created by gg on 2021/9/14.
//

#import "TUIPlayerSignalingHelper.h"

NSString *const PLAYER_SIGNALING_KEY_VERSION = @"version";
NSString *const PLAYER_SIGNALING_KEY_BUSINESSID = @"businessID";
NSString *const PLAYER_SIGNALING_KEY_PLATFORM = @"platform";
NSString *const PLAYER_SIGNALING_KEY_EXTINFO = @"extInfo";
NSString *const PLAYER_SIGNALING_KEY_DATA = @"data";
NSString *const PLAYER_SIGNALING_KEY_DATA_CMD = @"cmd";
NSString *const PLAYER_SIGNALING_KEY_DATA_CMD_INFO = @"cmdInfo";
NSString *const PLAYER_SIGNALING_KEY_DATA_STREAMID = @"streamID";

int       const PLAYER_SIGNALING_VALUE_VERSION = 1;
NSString *const PLAYER_SIGNALING_VALUE_BUSINESSID = @"TUIPlayer";
NSString *const PLAYER_SIGNALING_VALUE_PLATFORM = @"iOS";
NSString *const PLAYER_SIGNALING_VALUE_EXTINFO = @"extInfo";
NSString *const PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_REQ = @"link_req";
NSString *const PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_RES = @"link_res";
NSString *const PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_CANCEL = @"link_cancel";
NSString *const PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_STOP_REQ = @"link_stop_req";
NSString *const PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_STOP_RES = @"link_stop_res";
NSString *const PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_START_REQ = @"link_start_req";
NSString *const PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_START_RES = @"link_start_res";
NSString *const PLAYER_PUSHER_SIGNALING_VALUE_BUSINESSID = @"TUIPusher";

@implementation TUIPlayerSignalingHelper

+ (NSDictionary *)requestLinkMicSignaling:(NSString *)streamId {
    NSMutableDictionary *res = [NSMutableDictionary dictionaryWithDictionary:[self makeSignalingHeader]];
    [res setObject:[self makeRequestLinkMicData:streamId] forKey:PLAYER_SIGNALING_KEY_DATA];
    return res;
}

+ (NSDictionary *)startLinkMicReqSignaling:(NSString *)streamId {
    NSMutableDictionary *res = [NSMutableDictionary dictionaryWithDictionary:[self makeSignalingHeader]];
    [res setObject:[self makeStartLinkMicReqData:streamId] forKey:PLAYER_SIGNALING_KEY_DATA];
    return res;
}

+ (NSDictionary *)startLinkMicResSignaling {
    NSMutableDictionary *res = [NSMutableDictionary dictionaryWithDictionary:[self makeSignalingHeader]];
    [res setObject:[self makeStartLinkMicResData] forKey:PLAYER_SIGNALING_KEY_DATA];
    return res;
}

+ (NSDictionary *)stopLinkMicReqSignaling {
    NSMutableDictionary *res = [NSMutableDictionary dictionaryWithDictionary:[self makeSignalingHeader]];
    [res setObject:[self makeStopLinkMicReqData] forKey:PLAYER_SIGNALING_KEY_DATA];
    return res;
}

+ (NSDictionary *)stopLinkMicResSignaling {
    NSMutableDictionary *res = [NSMutableDictionary dictionaryWithDictionary:[self makeSignalingHeader]];
    [res setObject:[self makeStopLinkMicResData] forKey:PLAYER_SIGNALING_KEY_DATA];
    return res;
}

+ (NSDictionary *)cancelLinkMicSignaling {
    NSMutableDictionary *res = [NSMutableDictionary dictionaryWithDictionary:[self makeSignalingHeader]];
    [res setObject:[self makeCancelLinkMicData] forKey:PLAYER_SIGNALING_KEY_DATA];
    return res;
}

#pragma mark - Private

+ (NSDictionary *)makeCancelLinkMicData {
    return @{
        PLAYER_SIGNALING_KEY_DATA_CMD : PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_CANCEL
    };
}

+ (NSDictionary *)makeStopLinkMicReqData {
    return @{
        PLAYER_SIGNALING_KEY_DATA_CMD : PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_STOP_REQ,
    };
}

+ (NSDictionary *)makeStopLinkMicResData {
    return @{
        PLAYER_SIGNALING_KEY_DATA_CMD : PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_STOP_RES,
    };
}

+ (NSDictionary *)makeStartLinkMicReqData:(NSString *)streamId {
    return @{
        PLAYER_SIGNALING_KEY_DATA_CMD : PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_START_REQ,
        PLAYER_SIGNALING_KEY_DATA_STREAMID : streamId
    };
}

+ (NSDictionary *)makeStartLinkMicResData {
    return @{
        PLAYER_SIGNALING_KEY_DATA_CMD : PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_START_RES,
    };
}

+ (NSDictionary *)makeResponseLinkMicData:(NSString *)streamId {
    return @{
        PLAYER_SIGNALING_KEY_DATA_CMD : PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_RES,
        PLAYER_SIGNALING_KEY_DATA_STREAMID : streamId
    };
}

+ (NSDictionary *)makeRequestLinkMicData:(NSString *)streamId {
    return @{
        PLAYER_SIGNALING_KEY_DATA_CMD : PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_REQ,
        PLAYER_SIGNALING_KEY_DATA_STREAMID : streamId
    };
}

+ (NSDictionary *)makeSignalingHeader {
    return @{
        PLAYER_SIGNALING_KEY_VERSION : @(PLAYER_SIGNALING_VALUE_VERSION),
        PLAYER_SIGNALING_KEY_BUSINESSID : PLAYER_SIGNALING_VALUE_BUSINESSID,
        PLAYER_SIGNALING_KEY_PLATFORM : PLAYER_SIGNALING_VALUE_PLATFORM,
    };
}
@end
