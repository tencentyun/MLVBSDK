//
//  TUIBarrageExtension.h
//  TUIGiftView
//
//  Created by WesleyLei on 2021/9/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class TUIBarrageDisplayBaseView;
@interface TUIBarrageExtension : NSObject
/**
* 获取实例view
*
* @param groupId 群组id
*/
+ (TUIBarrageDisplayBaseView *)getDisplayViewByGroupId:(NSString *)groupId;

/**
* 设置实例view
*
* @param displayView TUIBarrageDisplayBaseView对象
* @param groupId 群组id
*/
+ (void)setDisplayViewByGroupId:(TUIBarrageDisplayBaseView *)displayView groupId:(NSString *)groupId;

/**
* 获取实例view
*
*/
+ (UIButton *)getEnterButton;

@end

NS_ASSUME_NONNULL_END
