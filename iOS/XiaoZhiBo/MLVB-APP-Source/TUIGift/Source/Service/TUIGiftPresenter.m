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

#pragma mark - 发送消息
- (void)sendGift:(TUIGiftModel *)giftModel {
    __weak typeof(self) wealSelf = self;
    [self.msgService sendGiftMessage:giftModel callback:^(NSInteger code, NSString * _Nonnull msg) {
        if ([wealSelf.delegate respondsToSelector:@selector(onGiftDidSend:isSuccess:message:)]) {
            BOOL isSuccess = (code == 0);
            [wealSelf.delegate onGiftDidSend:giftModel isSuccess:isSuccess message:msg];
        }
    }];
}

- (void)sendLike {
    __weak typeof(self) wealSelf = self;
    [self.msgService sendLikeMessageWithCallback:^(NSInteger code, NSString * _Nonnull msg) {
        if ([wealSelf.delegate respondsToSelector:@selector(onLikeDidSend:isSuccess:message:)]) {
            BOOL isSuccess = (code == 0);
            TUIGiftModel *model = [TUIGiftModel defaultCreate];
            [wealSelf.delegate onLikeDidSend:model isSuccess:isSuccess message:msg];
        }
    }];
}

#pragma mark - TUIGiftIMServiceDelegate
- (void)onReceiveGiftMessage:(TUIGiftModel *)giftModel {
    if ([self.delegate respondsToSelector:@selector(onReceiveGift:)]) {
        [self.delegate onReceiveGift:giftModel];
    }
}

- (void)onReceiveLikeMessage:(TUIGiftModel *)likeModel {
    if ([self.delegate respondsToSelector:@selector(onReceiveLike:)]) {
        [self.delegate onReceiveLike:likeModel];
    }
}

#pragma mark dealloc
- (void)dealloc {
    [self.msgService releaseResources];
}

@end
