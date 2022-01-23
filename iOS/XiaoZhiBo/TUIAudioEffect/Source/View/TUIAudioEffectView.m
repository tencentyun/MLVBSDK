//
//  TUIAudioEffect.m
//  TUIAudioEffect
//
//  Created by jack on 2021/9/27.
//

#import "TUIAudioEffectView.h"
#import "TUIAudioEffectBGMView.h"
#import "TUIAudioEffectPresenter.h"

#import "TUIAudioEffectTableCell.h"
#import "TUIAudioEffectDefine.h"
#import "TXAudioEffectManager.h"

@interface TUIAudioEffectView ()<TUIAudioEffectPresenterDelegate>

@property (nonatomic, strong) TUIAudioEffectPresenter *presenter;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) TUIAudioEffectBGMView *bgmSelectView;

@end

@implementation TUIAudioEffectView

#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame audioEffectManager:(TXAudioEffectManager *)audioEffectManager{
    if (self = [super initWithFrame:frame]) {
        
        // 1. presenter 配置初始化
        self.presenter = [[TUIAudioEffectPresenter alloc] initWithTableView:self.tableView audioEffectManager:audioEffectManager];
        self.presenter.delegate = self;
        
        // 2. UI布局
        [self constructViewHierarchy];
        [self activateConstraints];
        [self bindInteraction];
        // 配置默认主题
        [self setTheme:[TUILiveThemeConfig defaultConfig]];
        
        // 3. transform 动画相关设置
        self.transform = CGAffineTransformMakeTranslation(0, Screen_Height);
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0;
        
        // 4. userInteractionEnabled
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)setAlpha:(CGFloat)alpha {
    super.alpha = alpha;
    self.bgView.alpha = alpha * 0.6;
}

#pragma mark - drawRect
- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    [self.contentView roundedRect:UIRectCornerTopLeft | UIRectCornerTopRight withCornerRatio:12];
}

#pragma mark - dealloc
- (void)dealloc{
    [self.presenter clearStatus];
    LOGD("[TUIAudioEffect] TUIAudioEffectView dealloc");
}

#pragma mark - setupUI
- (void)constructViewHierarchy {
    [self addSubview:self.bgView];
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.tableView];
}

- (void)activateConstraints {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self);
        make.height.equalTo(self).multipliedBy(2);
    }];
    CGFloat tableHeight = TUIAudioEffectTableCellDefaultHeight * 5 + TUIAudioEffectTableCellCollectionHeight * 2 + Bottom_SafeHeight;
    CGFloat maxHeight = UIScreen.mainScreen.bounds.size.height * 0.5;
    if (tableHeight > maxHeight) {
        tableHeight = maxHeight;
    }
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(20);
        make.top.mas_equalTo(32);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(tableHeight+Bottom_SafeHeight+10);
        make.leading.trailing.mas_equalTo(0);
        make.top.mas_equalTo(_titleLabel.mas_bottom).mas_offset(20);
        make.bottom.mas_equalTo(0);
    }];
}

- (void)bindInteraction {
    
}

#pragma mark - Animation
- (void)show{
    [self showWithAnimation:YES];
}

- (void)showWithAnimation:(BOOL)animation{
    if (self.superview == nil) {
        return;
    }
    [self layoutIfNeeded];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.transform = CGAffineTransformMakeTranslation(0, 0);
        weakSelf.alpha = 1.0;
    }];
}

- (void)showFromView:(UIView *)fromView animation:(BOOL)animation{
    [fromView addSubview:self];
    [self showWithAnimation:animation];
}

- (void)dismiss{
    __weak typeof(self) weakSelf = self;
    
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.alpha = 0;
        weakSelf.transform = CGAffineTransformMakeTranslation(0, Screen_Height);
    }];
}

#pragma mark - 手势识别
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches allObjects].firstObject;
    if (!touch) {
        return;
    }
    CGPoint point = [touch locationInView:self];
    
    if (self.bgmSelectView.superview != nil) {
        if (!CGRectContainsPoint(self.bgmSelectView.frame, point)) {
            [self.bgmSelectView dismiss];
            return;
        }
    }
    if (!CGRectContainsPoint(self.contentView.frame, point)) {
        [self dismiss];
    }
}

#pragma mark - TUIAudioEffectPresenterDelegate
- (void)audioEffectPresenterBGMSelectAlertShow{
    [self showBGMSelect];
}

- (void)audioEffectPresenterBGMSelectAlertDidHide{
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.contentView.alpha = 1.0;
    }];
}

#pragma mark - bgmSelect
- (void)showBGMSelect{
    [self addSubview:self.bgmSelectView];
    [self.bgmSelectView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    [self.bgmSelectView show];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.contentView.alpha = 0;
    }];
}

#pragma mark - setter
- (void)setHidden:(BOOL)hidden{
    if (hidden) {
        [self dismiss];
    } else {
        [self show];
    }
}

- (void)setTheme:(TUILiveThemeConfig *)theme{
    _theme = theme;
    _contentView.backgroundColor = theme.backgroundColor;
    _titleLabel.font = theme.titleFont;
    _tableView.backgroundColor = theme.backgroundColor;
    [self.presenter setThemeConfig:theme];
}

#pragma mark - getter
- (UIView *)contentView{
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
        _contentView.backgroundColor = UIColor.whiteColor;
    }
    return _contentView;
}

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
        _bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    }
    return _bgView;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
    }
    return _tableView;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = UIColor.blackColor;
        _titleLabel.text = AudioEffectLocalize(@"TUIKit.AudioEffectView.title");
    }
    return _titleLabel;
}

- (TUIAudioEffectBGMView *)bgmSelectView{
    if (!_bgmSelectView) {
        _bgmSelectView = [[TUIAudioEffectBGMView alloc] initWithFrame:CGRectZero bgmDataSource:self.presenter.effectModel.bgmDataSource];
        _bgmSelectView.delegate = self.presenter;
    }
    return _bgmSelectView;
}

@end
