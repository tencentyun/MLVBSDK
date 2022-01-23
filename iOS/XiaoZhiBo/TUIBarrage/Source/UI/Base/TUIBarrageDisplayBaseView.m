//
//  TUIBarrageDisplayBaseView.m
//  TUIBarrageService
//
//  Created by WesleyLei on 2021/9/22.
//

#import "TUIBarrageDisplayBaseView.h"
#import "TUIBarragePresenter.h"

@interface TUIBarrageDisplayBaseView ()<TUIBarragePresenterDelegate>
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) TUIBarragePresenter *presenter;
@end

@implementation TUIBarrageDisplayBaseView

- (instancetype)initWithFrame:(CGRect)frame groupId:(NSString*)groupId {
    if (self = [super initWithFrame:frame]) {
        self.groupId = groupId;
        [self addObserver];
    }
    return self;
}

///展示弹幕消息
- (void)receiveBarrage:(TUIBarrageModel *)barrage {
}

- (void)addObserver {
    // 注册监听
    [self.presenter setGroupId:self.groupId];
}

#pragma mark - TUIBarragePresenterDelegate
- (void)onReceiveBarrage:(TUIBarrageModel *)barrage {
    [self receiveBarrage:barrage];
}

#pragma mark - set/get
- (TUIBarragePresenter *)presenter {
    if (!_presenter) {
        _presenter = [TUIBarragePresenter defaultCreate:self];
    }
    return _presenter;
}

@end
