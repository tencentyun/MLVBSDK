//
//  TUIGiftIMService.h
//  TUIGiftIMService

//
//  Created by WesleyLei on 2021/9/13.
//  Copyright © 2021 wesleylei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TUIGiftModel.h"

NS_ASSUME_NONNULL_BEGIN
typedef void (^TUIGiftIMSendBlock)(NSInteger code, NSString *msg);

/// Service 服务协议
@protocol TUIGiftIMServiceDelegate<NSObject>
@optional

/**
 * 收到礼物消息回调
 *
 * @param giftModel 礼物消息
*/
- (void)onReceiveGiftMessage:(TUIGiftModel *)giftModel;

/**
 * 收到点赞消息回调
 *
 * @param likeModel 点赞消息
*/
- (void)onReceiveLikeMessage:(TUIGiftModel *)likeModel;

@end


/////////////////////////////////////////////////////////////////////////////////
//
//                           TUIGiftIMService
//
//       TUI 接收发送消息主核心类，负责 IM 的消息收发功能
//
/////////////////////////////////////////////////////////////////////////////////

@interface TUIGiftIMService : NSObject

+ (instancetype)defaultCreate:(NSString *)groupID delegate:(id <TUIGiftIMServiceDelegate>)delegate;

/**
 * 发送礼物消息
 * 
 * @param giftModel 礼物消息
 * @param callback 发送结果回调
 *        - code: 0成功，其它失败
 *        - msg: 错误信息
 */
- (void)sendGiftMessage:(TUIGiftModel *)giftModel callback:(TUIGiftIMSendBlock)callback;

/**
 * 发送点赞消息
 *
 * @param callback 发送结果回调
 *        - code: 0成功，其它失败
 *        - msg: 错误信息
 */
- (void)sendLikeMessageWithCallback:(TUIGiftIMSendBlock)callback;

/**
 * 持有此对象，在dealloc时候调用此方法
 */
- (void)releaseResources;

@end


NS_ASSUME_NONNULL_END
