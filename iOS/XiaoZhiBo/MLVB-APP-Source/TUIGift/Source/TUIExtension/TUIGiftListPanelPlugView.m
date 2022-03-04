//
//  TUIGiftListPanelPlugView.m
//  TUIGiftView
//
//  Created by WesleyLei on 2021/9/28.
//

#import "TUIGiftListPanelPlugView.h"
#import "TUIGiftListPanelView.h"
#import "UIView+TUILayout.h"
#import "TUIDefine.h"
#import "TUILogin.h"
#import "TUIGiftModel.h"
#import "TUIGiftLocalized.h"
#import "Masonry.h"
#import "TUIGiftExtension.h"
#import "TUIGiftPlayBaseView.h"
#import "UIView+TUIToast.h"

@interface TUIGiftListPanelPlugView ()<TUIGiftPanelDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSString *groupId;
@property (nonatomic, strong) TUIGiftListPanelView *giftListPanelView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) NSMutableArray *giftMuArray;

@end

@implementation TUIGiftListPanelPlugView

- (instancetype)initWithFrame:(CGRect)frame groupId:(NSString*)groupId {
    if (self = [super initWithFrame:frame]) {
        self.layer.masksToBounds = YES;
        self.alpha = 0;
        self.groupId = groupId;
        [self setupUI];
        [self initData];
    }
    return self;
}

#pragma mark - setupUI

- (void)setupUI {
    UITapGestureRecognizer *tapOne = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClickAction:)];
    tapOne.numberOfTouchesRequired = 1; //手指数
    tapOne.numberOfTapsRequired = 1; //tap次数
    tapOne.delegate = self;
    [self addGestureRecognizer:tapOne];
    self.userInteractionEnabled = YES;
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.giftListPanelView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self);
        make.height.equalTo(@(96+60+Bottom_SafeHeight));
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(24));
        make.height.equalTo(@(36));
        make.left.equalTo(self.contentView).offset(20);
        make.right.equalTo(self.contentView).offset(20);
    }];
    [self.giftListPanelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(60));
        make.height.equalTo(@(96));
        make.width.equalTo(self.contentView);
    }];
}

- (void)initData {
    NSURL *url = [NSURL URLWithString:@"https://liteav.sdk.qcloud.com/app/res/picture/live/gift/gift_data.json"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if (dict && [dict isKindOfClass:[NSDictionary class]]) {
                NSArray *arrayList = dict[@"giftList"];
                if (arrayList && [arrayList isKindOfClass:[NSArray class]]) {
                    [self initGiftModel:dict[@"giftList"]];
                }
            }
        }
    }];
}

- (void)initGiftModel:(NSArray *)giftList {
    self.giftMuArray = [NSMutableArray array];
    for (NSDictionary *dict in giftList) {
        TUIGiftModel *mode = [TUIGiftModel defaultCreate];
        mode.giftId = dict[@"giftId"];
        mode.normalImageUrl = dict[@"giftImageUrl"];
        mode.selectedImageUrl = dict[@"giftImageUrl"];
        mode.animationURL = dict[@"lottieUrl"];
        mode.title = dict[@"title"];
        [self.giftMuArray addObject:mode];
    }
    [self.giftListPanelView setGiftModelSource:self.giftMuArray];
    [self.giftListPanelView reloadData];
}

- (void)setHidden:(BOOL)hidden{
    if (hidden) {
        [self dismissView];
    } else {
        [self showView];
    }
}

- (void)showView {
    if (self.alpha >= 1) {
        return;
    }
    if(!self.giftMuArray){
        [self initData];
    }
    self.alpha = 1;
    self.backgroundColor = [UIColor clearColor];
    if (!self.contentView.layer.mask) {
        self.contentView.layer.mask = [self getMaskLayer];
    }
    self.contentView.mm_y = self.mm_h;
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mm_h - self.contentView.mm_h);
    }];
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.15];
        [self layoutIfNeeded];
    }];
}

- (void)dismissView {
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mm_h);
    }];
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundColor = [UIColor clearColor];
        [self layoutIfNeeded];
    }completion:^(BOOL finished) {
        self.alpha = 0;
    }];
}

- (void)sendLike {
    [self.giftListPanelView sendLike];
}

#pragma mark Gesture

- (void)tapClickAction:(UITapGestureRecognizer *)tap {
    [self dismissView];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(nonnull UITouch *)touch {
    if (touch.view == self) {
        return YES;
    }
    return NO;
}

#pragma mark TUIGiftPresenterDelegate

/// 消息发送完成回调
- (void)onGiftWillSend:(TUIGiftListPanelView*)gitView gift:(TUIGiftModel *)model completion:(TUIGiftSendBlock)completion {
    model.giveDesc = [NSString stringWithFormat:@"%@%@",TUIGiftLocalize(@"TUIGiftView.SendOut"),model.title];
    model.extInfo = @{@"nickName":[TUILogin getNickName]?:@"",
                      @"userID":[TUILogin getUserID]?:@"",
                      @"avatarUrl":[TUILogin getFaceUrl]?:@"https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar1.png"};
    if (completion) {
        completion(YES);
    }
}

- (void)onGiftDidSend:( TUIGiftListPanelView* _Nonnull )gitView gift:(TUIGiftModel *)model isSuccess:(BOOL)success message:(NSString *)message {
    if (success) {
        TUIGiftPlayBaseView *playView = [TUIGiftExtension getPlayViewByGroupId:self.groupId];
        [playView playGiftModel:model];
    } else {
        [self.superview makeToast:message];
    }
}

- (void)onLikeDidSend:(TUIGiftPanelBaseView *)gitView like:(TUIGiftModel *)model isSuccess:(BOOL)success message:(NSString *)message {
    TUIGiftPlayBaseView *playView = [TUIGiftExtension getPlayViewByGroupId:self.groupId];
    [playView playLikeModel:model];
}

#pragma mark - set/get

- (TUIGiftListPanelView *)giftListPanelView {
    if (!_giftListPanelView) {
        _giftListPanelView = [[TUIGiftListPanelView alloc]initWithFrame:CGRectZero delegate:self groupId:self.groupId];
    }
    return _giftListPanelView;
}

- (UILabel*)titleLabel {
    if(!_titleLabel){
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:24];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.text = TUIGiftLocalize(@"TUIGiftView.SendGift");
    }
    return _titleLabel;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc]initWithFrame:CGRectZero];
        _contentView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.8];
        _contentView.userInteractionEnabled = YES;
    }
    return _contentView;
}

- (CAShapeLayer *)getMaskLayer {
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.contentView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(20, 20)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.contentView.bounds;
    maskLayer.path = maskPath.CGPath;
    return maskLayer;
}

@end
