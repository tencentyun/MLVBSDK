//
//  LiveRoomAccPlayerView.m
//  TXLiteAVDemo
//
//  Created by cui on 2019/5/7.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "LiveRoomAccPlayerView.h"

@interface LiveRoomPlayerItemView : UIView

- (void)startLoadingAnimation;
- (void)stopLoadingAnimation;

@end

@implementation LiveRoomAccPlayerView {
    LiveRoomPlayerItemView *_loadingView;
    UIButton *_closeButton;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.layer.borderWidth = 1;
        _loading = YES;
        _loadingView = [[LiveRoomPlayerItemView alloc] initWithFrame:self.bounds];
        _loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_loadingView startLoadingAnimation];
        [self addSubview:_loadingView];
    }
    return self;
}

- (void)setLoading:(BOOL)loading {
    if (_loading == loading) return;
    _loading = loading;
    _loadingView.hidden = !loading;
    if (loading) {
        [_loadingView startLoadingAnimation];
    } else {
        [_loadingView stopLoadingAnimation];
    }
}

- (void)setCloseEnabled:(BOOL)closeEnabled {
    if (_closeEnabled == closeEnabled) return;
    if (closeEnabled) {
        if (_closeButton == nil) {
            UIButton *btnKick = [UIButton buttonWithType:UIButtonTypeCustom];
            btnKick.frame = CGRectMake(CGRectGetWidth(self.bounds) - 18, 2, 16, 16);
            btnKick.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
            [btnKick setBackgroundImage:[UIImage imageNamed:@"linkmic_kickout"] forState:UIControlStateNormal];
            [btnKick setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
            [btnKick addTarget:self action:@selector(onTapClose:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btnKick];
            _closeButton = btnKick;
        }
    }
    _closeButton.hidden = !closeEnabled;
}

- (void)onTapClose:(UIButton *)sender {
    if (self.onClose) {
        self.onClose(self);
    }
}

@end

@implementation LiveRoomPlayerItemView
{
    UIImageView  *_loadingImageView;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        //loading imageview
        NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:[UIImage imageNamed:@"loading_1.png"],[UIImage imageNamed:@"loading_2.png"],[UIImage imageNamed:@"loading_3.png"],[UIImage imageNamed:@"loading_4.png"],[UIImage imageNamed:@"loading_5.png"],[UIImage imageNamed:@"loading_6.png"],[UIImage imageNamed:@"loading_7.png"],[UIImage imageNamed:@"loading_8.png"],[UIImage imageNamed:@"loading_9.png"],[UIImage imageNamed:@"loading_10.png"],[UIImage imageNamed:@"loading_11.png"],[UIImage imageNamed:@"loading_12.png"],[UIImage imageNamed:@"loading_13.png"],[UIImage imageNamed:@"loading_14.png"], nil];
        _loadingImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _loadingImageView.animationImages = array;
        _loadingImageView.animationDuration = 1;
        _loadingImageView.hidden = YES;
        [self addSubview:_loadingImageView];
    }
    return self;
}

- (void)layoutSubviews {
    float width = 45;
    float height = 45;
    float offsetX = (self.frame.size.width - width) / 2;
    float offsetY = (self.frame.size.height - height) / 2;
    _loadingImageView.frame = CGRectMake(offsetX, offsetY, width, height);
}

- (void)startLoadingAnimation {
    if (_loadingImageView != nil) {
        _loadingImageView.hidden = NO;
        [_loadingImageView startAnimating];
    }
}

- (void)stopLoadingAnimation {
    if (_loadingImageView != nil) {
        _loadingImageView.hidden = YES;
        [_loadingImageView stopAnimating];
    }
}

@end
