//
//  TUIGiftPlayBaseView.m
//  TUIGiftView
//
//  Created by WesleyLei on 2021/9/17.
//

#import "TUIGiftPlayBaseView.h"
#import "TUIGiftPresenter.h"

@interface TUIGiftPlayBaseView ()<TUIGiftPresenterDelegate>

@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) TUIGiftPresenter *presenter;

@end

@implementation TUIGiftPlayBaseView

- (instancetype)initWithFrame:(CGRect)frame groupId:(NSString*)groupId {
    if (self = [super initWithFrame:frame]) {
        self.groupId = groupId;
        self.userInteractionEnabled = NO;
        [self initPresenter];
    }
    return self;
}

- (void)initPresenter {
    self.presenter = [TUIGiftPresenter defaultCreate:self groupId:self.groupId];
}

- (void)playGiftModel:(TUIGiftModel *)giftModel {
    
}

- (void)playLikeModel:(TUIGiftModel *)likeModel {
    
}

#pragma mark TUIGiftPresenterDelegate

- (void)onReceiveGift:(TUIGiftModel *)model {
    [self playGiftModel:model];
}

- (void)onReceiveLike:(TUIGiftModel *)model {
    [self playLikeModel:model];
}
@end
