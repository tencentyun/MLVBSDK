//
//  LiveRoomMsgListTableView.m
//  TXLiteAVDemo
//
//  Created by lijie on 2017/11/22.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "LiveRoomMsgListTableView.h"
#import "UIView+Additions.h"

@implementation LiveRoomMsgListTableView
{
    NSMutableArray  *_msgArray;
    BOOL            _beginScroll;
    BOOL            _canScrollToBottom;
    BOOL            _canReload;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        [self initTableView];
        _msgArray = [NSMutableArray array];
        _beginScroll        = NO;
        _canScrollToBottom  = YES;
        _canReload = YES;
    }
    return self;
}

- (void)initTableView {
    self.delegate = self;
    self.dataSource = self;
    self.backgroundView  = nil;
    self.backgroundColor = [UIColor blackColor];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.showsVerticalScrollIndicator = NO;
}

- (void)appendMsg:(LiveRoomMsgModel *)msgModel {
    if (!msgModel) {
        return;
    }
    
    if (_msgArray.count > 1000) {
        [_msgArray removeObjectsInRange:NSMakeRange(0, 100)];
    }
    
    msgModel.attributedMsgText = [LiveRoomMsgListTableViewCell getAttributedStringFromModel:msgModel];
    msgModel.msgHeight = [self calCellHeight:msgModel.attributedMsgText];
    [_msgArray addObject:msgModel];
    
    if (_canReload) {
        _canReload = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            _canReload = YES;
            [self reloadData];
            
            if (!_beginScroll) {
                if ([self calculateTotalCellHeight] >= self.height) {
                    [self scrollToBottom];
                    _beginScroll = YES;
                }
            } else {
                [self scrollToBottom];
            }
        });
    }
}


- (void)scrollToBottom {
    if (_canScrollToBottom) {
        NSUInteger n = MIN(_msgArray.count, [self numberOfRowsInSection:0]);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0), dispatch_get_main_queue(), ^{
            [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:n - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        });
    }
}

- (CGFloat)calCellHeight:(NSAttributedString *)attribText {
    CGRect rect = [attribText boundingRectWithSize:CGSizeMake(250, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGFloat cellHeight = rect.size.height + 5;
    return cellHeight;
}

- (CGFloat)calculateTotalCellHeight {
    CGFloat totalCellHeight = 0;
    for (LiveRoomMsgModel *model in _msgArray) {
        totalCellHeight += model.msgHeight;
    }
    return totalCellHeight;
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < _msgArray.count) {
        LiveRoomMsgModel *msgModel = _msgArray[indexPath.row];
        return msgModel.msgHeight;
    }
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _msgArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID =@"MsgListCell";
    LiveRoomMsgListTableViewCell *cell = (LiveRoomMsgListTableViewCell *)[self dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[LiveRoomMsgListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle  = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.row < _msgArray.count) {
        LiveRoomMsgModel *msgModel = _msgArray[indexPath.row];
        [cell refreshWithModel:msgModel];
    }
    
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _canScrollToBottom = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat tableViewOffset = self.contentOffset.y + self.frame.size.height;
    if (tableViewOffset + 50 >= [self calculateTotalCellHeight]) {
        _canScrollToBottom = YES;
    }
}

@end
