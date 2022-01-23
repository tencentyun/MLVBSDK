//
//  TUIPlayerSignalingHelper.h
//  TUIPlayer
//
//  Created by gg on 2021/9/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const PLAYER_SIGNALING_KEY_VERSION;
extern NSString *const PLAYER_SIGNALING_KEY_BUSINESSID;
extern NSString *const PLAYER_SIGNALING_KEY_PLATFORM;
extern NSString *const PLAYER_SIGNALING_KEY_EXTINFO;
extern NSString *const PLAYER_SIGNALING_KEY_DATA;
extern NSString *const PLAYER_SIGNALING_KEY_DATA_CMD;
extern NSString *const PLAYER_SIGNALING_KEY_DATA_CMD_INFO;
extern NSString *const PLAYER_SIGNALING_KEY_DATA_STREAMID;

extern int       const PLAYER_SIGNALING_VALUE_VERSION;
extern NSString *const PLAYER_SIGNALING_VALUE_BUSINESSID;
extern NSString *const PLAYER_SIGNALING_VALUE_PLATFORM;
extern NSString *const PLAYER_SIGNALING_VALUE_EXTINFO;
extern NSString *const PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_REQ;
extern NSString *const PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_RES;
extern NSString *const PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_CANCEL;
extern NSString *const PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_STOP_REQ;
extern NSString *const PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_STOP_RES;
extern NSString *const PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_START_REQ;
extern NSString *const PLAYER_SIGNALING_VALUE_DATA_CMD_LINK_START_RES;
extern NSString *const PLAYER_PUSHER_SIGNALING_VALUE_BUSINESSID;

@interface TUIPlayerSignalingHelper : NSObject

+ (NSDictionary *)requestLinkMicSignaling:(NSString *)streamId;
+ (NSDictionary *)startLinkMicReqSignaling:(NSString *)streamId;
+ (NSDictionary *)startLinkMicResSignaling;
+ (NSDictionary *)stopLinkMicReqSignaling;
+ (NSDictionary *)stopLinkMicResSignaling;
+ (NSDictionary *)cancelLinkMicSignaling;
@end

NS_ASSUME_NONNULL_END
