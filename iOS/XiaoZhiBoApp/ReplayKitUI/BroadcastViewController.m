//
//  BroadcastViewController.m
//  TCLVBIMDemoUploadUI
//
//  Created by annidyfeng on 16/9/5.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "BroadcastViewController.h"
#import "TCConstants.h"
#import "TCLoginParam.h"
#import "TCUtil.h"
#import "TCLoginModel.h"
#import <ImSDK/ImSDK.h>
#import <TLSSDK/TLSHelper.h>
#import "TCUserInfoModel.h"


@implementation UITextFieldEx

- (void) drawPlaceholderInRect:(CGRect)rect {
    [[UIColor whiteColor] setFill];
    [[self placeholder] drawInRect:rect withFont:self.font
     lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
}

@end



@interface BroadcastViewController()<TLSRefreshTicketListener>

@end

@implementation BroadcastViewController {
    TCLoginParam *_loginParam;
    BOOL          _kickRetry;
    NSString     *_userid;
    NSString     *_groupid;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [self.view.backgroundColor colorWithAlphaComponent:0.8];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:)
                                                 name:UITextFieldTextDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    
    _loginParam = [TCLoginParam loadFromLocal];
    BOOL isAutoLogin = [TCLoginModel isAutoLogin];

    if (![_loginParam isValid] || !isAutoLogin) {
        [self onLoginFailed:@"您的帐号未登录，请先到小直播中登录"];
        return;
    }
    [[TCLoginModel sharedInstance] initIMSDK];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// Called when the user has finished interacting with the view controller and a broadcast stream can start
- (void)userDidFinishSetup:(NSString *)pushUrl {
    
    // Broadcast url that will be returned to the application
    NSURL *broadcastURL = [NSURL URLWithString:@"http://broadcastURL_example/stream1"];
    
    // Service specific broadcast data example which will be supplied to the process extension during broadcast
    if (_userid == nil) {
        _userid = @"";
    }
    if (_groupid == nil) {
        _groupid = @"";
    }
    
    CGSize sz = [[UIScreen mainScreen] bounds].size;
    
    NSString *endpointURL = pushUrl;
    NSDictionary *setupInfo = @{ @"userID" : _userid, @"groupID":_groupid, @"endpointURL" : endpointURL, @"rotate":@(sz.width>sz.height) };
    
    // Set broadcast settings
    RPBroadcastConfiguration *broadcastConfig = [[RPBroadcastConfiguration alloc] init];
    broadcastConfig.clipDuration = 5.0; // deliver movie clips every 5 seconds
    
    
    
    // Tell ReplayKit that the extension is finished setting up and can begin broadcasting
    [self.extensionContext completeRequestWithBroadcastURL:broadcastURL broadcastConfiguration:broadcastConfig setupInfo:setupInfo];
}

- (void)userDidCancelSetup {
    // Tell ReplayKit that the extension was cancelled by the user
    [self.extensionContext cancelRequestWithError:[NSError errorWithDomain:@"YourAppDomain" code:-1     userInfo:nil]];
}

- (IBAction)startBroadcast:(id)sender {
   
    BOOL isAutoLogin = [TCLoginModel isAutoLogin];
    if (![_loginParam isValid] || !isAutoLogin) {
        [self userDidCancelSetup];
        return;
    }
    
    [self autoLogin];
}

- (IBAction)cancelBroadcast:(id)sender {
    [self userDidCancelSetup];
}

- (void)textFieldDidChange:(NSNotification *)noti {
    self.startBtn.userInteractionEnabled = ([self.titleTextField.text length] != 0);
}

- (void)keyboardWillShow:(NSNotification *)sender
{
    CGFloat kMainScreenHeight = self.view.frame.size.height;
    CGSize kbSize = [[[sender userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    CGFloat newBottom = kMainScreenHeight - kbSize.height - 8;
    static CGFloat oldBottom, newTopOff;
    if (oldBottom == 0) {
        oldBottom = self.startBtn.frame.origin.y + self.startBtn.frame.size.height;
    }
    if (newTopOff == 0) {
        newTopOff = -(self.titleTextField.frame.origin.y-20);
    }
    
    self.startBtn.transform = CGAffineTransformMakeTranslation(0, newBottom - oldBottom);
    self.titleTextField.transform = CGAffineTransformMakeTranslation(0, newTopOff);
}

- (void)keyboardWillHide:(NSNotification *)sender
{
    NSTimeInterval duration = [[[sender userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        self.startBtn.transform = CGAffineTransformIdentity;
        self.titleTextField.transform = CGAffineTransformIdentity;
    }];
}

- (void)onLoginFailed:(NSString *)title {
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"错误"
                                 message:title
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"确认"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             //Do some thing here
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             [self userDidCancelSetup];
                         }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - login

- (void)autoLogin {
    if ([_loginParam isExpired]) {
        // 刷新票据
        [[TLSHelper getInstance] TLSRefreshTicket:_loginParam.identifier andTLSRefreshTicketListener:self];
    }
    else {
        [self loginIMSDK];
    }
}
#define kEachKickErrorCode    6208   //互踢下线错误码
- (void)loginIMSDK {
    __weak BroadcastViewController *weakSelf = self;
    
    [[TCLoginModel sharedInstance] login:_loginParam succ:^{
        [_loginParam saveToLocal];
        // 创建房间
        [weakSelf createRoom:self.titleTextField.text];
        _kickRetry = NO;
        
    } fail:^(int code, NSString *msg) {
        if (code == kEachKickErrorCode) {
            if (_kickRetry) {
                [self onLoginFailed:[NSString stringWithFormat:@"登录失败(%d)", code]];
                return;
            }
            _kickRetry = YES;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf loginIMSDK];
            });
        }
    }];
}

- (void)createRoom:(NSString *)title {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //创建群聊房间
        [[TIMGroupManager sharedInstance] CreateAVChatRoomGroup:@"live" succ:^(NSString *chatRoomID) {
            NSLog(@"主播创建聊天室成功, group id:%@", chatRoomID);
            _groupid = chatRoomID;
            _userid  = TC_PROTECT_STR(_loginParam.identifier);
            TCUserInfoData *userInfo = [[TCUserInfoModel sharedInstance] loadUserProfile];
            //从业务server申请推流地址
            NSDictionary* dictUser = @{@"nickname" : TC_PROTECT_STR(userInfo.nickName),
                                       @"headpic" : TC_PROTECT_STR(userInfo.faceURL),
                                       @"frontcover" : TC_PROTECT_STR(userInfo.coverURL),
                                       @"location" : @""};
            NSDictionary* dictParam = @{@"Action" : @"RequestLVBAddr",
                                        @"userid" : TC_PROTECT_STR(_loginParam.identifier),
                                        @"groupid" : TC_PROTECT_STR(chatRoomID),
                                        @"title" : TC_PROTECT_STR(title),
                                        @"userinfo" : dictUser};
            [TCUtil asyncSendHttpRequest:dictParam handler:^(int result, NSDictionary *resultDict) {
                if (result != 0)
                {
                    NSLog(@"主播创建聊天室失败, result:%d", result);
                    [self onLoginFailed:[NSString stringWithFormat:@"创建聊天室失败(%d)", result]];
                }
                else
                {
                    NSString* pusherUrl = nil;
                    if (resultDict)
                    {
                        pusherUrl = resultDict[@"pushurl"];
                        [self userDidFinishSetup:pusherUrl];
                    }
                }
            }];
            
        } fail:^(int code, NSString *error) {
            NSLog(@"主播创建聊天室失败, result:%d, error:%@", code, error);
            [self onLoginFailed:[NSString stringWithFormat:@"创建聊天室失败(%d)", code]];
        }];
    });
}

#pragma mark - 刷新票据代理

- (void)OnRefreshTicketSuccess:(TLSUserInfo *)userInfo {
    NSLog(@"OnRefreshTicketSuccess");
    [self loginWith:userInfo];
}

- (void)OnRefreshTicketFail:(TLSErrInfo *)errInfo {
    NSLog(@"OnRefreshTicketFail");
}

- (void)OnRefreshTicketTimeout:(TLSErrInfo *)errInfo {
    NSLog(@"OnRefreshTicketTimeout");
}

- (void)loginWith:(TLSUserInfo *)userInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (userInfo) {
            _loginParam.identifier = userInfo.identifier;
            _loginParam.userSig = [[TLSHelper getInstance] getTLSUserSig:userInfo.identifier];
            _loginParam.tokenTime = [[NSDate date] timeIntervalSince1970];
            
            [self loginIMSDK];
        }
    });
}
@end
