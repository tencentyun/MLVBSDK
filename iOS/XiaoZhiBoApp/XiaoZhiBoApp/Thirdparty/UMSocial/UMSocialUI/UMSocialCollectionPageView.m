//
//  UMSocialCollectionPageView.m
//  UMSocialSDK
//
//  Created by umeng on 16/9/21.
//  Copyright © 2016年 UMeng. All rights reserved.
//

#import "UMSocialCollectionPageView.h"

@implementation UMSocialCollectionPageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.columnSpace = 8;
        self.lineSpace = 10;
        self.edgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        self.lineCount = 3;
        self.columnCount = 4;
        self.itemSize = CGSizeMake(75, 75);
    
    }
    return self;
}

- (void)setLineCount:(NSInteger)lineCount
{
    _lineCount = lineCount;
    if (_lineCount <= 0) {
        _lineCount = 1;
    }
}

- (void)setColumnCount:(NSInteger)columnCount
{
    _columnCount = columnCount;
    if (_columnCount <= 0) {
        _columnCount = 1;
    }
}

- (void)reloadPageViewWithCells:(NSArray *)cells
{
    if (cells.count == 0) {
        return;
    }
    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }
    for (NSInteger index = 0; index < cells.count; index ++) {
        UIView *cell = cells[index];;
        cell.frame = [self cellFrameWithIndex:index];
        [self addSubview:cell];
    }
}


- (CGRect)cellFrameWithIndex:(NSInteger)index
{
    CGRect rect;
    NSInteger column = index % self.columnCount;//取余数作为列
    NSInteger line = index / self.columnCount;//取商为行
    
    rect.origin.x = self.edgeInsets.left + column * (self.columnSpace + self.itemSize.width);
    rect.origin.y = self.edgeInsets.top + line * (self.lineSpace + self.itemSize.height);
    
    rect.size = self.itemSize;
    
    return rect;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
