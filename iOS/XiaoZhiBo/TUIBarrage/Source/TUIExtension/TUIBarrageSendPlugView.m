//
//  TUIBarrageDisplayPlugView.m
//  TUIBarrageView
//
//  Created by WesleyLei on 2021/9/29.
//

#import "TUIBarrageSendPlugView.h"
#import "TUIBarrageSendView.h"
#import "TUIBarrageExtension.h"
#import "TUIBarrageDisplayBaseView.h"
#import "UIView+TUILayout.h"
#import "Masonry.h"
#import "TUILogin.h"
#import "TUIBarrageModel.h"
#import "UIView+TUIToast.h"

@interface TUIBarrageSendPlugView ()<TUIBarrageSendViewDelegate>
@property (nonatomic, strong) TUIBarrageSendView *barrageSendView;
@property (nonatomic, strong) NSString *groupId;
@end

@implementation TUIBarrageSendPlugView

- (instancetype)initWithFrame:(CGRect)frame groupId:(NSString*)groupId {
    if (self = [super initWithFrame:frame]) {
        self.groupId = groupId;
        [self setupUI];
        [self addObserver];
    }
    return self;
}

- (void)addObserver {
    // 注册监听
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - setupUI
- (void)setupUI {
    UITapGestureRecognizer *tapOne = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClickAction:)];
    tapOne.numberOfTouchesRequired = 1; //手指数
    tapOne.numberOfTapsRequired = 1; //tap次数
    [self addGestureRecognizer:tapOne];
    self.userInteractionEnabled = YES;
    [self addSubview:self.barrageSendView];
    self.backgroundColor = [UIColor clearColor];
    self.alpha = 0;
    [self.barrageSendView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(56));
        make.width.equalTo(self);
        make.bottom.equalTo(@(56));
        make.left.equalTo(@(0));
    }];
}

-(void)tapClickAction:(UITapGestureRecognizer *)tap {
    self.hidden = YES;
}

#pragma mark - set/get
-(void)setHidden:(BOOL)hidden {
    if (hidden == NO) {
        self.alpha = 1;
        [self.barrageSendView becomeFirstResponder];
    } else {
        [self.barrageSendView resignFirstResponder];
    }
}

-(TUIBarrageSendView *)barrageSendView {
    if (!_barrageSendView) {
        _barrageSendView = [[TUIBarrageSendView alloc]initWithFrame:CGRectMake(0, self.mm_h, self.mm_w, 56) delegate:self groupId:self.groupId];
        _barrageSendView.backgroundColor = [UIColor whiteColor];
    }
    return _barrageSendView;
}

- (void)onBarrageWillSend:(TUIBarrageSendBaseView* _Nonnull)view barrage:(TUIBarrageModel *)barrage completion:(TUIBarrageSendBlock)completion {
    barrage.extInfo = @{@"nickName":[TUILogin getNickName]?:@"",
                      @"userID":[TUILogin getUserID]?:@"",
                      @"avatarUrl":[TUILogin getFaceUrl]?:@"https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar1.png"};
    if (completion) {
        completion(YES);
    }
}

- (void)onBarrageDidSend:(TUIBarrageSendBaseView* _Nonnull)view barrage:(TUIBarrageModel *)barrage isSuccess:(BOOL)success message:(NSString *)message {
    if (success) {
        TUIBarrageDisplayBaseView *playView = [TUIBarrageExtension getDisplayViewByGroupId:self.groupId];
        [playView receiveBarrage:barrage];
    } else {
        [self.superview makeToast:message];
    }
}

#pragma mark - Keyboard Notification
- (void)keyboardWillShow:(NSNotification *)notification {
    if (self.alpha <= 0) {
        return;
    }
    //获取键盘高度，在不同设备上，以及中英文下是不同的
    CGFloat kbHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    //计算出键盘顶端到inputTextView panel底端的距离(加上自定义的缓冲距离INTERVAL_KEYBOARD)
    // 取得键盘的动画时间，这样可以在视图上移的时候更连贯
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    //将视图上移计算好的偏移
    [UIView animateWithDuration:duration animations:^{
        self.barrageSendView.mm_y = self.mm_h - kbHeight - self.barrageSendView.mm_h;
    } completion:^(BOOL finished) {
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if (self.alpha <= 0) {
        return;
    }
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration animations:^{
        self.barrageSendView.mm_y = self.mm_h;
    } completion:^(BOOL finished) {
        self.alpha = 0;
    }];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
