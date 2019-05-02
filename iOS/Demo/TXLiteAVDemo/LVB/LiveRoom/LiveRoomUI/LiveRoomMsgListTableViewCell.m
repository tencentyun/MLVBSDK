//
//  LiveRoomMsgListTableViewCell.m
//  TXLiteAVDemo
//
//  Created by lijie on 2017/11/22.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "LiveRoomMsgListTableViewCell.h"
#import "UIView+Additions.h"
#import "ColorMacro.h"

@implementation LiveRoomMsgModel

@end


@implementation LiveRoomMsgListTableViewCell
{
    UIView             *_msgView;
    UILabel            *_msgLabel;
    
    LiveRoomMsgModeType     _msgModeType;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _msgView = [[UIView alloc] initWithFrame:CGRectZero];
        _msgView.layer.cornerRadius = 10;
        _msgView.layer.masksToBounds = YES;
        
        _msgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _msgLabel.numberOfLines = 0;
        _msgLabel.font = [UIFont systemFontOfSize:14];
        
        [_msgView addSubview:_msgLabel];
        
        [self.contentView addSubview:_msgView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_msgModeType == LiveRoomMsgModeTypeOneself) {
        _msgLabel.frame = CGRectMake(6, 0, _msgLabel.width, _msgLabel.height);
        _msgView.frame  = CGRectMake(self.width - _msgLabel.width - 12, 0, _msgLabel.width + 12, _msgLabel.height);
        _msgLabel.textAlignment = NSTextAlignmentRight;
    } else {
        _msgLabel.frame = CGRectMake(6, 0, _msgLabel.width, _msgLabel.height);
        _msgView.frame  = CGRectMake(0, 0, _msgLabel.width + 12, _msgLabel.height);
        _msgLabel.textAlignment = NSTextAlignmentLeft;
    }
}

- (void)refreshWithModel:(LiveRoomMsgModel *)msgModel {
    _msgLabel.attributedText = msgModel.attributedMsgText;
    _msgLabel.width = 250;
    [_msgLabel sizeToFit];
    
    _msgModeType = msgModel.type;
}

+ (NSAttributedString *)getAttributedStringFromModel:(LiveRoomMsgModel *)msgModel {
    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] init];
    
    // 系统消息
    if (msgModel.type == LiveRoomMsgModeTypeSystem) {
        NSMutableAttributedString *msg = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"系统消息: %@\r\n", msgModel.userMsg]];
        [attributed appendAttributedString:msg];
        
        [attributed addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, attributed.length)];
        [attributed addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0x666666) range:NSMakeRange(0, attributed.length)];
        
        return attributed;
    }
    
    // 判断自己还是别人
    NSMutableAttributedString *userName = nil;
    UIColor *color = nil;
    if (msgModel.type == LiveRoomMsgModeTypeOneself) {
        userName = [[NSMutableAttributedString alloc] initWithString:@"我 "];
        color = UIColorFromRGB(0x999999);
    } else {
        userName = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ ", msgModel.userName]];
        color = UIColorFromRGB(0xffffff);
    }
    
    // 昵称
    [attributed appendAttributedString:userName];
    
    // 时间
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:msgModel.time];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"hh:mm:ss";
    NSString *strTime = [format stringFromDate:date];
    NSMutableAttributedString *time = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\r\n", strTime]];
    [attributed appendAttributedString:time];
    
    // 文本消息
    NSMutableAttributedString *userMsg = [[NSMutableAttributedString alloc] initWithString:msgModel.userMsg];
    [attributed appendAttributedString:userMsg];
    
    // 字体
    [attributed addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, userName.length)];
    [attributed addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:NSMakeRange(userName.length, time.length)];
    [attributed addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(userName.length + time.length, userMsg.length)];
    
    // 颜色
    [attributed addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, userName.length)];
    [attributed addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(userName.length, time.length)];
    [attributed addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(userName.length + time.length, userMsg.length)];
    
    return attributed;
}

@end
