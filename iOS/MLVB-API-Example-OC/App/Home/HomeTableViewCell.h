//
//  HomeTableViewCell.h
//  TRTCSimpleDemo-OC
//
//  Created by adams on 2021/4/14.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
static NSString *gHomeTableViewCellReuseIdentify = @"HomeTableViewCell";
@interface HomeTableViewCell : UITableViewCell
- (void)setHomeDictionary:(NSDictionary *)homeDic;
@end

NS_ASSUME_NONNULL_END
