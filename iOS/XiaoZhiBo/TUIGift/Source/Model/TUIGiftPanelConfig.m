//
//  TUIGiftPanelConfig.m
//  TUIGiftView_Example
//
//  Created by WesleyLei on 2021/9/13.
//  Copyright © 2021 wesleylei. All rights reserved.
//

#import "TUIGiftPanelConfig.h"

@interface TUIGiftPanelConfig ()
@end

@implementation TUIGiftPanelConfig

- (id)copyWithZone:(NSZone *)zone {
    TUIGiftPanelConfig *config = [[TUIGiftPanelConfig alloc] init];
    config.rows = self.rows;
    config.itemSize = self.itemSize;
    config.giftDataSource = self.giftDataSource;
    return config;
}

+ (instancetype)defaultCreate {
    TUIGiftPanelConfig *config = [[TUIGiftPanelConfig alloc] init];
    config.rows = 1;
    config.itemSize = CGSizeMake(72, 96);
    config.giftDataSource = @[];
    return config;
}

@end
