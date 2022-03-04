//
//  TUIPlayerContainerView.m
//  TUIPlayer
//
//  Created by gg on 2021/9/30.
//

#import "TUIPlayerContainerView.h"
#import "TUICore.h"
#import "TUIDefine.h"
#import "Masonry.h"

@interface TUIPlayerContainerView ()
@property (nonatomic,  weak ) UIView   *bottomMenuView;

@property (nonatomic, strong) UIButton *sendBtn;
@property (nonatomic, strong) UIView   *inputView;
@property (nonatomic, strong) UIView   *barrageView;

@property (nonatomic, strong) UIButton *giftBtn;
@property (nonatomic, strong) UIButton *likeBtn;
@property (nonatomic, strong) UIView   *giftView;
@property (nonatomic, strong) UIView   *giftPlayView;

@property (nonatomic, strong) NSString *groupId;
@end

@implementation TUIPlayerContainerView

- (instancetype)initWithFrame:(CGRect)frame groupId:(NSString * _Nullable)groupId {
    if (self = [super initWithFrame:frame]) {
        self.groupId = groupId;
        CGFloat width = UIScreen.mainScreen.bounds.size.width;
        
        UIView *bottomMenuView = [[UIView alloc] initWithFrame:CGRectZero];
        bottomMenuView.backgroundColor = [UIColor clearColor];
        [self addSubview:bottomMenuView];
        self.bottomMenuView = bottomMenuView;
        [bottomMenuView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom).offset(-10);
            } else {
                make.bottom.equalTo(self).offset(-10);
            }
            make.leading.equalTo(self);
            make.height.mas_equalTo(44);
        }];
        
        if ([self loadBarrageView:groupId]) {
            
            [bottomMenuView addSubview:self.sendBtn];
            [self.sendBtn addTarget:self action:@selector(sendBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [self.sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(bottomMenuView.mas_leading).offset(width * 0.5 * (1.0/6.0));
                make.width.height.equalTo(bottomMenuView.mas_height);
                make.top.bottom.equalTo(bottomMenuView);
            }];
            
            [self addSubview:self.barrageView];
            [self addSubview:self.inputView];
            [self.inputView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self);
            }];
        }
        
        if ([self loadGiftView:groupId]) {
            [bottomMenuView addSubview:self.giftBtn];
            [self.giftBtn addTarget:self action:@selector(giftBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [self.giftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(bottomMenuView.mas_leading).offset(width * 0.5 * (5.0/6.0));
                make.width.height.equalTo(bottomMenuView.mas_height);
                make.top.bottom.equalTo(bottomMenuView);
            }];
            
            [bottomMenuView addSubview:self.likeBtn];
            [self.likeBtn addTarget:self action:@selector(likeBtnClick) forControlEvents:UIControlEventTouchUpInside];
            [self.likeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(bottomMenuView.mas_leading).offset(width * 0.5 * (7.0/6.0));
                make.width.height.equalTo(bottomMenuView.mas_height);
                make.top.bottom.equalTo(bottomMenuView);
                make.trailing.equalTo(bottomMenuView.mas_trailing);
            }];
            
            [self addSubview:self.giftView];
        }
        
        if ([self loadGiftPlayView:groupId]) {
            
            [self addSubview:self.giftPlayView];
        }
    }
    return self;
}

- (void)setLinkMicBtn:(UIButton *)btn {
    CGFloat width = UIScreen.mainScreen.bounds.size.width;
    [self.bottomMenuView addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.bottomMenuView.mas_leading).offset(width * 0.5 * (3.0/6.0));
        make.width.height.equalTo(self.bottomMenuView.mas_height);
        make.centerY.equalTo(self.bottomMenuView);
    }];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    CGRect bottomRect = self.bottomMenuView.frame;
    bottomRect.size.width = self.bounds.size.width;
    
    CGRect bottomMenuRect = self.bottomMenuView.frame;
    
    if (CGRectContainsPoint(bottomRect, point)) {
        if (!CGRectContainsPoint(bottomMenuRect, point)) {
            return nil;
        }
    }
    
    return [super hitTest:point withEvent:event];
}

