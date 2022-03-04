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

/// 发送点赞时间戳标记
@property (nonatomic, strong) NSDate *sendLikeDate;
/// 当前未发送点赞数量累计
@property (nonatomic, assign) NSInteger currentLikeCount;

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
    // 初始化初始点赞时间，当前日期往前推一分钟
    self.sendLikeDate = [NSDate dateWithTimeIntervalSinceNow:-1*60];
    self.currentLikeCount = 0;
}

- (void)sendGift:(TUIGiftModel *)model {
    if (!model) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(onGiftWillSend:gift:completion:)]) {
        TUIGiftModel *gift = [model copy];
        __weak typeof(self) wealSelf = self;
        [self.delegate onGiftWillSend:self gift:gift completion:^(BOOL isSend) {
            __strong typeof(wealSelf) strongSelf = wealSelf;
            if (isSend) {
                [strongSelf.presenter sendGift:gift];
            }
        }];
    } else if (!self.delegate) {
        [self.presenter sendGift:[model copy]];
    }
}

- (void)sendLike {
    // 当前点赞数量累计大于20， 则发送一次点赞
    // 若点赞数量不足20条，则在5秒时间间隔内，检测有点赞记录，发送一次点赞
    NSInteger maxLikeCount = 20;
    NSTimeInterval maxDuration = 5;
    if (self.currentLikeCount >= maxLikeCount) {
        // 当前点赞数量累计大于20
        [self.presenter sendLike];
        self.currentLikeCount = 0;
        self.sendLikeDate = [NSDate date];
        return;
    }
    // 计算距离上一次点赞时间间隔
    NSTimeInterval duration = -[self.sendLikeDate timeIntervalSinceNow];
    if (duration >= maxDuration) {
        // 距离上一次点赞超过5秒
        [self.presenter sendLike];
        self.currentLikeCount = 0;
        self.sendLikeDate = [NSDate date];
    } else {
        self.currentLikeCount += 1;
        // 只播放动画，不发送IM
        [self onLikeDidSend:[TUIGiftModel defaultCreate] isSuccess:NO message:@"send like by local."];
        // 计算延迟检测时间间隔
        NSTimeInterval delayInSeconds = maxDuration - duration;
        // 开始点赞延迟检测 取消上一次延迟检测请求，避免循环异常
        [self.class cancelPreviousPerformRequestsWithTarget:self selector:@selector(sendLike) object:nil];
        [self performSelector:@selector(sendLike) withObject:nil afterDelay:delayInSeconds];
    }
}

#pragma mark TUIGiftPresenterDelegate
- (void)onGiftDidSend:(TUIGiftModel *)model isSuccess:(BOOL)success message:(NSString *)message {
    if ([self.delegate respondsToSelector:@selector(onGiftDidSend:gift:isSuccess:message:)]) {
        [self.delegate onGiftDidSend:self gift:model isSuccess:success message:message];
    }
}

- (void)onLikeDidSend:(TUIGiftModel *)model isSuccess:(BOOL)success message:(NSString *)message {
    if ([self.delegate respondsToSelector:@selector(onLikeDidSend:like:isSuccess:message:)]) {
        [self.delegate onLikeDidSend:self like:model isSuccess:success message:message];
    }
}

@end
