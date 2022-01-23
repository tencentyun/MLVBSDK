//
//  TUIGiftPanelConfig.h
//  TUIGiftView_Example
//
//  Created by WesleyLei on 2021/9/13.
//  Copyright © 2021 wesleylei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class TUIGiftModel;

@interface TUIGiftPanelConfig : NSObject

///设置行数，最多4行，默认1，最多4行
@property (nonatomic, assign) NSInteger rows;
///设置礼物控件大小，默认72*96，最大不超过屏幕宽度的三分之一
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, strong) NSArray<TUIGiftModel *> * giftDataSource;

/**
* 默认创建
*
*/
+ (instancetype)defaultCreate;

@end

NS_ASSUME_NONNULL_END
