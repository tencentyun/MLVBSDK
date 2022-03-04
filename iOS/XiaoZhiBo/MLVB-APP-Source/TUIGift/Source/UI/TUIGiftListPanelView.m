//
//  TUIGiftListPanelView.m
//  TUIGiftView
//
//  Created by WesleyLei on 2021/9/14.
//  Copyright © 2021 wesleylei. All rights reserved.
//

#import "TUIGiftListPanelView.h"
#import "TUIGiftSideslipLayout.h"
#import "TUIGiftPanelConfig.h"
#import "TUIGiftCell.h"
#import "TUIGiftModel.h"
#import "UIView+TUILayout.h"
#import "Masonry.h"
@interface TUIGiftListPanelView ()<UICollectionViewDelegate,UICollectionViewDataSource>{
    NSInteger _rows;
    CGSize _itemSize;
    NSArray<TUIGiftModel *> *_giftDataSource;
}

@property (nonatomic, strong) TUIGiftPanelConfig *config;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) TUIGiftSideslipLayout *flowLayout;
@property (nonatomic, strong) TUIGiftModel *selectedModel;

@end

@implementation TUIGiftListPanelView

- (instancetype)initWithFrame:(CGRect)frame delegate:(id <TUIGiftPanelDelegate>)delegate groupId:(NSString*)groupId {
    if (self = [super initWithFrame:frame delegate:delegate groupId:groupId]) {
        [self setRows:self.config.rows];
        [self setItemSize:self.config.itemSize];
        [self setupUI];
    }
    return self;
}

#pragma mark - setupUI
- (void)setupUI {
    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)reloadData {
    self.config.rows = _rows;
    self.config.itemSize = _itemSize;
    self.config.giftDataSource = _giftDataSource;
    self.flowLayout.itemSize = self.config.itemSize;
    self.flowLayout.rows = self.config.rows;
    [self.collectionView reloadData];
}

#pragma mark set
- (void)setRows:(NSInteger)rows {
    if (_rows != rows) {
        _rows = rows;
    }
}

- (void)setItemSize:(CGSize )itemSize {
    _itemSize = itemSize;
}

- (void)setGiftModelSource:(NSArray<TUIGiftModel *> *)giftDataSource {
    _giftDataSource = giftDataSource;
}

#pragma mark UICollectionViewDelegate/UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.config.giftDataSource.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    TUIGiftCell *giftCell = (TUIGiftCell *)cell;
    giftCell.isSelected = [self.selectedModel.giftId isEqualToString:giftCell.giftModel.giftId];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TUIGiftCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([TUIGiftCell class]) forIndexPath:indexPath];
    if (self.config.giftDataSource.count > indexPath.row) {
        TUIGiftModel *model = self.config.giftDataSource[indexPath.row];
        cell.giftModel = model;
        cell.isSelected = [self.selectedModel.giftId isEqualToString:model.giftId];
        __weak typeof(self) wealSelf = self;
        cell.sendBlock = ^(TUIGiftModel * _Nonnull giftModel) {
            __strong typeof(wealSelf) strongSelf = wealSelf;
            [strongSelf sendGift:giftModel];
        };
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    TUIGiftCell *cell = (TUIGiftCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.isSelected = YES;
    if (cell.sendBlock) {
        cell.sendBlock(cell.giftModel);
    }
    self.selectedModel = cell.giftModel;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    TUIGiftCell *cell = (TUIGiftCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.isSelected = NO;
}

#pragma mark set/get
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:self.flowLayout];
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [_collectionView registerClass:[TUIGiftCell class] forCellWithReuseIdentifier:NSStringFromClass([TUIGiftCell class])];
        _collectionView.scrollsToTop = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
    }
    return _collectionView;
}

- (TUIGiftSideslipLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[TUIGiftSideslipLayout alloc] init];
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 0);
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    return _flowLayout;
}

- (TUIGiftPanelConfig *)config {
    if (!_config) {
        _config = [TUIGiftPanelConfig defaultCreate];
    }
    return _config;
}

@end
