//
//  TUIGiftModel.m
//  Pods
//
//  Created by WesleyLei on 2021/9/15.
//

#import "TUIGiftModel.h"

@implementation TUIGiftModel

- (id)copyWithZone:(NSZone *)zone {
    TUIGiftModel *model = [[TUIGiftModel alloc]init];
    model.giftId = self.giftId;
    model.normalImageUrl = self.normalImageUrl;
    model.selectedImageUrl = self.selectedImageUrl;
    model.animationURL = self.animationURL;
    model.giveDesc = self.giveDesc;
    model.extInfo = self.extInfo;
    model.title = self.title;
    return model;
}

+ (instancetype)defaultCreate {
    TUIGiftModel *model = [[TUIGiftModel alloc]init];
    return model;
}

@end
