//
//  MCTip.m
//  PituMotionDemo
//
//  Created by ricocheng on 6/24/16.
//  Copyright © 2016 Pitu. All rights reserved.
//

#import "MCTip.h"
#import <UIKit/UIKit.h>
#import "UIColor+MCColor.h"
#import "UIImage+MCImage.h"

@interface NoFaceView : UIView

@property (nonatomic, retain) UIImageView *faceImageView;
@property (nonatomic, retain) UILabel *faceTip;
@property (nonatomic, retain) NSString *text;

@end

@implementation NoFaceView

+ (UIImage *)faceImage {
    return [UIImage MCImageNamed:@"camera_cry"];
}
+ (UIFont *)faceFont {
    return [UIFont systemFontOfSize:16];
}
- (void)dealloc {
    self.faceImageView = nil;
    self.faceTip = nil;
    self.text = nil;
}
- (id)init {

    UIImage *image = [NoFaceView faceImage];
    CGSize size = [NSLocalizedString(@"视频太短了，都来不及看清你的脸", nil) sizeWithAttributes:@{NSFontAttributeName:[NoFaceView faceFont]}];
    self = [super initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height+13+size.height)];
    if (self) {
        
        [self addSubview:self.faceImageView];
        [self addSubview:self.faceTip];
    }
    
    return self;
}
- (UIImageView *)faceImageView {

    if (!_faceImageView) {
        UIImage *image = [NoFaceView faceImage];
        _faceImageView = [[UIImageView alloc] initWithImage:image];
        _faceImageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    }
    
    return _faceImageView;
}
- (UILabel *)faceTip {
    
    if (!_faceTip) {
        _faceTip = [[UILabel alloc] init];
        _faceTip.backgroundColor = [UIColor clearColor];
        _faceTip.textAlignment = NSTextAlignmentCenter;
        _faceTip.textColor = [UIColor whiteColor];
        _faceTip.font = [NoFaceView faceFont];
    }
    
    return _faceTip;
}
- (void)setText:(NSString *)text {

    if (_text != text && text) {
        _text = text;
        _faceTip.text = _text;
        
        CGSize size = [_faceTip.text sizeWithAttributes:@{NSFontAttributeName:_faceTip.font}];
        _faceTip.frame = CGRectMake(0, CGRectGetHeight(self.frame)-size.height, size.width, size.height);
        _faceTip.center = CGPointMake(CGRectGetWidth(self.frame)/2, _faceTip.center.y);
    }
}
@end



@interface MCTipsView : UIView

@property (nonatomic, strong) UIView *tipsWrapper;
@property (nonatomic, strong) UIImageView *bgImg;
@property (nonatomic, strong) UIImageView *bgArrow;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UIImageView *tipsIcon;

@end

@implementation MCTipsView

- (id)init {
    UIImage *bgImg = [[UIImage MCImageNamed:@"camera_guide_bg"] resizableImageWithCapInsets:UIEdgeInsetsMake(5.f, 5.f, 5.f, 5.f)];
    UIImage *arrowImg = [UIImage MCImageNamed:@"camera_guide_arrow"];
    CGFloat labelMargin = 8.f;
    CGSize labelSize = CGSizeMake(160.f, 20.f);
    CGSize wrapperSize = CGSizeMake(labelSize.width + labelMargin * 2, labelSize.height + labelMargin * 2 + arrowImg.size.height);
    CGSize iconSize = CGSizeMake(wrapperSize.width, wrapperSize.width);
    self = [super initWithFrame:CGRectMake(0, 0, wrapperSize.width, iconSize.height + wrapperSize.height)];
    if (self) {
        self.tipsIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, iconSize.width, iconSize.height)];
        self.tipsIcon.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.tipsIcon];
    
        self.tipsWrapper = [[UIView alloc] initWithFrame:CGRectMake(0, iconSize.height, wrapperSize.width, wrapperSize.height)];
        [self addSubview:self.tipsWrapper];
    
        self.bgImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, wrapperSize.width, wrapperSize.height - arrowImg.size.height)];
        self.bgImg.image = bgImg;
        self.bgImg.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.bgImg.hidden = YES;
        [self.tipsWrapper addSubview:self.bgImg];
        
        self.bgArrow = [[UIImageView alloc] initWithImage:arrowImg];
        self.bgArrow.center = CGPointMake(wrapperSize.width * 0.5f, wrapperSize.height - arrowImg.size.height * 0.5f - 2.f);
        self.bgArrow.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        self.bgArrow.hidden = YES;
        [self.tipsWrapper addSubview:self.bgArrow];
        
        self.tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelMargin, labelMargin, labelSize.width, labelSize.height)];
        self.tipsLabel.backgroundColor = [UIColor clearColor];
        self.tipsLabel.textAlignment = NSTextAlignmentCenter;
        self.tipsLabel.textColor = [UIColor whiteColor];
        self.tipsLabel.font = [UIFont systemFontOfSize:16.f];
        self.tipsLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.tipsWrapper addSubview:self.tipsLabel];
    }
    
    return self;
}

