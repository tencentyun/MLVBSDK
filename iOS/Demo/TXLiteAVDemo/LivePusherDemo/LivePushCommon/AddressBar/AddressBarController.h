//
//  AddressBarController.h
//  TXLiteAVDemo
//
//  Created by shengcui on 2018/6/14.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressBar.h"

@protocol AddressBarControllerDelegate;

/**
 UI组件: 显示地址栏、QR扫描、获取地址三个控件，并在地址栏上可以显示展示QR码的按钮，方便在其它设备上扫描对应地址
 */
@interface AddressBarController : NSObject
@property (readonly, nonatomic) AddressBar *view;
/// 界面上的控件事件回调处理对象
@property (weak, nonatomic) id<AddressBarControllerDelegate> delegate;
/// 设置后可以此View上展示QR码
@property (weak, nonatomic) UIView   *qrPresentView;
/// 地址栏内容
@property (copy, nonatomic) NSString *text;
/// 二维码内容, 每个字符串格式为 "标题,qr内容"
@property (strong, nonatomic) NSArray<NSString *>* qrStrings;

/**
 @param option 有AddressBarButtonOptionQRScan 和 AddressBarButtonOptionNew两个选项，用逻辑或来设置
 */
- (instancetype)initWithButtonOption:(AddressBarButtonOption)option;
@end

@protocol AddressBarControllerDelegate <NSObject>
@optional
- (void)addressBarControllerTapCreateURL:(AddressBarController *)controller;
- (void)addressBarControllerTapShowQR:(AddressBarController *)controller;
- (void)addressBarControllerTapScanQR:(AddressBarController *)controller;
- (BOOL)addressBarControllerTextFieldShouldReturn:(AddressBarController *)controller;
@end
