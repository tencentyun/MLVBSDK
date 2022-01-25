//
//  TUIBarrageSendPlugView.h
//  TUIBarrageView
//
//  Created by WesleyLei on 2021/9/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIBarrageSendPlugView : UIView

/**
* 弹幕发送插件初始化
*
* @param frame 布局信息
* @param groupId 群组id
*/
- (instancetype)initWithFrame:(CGRect)frame groupId:(NSString*)groupId;
@end

NS_ASSUME_NONNULL_END