- (BOOL)loadGiftView:(NSString *)groupId {
    
    if (groupId == nil) {
        return NO;
    }
    
    NSDictionary *giftBtnInfo =  [TUICore getExtensionInfo:TUICore_TUIGiftExtension_GetEnterBtn param:nil];
    if (giftBtnInfo != nil && [giftBtnInfo isKindOfClass:[NSDictionary class]]) {
        UIButton *btn = giftBtnInfo[TUICore_TUIGiftExtension_GetEnterBtn];
        if (btn != nil && [btn isKindOfClass:[UIButton class]]) {
            self.giftBtn = btn;
        }
    }
    
    NSDictionary *likeBtnInfo = [TUICore getExtensionInfo:TUICore_TUIGiftExtension_GetLikeBtn param:nil];
    if (likeBtnInfo != nil && [likeBtnInfo isKindOfClass:[NSDictionary class]]) {
        UIButton *btn = likeBtnInfo[TUICore_TUIGiftExtension_GetLikeBtn];
        if (btn != nil && [btn isKindOfClass:[UIButton class]]) {
            self.likeBtn = btn;
        }
    }
    
    NSDictionary *giftViewInfo = [TUICore getExtensionInfo:TUICore_TUIGiftExtension_GetTUIGiftListPanel param:@{@"frame":NSStringFromCGRect(UIScreen.mainScreen.bounds),@"groupId":groupId}];
    if (giftViewInfo != nil && [giftViewInfo isKindOfClass:[NSDictionary class]]) {
        UIButton *giftView = giftViewInfo[TUICore_TUIGiftExtension_GetTUIGiftListPanel];
        if (giftView != nil && [giftView isKindOfClass:[UIView class]]) {
            self.giftView = giftView;
        }
    }
    
    return self.giftBtn != nil;
}

- (BOOL)loadGiftPlayView:(NSString *)groupId{
    if (groupId == nil || ![groupId isKindOfClass:[NSString class]]) {
        return NO;
    }
    NSDictionary *giftPlayInfo = (id)[TUICore getExtensionInfo:TUICore_TUIGiftExtension_GetTUIGiftPlayView param:@{@"frame":NSStringFromCGRect(UIScreen.mainScreen.bounds),@"groupId":groupId}];
    if (giftPlayInfo != nil && [giftPlayInfo isKindOfClass:[NSDictionary class]]) {
        UIView *giftView = giftPlayInfo[TUICore_TUIGiftExtension_GetTUIGiftPlayView];
        if (giftView != nil && [giftView isKindOfClass:[UIView class]]) {
            self.giftPlayView = giftView;
        }
    }
    return self.giftPlayView != nil;
}

- (BOOL)loadBarrageView:(NSString *)groupId {
    
    if (groupId == nil) {
        return NO;
    }
    
    NSDictionary *sendBtnInfo =  [TUICore getExtensionInfo:TUICore_TUIBarrageExtension_GetEnterBtn param:nil];
    if (sendBtnInfo != nil && [sendBtnInfo isKindOfClass:[NSDictionary class]]) {
        UIButton *btn = sendBtnInfo[TUICore_TUIBarrageExtension_GetEnterBtn];
        if (btn != nil && [btn isKindOfClass:[UIButton class]]) {
            self.sendBtn = btn;
        }
    }
    CGFloat width = UIScreen.mainScreen.bounds.size.width;
    CGFloat height = UIScreen.mainScreen.bounds.size.height;
    NSDictionary *inputViewInfo = [TUICore getExtensionInfo:TUICore_TUIBarrageExtension_GetTUIBarrageSendView param:@{@"frame":NSStringFromCGRect(UIScreen.mainScreen.bounds),@"groupId":groupId}];
    if (inputViewInfo != nil && [inputViewInfo isKindOfClass:[NSDictionary class]]) {
        UIView *inputView = inputViewInfo[TUICore_TUIBarrageExtension_GetTUIBarrageSendView];
        if (inputView != nil && [inputView isKindOfClass:[UIView class]]) {
            self.inputView = inputView;
        }
    }
    
    NSDictionary *barrageViewInfo = [TUICore getExtensionInfo:TUICore_TUIBarrageExtension_TUIBarrageDisplayView param:@{@"frame":NSStringFromCGRect(CGRectMake(20, height-300 - 120, width-20*2, 300)),@"groupId":groupId}];
    if (barrageViewInfo != nil && [barrageViewInfo isKindOfClass:[NSDictionary class]]) {
        UIView *barrageView = barrageViewInfo[TUICore_TUIBarrageExtension_TUIBarrageDisplayView];
        if (barrageView != nil && [barrageView isKindOfClass:[UIView class]]) {
            self.barrageView = barrageView;
        }
    }
    
    return self.sendBtn != nil;
}

- (void)sendBtnClick {
    self.inputView.hidden = NO;
}

- (void)giftBtnClick {
    self.giftView.hidden = NO;
}

- (void)likeBtnClick {
    if (self.groupId && [self.groupId isKindOfClass:[NSString class]]) {
        [TUICore callService:TUICore_TUIGiftService method:TUICore_TUIGiftService_SendLikeMethod param:@{@"groupId": self.groupId}];
    }
}
@end
