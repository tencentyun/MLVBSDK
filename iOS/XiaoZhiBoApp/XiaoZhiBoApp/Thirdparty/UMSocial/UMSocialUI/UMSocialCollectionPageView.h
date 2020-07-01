//
//  UMSocialCollectionPageView.h
//  UMSocialSDK
//
//  Created by umeng on 16/9/21.
//  Copyright © 2016年 UMeng. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UMSocial_Scale_With_iPhone6 [UIScreen mainScreen].bounds.size.width/375  //屏幕适配系数比(以iPhone6的屏幕宽度为基准)
#define UMSocial_Item_Size CGSizeMake(75*UMSocial_Scale_With_iPhone6, 75*UMSocial_Scale_With_iPhone6)

@interface UMSocialCollectionPageView : UIView

@property (nonatomic, strong) NSArray *collectionCellArray;

@property (nonatomic, assign) NSInteger lineCount;//行数

@property (nonatomic, assign) NSInteger columnCount;//列数

@property (nonatomic, assign) CGFloat lineSpace;//行间距

@property (nonatomic, assign) CGFloat columnSpace;//列间距

@property (nonatomic, assign) UIEdgeInsets edgeInsets;

@property (nonatomic, assign) CGSize itemSize;

- (void)reloadPageViewWithCells:(NSArray *)cells;

@end
