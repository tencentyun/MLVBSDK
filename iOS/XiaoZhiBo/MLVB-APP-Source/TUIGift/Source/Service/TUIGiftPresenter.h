//
//  TUIGiftPresenter.h
//  TUIGiftPresenter
//
//  Created by WesleyLei on 2021/9/13.
//  Copyright © 2021 wesleylei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TUIGiftModel.h"
#import "TUIGiftPanelBaseView.h"
#import "TUIGiftPlayBaseView.h"

NS_ASSUME_NONNULL_BEGIN
/// Service 服务协议
@protocol TUIGiftPresenterDelegate<NSObject>

@optional
/**
 * 发送礼物完成回调
 *
 * @param model 礼物信息
 * @param success YES发送成功，NO不发送失败
 * @param message 提示信息
*/
- (void)onGiftDidSend:(TUIGiftModel *)model isSuccess:(BOOL)success message:(NSString *)message;

/**
 * 发送点赞完成回调
 *
 * @param model 点赞信息
 * @param success YES发送成功，NO不发送失败
 * @param message 提示信息
*/
- (void)onLikeDidSend:(TUIGiftModel *)model isSuccess:(BOOL)success message:(NSString *)message;

/**
 * 收到礼物回调
 *
 * @param model 礼物信息
*/
- (void)onReceiveGift:(TUIGiftModel *)model;

/**
 * 收到点赞回调
 *
 * @param model 点赞信息
*/
- (void)onReceiveLike:(TUIGiftModel *)model;

@end

@interface TUIGiftPresenter : NSObject

/**
 * 默认创建
 *
 * @param delegate 代理
 * @param groupId 群组id
*/
+ (instancetype)defaultCreate:(id <TUIGiftPresenterDelegate>)delegate groupId:(NSString *)groupId;

/**
 * 发送礼物
 *
 * @param giftModel 礼物信息
*/
- (void)sendGift:(TUIGiftModel *)giftModel;


/**
 * 发送点赞
*/
- (void)sendLike;

@end

NS_ASSUME_NONNULL_END
