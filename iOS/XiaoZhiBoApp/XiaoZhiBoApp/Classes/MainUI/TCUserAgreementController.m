/**
 * Module: TCUserAgreementController
 *
 * Function: 用户条款
 */

#import "TCUserAgreementController.h"
#import "UIView+Additions.h"
#import "AppDelegate.h"
#import "TCAccountMgrModel.h"
#import "ColorMacro.h"
#import "TCGlobalConfig.h"

@implementation TCUserAgreementController
{
    UIWebView *_webView;
    NSLock *_lock;
    NSString *_htmlContent;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self loadResourceInBackground];
    }
    return self;
}

- (void)loadResourceInBackground {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0), ^{
        [self->_lock lock];
        NSString * htmlPath = [[NSBundle mainBundle] pathForResource:@"UserProtocol"
                                                              ofType:@"html"];
        self->_htmlContent = [NSString stringWithContentsOfFile:htmlPath
                                                        encoding:NSUTF8StringEncoding
                                                           error:nil];
        [self->_lock unlock];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self isViewLoaded]) {
                NSString *path = [[NSBundle mainBundle] bundlePath];
                NSURL *baseURL = [NSURL fileURLWithPath:path];
                [self->_webView loadHTMLString:self->_htmlContent baseURL:baseURL];
            }
        });
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat bottom = 0;
    if (@available(iOS 11, *)) {
        bottom = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    }
    
    self.title = @"用户协议";
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - 50 - bottom)];
    [self.view addSubview:_webView];
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    [_lock lock];
    [_webView loadHTMLString:_htmlContent baseURL:baseURL];
    [_lock unlock];
    
    UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - 50 - bottom, self.view.width, 0.5)];
    lineView1.backgroundColor = [UIColor grayColor];
    [self.view addSubview:lineView1];
    
    UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(self.view.width/2,lineView1.bottom, 0.5, 49)];
    lineView2.backgroundColor = [UIColor grayColor];
    [self.view addSubview:lineView2];
    
    //同意
    UIButton *unAgreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    unAgreeBtn.frame = CGRectMake(0,lineView1.bottom, self.view.width/2, 49);
    [unAgreeBtn setTitle:@"不同意" forState:UIControlStateNormal];
    [unAgreeBtn setTitleColor:UIColorFromRGB(0x0ACCAC) forState:UIControlStateNormal];
    [unAgreeBtn addTarget:self action:@selector(unAgree) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:unAgreeBtn];
    
    //不同意
    UIButton *agreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    agreeBtn.frame = CGRectMake(self.view.width/2 + 1, lineView1.bottom, self.view.width/2, 49);
    [agreeBtn setTitle:@"同意" forState:UIControlStateNormal];
    [agreeBtn setTitleColor:UIColorFromRGB(0x0ACCAC) forState:UIControlStateNormal];
    [agreeBtn addTarget:self action:@selector(agree) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:agreeBtn];
}

- (void)unAgree {
    [[TCAccountMgrModel sharedInstance] logout:^{
        [[AppDelegate sharedInstance] enterLoginUI];
    }];
}

- (void)agree {
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:hasEnteredXiaoZhiBo];
    [[AppDelegate sharedInstance] enterMainUI];
}

@end
