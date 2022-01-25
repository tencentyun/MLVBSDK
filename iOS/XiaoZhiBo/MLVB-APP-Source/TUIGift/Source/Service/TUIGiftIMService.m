//
//  TUIGiftIMService.m
//  TUIGiftIMService
//
//  Created by WesleyLei on 2021/9/13.
//  Copyright © 2021 wesleylei. All rights reserved.
//

#import "TUIGiftIMService.h"
#import "MJExtension.h"
#import <ImSDK_Plus/ImSDK_Plus.h>

NSString *const TUIGIFTIM_DATA_VERSION = @"1.0";
NSString *const TUIGIFTIM_DATA_PLATFORM = @"iOS";
NSString *const TUIGIFTIM_DATA_BUSINESSID = @"TUIGift";
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

#pragma mark 资源释放
///持有此对象，在dealloc时候调用此方法
- (void)releaseResources {
    [self.imManager removeSimpleMsgListener:self];
}

#pragma mark 发送Msg

- (BOOL)onSendMsg:(NSDictionary<NSString *,id> *)param {
	///im 发送并回调，delegate
	if ([param isKindOfClass:[NSDictionary class]] && param.count && ([self.imManager getLoginStatus] == V2TIM_STATUS_LOGINED)) {
		NSMutableDictionary *mudict = [self getMsgDict];
		NSMutableDictionary *muParam = [NSMutableDictionary dictionaryWithDictionary:param];
		muParam[TUIGIFTIM_SIGNALING_KEY_USERID] = [self.imManager getLoginUser]?:@"";
		mudict[TUIGIFTIM_SIGNALING_KEY_DATA] = param;
		[self sendGroupMsg:[mudict mj_JSONString] param:param];
		return YES;
	} else {
		return NO;
	}
}

- (void)sendGroupMsg:(NSString *)message param:(NSDictionary<NSString *,id> *)param {
	if (self.groupID.length <= 0) {
		[self sendCallBack:-1 desc:@"gourp id is wrong.please check it." param:param];
		return;
	}
	NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
	if (!data) {
		[self sendCallBack:-1 desc:@"message can't covert to data" param:param];
		return;
	}
	__weak typeof(self) wealSelf = self;
    [self.imManager sendGroupCustomMessage:data to:self.groupID priority:V2TIM_PRIORITY_HIGH succ:^{
        __strong typeof(wealSelf) strongSelf = wealSelf;
        [strongSelf sendCallBack:0 desc:@"send group message success." param:param];
    } fail:^(int code, NSString *desc) {
        __strong typeof(wealSelf) strongSelf = wealSelf;
        [strongSelf sendCallBack:code desc:desc param:param];
    }];
}

#pragma mark delegate

- (void)sendCallBack:(NSInteger)code desc:(NSString *)desc param:(NSDictionary<NSString *,id> *)param {
	if ([self.delegate respondsToSelector:@selector(didSend:isSuccess:message:)]) {
		[self.delegate didSend:param isSuccess:(code==0) message:@"message can't covert to data"];
	}
}

- (void)onReceive:(NSDictionary *)dict {
	if ([self.delegate respondsToSelector:@selector(onReceive:)]) {
		[self.delegate onReceive:dict];
	}
}

#pragma mark 消息体

- (NSMutableDictionary *)getMsgDict {
	NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:8];
	result[TUIGIFTIM_SIGNALING_KEY_VERSION] = TUIGIFTIM_DATA_VERSION;
	result[TUIGIFTIM_SIGNALING_KEY_PLATFORM] = TUIGIFTIM_DATA_PLATFORM;
	result[TUIGIFTIM_SIGNALING_KEY_BUSINESSID] = TUIGIFTIM_DATA_BUSINESSID;
	return result;
}

#pragma mark V2TIMSimpleMsgListener

- (void)onRecvGroupCustomMessage:(NSString *)msgID groupID:(NSString *)groupID sender:(V2TIMGroupMemberInfo *)info customData:(NSData *)data {
	if ([self.groupID isEqualToString:groupID] && data) {
		NSString* jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		NSDictionary* dic = [jsonString mj_JSONObject];
		NSDictionary *dicData = dic[TUIGIFTIM_SIGNALING_KEY_DATA];
		if (![dicData isKindOfClass:[NSDictionary class]] || !dicData.count) {
			return;
		}
		NSString *businessID = dic[TUIGIFTIM_SIGNALING_KEY_BUSINESSID];
		if (![businessID isKindOfClass:[NSString class]]) {
			return;
		}
		if ([businessID isEqualToString:TUIGIFTIM_DATA_BUSINESSID]) {
			[self onReceive:dicData];
		}
	}
}

@end
