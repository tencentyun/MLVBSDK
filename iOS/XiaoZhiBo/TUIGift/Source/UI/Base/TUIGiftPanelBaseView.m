//
//  TUIGiftPanelBaseView.m
//  TUIGiftView
//
//  Created by WesleyLei on 2021/9/17.
//

#import "TUIGiftPanelBaseView.h"
#import "TUIGiftPresenter.h"

@interface TUIGiftPanelBaseView ()<TUIGiftPresenterDelegate>

@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, weak, nullable) id <TUIGiftPanelDelegate> delegate;
@property (nonatomic, strong) TUIGiftPresenter *presenter;

@end

@implementation TUIGiftPanelBaseView

- (instancetype)initWithFrame:(CGRect)frame delegate:(id <TUIGiftPanelDelegate>)delegate groupId:(NSString*)groupId {
    if (self = [super initWithFrame:frame]) {
        self.groupId = groupId;
        self.delegate = delegate;
        [self initPresenter];
    }
    return self;
}

- (void)initPresenter {
    self.presenter = [TUIGiftPresenter defaultCreate:self groupId:self.groupId];
}

- (void)onGiftSend:(TUIGiftModel *)model {
    if (!model) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(onGiftWillSend:gift:completion:)]) {
        TUIGiftModel *gift = [model copy];
        __weak typeof(self) wealSelf = self;
        [self.delegate onGiftWillSend:self gift:gift completion:^(BOOL isSend) {
            __strong typeof(wealSelf) strongSelf = wealSelf;
            if (isSend) {
                [strongSelf.presenter onGiftSend:gift];
            }
        }];
    } else if (!self.delegate) {
        [self.presenter onGiftSend:[model copy]];
    }
}

#pragma mark TUIGiftPresenterDelegate
- (void)onGiftDidSend:(TUIGiftModel *)model isSuccess:(BOOL)success message:(NSString *)message {
    if ([self.delegate respondsToSelector:@selector(onGiftDidSend:gift:isSuccess:message:)]) {
        [self.delegate onGiftDidSend:self gift:model isSuccess:success message:message];
    }
}

@end
