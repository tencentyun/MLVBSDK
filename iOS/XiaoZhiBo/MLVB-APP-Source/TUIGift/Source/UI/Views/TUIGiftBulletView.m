//
//  TUIGiftBulletView.m
//  TUIGiftView
//
//  Created by WesleyLei on 2021/9/17.
//

#import "TUIGiftBulletView.h"
#import "UIImageView+WebCache.h"
#import "UIView+TUILayout.h"
#import "TUIGiftModel.h"
#import "TUILogin.h"
#import "TUIGiftLocalized.h"
#import "TUIDefine.h"

@interface TUIGiftBulletView ()<CAAnimationDelegate>
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UIImageView *giftIconView;
@property (nonatomic, strong) UILabel *nickNameLabel;
@property (nonatomic, strong) UILabel *giveDescLabel;
@property (nonatomic, copy, nullable) TUIGiftAnimationCompletionBlock completionBlock;
@end

@implementation TUIGiftBulletView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setMm_h:50];
        [self setupUI];
    }
    return self;
}

#pragma mark - setupUI
- (void)setupUI {
    self.clipsToBounds = YES;
    [self addSubview:self.avatarView];
    [self addSubview:self.giftIconView];
    [self addSubview:self.nickNameLabel];
    [self addSubview:self.giveDescLabel];
    self.layer.cornerRadius = self.mm_h*0.5;
    self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
}

- (void)setGiftModel:(TUIGiftModel *)giftModel {
    _giftModel = giftModel;
    NSDictionary *extInfo = giftModel.extInfo;
    if (![extInfo isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSString *userID = extInfo[@"userID"]?:@"";
    NSString *nickName = extInfo[@"nickName"]?:@"";
    NSString *avatarUrl = extInfo[@"avatarUrl"]?:@"";
    if (![userID isKindOfClass:[NSString class]]) {
        userID = @"";
    }
    if (![nickName isKindOfClass:[NSString class]]) {
        nickName = @"";
    }
    if (![avatarUrl isKindOfClass:[NSString class]]) {
        avatarUrl = @"";
    }
    if ([userID isEqualToString:[TUILogin getUserID]?:@""]) {
        nickName = TUIGiftLocalize(@"TUIGiftView.me");
    } else {
        if (!nickName.length) {
            nickName = userID;
        }
    }
    CGFloat maxWidth = Screen_Width / 2;
    self.nickNameLabel.text = nickName;
    [self.nickNameLabel sizeToFit];
    [self.nickNameLabel setMm_w:MIN(self.nickNameLabel.mm_w, maxWidth)];
    self.giveDescLabel.text = giftModel.giveDesc;
    [self.giveDescLabel sizeToFit];
    [self.giveDescLabel setMm_w:MIN(self.giveDescLabel.mm_w, maxWidth)];
    CGFloat width = MAX(self.giveDescLabel.mm_w, self.nickNameLabel.mm_w);
    [self setMm_w: self.avatarView.mm_w + width + self.giftIconView.mm_w + 30];
    [self.giftIconView sd_setImageWithURL:[NSURL URLWithString:giftModel.normalImageUrl]];
    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:avatarUrl]];
}

- (void)playWithCompletion:(TUIGiftAnimationCompletionBlock)completion {
    if (!_isAnimationPlaying) {
        _isAnimationPlaying = YES;
        self.completionBlock = completion;
        [self beginAnim];
    }
}

- (void)stopAnim {
    [self.giftIconView.layer removeAllAnimations];
    [self.layer removeAllAnimations];
    self.alpha = 0;
    if (self.completionBlock) {
        self.completionBlock(NO);
    }
}

- (void)beginAnim {
    ///创建位移动画
    CAKeyframeAnimation *contentAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
    contentAnimation.values = @[@(-self.mm_w * 0.5), @(self.mm_w * 0.5 + 40), @( self.mm_w * 0.5 + 20)];
    contentAnimation.duration = 0.25;
    contentAnimation.delegate = self;
    contentAnimation.fillMode = kCAFillModeForwards;
    contentAnimation.removedOnCompletion = NO;
    ///创建透明度动画（渐变消失）
    CAKeyframeAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacity.values = @[@0.6,@1];
    opacity.calculationMode = kCAAnimationLinear;
    opacity.fillMode = kCAFillModeForwards;
    opacity.removedOnCompletion = NO;
    opacity.duration = 0.1;
    [self.layer addAnimation:contentAnimation forKey:@"tui_anim_begin.x"];
    [self.layer addAnimation:opacity forKey:@"tui_anim_begin.opacity"];
}

