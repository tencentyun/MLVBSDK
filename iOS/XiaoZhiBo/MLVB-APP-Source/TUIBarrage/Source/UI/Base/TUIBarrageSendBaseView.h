//
//  TUIBarrageSendBaseView.h
//  TUIBarrageService
//
//  Created by WesleyLei on 2021/9/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/// 发送回调
typedef  void (^TUIBarrageSendBlock)(BOOL isSend);
@class TUIBarrageModel,TUIBarrageSendBaseView;
@protocol TUIBarrageSendViewDelegate<NSObject>
@optional

/**
* 弹幕信息即将发送回调
*
* @param view 发送view实例对象
* @param barrage 弹幕信息
* @param completion 发送确定回调：YES发送，NO不发送
*/
- (void)onBarrageWillSend:(TUIBarrageSendBaseView* _Nonnull)view barrage:(TUIBarrageModel *)barrage completion:(TUIBarrageSendBlock)completion;

/**
* 弹幕信息发送完成回调
*
* @param view 发送view实例对象
* @param barrage 弹幕信息
* @param success YES发送成功，NO不发送失败
* @param message 提示信息
*/
- (void)onBarrageDidSend:(TUIBarrageSendBaseView* _Nonnull)view barrage:(TUIBarrageModel *)barrage isSuccess:(BOOL)success message:(NSString *)message;

@end

@interface TUIBarrageSendBaseView : UIView

/**
* 初始化
*
* @param frame 布局信息
* @param delegate 代理
* @param groupId 群组id
*/
- (instancetype)initWithFrame:(CGRect)frame delegate:(id <TUIBarrageSendViewDelegate>)delegate groupId:(NSString*)groupId;
/**
* 发送弹幕
*
* @param barrage 弹幕信息
*/
- (void)sendMessage:(TUIBarrageModel *)barrage;

@end

NS_ASSUME_NONNULL_END
