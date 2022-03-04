//
//  TUIGiftListPanelPlugView.h
//  TUIGiftView
//
//  Created by WesleyLei on 2021/9/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIGiftListPanelPlugView : UIView

/**
 * 礼物发送插件初始化
 *
 * @param frame 布局信息
 * @param groupId 群组id
*/
- (instancetype)initWithFrame:(CGRect)frame groupId:(NSString*)groupId;

/**
 * 发送点赞
 */
- (void)sendLike;
@end

NS_ASSUME_NONNULL_END
