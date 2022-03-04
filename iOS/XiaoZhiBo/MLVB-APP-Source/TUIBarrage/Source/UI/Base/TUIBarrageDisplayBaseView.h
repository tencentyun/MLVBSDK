//
//  TUIBarrageDisplayBaseView.h
//  TUIBarrageService
//
//  Created by WesleyLei on 2021/9/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class TUIBarrageModel;

typedef NS_ENUM (NSInteger, TUIBarrageStyle) {
    TUIBarrageStyleLandscape = 0, // 横向弹幕
    TUIBarrageStyleVertical, // 纵向弹幕
};

@interface TUIBarrageDisplayBaseView : UIView
/**
* 初始化
*
* @param frame 布局信息
* @param groupId 群组id
*/
- (instancetype)initWithFrame:(CGRect)frame groupId:(NSString*)groupId;
/**
* 展示弹幕消息
*
* @param barrage 弹幕信息
*/
- (void)receiveBarrage:(TUIBarrageModel *)barrage;
@end

NS_ASSUME_NONNULL_END
