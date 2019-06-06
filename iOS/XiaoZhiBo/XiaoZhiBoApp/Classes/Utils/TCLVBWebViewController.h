/**
 * Module: TCLVBWebViewController
 *
 * Function: 简易浏览器。
 *         因为直接用浏览器打开官网页面包含了”购买“关键词，可能导致小直播无法上架，
 *         所以该类对页面做了特殊处理，去掉了”购买”等关键词
 */

#import <UIKit/UIKit.h>
@import WebKit;

@interface TCLVBWebViewController : UIViewController <WKNavigationDelegate>
@property (strong, nonatomic) WKWebView *webView;
- (instancetype)initWithURL:(NSString *)url;
@end
