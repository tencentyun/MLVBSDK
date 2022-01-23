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
/// 发送回调
typedef  void (^TUIGiftSendBlock)(BOOL isSend);
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
* 收到礼物回调
*
* @param model 礼物信息
*/
- (void)onReceiveGift:(TUIGiftModel *)model;

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
- (void)onGiftSend:(TUIGiftModel *)giftModel;

@end

NS_ASSUME_NONNULL_END
