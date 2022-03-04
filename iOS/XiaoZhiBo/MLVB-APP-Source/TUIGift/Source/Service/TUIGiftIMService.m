//
//  TUIGiftIMService.m
//  TUIGiftIMService
//
//  Created by WesleyLei on 2021/9/13.
//  Copyright © 2021 wesleylei. All rights reserved.
//

#import "TUIGiftIMService.h"
#import "TUITool.h"
#import "TUILogin.h"
#import <ImSDK_Plus/ImSDK_Plus.h>

NSString *const TUIGIFTIM_DATA_VERSION = @"1.0";
NSString *const TUIGIFTIM_DATA_PLATFORM = @"iOS";
NSString *const TUIGIFTIM_DATA_BUSINESSID = @"TUIGift";
NSString *const TUIGIFTIM_DATA_BUSINESSID_LIKE = @"TUIGift_like";
NSString *const TUIGIFTIM_SIGNALING_KEY_DATA = @"data";
NSString *const TUIGIFTIM_SIGNALING_KEY_USERID = @"userId";
NSString *const TUIGIFTIM_SIGNALING_KEY_VERSION = @"version";
NSString *const TUIGIFTIM_SIGNALING_KEY_BUSINESSID = @"businessID";
NSString *const TUIGIFTIM_SIGNALING_KEY_PLATFORM = @"platform";

@interface TUIGiftIMService ()<V2TIMSimpleMsgListener>

@property (nonatomic, weak, nullable) id <TUIGiftIMServiceDelegate> delegate;
@property (nonatomic, weak, nullable) V2TIMManager *imManager;
@property (nonatomic, strong) NSString *groupID;

@end

@implementation TUIGiftIMService

+ (instancetype)defaultCreate:(NSString *)groupID delegate:(id <TUIGiftIMServiceDelegate>)delegate {
	TUIGiftIMService *service = [[TUIGiftIMService alloc]init];
	service.delegate = delegate;
	service.groupID = groupID;
	[service initIMListener];
	return service;
}

- (void)initIMListener {
	self.imManager = [V2TIMManager sharedInstance];
	[self.imManager addSimpleMsgListener:self];
}

#pragma mark - 资源释放
///持有此对象，在dealloc时候调用此方法
- (void)releaseResources {
    [self.imManager removeSimpleMsgListener:self];
}

#pragma mark - 发送Msg
- (void)sendGiftMessage:(TUIGiftModel *)giftModel callback:(TUIGiftIMSendBlock)callback {
    NSDictionary *messageInfo = [self getGiftMessageParamWithModel:giftModel];
    NSString *messageString = [TUITool dictionary2JsonStr:messageInfo];
    [self sendGroupMsg:messageString priority:V2TIM_PRIORITY_HIGH callback:callback];
}

- (void)sendLikeMessageWithCallback:(TUIGiftIMSendBlock)callback {
    NSDictionary *messageInfo = [self getLikeMessageParam];
    NSString *messageString = [TUITool dictionary2JsonStr:messageInfo];
    [self sendGroupMsg:messageString priority:V2TIM_PRIORITY_NORMAL callback:callback];
}

/**
 * 发送群组自定义消息
 * @param message 群组自定义消息json字符串
 * @param priority 设置消息的优先级，我们没有办法所有消息都能 100% 送达每一个用户，但高优先级的消息会有更高的送达成功率。
 *      - HIGH ：云端会优先传输，适用于在群里发送重要信令，比如连麦邀请，PK邀请、礼物赠送等关键性信令。
 *      - NORMAL ：云端按默认优先级传输，适用于在群里发送非重要信令，比如观众的点赞提醒等等。
 * @param callback 结果回调
 */
- (void)sendGroupMsg:(NSString *)message priority:(V2TIMMessagePriority)priority callback:(TUIGiftIMSendBlock)callback {
	if (!self.groupID || ![self.groupID isKindOfClass:[NSString class]] || self.groupID.length == 0) {
        [self sendCallBack:callback code:-1 msg:@"group id is wrong. please check it."];
		return;
	}
    if ([self.imManager getLoginStatus] != V2TIM_STATUS_LOGINED) {
        [self sendCallBack:callback code:-1 msg:@"IM not login. please check it."];
        return;
    }
    if (!message || ![message isKindOfClass:[NSString class]] || message.length == 0) {
        [self sendCallBack:callback code:-1 msg:@"message is empty. please check it."];
        return;
    }
	NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
	if (!data) {
        [self sendCallBack:callback code:-1 msg:@"message can't covert to data"];
		return;
	}
	__weak typeof(self) wealSelf = self;
    [self.imManager sendGroupCustomMessage:data to:self.groupID priority:priority succ:^{
        __strong typeof(wealSelf) strongSelf = wealSelf;
        [strongSelf sendCallBack:callback code:0 msg:@"send group message success."];
    } fail:^(int code, NSString *desc) {
        __strong typeof(wealSelf) strongSelf = wealSelf;
        [strongSelf sendCallBack:callback code:code msg:desc];
    }];
}

- (void)sendCallBack:(TUIGiftIMSendBlock)callback code:(NSInteger)code msg:(NSString *)msg {
    if (callback) {
        NSString *desc = [NSString stringWithFormat:@"%@: %@", NSStringFromClass([self class]), msg];
        callback(code, desc);
    }
}

