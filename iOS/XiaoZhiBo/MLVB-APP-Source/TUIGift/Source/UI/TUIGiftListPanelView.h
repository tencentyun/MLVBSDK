//
//  TUIGiftListPanelView.h
//  TUIGiftView
//
//  Created by WesleyLei on 2021/9/14.
//  Copyright © 2021 wesleylei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUIGiftPanelBaseView.h"
NS_ASSUME_NONNULL_BEGIN

@interface TUIGiftListPanelView : TUIGiftPanelBaseView

/**
* 设置行数
*
* @param rows 行数
*/
- (void)setRows:(NSInteger)rows;

/**
* 设置size大小
*
* @param itemSize size大小
*/
- (void)setItemSize:(CGSize )itemSize;

/**
* 设置数据源
*
* @param giftDataSource 数据model列表
*/
- (void)setGiftModelSource:(NSArray<TUIGiftModel *> *)giftDataSource;

/**
* 刷新数据
*
*/
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
