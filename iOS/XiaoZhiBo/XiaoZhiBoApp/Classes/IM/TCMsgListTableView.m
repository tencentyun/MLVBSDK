//
//  TCMessageTableView.m
//  TCLVBIMDemo
//
//  Created by zhangxiang on 16/7/29.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "TCMsgListTableView.h"
#import "UIView+Additions.h"
#import <UIImageView+WebCache.h>

@implementation TCMsgListTableView
{
    NSMutableArray  *_msgArray;
    BOOL            _beginScroll;
    BOOL            _canScrollToBottom;
    BOOL            _canReload;
}

-(id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self initTableView];
        _msgArray = [NSMutableArray array];
        _beginScroll        = NO;
        _canScrollToBottom  = YES;
        _canReload = YES;
    }
    return self;
}
-(void)initTableView{
    self.delegate = self;
    self.dataSource = self;
    self.backgroundView  = nil;
    self.backgroundColor = [UIColor clearColor];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.showsVerticalScrollIndicator = NO;
    self.hidden = YES;
}

-(void)bulletNewMsg:(TCMsgModel *)msgModel{
    if (msgModel) {
        if (_msgArray.count > 1000)
        {
            [_msgArray removeObjectsInRange:NSMakeRange(0, 100)];
        }
        
        msgModel.msgAttribText = [TCMsgListCell getAttributedStringFromModel:msgModel];
        msgModel.msgHeight = [self calCellHeight:msgModel.msgAttribText];
        [_msgArray addObject:msgModel];
         self.hidden = NO;
        
        if (_canReload) {
            _canReload = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                _canReload = YES;
                [self reloadData];
                
                if (!_beginScroll)
                {
                    if ([self calculateTotalCellHeight] >= self.height) {
                        [self scrollToBottom];
                        _beginScroll = YES;
                    }
                }else{
                    [self scrollToBottom];
                }

            });
        }
    }
}

-(void)scrollToBottom{
    if (_canScrollToBottom) {
        NSUInteger n = MIN(_msgArray.count, [self numberOfRowsInSection:0]);
        [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:n - 1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:NO];
    }
}

-(CGFloat)calculateCellHeight:(NSIndexPath *)indexPath{
    TCMsgModel *msgModel = _msgArray[indexPath.row];
    NSAttributedString *msg = [TCMsgListCell getAttributedStringFromModel:msgModel];
    CGRect rect = [msg boundingRectWithSize:CGSizeMake(self.width - 20, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGFloat cellHeight = rect.size.height + 5;
    return cellHeight;
}

-(CGFloat)calCellHeight:(NSAttributedString *)attribText{
    CGRect rect = [attribText boundingRectWithSize:CGSizeMake(self.width - 20, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGFloat cellHeight = rect.size.height + 5;
    return cellHeight;
}

-(CGFloat)calculateTotalCellHeight{
    CGFloat totalCellHeight = 0;
    for (TCMsgModel *model in _msgArray) {
        NSInteger index = [_msgArray indexOfObject:model];
        totalCellHeight += model.msgHeight;
    }
    return totalCellHeight;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //return [self calculateCellHeight:indexPath];
    
    if (_msgArray.count > indexPath.row)
    {
        TCMsgModel *msgModel = _msgArray[indexPath.row];
        return msgModel.msgHeight;
    }
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //to
    
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _msgArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID =@"MsgListCell";
    TCMsgListCell *cell = (TCMsgListCell *)[self dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[TCMsgListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle  = UITableViewCellSelectionStyleNone;
    }
    if (_msgArray.count > indexPath.row) {
        TCMsgModel *msgModel = _msgArray[indexPath.row];
        [cell refreshWithModel:msgModel];
    }
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
     _canScrollToBottom = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat tableViewOffset = self.contentOffset.y + self.frame.size.height;
    if (tableViewOffset + 10 >= [self calculateTotalCellHeight]) {
        _canScrollToBottom = YES;
    }
}

@end


#pragma mark 观众列表
#import "TCUserInfoModel.h"
@implementation TCAudienceListTableView
{
    TCLiveInfo     *_liveInfo;
    NSMutableArray *_dataArray;
}

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style liveInfo:(TCLiveInfo *)liveInfo {
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.dataSource = self;
        self.delegate   = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.showsVerticalScrollIndicator = NO;
        self.backgroundColor = [UIColor clearColor];
        
        _liveInfo = liveInfo;
        [self getGroupMembers];
    }
    return self;
}

-(void)getGroupMembers{
    NSString* realGroupId = _liveInfo.groupid;
    //录播文件由于group已经解散，故使用fileid替代groupid
    if (TCLiveListItemType_Record == _liveInfo.type)
        realGroupId = _liveInfo.fileid;
    
    _dataArray = [[NSMutableArray alloc] init];

    //fetchGroupMemberList
}

-(BOOL)isAlreadyInAudienceList:(TCMsgModel *)model
{
    if (model.userId == nil) {
        return NO;
    }
    
    for (TCUserInfoData *data in _dataArray) {
        if ([data.identifier isEqualToString:model.userId]) {
            return YES;
        }
    }
    
    return NO;
}

-(void)refreshAudienceList:(TCMsgModel *)model{
    if (model.userId == nil) {
        return;
    }
    
    for (TCUserInfoData *data in _dataArray) {
        if ([data.identifier isEqualToString:model.userId]) {
            [_dataArray removeObject:data];
            break;
        }
    }
    if (model.msgType == TCMsgModelType_MemberEnterRoom) {
        TCUserInfoData *infoData = [[TCUserInfoData alloc] init];
        infoData.identifier = model.userId;
        infoData.faceURL = model.userHeadImageUrl;
        [_dataArray insertObject:infoData atIndex:0];
    }
    [self reloadData];
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return IMAGE_SIZE + IMAGE_SPACE;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID =@"AudienceListCell";
    TCAudienceListCell  *cell = (TCAudienceListCell *)[self dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[TCAudienceListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle  = UITableViewCellSelectionStyleNone;
    }
    if (_dataArray.count > indexPath.row) {
        TCUserInfoData *msgModel = (TCUserInfoData *)_dataArray[indexPath.row];
        [cell refreshWithModel:msgModel];
    }
    return cell;
}

@end
