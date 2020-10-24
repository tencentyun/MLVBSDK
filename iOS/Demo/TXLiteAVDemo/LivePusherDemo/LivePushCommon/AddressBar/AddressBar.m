//
//  AddressBar.m
//  TXLiteAVDemo
//
//  Created by shengcui on 2018/6/14.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "AddressBar.h"
#import "SmallButton.h"
#import <Masonry/Masonry.h>

@implementation AddressBar
{

}
- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame buttons:0xffffff];
}

- (instancetype)initWithFrame:(CGRect)frame buttons:(AddressBarButtonOption)buttons
{
    if (self = [super initWithFrame:frame]) {
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.text = @"";
        textField.backgroundColor = UIColor.whiteColor;
        textField.alpha = 0.5;
        textField.autocapitalizationType = UITextAutocorrectionTypeNo;
        [self addSubview:textField];
        
        [textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.height.equalTo(self.mas_height);
            make.top.equalTo(self.mas_top);
        }];
        _textField = textField;
        UIView *prevLayoutItem = textField;
        
        if (buttons & AddressBarButtonOptionQRScan) {
            UIButton *btnScan = [UIButton buttonWithType:UIButtonTypeCustom];
            [btnScan setImage:[UIImage imageNamed:@"QR_code"] forState:UIControlStateNormal];
            [self addSubview:btnScan];
            _scanQRButton = btnScan;
            [btnScan mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.equalTo(self.mas_height);
                make.width.equalTo(self.mas_height);
                make.top.equalTo(self.mas_top);
                make.left.equalTo(prevLayoutItem.mas_right).with.offset(3);
            }];
            prevLayoutItem = btnScan;
        }

        if (buttons & AddressBarButtonOptionNew) {
            UIButton *btn = [SmallButton buttonWithType:UIButtonTypeCustom];
            [btn setImage:[UIImage imageNamed:@"QR_code"] forState:UIControlStateNormal];
            _showQRButton = btn;
            
            UIButton *btnNewUrl = [UIButton buttonWithType:UIButtonTypeCustom];
            [btnNewUrl setImage:[UIImage imageNamed:@"new"] forState:UIControlStateNormal];
            [self addSubview:btnNewUrl];
            _createAddressButton = btnNewUrl;
            [btnNewUrl mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(prevLayoutItem.mas_right).with.offset(3);
                make.height.equalTo(self.mas_height);
                make.width.equalTo(self.mas_height);
                make.top.equalTo(self.mas_top);
            }];
            prevLayoutItem = btnNewUrl;
        }
        
        [prevLayoutItem mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right);
        }];
    }
    return self;
}

- (void)setShowQRCode:(BOOL)showQRCode
{
    _showQRCode = showQRCode;
    if (showQRCode) {
        _textField.leftView = _showQRButton;
        _textField.leftViewMode = UITextFieldViewModeUnlessEditing;
        CGFloat size = _textField.frame.size.height - 4;
        _showQRButton.frame = CGRectMake(0, 0, size, size);
    } else {
        _textField.leftView = nil;
        _textField.leftViewMode = UITextFieldViewModeNever;
    }
}

@end
