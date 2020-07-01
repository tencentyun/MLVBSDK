/**
 * Module: TCLoginViewController
 *
 * Function: 登录界面
 */

#import "TCLoginViewController.h"
#import "TCAccountMgrModel.h"
#import "TCUtil.h"
#import "TCAccountMgrModel.h"
#import "TCRegisterViewController.h"
#import "UIView+CustomAutoLayout.h"
#import "HUDHelper.h"
#import "TCRegisterViewController.h"
#import "TCUserProfileModel.h"
#import "TCWechatInfoView.h"
#import "AppDelegate.h"

@interface TCLoginViewController () <UITextFieldDelegate,TCLoginDelegate>
{
    TCLoginParam *_loginParam;

    UILabel        *_accountLabel;
    UITextField    *_accountTextField;  // 用户名/手机号
    UILabel        *_pwdLabel;
    UITextField    *_pwdTextField;      // 密码/验证码
    UIButton       *_loginBtn;          // 登录
    UIButton       *_regBtn;            // 注册
    TCWechatInfoView *_wechatInfoView;    // 公众号信息
    UIView         *_lineView1;
    UIView         *_lineView2;
    UIImageView    *_logoView;
    
    BOOL           _isSMSLoginType;     // YES 表示手机号登录，NO 表示用户名登录
}
@end

@implementation TCLoginViewController

- (void)dealloc {
    if (_loginParam) {
        // 持久化param
        [_loginParam saveToLocal];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    // 先判断是否自动登录
    BOOL isAutoLogin = [TCAccountMgrModel isAutoLogin];
    if (isAutoLogin) {
        _loginParam = [TCLoginParam loadFromLocal];
    }
    else {
        _loginParam = [[TCLoginParam alloc] init];
    }
    
    if (isAutoLogin && [_loginParam isValid]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self autoLogin];
        });
    }
    else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self pullLoginUI];
        });
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - login

- (void)autoLogin {
    if (![_loginParam isExpired]) {
        // 刷新票据
        [[HUDHelper sharedInstance] syncLoading];
        [[TCAccountMgrModel sharedInstance] loginByToken:_loginParam.identifier hashPwd:_loginParam.hashedPwd succ:^(NSString *userName, NSString *md5pwd) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[HUDHelper sharedInstance] syncStopLoading];
                [[AppDelegate sharedInstance] enterMainUI];
            });
            
        } fail:^(int errCode, NSString *errMsg) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[HUDHelper sharedInstance] syncStopLoading];
                NSLog(@"自动登录失败%s %d %@", __func__, errCode, errMsg);
                [self pullLoginUI];
            });
        }];
    }
    else {
        [self pullLoginUI];
    }
}

- (void)pullLoginUI {
    [self setupUI];
}

- (void)setupUI {
    [super viewDidLoad];

    _isSMSLoginType = NO;
    [self initUI];

    UITapGestureRecognizer *tag = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickScreen)];
    [self.view addGestureRecognizer:tag];
}

- (void)initUI {
    _logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cloud_logo"]];
    [self.view addSubview:_logoView];
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
    _accountTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入用户名" attributes:@{NSForegroundColorAttributeName: fieldColor}];
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
    _pwdTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"输入密码" attributes:@{NSForegroundColorAttributeName: fieldColor}];
    _pwdTextField.secureTextEntry = YES;

    _lineView1 = [[UIView alloc] init];
    _lineView1.height = 1;
    [_lineView1 setBackgroundColor:labelColor];
    
    _lineView2 = [[UIView alloc] init];
    _lineView2.height = 1;
    [_lineView2 setBackgroundColor:labelColor];
    
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
    _loginBtn = createButton(@"登录", @selector(login:));
    
    _regBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _regBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_regBtn setTitle:@"新用户注册" forState:UIControlStateNormal];
    [_regBtn sizeToFit];
    _regBtn.height = 44;
    [_regBtn addTarget:self action:@selector(reg:) forControlEvents:UIControlEventTouchUpInside];
    [_regBtn setTitleColor: [UIColor colorWithRed:51/255.0 green:139/255.0 blue:255/255.0 alpha:1.0] forState:UIControlStateNormal];
    TCWechatInfoView *infoView = [[TCWechatInfoView alloc] initWithFrame:CGRectMake(10, _regBtn.bottom+20, self.view.width - 20, 100)];
    _wechatInfoView = infoView;

    [self.view addSubview:_accountLabel];
    [self.view addSubview:_accountTextField];
    [self.view addSubview:_lineView1];
    [self.view addSubview:_pwdLabel];
    [self.view addSubview:_pwdTextField];
    [self.view addSubview:_lineView2];
    [self.view addSubview:_regBtn];
    [self.view addSubview:_loginBtn];
    [self.view addSubview:infoView];
    
    [self relayout];
}