- (void)setText:(NSString *)content withType:(MCTipsType)type showBG:(BOOL)showBG {
    [self.tipsIcon stopAnimating];
    self.tipsIcon.animationImages = nil;
    self.tipsIcon.image = nil;
    self.tipsIcon.hidden = YES;
    switch (type) {
        case MCTipsNoFace:{
            self.tipsIcon.image = [UIImage MCImageNamed:@"camera_cry"];
            self.tipsIcon.frame = CGRectMake(0, 0, self.tipsIcon.image.size.width, self.tipsIcon.image.size.height);
            self.tipsIcon.hidden = NO;
            break;
        }
        case MCTipsSwipUpDown:{
            UIImage *iconImg1 = [UIImage MCImageNamed:@"camera_guide_swipupdown1"];
            UIImage *iconImg2 = [UIImage MCImageNamed:@"camera_guide_swipupdown2"];
            UIImage *iconImg3 = [UIImage MCImageNamed:@"camera_guide_swipupdown3"];
            NSArray *iconImgs = [NSArray arrayWithObjects:iconImg1, iconImg2, iconImg3, iconImg2, iconImg1, nil];
            self.tipsIcon.animationImages = iconImgs;
            self.tipsIcon.animationDuration = 0.5f;
            [self.tipsIcon startAnimating];
            self.tipsIcon.frame = CGRectMake(0, 0, iconImg1.size.width, iconImg1.size.height);
            self.tipsIcon.hidden = NO;
            break;
        }
        default:
            break;
    }

    if (showBG) {
        self.bgImg.hidden = NO;
        self.bgArrow.hidden = NO;
        self.tipsLabel.textColor = [UIColor blackColor];
        self.tipsLabel.font = [UIFont systemFontOfSize:14.f];
    } else {
        self.bgImg.hidden = YES;
        self.bgArrow.hidden = YES;
        self.tipsLabel.textColor = [UIColor whiteColor];
        self.tipsLabel.font = [UIFont systemFontOfSize:16.f];
    }
    
    UIImage *arrowImg = [UIImage MCImageNamed:@"camera_guide_arrow"];
    CGSize labelSize = [content sizeWithAttributes:@{NSFontAttributeName:self.tipsLabel.font}];
    self.tipsWrapper.frame = CGRectMake(0.f, 0.f, labelSize.width + 16.f, labelSize.height + 16.f + arrowImg.size.height);
    self.tipsLabel.text = content;
    
    if (self.tipsIcon.hidden) {
        self.frame = self.tipsWrapper.frame;
    } else {
        CGFloat frameWidth = fmax(self.tipsIcon.bounds.size.width, self.tipsWrapper.bounds.size.width);
        CGFloat frameHeight = self.tipsIcon.bounds.size.height + self.tipsIcon.bounds.size.height;
        self.frame = CGRectMake(0.f, 0.f, frameWidth, frameHeight);
        self.tipsIcon.center = CGPointMake(frameWidth * 0.5f, self.tipsIcon.bounds.size.height * 0.5f);
        self.tipsWrapper.center = CGPointMake(frameWidth * 0.5f, self.tipsIcon.bounds.size.height + self.tipsWrapper.bounds.size.height * 0.5f);
    }
}

@end



static MCTip *_instance = nil;

@interface MCTip ()

