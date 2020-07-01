//
//  AddressBar.h
//  TXLiteAVDemo
//
//  Created by shengcui on 2018/6/14.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, AddressBarButtonOption) {
    AddressBarButtonOptionQRScan = 1,
    AddressBarButtonOptionNew = 1 << 1
};

@interface AddressBar : UIView
@property (strong, readonly, nonatomic) UITextField *textField;
@property (strong, readonly, nonatomic) UIButton *showQRButton;
@property (strong, readonly, nonatomic) UIButton *scanQRButton;
@property (strong, readonly, nonatomic) UIButton *createAddressButton;
@property (assign, nonatomic) BOOL showQRCode;
- (instancetype)initWithFrame:(CGRect)frame buttons:(AddressBarButtonOption)buttons;
@end
