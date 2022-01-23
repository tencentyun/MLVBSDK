//
//  TUIBarrageIMService.h
//  TUIBarrageIMService

//
//  Created by WesleyLei on 2021/9/13.
//  Copyright © 2021 wesleylei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/// Service 服务协议
@protocol TUIBarrageIMServiceDelegate<NSObject>
@optional

/**
* 消息发送完成回调
*
* @param param 消息体
* @param success YES发送成功，NO不发送失败
* @param message 提示信息
*/
- (void)didSend:(NSDictionary<NSString *,id> *)param isSuccess:(BOOL)success message:(NSString *)message;

/**
* 收到消息回调
*
* @param param 消息体
*/
- (void)onReceive:(NSDictionary<NSString *,id> *)param;
@end


/////////////////////////////////////////////////////////////////////////////////
//
//                           TUIBarrageIMService
//
//       TUI 接收发送消息主核心类，负责 IM 的消息收发功能
//
/////////////////////////////////////////////////////////////////////////////////

@interface TUIBarrageIMService : NSObject

/**
* 默认创建
*
* @param groupID 群组id
* @param delegate 代理
*/
+ (instancetype)defaultCreate:(NSString *)groupID delegate:(id <TUIBarrageIMServiceDelegate>)delegate;

/**
* 发送Msg
*
* @param param 弹幕信息字典
*/
- (BOOL)onSendMsg:(NSDictionary<NSString *,id> *)param;

/**
* 资源释放（持有此对象，在dealloc时候调用此方法）
*
*/
- (void)releaseResources;
@end


NS_ASSUME_NONNULL_END
