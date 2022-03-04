//
//  TUIBarrageModel.m
//  TUIBarrageService
//
//  Created by WesleyLei on 2021/9/22.
//

#import "TUIBarrageModel.h"

@implementation TUIBarrageModel

- (id)copyWithZone:(NSZone *)zone {
    TUIBarrageModel *model = [[TUIBarrageModel alloc]init];
    model.message = self.message;
    model.extInfo = self.extInfo;
    return model;
}

+ (instancetype)defaultCreate {
    TUIBarrageModel *model = [[TUIBarrageModel alloc]init];
    return model;
}

@end
