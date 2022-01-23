//
//  TUIBarrageCell.h
//  lottie-ios
//
//  Created by WesleyLei on 2021/9/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class TUIBarrageModel;
@interface TUIBarrageCell : UITableViewCell

/**
* 弹幕信息展示
*
* @param barrage 弹幕信息
* @param index 弹幕位置
*/
- (void)setBarrage:(TUIBarrageModel *)barrage index:(NSInteger)index;

/**
* 获取弹幕空间高度
*
*/
- (CGFloat)getCellHeight;
@end

NS_ASSUME_NONNULL_END