@property (nonatomic, retain) UILabel *loadingLabel;
@property (nonatomic, retain) UIView *loadingView;
@property (nonatomic, retain) UIImageView *loadingImageView;
@property (nonatomic, retain) NoFaceView *noFaceView;
@property (nonatomic, retain) MCTipsView *tipsView;

@end

@implementation MCTip

+ (MCTip *)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[MCTip alloc] init];
    });
    
    return _instance;
}
+ (void)showText:(NSString *)text withFaceIcon:(BOOL)withFaceIcon inView:(UIView *)parentView {
    if ([[NSThread currentThread] isMainThread]) {
        [[MCTip shareInstance] showText:text withFaceIcon:withFaceIcon inView:parentView];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MCTip shareInstance] showText:text withFaceIcon:withFaceIcon inView:parentView];
        });
    }
}
+ (void)hideText {
    if ([[NSThread currentThread] isMainThread]) {
        [[MCTip shareInstance] hideText];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MCTip shareInstance] hideText];
        });
    }
}
+ (void)showText:(NSString *)text inView:(UIView *)parentView afterDelay:(NSTimeInterval)delay {
    [self showText:text inView:parentView atPoint:CGPointZero withType:MCTipsContent showBG:NO afterDelay:delay];
}
+ (void)showText:(NSString *)text
          inView:(UIView *)parentView
         atPoint:(CGPoint)point
        withType:(MCTipsType)type
          showBG:(BOOL)showBG
      afterDelay:(NSTimeInterval)delay {
    if ([[NSThread currentThread] isMainThread]) {
        [[MCTip shareInstance] showText:text inView:parentView atPoint:point withType:type showBG:showBG afterDelay:delay];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MCTip shareInstance] showText:text inView:parentView atPoint:point withType:type showBG:showBG afterDelay:delay];
        });
    }
}
+ (void)showLoadingText:(NSString *)text inView:(UIView *)parentView {
    [[MCTip shareInstance] showLoadingText:text inView:parentView];
}
+ (void)stopLoadingText {
    [[MCTip shareInstance] stopLoadingText];
}
+ (CGFloat)xOffset {
    return 5;
}
+ (CGFloat)height {
    return 26;
}
- (void)dealloc {
    self.tipsView = nil;
    self.loadingLabel = nil;
    self.loadingView = nil;
    self.loadingImageView = nil;
    self.noFaceView = nil;
}

- (void)showText:(NSString *)text withFaceIcon:(BOOL)withFaceIcon inView:(UIView *)parentView {
    if (_tipsView && _tipsView.tag > 0) {
        return;
    }
    
    if (withFaceIcon) {
        if (_tipsView) {
            [_tipsView removeFromSuperview];
            self.tipsView = nil;
        }
        
        self.noFaceView.text = text;
        self.noFaceView.center = CGPointMake(CGRectGetWidth(parentView.frame)/2, CGRectGetHeight(parentView.frame)/2);
        [parentView addSubview:self.noFaceView];
        self.noFaceView.alpha = 1.f;
    } else {
        if (_noFaceView) {
            [_noFaceView removeFromSuperview];
            self.noFaceView = nil;
        }
        
        [self.tipsView setText:text withType:MCTipsContent showBG:NO];
        self.tipsView.center = CGPointMake(parentView.bounds.size.width * 0.5f, parentView.bounds.size.height * 0.5f);
        [parentView addSubview:self.tipsView];
        self.tipsView.alpha = 1.f;
    }
}
- (void)hideText {
    if (_tipsView && _tipsView.tag > 0) {
        return;
    }
    
    if (_noFaceView) {
        [_noFaceView removeFromSuperview];
        self.noFaceView = nil;
    }
    
    if (_tipsView) {
        [_tipsView removeFromSuperview];
        self.tipsView = nil;
    }
}
- (void)showText:(NSString *)text inView:(UIView *)parentView afterDelay:(NSTimeInterval)delay {
    [self showText:text inView:parentView atPoint:CGPointZero withType:MCTipsContent showBG:NO afterDelay:delay];
}
- (void)showText:(NSString *)text
          inView:(UIView *)parentView
         atPoint:(CGPoint)point
        withType:(MCTipsType)type
          showBG:(BOOL)showBG
      afterDelay:(NSTimeInterval)delay {
    
    if (_noFaceView) {
        [_noFaceView removeFromSuperview];
        self.noFaceView = nil;
    }
    
    [self.tipsView setText:text withType:type showBG:showBG];
    self.tipsView.center = CGPointEqualToPoint(point, CGPointZero) ? CGPointMake(parentView.bounds.size.width * 0.5f, parentView.bounds.size.height * 0.5f) : point;
    self.tipsView.tag = roundf(delay * 1000.f);
    [parentView addSubview:self.tipsView];
    [UIView animateWithDuration:delay<0.3?delay:0.3 animations:^{
        self.tipsView.alpha = 1;
    }];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fadeOut) object:nil];
    [self performSelector:@selector(fadeOut) withObject:nil afterDelay:delay];
}
- (void)fadeOut {

    [UIView animateWithDuration:0.3 animations:^{
        self.tipsView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.tipsView removeFromSuperview];
        self.tipsView = nil;
    }];
}

