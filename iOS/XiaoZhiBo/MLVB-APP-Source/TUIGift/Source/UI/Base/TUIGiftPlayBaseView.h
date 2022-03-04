//
//  TUIGiftPlayBaseView.h
//  TUIGiftView
//
//  Created by WesleyLei on 2021/9/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TUIGiftModel;

@interface TUIGiftPlayBaseView : UIView

/**
 * 初始化
 *
 * @param frame 布局信息
 * @param groupId 群组id
*/
- (instancetype)initWithFrame:(CGRect)frame groupId:(NSString*)groupId;

/**
 * 展示礼物
 *
 * @param giftModel 礼物信息
*/
- (void)playGiftModel:(TUIGiftModel *)giftModel;

/**
 * 展示点赞消息
 *
 * @param likeModel 点赞信息
*/
- (void)playLikeModel:(TUIGiftModel *)likeModel;

@end

NS_ASSUME_NONNULL_END
