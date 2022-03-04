//
//  TUIBarrageSendBaseView.m
//  TUIBarrageService
//
//  Created by WesleyLei on 2021/9/22.
//

#import "TUIBarrageSendBaseView.h"
#import "UIView+TUILayout.h"
#import "TUIBarragePresenter.h"

@interface TUIBarrageSendBaseView ()<TUIBarragePresenterDelegate>
@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, weak, nullable) id <TUIBarrageSendViewDelegate> delegate;
@property (nonatomic, strong) TUIBarragePresenter *presenter;
@end

@implementation TUIBarrageSendBaseView

- (instancetype)initWithFrame:(CGRect)frame delegate:(id <TUIBarrageSendViewDelegate>)delegate groupId:(NSString*)groupId {
    if (self = [super initWithFrame:frame]) {
        self.groupId = groupId;
        self.delegate = delegate;
        [self addObserver];
    }
    return self;
}

#pragma mark - set/get
-(TUIBarragePresenter *)presenter {
    if (!_presenter) {
        _presenter = [TUIBarragePresenter defaultCreate:self];
    }
    return _presenter;
}

-(void)sendMessage:(TUIBarrageModel *)barrage {
    if ([self.delegate respondsToSelector:@selector(onBarrageWillSend:barrage:completion:)]) {
        __weak typeof(self) wealSelf = self;
        [self.delegate onBarrageWillSend:self barrage:barrage completion:^(BOOL isSend) {
            if (isSend) {
                __strong typeof(wealSelf) strongSelf = wealSelf;
                [strongSelf.presenter sendBarrage:barrage];
            }
        }];
    } else {
        [self.presenter sendBarrage:barrage];
    }
}

#pragma mark - 注册监听
- (void)addObserver {
    [self.presenter setGroupId:self.groupId];
}

#pragma mark - TUIBarragePresenterDelegate
- (void)onBarrageDidSend:(TUIBarrageModel *)barrage isSuccess:(BOOL)success message:(NSString *)message {
    if ([self.delegate respondsToSelector:@selector(onBarrageDidSend:barrage:isSuccess:message:)]) {
        [self.delegate onBarrageDidSend:self barrage:barrage isSuccess:success message:message];
    }
}

@end
