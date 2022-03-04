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
#import "TUIGiftLocalized.h"
#import "TUIDefine.h"
// 点赞动画播放限制，最多播放10组
static NSInteger likeMaxAnimationCount = 10;
@interface TUIGiftPlayView ()

@property (nonatomic, strong) TUIGiftAnimationManager *animationManager;
@property (nonatomic, strong) TUIGiftAnimationManager *lottieManager;
/// 点赞动画颜色
@property (nonatomic, strong) NSArray *likeColors;
/// 动画播放限制
@property (nonatomic, assign) NSInteger currentLikeAnimationCount;
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

- (void)playLikeModel:(TUIGiftModel *)likeModel {
    if (_currentLikeAnimationCount >= likeMaxAnimationCount) {
        return;
    }
    CGRect startFrame = CGRectMake((Screen_Width*5)/6, Screen_Height-Bottom_SafeHeight-10-44, 44, 44);
    UIImageView *heartImageView = [[UIImageView alloc] initWithFrame:startFrame];
    UIImage *heartImage = [UIImage imageNamed:@"gift_like" inBundle:TUIGiftBundle() compatibleWithTraitCollection:nil];
    heartImageView.image = [heartImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    heartImageView.tintColor = self.likeColors[arc4random()%self.likeColors.count];
    [self addSubview:heartImageView];
    heartImageView.alpha = 0;
    [heartImageView.layer addAnimation:[self likeAnimationWithFrame:startFrame] forKey:nil];
    _currentLikeAnimationCount += 1;
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [heartImageView removeFromSuperview];
        if (weakSelf) {
            weakSelf.currentLikeAnimationCount -= 1;
        }
    });
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


#pragma mark - Private: 点赞动画
- (CAAnimation *)likeAnimationWithFrame:(CGRect)frame {
    // 透明度
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    opacityAnimation.toValue = [NSNumber numberWithFloat:0];
    opacityAnimation.removedOnCompletion = NO;
    opacityAnimation.beginTime = 0.0;
    opacityAnimation.duration = 3.0;
    // 缩放
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    scaleAnimation.toValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation.removedOnCompletion = NO;
    scaleAnimation.fillMode = kCAFillModeForwards;
    scaleAnimation.duration = 0.5;
    // 位置
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.beginTime = 0.5;
    positionAnimation.duration = 2.5;
    positionAnimation.fillMode = kCAFillModeForwards;
    positionAnimation.calculationMode = kCAAnimationCubicPaced;
    positionAnimation.path = [self likeAnimationPostionPathWithFrame:frame].CGPath;
    // 动画组
    CAAnimationGroup *animationGroup = [[CAAnimationGroup alloc] init];
    animationGroup.animations = @[opacityAnimation, scaleAnimation, positionAnimation];
    animationGroup.duration = 3.0;
    return animationGroup;
}

- (UIBezierPath *)likeAnimationPostionPathWithFrame:(CGRect)frame {
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    CGPoint point0 = CGPointMake(frame.origin.x + frame.size.width/2, frame.origin.y + frame.size.height/2);
    CGPoint point1 = CGPointMake(point0.x - arc4random()%30 + 30.0, frame.origin.y - arc4random()%60);
    CGPoint point2 = CGPointMake(point0.x - arc4random()%15 + 15, frame.origin.y - arc4random()%60 - 30);
    CGFloat pointOffset3 = CGRectGetWidth([UIScreen mainScreen].bounds)*0.1;
    CGFloat pointOffset4 = CGRectGetWidth([UIScreen mainScreen].bounds)*0.2;
    CGPoint point4 = CGPointMake(point0.x - arc4random()%(uint32_t)pointOffset4 + pointOffset4, arc4random()%30 + 240);
    CGPoint point3 = CGPointMake(point0.x - arc4random()%(uint32_t)pointOffset3 + pointOffset3, (point4.y + point2.y)/2 + arc4random()%30 - 30);
    [path moveToPoint:point0];
    [path addQuadCurveToPoint:point2 controlPoint:point1];
    [path addQuadCurveToPoint:point4 controlPoint:point3];
    return path;
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

- (NSArray *)likeColors {
    if (!_likeColors) {
        _likeColors = @[
            [UIColor redColor],
            [UIColor purpleColor],
            [UIColor orangeColor],
            [UIColor yellowColor],
            [UIColor greenColor],
            [UIColor blueColor],
            [UIColor grayColor],
            [UIColor cyanColor],
            [UIColor brownColor]
        ];
    }
    return _likeColors;
}
@end
