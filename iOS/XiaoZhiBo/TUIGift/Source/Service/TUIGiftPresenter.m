//
//  TUIGiftPresenter.m
//  TUIGiftPresenter
//
//  Created by WesleyLei on 2021/9/13.
//  Copyright © 2021 wesleylei. All rights reserved.
//

#import "TUIGiftPresenter.h"
#import "TUIGiftPanelConfig.h"
#import "TUIGiftIMService.h"

typedef  TUIGiftPlayBaseView* (^TUICacheSendViewBlock)(void);
@interface TUIGiftPresenter ()<TUIGiftPanelDelegate,TUIGiftIMServiceDelegate>

@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) TUIGiftIMService *msgService;
@property (nonatomic, strong) NSCache <NSString*,TUIGiftModel*> *cacheSendModel;
@property (nonatomic, weak, nullable) id <TUIGiftPresenterDelegate> delegate;

@end

@implementation TUIGiftPresenter

+ (instancetype)defaultCreate:(id <TUIGiftPresenterDelegate>)delegate groupId:(NSString *)groupId {//初始化
	TUIGiftPresenter *service = [[TUIGiftPresenter alloc]init];
	service.delegate = delegate;
	service.groupId = groupId;
	[service initIM];
	return service;
}

- (void)initIM {
	self.msgService = [TUIGiftIMService defaultCreate:self.groupId delegate:self];
}

#pragma mark set/get
- (NSCache *)cacheSendModel {
	if (_cacheSendModel == nil) {
		_cacheSendModel = [[NSCache alloc] init];
	}
	return _cacheSendModel;
}

- (void)onGiftSend:(TUIGiftModel *)giftModel {
	NSDictionary *param = @{@"giftId":giftModel.giftId?:@"",
                            @"lottieUrl":giftModel.animationURL?:@"",
                            @"imageUrl":giftModel.normalImageUrl?:@"",
                            @"message":giftModel.giveDesc?:@"",
                            @"extInfo":giftModel.extInfo?:@{}};
	if (![self.msgService onSendMsg:param]) {
		NSLog(@"gourpid is wrong.please check it");
		if ([self.delegate respondsToSelector:@selector(onGiftDidSend:isSuccess:message:)]) {
			[self.delegate onGiftDidSend:giftModel isSuccess:NO message:@"gourpid is wrong.please check it"];
		}
	} else {
		NSString *key = ([NSString stringWithFormat:@"%ld",(long)((NSInteger)param)]);
		[self.cacheSendModel setObject:giftModel forKey:key];
	}
}

#pragma mark TUIGiftIMServiceDelegate
/// 消息发送完成回调
- (void)didSend:(NSDictionary *)param isSuccess:(BOOL)success message:(NSString *)message {
	NSString *key = ([NSString stringWithFormat:@"%ld",(long)((NSInteger)param)]);
	TUIGiftModel *gift = [self.cacheSendModel objectForKey:key];
	if ([self.delegate respondsToSelector:@selector(onGiftDidSend:isSuccess:message:)] && gift) {
		[self.delegate onGiftDidSend:gift isSuccess:success message:message];
	}
	[self.cacheSendModel removeObjectForKey:key];
}

/// 收到消息回调
- (void)onReceive:(NSDictionary<NSString *,id> *)param {
	if (![param isKindOfClass:[NSDictionary class]]) {
		return;
	}
	NSString *giftId = param[@"giftId"];
	NSString *message = param[@"message"];
	NSString *lottieUrl = param[@"lottieUrl"];
	NSString *imageUrl = param[@"imageUrl"];
	NSDictionary *extInfo = param[@"extInfo"];

	if (![giftId isKindOfClass:[NSString class]] || !giftId.length) {
		return;
	}
	if (![message isKindOfClass:[NSString class]]) {
		return;
	}
	if (![lottieUrl isKindOfClass:[NSString class]]) {
		return;
	}
	if (![imageUrl isKindOfClass:[NSString class]]) {
		return;
	}
	if (![extInfo isKindOfClass:[NSDictionary class]]) {
		return;
	}
	//后期可以改为map形式
	TUIGiftModel *receiveGift = [[TUIGiftModel alloc]init];
    receiveGift.giftId = giftId;
    receiveGift.normalImageUrl = imageUrl;
    receiveGift.animationURL = lottieUrl;
    receiveGift.giveDesc = message;
    receiveGift.extInfo = extInfo;
	if ([self.delegate respondsToSelector:@selector(onReceiveGift:)]) {
		[self.delegate onReceiveGift:receiveGift];
	}
}

#pragma mark dealloc

- (void)dealloc {
    [self.msgService releaseResources];
}

@end
