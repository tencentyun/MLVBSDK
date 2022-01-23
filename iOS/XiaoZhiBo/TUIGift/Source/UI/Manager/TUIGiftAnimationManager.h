//
//  TUIGiftAnimationManager.h
//  TUIGiftView
//
//  Created by WesleyLei on 2021/9/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TUIGiftModel;
typedef void (^TUIDequeueBlock)(TUIGiftModel *giftModel);

@interface TUIGiftAnimationManager : NSObject

/**
* 初始化
*
* @param simulcastCount 计数count
*/
- (instancetype)initWithCount:(NSUInteger)simulcastCount;

/**
* 入队
*
* @param giftModel 礼物信息
*/
- (void)enqueue:(TUIGiftModel *)giftModel;

/**
* 出队回调
*
* @param block 回调block
*/
- (void)dequeue:(TUIDequeueBlock)block;

/**
* 完成播放
*
*/
- (void)finishPlay;

/**
* 清空资源
*
*/
- (void)clearData;

@end

NS_ASSUME_NONNULL_END
