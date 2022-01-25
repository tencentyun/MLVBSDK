//
//  TUIGiftCell.m
//  TUIGiftView
//
//  Created by WesleyLei on 2021/9/10.
//

#import "TUIGiftCell.h"
#import "TUIGiftModel.h"
#import "UIView+TUILayout.h"
#import "TUIGiftView.h"

@interface TUIGiftCell ()

@property(nonatomic,strong)TUIGiftView *giftBaseView;

@end

@implementation TUIGiftCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}
#pragma mark - setupUI

- (void)setupUI {
    self.clipsToBounds = YES;
    [self addSubview:self.giftBaseView];
}

- (void)setGiftModel:(TUIGiftModel *)giftModel {
    _giftModel = giftModel;
    self.giftBaseView.giftModel = giftModel;
}

- (void)setIsSelected:(BOOL)isSelected {
    if (_isSelected != isSelected) {
        _isSelected = isSelected;
        self.giftBaseView.isSelected = isSelected;
    }
}

- (TUIGiftView *)giftBaseView {
    if (!_giftBaseView) {
        _giftBaseView = [[TUIGiftView alloc]initWithFrame:CGRectZero];
        [_giftBaseView setMm_centerX:self.mm_w * 0.5];
        [_giftBaseView setMm_centerY:self.mm_h * 0.5];
        __weak typeof(self) wealSelf = self;
        _giftBaseView.sendBlock = ^(TUIGiftModel *giftModel) {
            __strong typeof(wealSelf) strongSelf = wealSelf;
            if (strongSelf.sendBlock) {
                strongSelf.sendBlock(giftModel);
            }
        };
    }
    return _giftBaseView;
}

@end
