//
//  LiveRoomNewViewController.m
//  TXLiteAVDemo
//
//  Created by lijie on 2017/11/22.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import "LiveRoomNewViewController.h"
#import "UIView+Additions.h"
#import "ColorMacro.h"
#import "LiveRoomPusherViewController.h"

@interface LiveRoomNewViewController() <UITextFieldDelegate> {
    UILabel           *_tipLabel;
    UITextField       *_roomNameTextField;
    UIButton          *_createBtn;
}
@end

@implementation LiveRoomNewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"创建直播间";
    [self.view setBackgroundColor:UIColorFromRGB(0x333333)];
    
    _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 100, 200, 30)];
    _tipLabel.textColor = UIColorFromRGB(0x999999);
    _tipLabel.text = @"直播间名称";
    _tipLabel.textAlignment = NSTextAlignmentLeft;
    _tipLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:_tipLabel];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, 40)];
    _roomNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 136, self.view.width, 40)];
    _roomNameTextField.delegate = self;
    _roomNameTextField.leftView = paddingView;
    _roomNameTextField.leftViewMode = UITextFieldViewModeAlways;
    _roomNameTextField.placeholder = @"请输入直播间名称";
    _roomNameTextField.backgroundColor = UIColorFromRGB(0x4a4a4a);
    _roomNameTextField.textColor = UIColorFromRGB(0x939393);
    
    [self.view addSubview:_roomNameTextField];
    
    _createBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _createBtn.frame = CGRectMake(40, self.view.height - 70, self.view.width - 80, 50);
    _createBtn.layer.cornerRadius = 8;
    _createBtn.layer.masksToBounds = YES;
    _createBtn.layer.shadowOffset = CGSizeMake(1, 1);
    _createBtn.layer.shadowColor = UIColorFromRGB(0x019b5c).CGColor;
    _createBtn.layer.shadowOpacity = 0.8;
    _createBtn.backgroundColor = UIColorFromRGB(0x05a764);
    [_createBtn setTitle:@"开始直播" forState:UIControlStateNormal];
    [_createBtn addTarget:self action:@selector(onCreateBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_createBtn];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)onCreateBtnClicked:(UIButton *)sender {
    NSString *roomName = _roomNameTextField.text;
    if (roomName.length == 0) {
        [self alertTips:@"提示" msg:@"直播间名称不能为空"];
        return;
    }
    if (roomName.length > 30) {
        [self alertTips:@"提示" msg:@"直播间名称长度超过限制"];
        return;
    }
    
    LiveRoomPusherViewController *vc = [[LiveRoomPusherViewController alloc] init];
    vc.roomName = roomName;
    vc.userID   = _userID;
    vc.userName = _userName;
    vc.liveRoom = _liveRoom;
    _liveRoom.delegate = vc;
    [self.navigationController pushViewController:vc animated:YES];

}

- (void)alertTips:(NSString *)title msg:(NSString *)msg {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        
        [self.navigationController presentViewController:alertController animated:YES completion:nil];
    });
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_roomNameTextField resignFirstResponder];
}

@end