- (void)relayout {
    CGFloat screen_width = self.view.bounds.size.width;
    const CGFloat HPadding = 15;
    const CGFloat ControlWidth = screen_width - 2 * HPadding;
    
    _logoView.center = CGPointMake(self.view.width / 2, [UIApplication sharedApplication].statusBarFrame.size.height + 49);
    
    _accountLabel.top = 97;
    _accountLabel.left = HPadding;
    
    _accountTextField.size = CGSizeMake(ControlWidth, 33);
    _accountTextField.left = 15;
    _accountTextField.top = _accountLabel.bottom + 20;
    
    _lineView1.top = _accountTextField.bottom + 6;
    _lineView1.left = HPadding;
    _lineView1.width = ControlWidth;
    
    
    _pwdLabel.top = _lineView1.bottom + 30;
    _pwdLabel.left = HPadding;
    
    _pwdTextField.top = _pwdLabel.bottom + 20;
    _pwdTextField.left = HPadding;
    if (_isSMSLoginType) {
        [_pwdTextField setSize:CGSizeMake(150, 33)];
    } else {
        [_pwdTextField setSize:CGSizeMake(ControlWidth, 33)];
    }

    _lineView2.top = _pwdTextField.bottom + 6;
    _lineView2.left = HPadding;
    _lineView2.width = ControlWidth;

    _regBtn.top = _lineView2.bottom + 5;
    _regBtn.right = _lineView2.right;

    _loginBtn.top = _lineView2.bottom + 89;
    _loginBtn.left = HPadding;
    _loginBtn.width = ControlWidth;

    _wechatInfoView.top = _loginBtn.bottom + 30;
}

- (void)clickScreen {
    [_accountTextField resignFirstResponder];
    [_pwdTextField resignFirstResponder];
}

- (void)reg:(UIButton *)button {
    TCRegisterViewController *regViewController = [[TCRegisterViewController alloc] init];
    regViewController.delegate = self;
    [self.navigationController pushViewController:regViewController animated:YES];
}

- (void)switchLoginWay:(UIButton *)button {
    _isSMSLoginType = !_isSMSLoginType;
    [self clickScreen];
    [self relayout];
}

- (void)login:(UIButton *)button {
    NSString *userName = _accountTextField.text;
    if (userName == nil || [userName length] == 0) {
        [HUDHelper alertTitle:@"用户名错误" message:@"用户名不能为空" cancel:@"确定"];
        return;
    }
    NSString *pwd = _pwdTextField.text;
    if (pwd == nil || [pwd length] == 0) {
        [HUDHelper alertTitle:@"密码错误" message:@"密码不能为空" cancel:@"确定"];
        return;
    }
    
    // 用户名密码登录
    __weak typeof(self) weakSelf = self;
    [self clickScreen];
    [[HUDHelper sharedInstance] syncLoading];
    [[TCAccountMgrModel sharedInstance] loginWithUsername:userName password:pwd succ:^(NSString *userName, NSString *md5pwd) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[HUDHelper sharedInstance] syncStopLoading];
            
            __strong typeof(weakSelf) self = weakSelf;
            if (self) {
                [self loginSuccess:userName hashedPwd:md5pwd];
            }
        });

    } fail:^(int errCode, NSString *errMsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[HUDHelper sharedInstance] syncStopLoading];
            [HUDHelper alertTitle:@"登录失败" message:errMsg cancel:@"确定"];
            NSLog(@"%s %d %@", __func__, errCode, errMsg);
        });
    }];
}

- (void)loginSuccess:(NSString*)userName hashedPwd:(NSString*)hashedPwd {
    // 进入主界面
    _loginParam.identifier = userName;
    _loginParam.hashedPwd = hashedPwd;
    [_loginParam saveToLocal];
    [[AppDelegate sharedInstance] enterMainUI];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