#pragma mark - TUIGiftIMServiceDelegate回调处理
- (void)onReceiveGift:(NSDictionary *)param {
    NSString *giftId = param[@"giftId"];
    NSString *message = param[@"message"];
    NSString *lottieUrl = param[@"lottieUrl"];
    NSString *imageUrl = param[@"imageUrl"];
    NSDictionary *extInfo = param[@"extInfo"];
    if (!giftId || ![giftId isKindOfClass:[NSString class]] || giftId.length == 0) {
        return;
    }
    if (!message || ![message isKindOfClass:[NSString class]]) {
        return;
    }
    if (!lottieUrl || ![lottieUrl isKindOfClass:[NSString class]]) {
        return;
    }
    if (!imageUrl || ![imageUrl isKindOfClass:[NSString class]]) {
        return;
    }
    if (!extInfo || ![extInfo isKindOfClass:[NSDictionary class]]) {
        return;
    }
    TUIGiftModel *giftModel = [[TUIGiftModel alloc]init];
    giftModel.giftId = giftId;
    giftModel.normalImageUrl = imageUrl;
    giftModel.animationURL = lottieUrl;
    giftModel.giveDesc = message;
    giftModel.extInfo = extInfo;
	if ([self.delegate respondsToSelector:@selector(onReceiveGiftMessage:)]) {
		[self.delegate onReceiveGiftMessage:giftModel];
	}
}

- (void)onReceiveLike:(NSDictionary *)param {
    NSDictionary *extInfo = param[@"extInfo"];
    if (![extInfo isKindOfClass:[NSDictionary class]]) {
        return;
    }
    TUIGiftModel *likeModel = [[TUIGiftModel alloc]init];
    likeModel.extInfo = extInfo;
    if ([self.delegate respondsToSelector:@selector(onReceiveLikeMessage:)]) {
        [self.delegate onReceiveLikeMessage:likeModel];
    }
}

#pragma mark - V2TIMSimpleMsgListener
- (void)onRecvGroupCustomMessage:(NSString *)msgID groupID:(NSString *)groupID sender:(V2TIMGroupMemberInfo *)info customData:(NSData *)data {
	if ([self.groupID isEqualToString:groupID] && data) {
		NSDictionary *dic = [TUITool jsonData2Dictionary:data];
		NSString *businessID = dic[TUIGIFTIM_SIGNALING_KEY_BUSINESSID];
		if (![businessID isKindOfClass:[NSString class]]) {
			return;
		}
        NSDictionary *dicData = dic[TUIGIFTIM_SIGNALING_KEY_DATA];
        if (![dicData isKindOfClass:[NSDictionary class]] || !dicData.count) {
            return;
        }
		if ([businessID isEqualToString:TUIGIFTIM_DATA_BUSINESSID]) {
			[self onReceiveGift:dicData];
		}
        if ([businessID isEqualToString:TUIGIFTIM_DATA_BUSINESSID_LIKE]) {
            [self onReceiveLike:dicData];
        }
	}
}

#pragma mark - 消息体转换、封装
/**
 * 获取礼物发送消息结构体
 * @param giftModel 礼物消息
 * @return 礼物消息结构体(NSMutableDictionary)
 */
- (NSMutableDictionary *)getGiftMessageParamWithModel:(TUIGiftModel *)giftModel {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:8];
    result[TUIGIFTIM_SIGNALING_KEY_VERSION] = TUIGIFTIM_DATA_VERSION;
    result[TUIGIFTIM_SIGNALING_KEY_PLATFORM] = TUIGIFTIM_DATA_PLATFORM;
    result[TUIGIFTIM_SIGNALING_KEY_BUSINESSID] = TUIGIFTIM_DATA_BUSINESSID;
    NSDictionary *defaultExtInfo = [self getDefaultExtInfo];
    NSDictionary *param = @{@"giftId": (giftModel.giftId ?: @""),
                            @"lottieUrl": (giftModel.animationURL ?: @""),
                            @"imageUrl": (giftModel.normalImageUrl ?: @""),
                            @"message": (giftModel.giveDesc ?: @""),
                            @"extInfo": (giftModel.extInfo ?: defaultExtInfo)};
    result[TUIGIFTIM_SIGNALING_KEY_DATA] = param;
    return result;
}

/**
 * 获取点赞发送消息结构体
 * @return 点赞消息结构体(NSMutableDictionary)
 */
- (NSMutableDictionary *)getLikeMessageParam {
    NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:8];
    result[TUIGIFTIM_SIGNALING_KEY_VERSION] = TUIGIFTIM_DATA_VERSION;
    result[TUIGIFTIM_SIGNALING_KEY_PLATFORM] = TUIGIFTIM_DATA_PLATFORM;
    result[TUIGIFTIM_SIGNALING_KEY_BUSINESSID] = TUIGIFTIM_DATA_BUSINESSID_LIKE;
    NSDictionary *defaultExtInfo = [self getDefaultExtInfo];
    NSDictionary *param = @{@"message": @"",
                            @"extInfo": defaultExtInfo};
    result[TUIGIFTIM_SIGNALING_KEY_DATA] = param;
    return result;
}

/**
 * 获取默认的扩展信息
 */
- (NSDictionary *)getDefaultExtInfo {
    NSString *defaultAvatar = @"https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar1.png";
    NSDictionary *info = @{@"nickName": ([TUILogin getNickName] ?: @""),
                           @"userID": ([TUILogin getUserID] ?: @""),
                           @"avatarUrl": ([TUILogin getFaceUrl] ?: defaultAvatar)};
    return info;
}

@end
