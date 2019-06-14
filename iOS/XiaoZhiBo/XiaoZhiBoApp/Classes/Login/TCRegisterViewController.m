/**
 * Module: TCRegisterViewController
 *
 * Function: 注册界面
 */

#import "TCRegisterViewController.h"
#import "UIView+CustomAutoLayout.h"
#import "TCAccountMgrModel.h"
#import "TCWechatInfoView.h"
#import "HUDHelper.h"

#define L(X) NSLocalizedString((X), nil)

@interface TCRegisterViewController () <UITextFieldDelegate>

@end

@implementation TCRegisterViewController
{
    UILabel        *_accountLabel;
    UILabel        *_pwdLabel;
    UILabel        *_pwdConfirmLabel;
    
    UITextField    *_accountTextField;  // 用户名/手机号
    UITextField    *_pwdTextField;      // 密码/验证码
    UITextField    *_pwdConfirmField;     // 确认密码（用户名注册）
    TCWechatInfoView *_wechatInfoView;
    UIButton       *_regBtn;            // 注册
    UIView         *_lineView1;
    UIView         *_lineView2;
    UIView         *_lineView3;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"注册账号";
    self.view.backgroundColor = [UIColor whiteColor];
    [self initUI];
    
    UITapGestureRecognizer *tag = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickScreen)];
    [self.view addGestureRecognizer:tag];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
//    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
//    [self.navigationController.navigationBar setBackgroundColor:[UIColor clearColor]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES];
//    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
//    [self.navigationController.navigationBar setShadowImage:nil];
}

- (void)initUI {
//    UIImage *image = [UIImage imageNamed:@"loginBG.jpg"];
//    self.view.layer.contents = (id)image.CGImage;
    
    UIColor *labelColor = [UIColor colorWithRed:136/255.0 green:136/255.0 blue:136/255.0 alpha:1.0];
    UIColor *fieldColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    
    _accountLabel = [[UILabel alloc] init];
    _accountLabel.textColor = labelColor;
    _accountLabel.text = @"账号昵称";
    [_accountLabel sizeToFit];
    
    _accountTextField = [[UITextField alloc] init];
    _accountTextField.font = [UIFont systemFontOfSize:14];
    _accountTextField.textColor = fieldColor;
    _accountTextField.returnKeyType = UIReturnKeyDone;
    _accountTextField.delegate = self;
    _accountTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"用户名为小写字母、数字、下划线" attributes:@{NSForegroundColorAttributeName: fieldColor}];
    _accountTextField.keyboardType = UIKeyboardTypeDefault;
    
    _pwdLabel = [[UILabel alloc] init];
    _pwdLabel.textColor = labelColor;
    _pwdLabel.text = @"账号密码";
    [_pwdLabel sizeToFit];
    
    _pwdTextField = [[UITextField alloc] init];
    _pwdTextField.font = [UIFont systemFontOfSize:14];
    _pwdTextField.textColor = fieldColor;
    _pwdTextField.returnKeyType = UIReturnKeyDone;
    _pwdTextField.delegate = self;
    _pwdTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"用户密码为8~16个字符" attributes:@{NSForegroundColorAttributeName: fieldColor}];
    _pwdTextField.secureTextEntry = YES;
    

    _pwdConfirmLabel = [[UILabel alloc] init];
    _pwdConfirmLabel.textColor = labelColor;
    _pwdConfirmLabel.text = @"密码确认";
    [_pwdConfirmLabel sizeToFit];
    
    _pwdConfirmField = [[UITextField alloc] init];
    _pwdConfirmField.font = [UIFont systemFontOfSize:14];
    _pwdConfirmField.textColor = fieldColor;
    _pwdConfirmField.secureTextEntry = YES;
    _pwdConfirmField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"确认密码" attributes:@{NSForegroundColorAttributeName: fieldColor}];

    _pwdConfirmField.returnKeyType = UIReturnKeyDone;
    _pwdConfirmField.delegate = self;
    
    _lineView1 = [[UIView alloc] init];
    _lineView1.height = 1;
    [_lineView1 setBackgroundColor:labelColor];
    
    _lineView2 = [[UIView alloc] init];
    _lineView2.height = 1;
    [_lineView2 setBackgroundColor:labelColor];

    _lineView3 = [[UIView alloc] init];
    _lineView3.height = 1;
    [_lineView3 setBackgroundColor:labelColor];

    UIButton *(^createButton)(NSString *title, SEL action) = ^(NSString *title, SEL action) {
        UIButton *button =[[UIButton alloc] init];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor colorWithRed:51/255.0 green:139/255.0 blue:255/255.0 alpha:1.0]];
        [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
        button.layer.cornerRadius = 10;
        button.height = 45;
        return button;
    };

    _regBtn = createButton(@"注册", @selector(reg:));
    
    TCWechatInfoView *infoView = [[TCWechatInfoView alloc] initWithFrame:CGRectMake(10, _regBtn.bottom+20, self.view.width - 20, 100)];
    _wechatInfoView = infoView;

    [self.view addSubview:_accountLabel];
    [self.view addSubview:_accountTextField];
    [self.view addSubview:_lineView1];
    
    [self.view addSubview:_pwdLabel];
    [self.view addSubview:_pwdTextField];
    [self.view addSubview:_lineView2];
    
    [self.view addSubview:_pwdConfirmLabel];
    [self.view addSubview:_pwdConfirmField];
    [self.view addSubview:_lineView3];
    
    [self.view addSubview:_regBtn];
    [self.view addSubview:infoView];
    
    [self relayout];
}

