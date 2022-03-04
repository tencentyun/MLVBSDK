//
//  TUIAudioEffectBGMView.m
//  Masonry
//
//  Created by jack on 2021/9/29.
//  背景音乐选择视图

#import "TUIAudioEffectBGMView.h"
#import "TUIAudioEffectModel.h"
#import "TUIAudioEffectDefine.h"

@interface TUIAudioEffectBGMView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *backBtn;

@property (strong, nonatomic) UITableView *tableView;

@property (nonatomic, strong) NSArray *bgmDataSource;

@end

@implementation TUIAudioEffectBGMView

- (instancetype)initWithFrame:(CGRect)frame bgmDataSource:(NSArray *)dataSource{
    if (self = [super initWithFrame:frame]) {
        self.bgmDataSource = dataSource;
        [self setupUI];
        
        self.transform = CGAffineTransformMakeTranslation(0, Screen_Height);
        self.alpha = 0;
    }
    return self;
}

- (void)setupUI{
    
    self.backgroundColor = UIColor.whiteColor;    
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.backBtn];
    [self addSubview:self.tableView];
    
    CGFloat tableHeight = 52 * 3;
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(20);
        make.top.mas_equalTo(32);
    }];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(-20);
        make.centerY.mas_equalTo(_titleLabel);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(tableHeight+10+Bottom_SafeHeight);
        make.leading.trailing.mas_equalTo(0);
        make.top.mas_equalTo(_titleLabel.mas_bottom).mas_offset(20);
        make.bottom.mas_equalTo(0);
    }];
}

- (void)removeFromSuperview{
    [super removeFromSuperview];
    if (_delegate && [_delegate respondsToSelector:@selector(audioEffectBGMDidDismiss)]) {
        [_delegate audioEffectBGMDidDismiss];
    }
}

#pragma mark - drawRect
- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    [self roundedRect:UIRectCornerTopLeft | UIRectCornerTopRight withCornerRatio:12];
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
    [UIView animateWithDuration:animation ? 0.25 : 0.01 animations:^{
        weakSelf.alpha = 1.0;
        weakSelf.transform = CGAffineTransformMakeTranslation(0, 0);
    }];
}

- (void)dismiss{
    __weak typeof(self) weakSelf = self;
    CGFloat height = self.frame.size.height;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.alpha = 0;
        weakSelf.transform = CGAffineTransformMakeTranslation(0, height);
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _bgmDataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellId" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = UIColor.whiteColor;
    
    TUIAudioEffectSongModel *songModel = _bgmDataSource[indexPath.row];
    cell.textLabel.text = songModel.name;
    cell.textLabel.textColor = UIColor.blackColor;
    return cell;
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TUIAudioEffectSongModel *songModel = _bgmDataSource[indexPath.row];
    if (self.delegate && [self.delegate respondsToSelector:@selector(audioEffectBGMDidSelect:)]) {
        [self.delegate audioEffectBGMDidSelect:songModel];
    }
    [self dismiss];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 52;
}

#pragma mark - getter
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = UIColor.whiteColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CellId"];
    }
    return _tableView;
}

- (UIButton *)backBtn{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_backBtn setTitle:AudioEffectLocalize(@"TUIKit.AudioEffectView.Back") forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = UIColor.blackColor;
        _titleLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightMedium];
        _titleLabel.text = AudioEffectLocalize(@"TUIKit.AudioEffectView.MusicBackground.title");
    }
    return _titleLabel;
}

@end
