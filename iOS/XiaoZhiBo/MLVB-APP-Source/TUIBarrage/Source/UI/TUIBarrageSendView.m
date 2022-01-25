//
//  TUIBarrageSendView.m
//  TUIBarrageService
//
//  Created by WesleyLei on 2021/9/22.
//

#import "TUIBarrageSendView.h"
#import "TUIBarrageModel.h"
#import "UIView+TUILayout.h"
#import "TUIBarrageLocalized.h"
#import "TUIGlobalization.h"
#import "Masonry.h"
#import "UIColor+TUIHexColor.h"
@interface TUIBarrageSendView ()<UITextFieldDelegate>
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *sendButton;
@end

@implementation TUIBarrageSendView

- (instancetype)initWithFrame:(CGRect)frame delegate:(id <TUIBarrageSendViewDelegate>)delegate groupId:(NSString*)groupId {
    if (self = [super initWithFrame:frame delegate:delegate groupId:groupId]) {
        [self setupUI];
    }
    return self;
}

#pragma mark - setupUI
-(void)setupUI {
    [self addSubview:self.sendButton];
    [self addSubview:self.textField];
    self.hidden = YES;
    [self.sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-20);
        make.top.equalTo(@(10));
        make.bottom.equalTo(@(-10));
    }];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(10));
        make.bottom.equalTo(self).offset(-10);
        make.left.equalTo(@(10));
    }];
}

#pragma mark - drawRect
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    self.sendButton.layer.cornerRadius = self.sendButton.mm_h * 0.5;
    [self.sendButton sizeToFit];
    CGFloat width = self.sendButton.mm_w + 15 * 2;
    [self.sendButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width);
    }];
    [self.textField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.sendButton).offset(-width-10);
    }];
}

-(void)becomeFirstResponder {
    self.hidden = NO;
    self.textField.text = @"";
    [self.textField becomeFirstResponder];
    [self.superview bringSubviewToFront:self];
}

-(void)resignFirstResponder {
    [self.textField resignFirstResponder];
    self.textField.text = @"";
}

- (void)sendButtonClick {
    NSString *msg = [self.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (!msg || [msg isEqualToString:@""]) {
        return;
    }
    TUIBarrageModel *barrage = [TUIBarrageModel defaultCreate];
    barrage.message = msg;
    [self sendMessage:barrage];
    [self resignFirstResponder];
}

#pragma mark - set/get
- (UITextField *)textField {
    if (!_textField) {
        _textField = [[UITextField alloc]init];
        _textField.font =  [UIFont systemFontOfSize:14];
        _textField.placeholder = TUIBarrageLocalize(@"TUIBarrageView.Placeholder");
        _textField.delegate = self;
        _textField.textColor = [UIColor colorWithHex:@"0x333333"];
    }
    return _textField;
}

- (UIButton *)sendButton {
    if (!_sendButton) {
        _sendButton = [[UIButton alloc]initWithFrame:CGRectZero];
        [_sendButton setTitle:TUIBarrageLocalize(@"TUIBarrageView.Send") forState:UIControlStateNormal];
        [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_sendButton addTarget:self action:@selector(sendButtonClick) forControlEvents:UIControlEventTouchUpInside];
        _sendButton.layer.masksToBounds = YES;
        _sendButton.adjustsImageWhenHighlighted = NO;
        _sendButton.backgroundColor = [UIColor colorWithHex:@"0x29CC85"];
    }
    return _sendButton;
}

@end
