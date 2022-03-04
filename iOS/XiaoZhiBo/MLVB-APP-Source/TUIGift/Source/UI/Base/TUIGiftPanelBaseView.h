//
//  TUIGiftPanelBaseView.h
//  TUIGiftView
//
//  Created by WesleyLei on 2021/9/17.
//

#import <UIKit/UIKit.h>
#import "TUIGiftModel.h"
NS_ASSUME_NONNULL_BEGIN

typedef void (^TUIGiftSendBlock)(BOOL isSend);

@class TUIGiftPanelBaseView;

@protocol TUIGiftPanelDelegate<NSObject>

@optional


/**
 * 礼物即将发送回调
 *
 * @param gitView 发送view实例对象
 * @param model 礼物信息
 * @param completion 发送确定回调：YES发送，NO不发送
*/
- (void)onGiftWillSend:(TUIGiftPanelBaseView *)gitView gift:(TUIGiftModel *)model completion:(TUIGiftSendBlock)completion;

/**
 * 礼物发送完成回调
 *
 * @param gitView 发送view实例对象
 * @param model 礼物信息
 * @param success YES发送成功，NO不发送失败
 * @param message 提示信息
*/
- (void)onGiftDidSend:(TUIGiftPanelBaseView *)gitView gift:(TUIGiftModel *)model isSuccess:(BOOL)success message:(NSString *)message;

/**
 * 点赞发送完成回调
 *
 * @param gitView 发送view实例对象
 * @param model 点赞信息
 * @param success YES发送成功，NO不发送失败
 * @param message 提示信息
*/
- (void)onLikeDidSend:(TUIGiftPanelBaseView *)gitView like:(TUIGiftModel *)model isSuccess:(BOOL)success message:(NSString *)message;

@end

@interface TUIGiftPanelBaseView : UIView

/**
 * 初始化
 *
 * @param frame 布局信息
 * @param delegate 代理
 * @param groupId 群组id
*/
- (instancetype)initWithFrame:(CGRect)frame delegate:(id <TUIGiftPanelDelegate>)delegate groupId:(NSString*)groupId;


/**
 * 发送礼物
 *
 * @param model 礼物信息
*/
- (void)sendGift:(TUIGiftModel *)model;


/**
 * 发送礼物
*/
- (void)sendLike;

@end

NS_ASSUME_NONNULL_END
