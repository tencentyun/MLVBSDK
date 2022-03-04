//
//  TUIGiftExtension.h
//  TUIGiftView
//
//  Created by WesleyLei on 2021/9/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class TUIGiftPlayBaseView;

@interface TUIGiftExtension : NSObject

/**
 * 获取实例view
 *
 * @param groupId 群组id
*/
+ (TUIGiftPlayBaseView *)getPlayViewByGroupId:(NSString *)groupId;

/**
 * 设置实例view
 *
 * @param playView TUIGiftPlayBaseView对象
 * @param groupId 群组id
*/
+ (void)setPlayViewByGroupId:(TUIGiftPlayBaseView *)playView groupId:(NSString *)groupId;

/**
 * 获取礼物按钮实例view
 *
*/
+ (UIButton *)getEnterButton;

/**
 * 获取点赞按钮实例view
 *
*/
+ (UIButton *)getLikeButton;

@end

NS_ASSUME_NONNULL_END
