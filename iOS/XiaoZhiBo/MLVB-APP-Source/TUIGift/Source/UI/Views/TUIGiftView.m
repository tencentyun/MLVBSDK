//
//  TUIGiftView.m
//  TUIGiftView
//
//  Created by WesleyLei on 2021/9/16.
//

#import "TUIGiftView.h"
#import "UIView+TUILayout.h"
#import "TUIGiftModel.h"
#import "UIImageView+WebCache.h"

@interface TUIGiftView ()

@property (nonatomic, strong) UIImageView *normalImageView;
@property (nonatomic, strong) UIImageView *selectedImageView;
@property (nonatomic, strong) UILabel *giftNameLabel;

@end

@implementation TUIGiftView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.mm_h = 76;
        self.mm_w = 52;
        [self setupUI];
    }
    return self;
}

#pragma mark - setupUI

- (void)setupUI {
    self.clipsToBounds = YES;
    [self addSubview:self.normalImageView];
    [self addSubview:self.selectedImageView];
    [self addSubview:self.giftNameLabel];
}

- (void)setGiftModel:(TUIGiftModel *)giftModel {
    _giftModel = giftModel;
    [self.normalImageView sd_setImageWithURL:[NSURL URLWithString:giftModel.normalImageUrl]];
    [self.selectedImageView sd_setImageWithURL:[NSURL URLWithString:giftModel.selectedImageUrl]];
    self.giftNameLabel.text = giftModel.title;
}

- (UIImageView *)normalImageView {
    if (!_normalImageView) {
        _normalImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 52, 52)];
        _normalImageView.layer.masksToBounds = YES;
        _normalImageView.layer.cornerRadius = _normalImageView.mm_h*0.5;
        [self addSubview:_normalImageView];
    }
    return _normalImageView;
}

- (UIImageView *)selectedImageView {
    if (!_selectedImageView) {
        _selectedImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 52, 52)];
        _selectedImageView.hidden = YES;
        _selectedImageView.layer.cornerRadius = _selectedImageView.mm_h * 0.5;
        [self addSubview:_selectedImageView];
    }
    return _selectedImageView;
}

- (UILabel*)giftNameLabel {
    if (!_giftNameLabel) {
        _giftNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0 , self.normalImageView.mm_h + 4, self.mm_w, 20)];
        _giftNameLabel.font = [UIFont systemFontOfSize:14];
        _giftNameLabel.textAlignment = NSTextAlignmentCenter;
        _giftNameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _giftNameLabel.textColor = [[UIColor whiteColor]colorWithAlphaComponent:0.6];
    }
    return _giftNameLabel;
}

@end