- (void)relayout {
    CGFloat screen_width = self.view.bounds.size.width;
    const CGFloat HPadding = 15;
    const CGFloat ControlWidth = screen_width - 2 * HPadding;

    _accountLabel.top = 97;
    _accountLabel.left = HPadding;
    
    _accountTextField.size = CGSizeMake(ControlWidth, 33);
    _accountTextField.left = 15;
    _accountTextField.top = _accountLabel.bottom + 20;
    
    _lineView1.top = _accountTextField.bottom + 6;
    _lineView1.left = HPadding;
    _lineView1.width = screen_width - 2 * HPadding;

    
    _pwdLabel.top = _lineView1.bottom + 30;
    _pwdLabel.left = HPadding;

    _pwdTextField.size = CGSizeMake(ControlWidth, 33);
    _pwdTextField.top = _pwdLabel.bottom + 20;
    _pwdTextField.left = HPadding;

    _lineView2.top = _pwdTextField.bottom + 6;
    _lineView2.left = HPadding;
    _lineView2.width = ControlWidth;
    
    
    _pwdConfirmLabel.top = _lineView2.top + 20;
    _pwdConfirmLabel.left = HPadding;
    
    _pwdConfirmField.size = CGSizeMake(ControlWidth, 33);
    _pwdConfirmField.top = _pwdConfirmLabel.bottom + 20;
    _pwdConfirmField.left = HPadding;
    
    _lineView3.top = _pwdConfirmField.bottom + 6;
    _lineView3.left = HPadding;
    _lineView3.width = ControlWidth;

    
    _regBtn.size = CGSizeMake(ControlWidth, 35);
    _regBtn.bottom = _lineView3.bottom + 89;
    _regBtn.left = HPadding;
    

    _wechatInfoView.top = _regBtn.bottom + 30;
}

- (void)clickScreen {
    [_accountTextField resignFirstResponder];
    [_pwdTextField resignFirstResponder];
    [_pwdConfirmField resignFirstResponder];
}

- (void)reg:(UIButton *)button {
    NSString *userName = _accountTextField.text;
    if (userName == nil || [userName length] == 0) {
        [HUDHelper alertTitle:@"用户名错误" message:@"用户名不能为空" cancel:@"确定"];
        return;
    }
    if ([userName length] < 4 || [userName length] > 24) {
        [HUDHelper alertTitle:@"用户名错误" message:@"用户名不能小于4位或者大于24位" cancel:@"确定"];
        return;
    }
    NSString *pattern = @"^[0-9]*$";
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray<NSTextCheckingResult *> *result = [regex matchesInString:userName options:NSMatchingReportCompletion range:NSMakeRange(0, userName.length)];
    if (result.count > 0) {
        [HUDHelper alertTitle:@"用户名错误" message:@"用户名不能是全数字" cancel:@"确定"];
        return;
    }
    
    pattern = @"[a-z0-9_]{4,24}$";
    regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    result = [regex matchesInString:userName options:NSMatchingReportCompletion range:NSMakeRange(0, userName.length)];
    if (result.count <= 0) {
        [HUDHelper alertTitle:@"用户名错误" message:@"用户名不符合规范" cancel:@"确定"];
        return;
    }
    
    NSString *pwd = _pwdTextField.text;
    if (pwd == nil || [pwd length] == 0) {
        [HUDHelper alertTitle:@"密码错误" message:@"密码不能为空" cancel:@"确定"];
        return;
    }
    if ([pwd length] < 8 || [pwd length] > 16) {
        [HUDHelper alertTitle:@"密码错误" message:@"密码必须为8到16位" cancel:@"确定"];
        return;
    }
    NSString *pwd2 = _pwdConfirmField.text;
    if ([pwd compare:pwd2] != NSOrderedSame) {
        [HUDHelper alertTitle:@"密码错误" message:@"两次密码不一致" cancel:@"确定"];
        return;
    }
    
    // 用户名密码注册
    __weak typeof(self) weakSelf = self;
    [[HUDHelper sharedInstance] syncLoading];
    [[TCAccountMgrModel sharedInstance] registerWithUsername:userName password:pwd succ:^(NSString *userName, NSString *md5pwd) {
        // 注册成功后直接登录
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TCAccountMgrModel sharedInstance] loginWithUsername:userName password:pwd succ:^(NSString *userName, NSString *md5pwd) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[HUDHelper sharedInstance] syncStopLoading];
                    
                    __strong typeof(weakSelf) self = weakSelf;
                    if (self) {
                        [self.delegate loginSuccess:userName hashedPwd:md5pwd];
                    }
                });
            } fail:^(int errCode, NSString *errMsg) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[HUDHelper sharedInstance] syncStopLoading];
                    [HUDHelper alertTitle:@"登录失败" message:errMsg cancel:@"确定"];
                    NSLog(@"%s %d %@", __func__, errCode, errMsg);
                });
            }];
        });
        
    } fail:^(int errCode, NSString *errMsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[HUDHelper sharedInstance] syncStopLoading];
            [HUDHelper alertTitle:@"注册失败" message:errMsg cancel:@"确定"];
            NSLog(@"%s %d %@", __func__, errCode, errMsg);
        });
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
