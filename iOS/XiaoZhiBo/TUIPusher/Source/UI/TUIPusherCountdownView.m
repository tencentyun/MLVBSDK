//
//  TUIPusherCountdownView.m
//  TUIPusher
//
//  Created by gg on 2021/9/9.
//

#import "TUIPusherCountdownView.h"
#import "Masonry.h"
#import "TUIPusherHeader.h"
#import "UIColor+TUIHexColor.h"

@interface TUIPusherCountdownView ()
@property (nonatomic,  weak ) UILabel *countdownLabel;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger currentValue;
@end

@implementation TUIPusherCountdownView {
    BOOL _isInCountdown;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
        self.alpha = 0;
        _isInCountdown = NO;
    }
    return self;
}

- (void)updateText {
    self.countdownLabel.text = [NSString stringWithFormat:@"%ld", (long)self.currentValue];
}

- (BOOL)isInCountdown {
    return _isInCountdown;
}

- (void)start {
    _isInCountdown = YES;
    self.currentValue = 3;
    [self updateText];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        [self startTimer];
    }];
}

- (void)end {
    if (self.willDismiss) {
        self.willDismiss();
    }
    [self invalidateTimer];
    _isInCountdown = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (self.didDismiss) {
            self.didDismiss();
        }
    }];
}

- (void)startTimer {
    [self invalidateTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerCallback:) userInfo:nil repeats:YES];
}

- (void)invalidateTimer {
    if (_timer != nil) {
        [self.timer invalidate];
        _timer = nil;
    }
}

- (void)timerCallback:(NSTimer *)timer {
    self.currentValue--;
    if (self.currentValue > 0) {
        [self updateText];
    }
    else {
        [self invalidateTimer];
        [self end];
    }
}

- (void)setupUI {
    
    CGFloat width = 200;
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectZero];
    bgView.backgroundColor = [UIColor colorWithHex:@"29CC85"];
    bgView.clipsToBounds = YES;
    bgView.layer.cornerRadius = width * 0.5;
    [self addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(width, width));
    }];
    
    UILabel *countdownLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    countdownLabel.textColor = [UIColor whiteColor];
    countdownLabel.font = [UIFont systemFontOfSize:140];
    [self addSubview:countdownLabel];
    self.countdownLabel = countdownLabel;
    [countdownLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
}

@end