- (void)showLoadingText:(NSString *)text inView:(UIView *)parentView {
    
    self.loadingLabel.text = text;
    
    [self.loadingView addSubview:self.loadingImageView];
    [self.loadingView addSubview:self.loadingLabel];
    [parentView addSubview:self.loadingView];
    
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
    rotationAnimation.duration = 1;
    rotationAnimation.cumulative = NO;
    rotationAnimation.repeatCount = 10000;
    [_loadingImageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
    _loadingLabel.frame = CGRectMake(CGRectGetWidth(self.loadingView.frame)-CGRectGetWidth(_loadingLabel.frame)-[MCTip xOffset], 0, CGRectGetWidth(_loadingLabel.frame), CGRectGetHeight(_loadingLabel.frame));
    _loadingLabel.center = CGPointMake(_loadingLabel.center.x, CGRectGetHeight(self.loadingView.frame)/2);
    
    _loadingImageView.center = CGPointMake(_loadingImageView.center.x, CGRectGetHeight(self.loadingView.frame)/2);
    
    _loadingView.center = CGPointMake(CGRectGetWidth(parentView.frame)/2, CGRectGetHeight(parentView.frame)-100.f-CGRectGetHeight(_loadingView.frame));
}
- (void)stopLoadingText {
    [self.loadingView removeFromSuperview];
    [_loadingImageView.layer removeAllAnimations];
}
- (MCTipsView *)tipsView {

    if (!_tipsView) {
        _tipsView = [[MCTipsView alloc] init];
        _tipsView.backgroundColor = [UIColor clearColor];
        _tipsView.alpha = 0;
    }
    
    return _tipsView;
}
- (UILabel *)loadingLabel {

    if (!_loadingLabel) {
        _loadingLabel = [[UILabel alloc] init];
        _loadingLabel.backgroundColor = [UIColor clearColor];
        _loadingLabel.textColor = [UIColor MCNormal];
        _loadingLabel.font = [UIFont systemFontOfSize:12];
    }
    
    CGSize size = [_loadingLabel.text sizeWithAttributes:@{NSFontAttributeName:_loadingLabel.font}];
    _loadingLabel.frame = CGRectMake(0, 0, size.width, size.height);
    
    return _loadingLabel;
}
- (UIView *)loadingView {

    if (!_loadingView) {
        _loadingView = [[UIView alloc] init];
        _loadingView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
        _loadingView.layer.masksToBounds = YES;
    }
    _loadingView.frame = CGRectMake(0, 0, _loadingImageView.frame.size.width+_loadingLabel.frame.size.width+([MCTip xOffset]*3), [MCTip height]+([MCTip xOffset]*2));
    _loadingView.layer.cornerRadius = CGRectGetHeight(_loadingView.frame)/2;
    
    return _loadingView;
}
- (UIImageView *)loadingImageView {

    if (!_loadingImageView) {
        UIImage *image = [UIImage MCImageNamed:@"loadingAni"];
        _loadingImageView = [[UIImageView alloc] initWithImage:image];
        _loadingImageView.frame = CGRectMake([MCTip xOffset], 0, [MCTip height], [MCTip height]);
    }
    
    return _loadingImageView;
}
- (NoFaceView *)noFaceView {

    if (!_noFaceView) {
        _noFaceView = [[NoFaceView alloc] init];
        _noFaceView.alpha = 0;
    }
    
    return _noFaceView;
}
@end
