//
//  TUIGiftSideslipLayout.m
//  TUIGiftView
//
//  Created by WesleyLei on 2021/9/10.
//

#import "TUIGiftSideslipLayout.h"

@interface TUIGiftSideslipLayout ()

@property (strong, nonatomic) NSMutableArray<UICollectionViewLayoutAttributes *> *layoutAttributes;
@end

@implementation TUIGiftSideslipLayout

#pragma mark - Layout
/// 布局前准备
- (void)prepareLayout {
    self.layoutAttributes = [NSMutableArray array];
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    // 获取所有布局
    for (NSInteger i = 0; i < itemCount; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForItemAtIndexPath:indexPath];
        [self.layoutAttributes addObject:attributes];
    }
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    NSInteger indexRow = indexPath.item % self.rows;
    CGFloat x = (indexPath.item / self.rows) * (self.itemSize.width + self.sectionInset.right) + self.sectionInset.left;
    CGFloat y = 0;
    if (indexRow) {
        y = self.itemSize.height;
        attributes.frame = CGRectMake(x, y, self.itemSize.width, self.itemSize.height);
    }else{
        attributes.frame = CGRectMake(x, y, self.itemSize.width, self.itemSize.height);
    }
    return attributes;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.layoutAttributes;
}

- (CGSize)collectionViewContentSize {
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    NSInteger flagRow = 0;
    if (itemCount % self.rows) {
        flagRow = 1;
    }
    return CGSizeMake(((itemCount / self.rows) + flagRow) * (self.itemSize.width + self.sectionInset.right) + self.sectionInset.left, self.collectionView.bounds.size.height);
}

@end
