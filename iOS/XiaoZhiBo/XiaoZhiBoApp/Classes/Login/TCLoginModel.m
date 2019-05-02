//
//  TCLoginModel.m
//  TCLVBIMDemo
//
//  Created by dackli on 16/8/3.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "TCLoginModel.h"
#import "MLVBLiveRoomDef.h"
#import "TCUserInfoModel.h"
#import "TCLiveListModel.h"
#import "TCConstants.h"
#import "TCUtil.h"
#ifndef APP_EXT
#import "AppDelegate.h"
#endif
#import "AFNetworking.h"
#import "NSString+Common.h"

#define kAutoLoginKey         @"kAutoLoginKey"
#define kEachKickErrorCode    6208   //互踢下线错误码


@interface TCLoginModel()
{
    TCLoginParam *_loginParam;

}
@property (nonatomic, copy) NSString* refreshToken;
@property (nonatomic, assign) int64_t expires;
@property (nonatomic, strong) NSDate *expireTime;
@property (nonatomic, copy) NSString* sign;
@property (nonatomic, copy) NSString* txTime;
@property (nonatomic, copy) NSString* accountType;
@property (nonatomic, assign) int sdkAppID;
@end

@implementation TCLoginModel

static TCLoginModel *_sharedInstance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _sharedInstance = [[TCLoginModel alloc] init];
    });
    return _sharedInstance;
}


+ (BOOL)isAutoLogin {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP];
    if (defaults == nil) {
        defaults = [NSUserDefaults standardUserDefaults];
    }
    NSNumber *num = [defaults objectForKey:kAutoLoginKey];
    return [num boolValue];
}

+ (void)setAutoLogin:(BOOL)autoLogin {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP];
    if (defaults == nil) {
        defaults = [NSUserDefaults standardUserDefaults];
    }
    [defaults setObject:@(autoLogin) forKey:kAutoLoginKey];
}

