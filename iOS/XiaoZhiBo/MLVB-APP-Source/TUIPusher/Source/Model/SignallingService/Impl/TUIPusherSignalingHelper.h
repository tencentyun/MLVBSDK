//
//  TUIPusherSignalingHelper.h
//  TUIPusher
//
//  Created by gg on 2021/9/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const PUSHER_SIGNALING_KEY_VERSION;
extern NSString *const PUSHER_SIGNALING_KEY_BUSINESSID;
extern NSString *const PUSHER_SIGNALING_KEY_PLATFORM;
extern NSString *const PUSHER_SIGNALING_KEY_EXTINFO;
extern NSString *const PUSHER_SIGNALING_KEY_DATA;
extern NSString *const PUSHER_SIGNALING_KEY_DATA_CMD;
extern NSString *const PUSHER_SIGNALING_KEY_DATA_CMD_INFO;
extern NSString *const PUSHER_SIGNALING_KEY_DATA_STREAMID;

extern int       const PUSHER_SIGNALING_VALUE_VERSION;
extern NSString *const PUSHER_SIGNALING_VALUE_BUSINESSID;
extern NSString *const PUSHER_SIGNALING_VALUE_PLATFORM;
extern NSString *const PUSHER_SIGNALING_VALUE_EXTINFO;
extern NSString *const PUSHER_SIGNALING_VALUE_DATA_CMD_PK_REQ;
extern NSString *const PUSHER_SIGNALING_VALUE_DATA_CMD_PK_RES;
extern NSString *const PUSHER_SIGNALING_VALUE_DATA_CMD_PK_CANCEL;
extern NSString *const PUSHER_SIGNALING_VALUE_DATA_CMD_PK_STOP_REQ;
extern NSString *const PUSHER_SIGNALING_VALUE_DATA_CMD_PK_STOP_RES;
extern NSString *const PUSHER_PLAYER_SIGNALING_VALUE_BUSINESSID;
extern NSString *const PUSHER_PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_REQ;
extern NSString *const PUSHER_PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_RES;
extern NSString *const PUSHER_PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_START_REQ;
extern NSString *const PUSHER_PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_START_RES;
extern NSString *const PUSHER_PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_STOP_REQ;
extern NSString *const PUSHER_PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_STOP_RES;
extern NSString *const PUSHER_PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_CANCEL;

@interface TUIPusherSignalingHelper : NSObject

+ (NSDictionary *)requestPkSignaling:(NSString *)streamId;
+ (NSDictionary *)acceptPkSignaling:(NSString *)streamId;
+ (NSDictionary *)rejectPkSignaling:(int)reason;
+ (NSDictionary *)cancelPkSignaling;
+ (NSDictionary *)stopPkReqSignaling;
+ (NSDictionary *)stopPkResSignaling;

+ (NSDictionary *)acceptLinkMicSignaling:(NSString *)streamId;
+ (NSDictionary *)rejectLinkMicSignaling:(int)reason;
+ (NSDictionary *)stopLinkMicReqSignaling;
+ (NSDictionary *)stopLinkMicResSignaling;
+ (NSDictionary *)startLinkMicResSignaling;
@end

NS_ASSUME_NONNULL_END
