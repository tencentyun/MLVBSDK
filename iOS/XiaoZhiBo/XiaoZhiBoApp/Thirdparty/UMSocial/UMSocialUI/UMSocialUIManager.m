//
//  UMSocialUIManager.m
//  UMSocialSDK
//
//  Created by umeng on 16/8/10.
//  Copyright © 2016年 dongjianxiong. All rights reserved.
//

#import "UMSocialUIManager.h"

@interface UMSocialUIManager ()

@property (nonatomic, strong) UMSocialShareSelectionView *shareMenuView;

//@property (nonatomic, strong) UIView *superView;

@end

@implementation UMSocialUIManager

+ (UMSocialUIManager *)defaultManager
{
    static UMSocialUIManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!instance) {
            instance = [[self alloc] init];
        }
    });
    return instance;
}

+ (void)showShareMenuViewInView:(UIView *)view sharePlatformSelectionBlock:(UMSocialSharePlatformSelectionBlock)sharePlatformSelectionBlock
{
    UMSocialUIManager *uiManager = [UMSocialUIManager defaultManager];
    [uiManager showShareMenuViewInView:view sharePlatformSelectionBlock:sharePlatformSelectionBlock];
}

+ (void)dismissShareMenuView
{
    UMSocialUIManager *uiManager = [UMSocialUIManager defaultManager];
    [uiManager hiddenShareMenuView];
}

- (void)hiddenShareMenuView
{
//    [UIView animateWithDuration:0.2 animations:^{
//        CGRect frame = self.shareMenuView.frame;
//        frame.origin.y = self.superView.frame.size.height;
//        self.shareMenuView.frame = frame;
//    } completion:^(BOOL finished) {
//        
//    }];
}


- (void)showShareMenuViewInView:(UIView *)view sharePlatformSelectionBlock:(UMSocialSharePlatformSelectionBlock)sharePlatformSelectionBlock
{
    if (!self.shareMenuView) {
        [self creatShareSelectionView];
    }
    self.shareMenuView.shareSelectionBlock = ^(UMSocialShareSelectionView *shareSelectionView, NSIndexPath *indexPath,UMSocialPlatformType platformType){
        [UMSocialUIManager dismissShareMenuView];
        if (sharePlatformSelectionBlock) {
            sharePlatformSelectionBlock(shareSelectionView, indexPath, platformType);
        }
    };//sharePlatformSelectionBlock;

    [self.shareMenuView show];
}


- (void)creatShareSelectionView
{
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//    int sectionCount = 4;
//    CGFloat itemSpace = 2;
//    layout.minimumInteritemSpacing = itemSpace;
//    layout.minimumLineSpacing = itemSpace;
//    CGFloat totalSpace = (sectionCount + 4) * itemSpace;
//    
//    CGSize itemSize = layout.itemSize;
//    CGRect frame = self.superView.frame;
//    frame.origin.x = itemSpace;
//    frame.size.width = frame.size.width - frame.origin.x*2;
//    
//    if (frame.size.width > frame.size.height) {
//        itemSize.width = (frame.size.height - totalSpace) / sectionCount;
//        itemSize.height = itemSize.width;
//    }else{
//        itemSize.width = (frame.size.width - totalSpace) / sectionCount;
//        itemSize.height = itemSize.width;
//    }
//    layout.itemSize = itemSize;
//    layout.sectionInset = UIEdgeInsetsMake(itemSpace, itemSpace, itemSpace, itemSpace);
    
    UMSocialShareSelectionView *selectionView = [[UMSocialShareSelectionView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) collectionViewLayout:layout];

//    NSInteger rowCount = ceilf(selectionView.sharePaltformNames.count/3.0);
//    if (rowCount > 3) {
//        rowCount = 3;
//    }
//    frame.size.height = rowCount * selectionView.itemSize.height + selectionView.itemSpace*(rowCount + 2);
//    selectionView.frame = frame;

    self.shareMenuView = selectionView;
}




@end