- (void)registerWithUsername:(NSString *)username password:(NSString *)password succ:(TCRegistSuccess)succ fail:(TCRegistFail)fail
{
    NSString* pwdMD5 = [password md5];
    NSString* hashPwd = [[pwdMD5 stringByAppendingString:username] md5];
    
    NSDictionary* params = @{@"userid": username, @"password": hashPwd};
    
    [TCUtil asyncSendHttpRequest:@"register" params:params handler:^(int resultCode, NSString *message, NSDictionary *resultDict) {
        NSLog(@"%d, %@, %@", resultCode, message, resultDict.description);
        if (resultCode == 200) {
            succ(username, hashPwd);
            [TCUtil report:xiaozhibo_register userName:username code:0 msg:@"注册成功"];
        }
        else {
            fail(resultCode, message);
            if (resultCode == 610 ) {
                [TCUtil report:xiaozhibo_register userName:username code:-1 msg:@"用户名格式错误"];
            } else if(resultCode == 611){
                [TCUtil report:xiaozhibo_register userName:username code:-2 msg:@"密码格式错误"];
            } else {
                [TCUtil report:xiaozhibo_register userName:username code:-3 msg:@"用户已存在"];
            }
        }
    }];
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password succ:(TCLoginSuccess)succ fail:(TCLoginFail)fail
{
    NSString* pwdMD5 = [password md5];
    NSString* hashPwd = [[pwdMD5 stringByAppendingString:username] md5];
    
    [self loginByToken:username hashPwd:hashPwd succ:succ fail:fail];
}

- (void)loginByToken:(NSString*)username hashPwd:(NSString*)hashPwd succ:(TCLoginSuccess)succ fail:(TCLoginFail)fail
{
    NSDictionary* params = @{@"userid": username, @"password": hashPwd};
    __weak typeof(self) weakSelf = self;

    [TCUtil asyncSendHttpRequest:@"login" params:params handler:^(int resultCode, NSString *message, NSDictionary *resultDict) {
        if (resultCode == 200) {
            weakSelf.token = resultDict[@"token"];
            weakSelf.expires = ((NSNumber*)resultDict[@"expires"]).unsignedLongLongValue;
            weakSelf.expireTime = [NSDate dateWithTimeIntervalSinceNow:weakSelf.expires];
            weakSelf.refreshToken = resultDict[@"refresh_token"];
            if (resultDict[@"roomservice_sign"]) {
                weakSelf.sign = resultDict[@"roomservice_sign"][@"userSig"];
                weakSelf.accountType = resultDict[@"roomservice_sign"][@"accountType"];
                weakSelf.sdkAppID = ((NSNumber*)resultDict[@"roomservice_sign"][@"sdkAppID"]).intValue;
            }
            
            if (resultDict[@"cos_info"]) {
                [[TCUserInfoModel sharedInstance] setBucket:resultDict[@"cos_info"][@"Bucket"] secretId:resultDict[@"cos_info"][@"SecretId"]
                                        appid:[resultDict[@"cos_info"][@"Appid"] longValue] region:resultDict[@"cos_info"][@"Region"] accountType:weakSelf.accountType];
            }

            _loginParam = [TCLoginParam new];
            _loginParam.identifier = username;
            _loginParam.hashedPwd = hashPwd;

            [TCLoginModel setAutoLogin:YES];
            [[TCUserInfoModel sharedInstance] setIdentifier:username expires:@(weakSelf.expires) token:weakSelf.token completion:^(int code, NSString *errMsg, NSString *nickname, NSString *avatar) {
                [[TCLiveListMgr sharedMgr] setUserId:username expires:@(weakSelf.expires) token:weakSelf.token];
                
                MLVBLoginInfo* loginInfo = [MLVBLoginInfo new];
                loginInfo.sdkAppID = weakSelf.sdkAppID;
                loginInfo.userID = username;
                loginInfo.userName = nickname;
                NSString *userAvatar = avatar;
                loginInfo.userAvatar = (userAvatar == nil ? @"" : userAvatar);
                loginInfo.userSig = weakSelf.sign;
                [[MLVBLiveRoom sharedInstance] loginWithInfo:loginInfo completion:^(int errCode, NSString *errMsg) {
                    NSLog(@"errCode:%d, errMsg:%@", errCode, errMsg);
                    if (errCode == ROOM_SUCCESS) {
                        succ(username, hashPwd);
                    }
                    else {
                        fail(errCode, errMsg);
                    }
                }];
                [TCUtil report:xiaozhibo_login userName:username code:0 msg:@"登录成功"];
            }];
        } else {
            fail(resultCode, message);
            if (resultCode == 620) {
                [TCUtil report:xiaozhibo_login userName:username code:-1 msg:@"用户不存在"];
            } else {
                [TCUtil report:xiaozhibo_login userName:username code:-2 msg:@"密码错误"];
            }
        }
    }];
}

- (void)reLoginIfNeeded:(TCLoginSuccess)succ fail:(TCLoginFail)fail {
    if ([self.expireTime timeIntervalSinceNow] < 60) {
        [self reLogin:succ fail:fail];
    } else {
        if (succ) {
            succ(_loginParam.identifier, _loginParam.hashedPwd);
        }
    }
}

- (void)reLogin:(TCLoginSuccess)succ fail:(TCLoginFail)fail {
    if (_loginParam == nil) {
        if (fail) {
            fail(kError_InvalidParam, @"参数错误");
        }
        return;
    }
    
    [self loginByToken:_loginParam.identifier hashPwd:_loginParam.hashedPwd succ:^(NSString *userName, NSString *md5pwd) {
        DebugLog(@"relogin success,id:%@", _loginParam.identifier);
        if (succ) {
            succ(_loginParam.identifier, nil);
        }
    } fail:^(int errCode, NSString *errMsg) {
        DebugLog(@"relogin failed,code:%d, msg:%@", errCode, errMsg);
        if (fail) {
            fail(errCode, errMsg);
        }
    }];
}

- (void)logout:(TCLogoutComplete)completion {
    [TCLoginModel setAutoLogin:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:logoutNotification object:nil];
    if (completion) {
        completion();
    }
    self.token = nil;
    self.refreshToken = nil;
    self.sign = nil;
    self.expires = 0;
    self.txTime = nil;
}

- (TCLoginParam *)getLoginParam {
    if (_loginParam) {
        return _loginParam;
    }
    return [[TCLoginParam alloc] init];
}

- (void)getCosSign:(void (^)(int, NSString *, NSDictionary *))completion
{
    NSDictionary* params = @{@"userid": _loginParam.identifier, @"timestamp":@([[NSDate date] timeIntervalSince1970] * 1000), @"expires":@(self.expires)};
    
    [TCUtil asyncSendHttpRequest:@"get_cos_sign" token:self.token params:params handler:^(int resultCode, NSString *message, NSDictionary *resultDict) {
        completion(resultCode, message, resultDict);
    }];
}

- (void)getVodSign:(void (^)(int, NSString *, NSDictionary *))completion
{
    NSDictionary* params = @{@"userid": _loginParam.identifier, @"timestamp":@([[NSDate date] timeIntervalSince1970] * 1000), @"expires":@(self.expires)};
    [TCUtil asyncSendHttpRequest:@"get_vod_sign" token:self.token params:params handler:^(int resultCode, NSString *message, NSDictionary *resultDict) {
        completion(resultCode, message, resultDict);
    }];
}

- (void)uploadUGC:(NSDictionary *)params completion:(void (^)(int, NSString *, NSDictionary *))completion
{
    NSDictionary* hparams = @{@"userid": _loginParam.identifier, @"timestamp":@([[NSDate date] timeIntervalSince1970] * 1000), @"expires":@(self.expires)};

    NSMutableDictionary* mparams = [NSMutableDictionary dictionaryWithDictionary:hparams];
    [mparams addEntriesFromDictionary:params];
    
    [TCUtil asyncSendHttpRequest:@"upload_ugc" token:self.token params:mparams handler:^(int resultCode, NSString *message, NSDictionary *resultDict) {
        completion(resultCode, message, resultDict);
    }];
}

@end
