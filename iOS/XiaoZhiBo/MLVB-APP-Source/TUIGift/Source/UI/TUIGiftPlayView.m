//
//  TUIGiftPlayView.m
//  TUIGiftView
//
//  Created by WesleyLei on 2021/9/14.
//  Copyright © 2021 wesleylei. All rights reserved.
//

#import "TUIGiftPlayView.h"
#import "TUIGiftAnimationManager.h"
#import "LOTAnimationView.h"
#import "TUIGiftModel.h"
#import "TUIGiftBulletView.h"
#import "UIView+TUILayout.h"

@interface TUIGiftPlayView ()

@property (nonatomic, strong) TUIGiftAnimationManager *animationManager;
@property (nonatomic, strong) TUIGiftAnimationManager *lottieManager;

@end

@implementation TUIGiftPlayView

- (void)clearData {
    [self.animationManager clearData];
    [self.lottieManager clearData];
}

- (void)playGiftModel:(TUIGiftModel *)giftModel {
    if (giftModel.animationURL.length) {
        [self.lottieManager enqueue:giftModel];
    } else {
        [self.animationManager enqueue:giftModel];
    }
}

- (void)showViewAnim:(TUIGiftModel *)giftModel {
    CGFloat beginY = self.mm_h*0.5;
    for (TUIGiftBulletView *view in self.subviews) {
        if ([view isKindOfClass:[TUIGiftBulletView class]]) {
            [UIView animateWithDuration:0.1 animations:^{
                [view setMm_y:view.mm_y - (view.mm_h + 10)];
            }];
            if ((beginY - (view.mm_h + 10) * 2) > view.mm_y) {
                [view stopAnim];
            }
        }
    }
    TUIGiftBulletView *all = [[TUIGiftBulletView alloc]initWithFrame:CGRectZero];
    [all setMm_y:beginY];
    [all setMm_x:20];
    all.giftModel= giftModel;
    [self addSubview:all];
    __weak typeof(all) wealAnimation = all;
    __weak typeof(self) wealSelf = self;
    [all playWithCompletion:^(BOOL animationFinished) {
        __strong typeof(wealSelf) strongSelf = wealSelf;
        [wealAnimation removeFromSuperview];
        [strongSelf.animationManager finishPlay];
    }];
}

- (void)showLottieAnim:(TUIGiftModel *)giftModel {
    LOTAnimationView *animation = [[LOTAnimationView alloc] initWithContentsOfURL:[NSURL URLWithString:giftModel.animationURL]];
    animation.frame = self.bounds;
    animation.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:animation];
    __weak typeof(self) wealSelf = self;
    __weak typeof(animation) wealAnimation = animation;
    [animation playWithCompletion:^(BOOL animationFinished) {
        __strong typeof(wealSelf) strongSelf = wealSelf;
        __strong typeof(wealAnimation) strongAnimation = wealAnimation;
        [UIView animateWithDuration:0.2 animations:^{
            strongAnimation.alpha = 0;
        }completion:^(BOOL finished) {
            [strongAnimation removeFromSuperview];
        }];
        [strongSelf.lottieManager finishPlay];
    }];
}

#pragma mark set/get
- (TUIGiftAnimationManager *)animationManager {
    if (!_animationManager) {
        _animationManager = [[TUIGiftAnimationManager alloc]initWithCount:99];
        __weak typeof(self) wealSelf = self;
        [_animationManager dequeue:^(TUIGiftModel * _Nonnull giftModel) {
            __strong typeof(wealSelf) strongSelf = wealSelf;
            [strongSelf showViewAnim:giftModel];
        }];
    }
    return _animationManager;
}

- (TUIGiftAnimationManager *)lottieManager {
    if (!_lottieManager) {
        _lottieManager = [[TUIGiftAnimationManager alloc]initWithCount:1];
        __weak typeof(self) wealSelf = self;
        [_lottieManager dequeue:^(TUIGiftModel * _Nonnull giftModel) {
            __strong typeof(wealSelf) strongSelf = wealSelf;
            [strongSelf showLottieAnim:giftModel];
        }];
    }
    return _lottieManager;
}

@end
