//
//  SDKIntroViewController.h
//  TXXiaoShiPinDemo
//
//  Created by shengcui on 2018/8/31.
//  Copyright © 2018年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
@import WebKit;

@interface TCLVBWebViewController : UIViewController <WKNavigationDelegate>
@property (strong, nonatomic) WKWebView *webView;
- (instancetype)initWithURL:(NSString *)url;
@end
