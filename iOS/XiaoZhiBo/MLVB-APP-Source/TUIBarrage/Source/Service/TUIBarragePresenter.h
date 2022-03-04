//
//  TUIBarragePresenter.h
//  TUIBarrageService
//
//  Created by WesleyLei on 2021/9/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class TUIBarrageModel;
/// Service 服务协议
@protocol TUIBarragePresenterDelegate<NSObject>
@optional

/**
* 发送弹幕完成回调
*
* @param barrage 弹幕信息
* @param success YES发送成功，NO不发送失败
* @param message 提示信息
*/
- (void)onBarrageDidSend:(TUIBarrageModel *)barrage isSuccess:(BOOL)success message:(NSString *)message;

/**
* 收到弹幕回调
*
* @param barrage 弹幕信息
*/
- (void)onReceiveBarrage:(TUIBarrageModel *)barrage;

@end

@interface TUIBarragePresenter : NSObject

/**
* 默认创建
*
* @param delegate 代理
*/
+ (instancetype)defaultCreate:(id <TUIBarragePresenterDelegate>)delegate;

/**
* 设置群组
*
* @param groupId 群组id
*/
- (void)setGroupId:(NSString *)groupId;

/**
* 发送弹幕
*
* @param barrage 弹幕信息
*/
- (void)sendBarrage:(TUIBarrageModel*)barrage;
@end

NS_ASSUME_NONNULL_END