- (void)giftIconEnterAnim {
    CAKeyframeAnimation *contentAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position.x"];
    contentAnimation.values = @[@(-self.mm_w * 0.5), @(self.mm_w  - self.giftIconView.mm_w * 0.5 - 5)];
    contentAnimation.duration = 0.25;
    contentAnimation.delegate = self;
    contentAnimation.fillMode = kCAFillModeForwards;
    contentAnimation.removedOnCompletion = NO;
    [self.giftIconView.layer addAnimation:contentAnimation forKey:@"tui_anim_begin.x"];
}

- (void)dismissAnim {
    CAKeyframeAnimation *contentAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position.y"];
    contentAnimation.values = @[@(self.frame.origin.y), @(self.frame.origin.y - self.mm_h * 1.5)];
    contentAnimation.duration = 0.25;
    contentAnimation.delegate = self;
    contentAnimation.fillMode = kCAFillModeForwards;
    contentAnimation.removedOnCompletion = NO;
    ///创建透明度动画（渐变消失）
    CAKeyframeAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opacity.values = @[@1,@0];
    opacity.duration = 0.25;
    opacity.calculationMode = kCAAnimationLinear;
    opacity.fillMode = kCAFillModeForwards;
    opacity.removedOnCompletion = NO;
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = @[contentAnimation,opacity];
    animationGroup.fillMode = kCAFillModeForwards;
    animationGroup.removedOnCompletion = NO;
    animationGroup.delegate = self;
    [self.layer addAnimation:animationGroup forKey:@"tui_anim_begin.y"];
}

#pragma mark CAAnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if ([self.layer animationForKey:@"tui_anim_begin.x"] == anim) {
        [self.layer removeAllAnimations];
        if (flag) {
            [self giftIconEnterAnim];
        }
    } else if ([self.giftIconView.layer animationForKey:@"tui_anim_begin.x"] == anim){
        __weak typeof(self) wealSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __strong typeof(wealSelf) strongSelf = wealSelf;
            [strongSelf dismissAnim];
        });
    } else if ([self.layer animationForKey:@"tui_anim_begin.y"] == anim) {
        [self.layer removeAllAnimations];
        [self.giftIconView.layer removeAllAnimations];
        if (flag) {
            self.alpha = 0;
            if (self.completionBlock) {
                self.completionBlock(YES);
            }
        }
    }
}

#pragma mark set/get
- (UIImageView *)giftIconView {
    if (!_giftIconView) {
        _giftIconView = [[UIImageView alloc]initWithFrame:CGRectMake(-200, 5, 40, 40)];
        _giftIconView.layer.masksToBounds = YES;
        _giftIconView.layer.cornerRadius = _giftIconView.mm_h*0.5;
        [self addSubview:_giftIconView];
    }
    return _giftIconView;
}

- (UIImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 40, 40)];
        _avatarView.layer.masksToBounds = YES;
        _avatarView.layer.cornerRadius = _avatarView.mm_h*0.5;
        [self addSubview:_avatarView];
    }
    return _avatarView;
}

- (UILabel*)nickNameLabel {
    if (!_nickNameLabel) {
        _nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.avatarView.mm_w+15 , 5, 0, 20)];
        _nickNameLabel.font = [UIFont systemFontOfSize:13];
        _nickNameLabel.textAlignment = NSTextAlignmentLeft;
        _nickNameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _nickNameLabel.textColor = [UIColor whiteColor];
    }
    return _nickNameLabel;
}

- (UILabel*)giveDescLabel {
    if (!_giveDescLabel) {
        _giveDescLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.avatarView.mm_w+15 , 25, 0, 20)];
        _giveDescLabel.font = [UIFont systemFontOfSize:13];
        _giveDescLabel.textAlignment = NSTextAlignmentLeft;
        _giveDescLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _giveDescLabel.textColor = [UIColor whiteColor];
    }
    return _giveDescLabel;
}

@end
