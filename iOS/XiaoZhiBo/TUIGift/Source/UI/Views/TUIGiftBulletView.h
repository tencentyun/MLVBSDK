//
//  TUIGiftBulletView.h
//  TUIGiftView
//
//  Created by WesleyLei on 2021/9/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TUIGiftModel;
typedef void (^TUIGiftAnimationCompletionBlock)(BOOL animationFinished);

@interface TUIGiftBulletView : UIView

@property (nonatomic, readonly) BOOL isAnimationPlaying;
@property (nonatomic, strong) TUIGiftModel *giftModel;

/**
* 播放动画
*
* @param completion 播放完成回调block
*/
- (void)playWithCompletion:(TUIGiftAnimationCompletionBlock)completion;

/**
* 停止动画
*
*/
- (void)stopAnim;

@end

NS_ASSUME_NONNULL_END
