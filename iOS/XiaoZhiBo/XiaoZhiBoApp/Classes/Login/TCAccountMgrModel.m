/**
 * Module: TCAccountMgrModel
 *
 * Function: 账号管理模块
 */

#import "TCAccountMgrModel.h"
#import "MLVBLiveRoomDef.h"
#import "TCUserProfileModel.h"
#import "TCRoomListModel.h"
#import "TCGlobalConfig.h"
#import "TCUtil.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "NSString+Common.h"

#define kLoginParamKey        @"kLoginParamKey"
#define kAutoLoginKey         @"kAutoLoginKey"
#define kEachKickErrorCode    6208   //互踢下线错误码


@implementation TCLoginParam

+ (instancetype)shareInstance {
    static TCLoginParam *mgr;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (mgr == nil) {
            NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP];
            if (defaults == nil) {
                defaults = [NSUserDefaults standardUserDefaults];
            }
            NSString *useridKey = [defaults objectForKey:kLoginParamKey];
            if (useridKey) {
                NSString *strLoginParam = [defaults objectForKey:useridKey];
                NSDictionary *dic = [TCUtil jsonData2Dictionary: strLoginParam];
                if (dic) {
                    mgr = [[TCLoginParam alloc] init];
                    mgr.tokenTime = [[dic objectForKey:@"tokenTime"] longValue];
                    mgr.identifier = [dic objectForKey:@"identifier"];
                    mgr.hashedPwd = [dic objectForKey:@"hashedPwd"];
                    mgr.isLastAppExt = [[dic objectForKey:@"isLastAppExt"] intValue];
                }
            }
        }
    });
    return mgr;
}

+ (instancetype)loadFromLocal {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP];
    if (defaults == nil) {
        defaults = [NSUserDefaults standardUserDefaults];
    }
    NSString *useridKey = [defaults objectForKey:kLoginParamKey];
    if (useridKey) {
        NSString *strLoginParam = [defaults objectForKey:useridKey];
        NSDictionary *dic = [TCUtil jsonData2Dictionary: strLoginParam];
        if (dic) {
            TCLoginParam *param = [[TCLoginParam alloc] init];
            param.tokenTime = [[dic objectForKey:@"tokenTime"] longValue];
            param.identifier = [dic objectForKey:@"identifier"];
            param.hashedPwd = [dic objectForKey:@"hashedPwd"];
            param.isLastAppExt = [[dic objectForKey:@"isLastAppExt"] intValue];
            return param;
        }
    }
    return [[TCLoginParam alloc] init];
}

- (void)saveToLocal {
    if (self.tokenTime == 0) {
        self.tokenTime = [[NSDate date] timeIntervalSince1970];
    }
    
    if (![self isValid]) {
        return;
    }
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@(self.tokenTime) forKey:@"tokenTime"];
    [dic setObject:self.identifier forKey:@"identifier"];
    [dic setObject:self.hashedPwd forKey:@"hashedPwd"];
#if APP_EXT
    [dic setObject:@(1) forKey:@"isLastAppExt"];
#else
    [dic setObject:@(0) forKey:@"isLastAppExt"];
#endif
    
    NSData *data = [TCUtil dictionary2JsonData: dic];
    NSString *strLoginParam = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *useridKey = [NSString stringWithFormat:@"%@_LoginParam", self.identifier];
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP];
    if (defaults == nil) {
        defaults = [NSUserDefaults standardUserDefaults];
    }
    
    [defaults setObject:useridKey forKey:kLoginParamKey];
    
    // save login param
    [defaults setObject:strLoginParam forKey:useridKey];
    [defaults synchronize];
}

- (BOOL)isExpired {
    //    time_t curTime = [[NSDate date] timeIntervalSince1970];
    //    if (curTime - self.tokenTime > 10 * 24 * 3600) {
    //        return YES;
    //    }
    return NO;
}

- (BOOL)isValid {
    if (self.identifier == nil || self.identifier.length == 0) {
        return NO;
    }
    if (self.hashedPwd == nil || self.hashedPwd.length == 0) {
        return NO;
    }
    if ([self isExpired]) {
        return NO;
    }
    return YES;
}

@end


@interface TCAccountMgrModel()

@property (nonatomic, strong) TCLoginParam *loginParam;
@property (nonatomic, copy) NSString* refreshToken;
@property (nonatomic, assign) int64_t expires;
@property (nonatomic, strong) NSDate *expireTime;
@property (nonatomic, copy) NSString* sign;
@property (nonatomic, copy) NSString* txTime;
@property (nonatomic, copy) NSString* accountType;
@property (nonatomic, assign) int sdkAppID;

@end

@implementation TCAccountMgrModel

static TCAccountMgrModel *_sharedInstance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _sharedInstance = [[TCAccountMgrModel alloc] init];
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

- (void)registerWithUsername:(NSString *)username password:(NSString *)password succ:(TCRegistSuccess)succ fail:(TCRegistFail)fail {
    NSString* pwdMD5 = [password md5];
    NSString* hashPwd = [[pwdMD5 stringByAppendingString:username] md5];
    
    NSDictionary* params = @{@"userid": username, @"password": hashPwd};
    
    [TCUtil asyncSendHttpRequest:@"register" params:params handler:^(int resultCode, NSString *message, NSDictionary *resultDict) {
        NSLog(@"%d, %@, %@", resultCode, message, resultDict.description);
        if (resultCode == 200) {
            succ(username, hashPwd);
        }
        else {
            int code = resultCode;
            NSString *msg = message;
            
            if (resultCode == 610) {
                code = -1;
                msg = @"用户名格式错误";
            } else if(resultCode == 611) {
                code = -2;
                msg = @"密码格式错误";
            } else if (resultCode == 612) {
                code = -3;
                msg = @"用户已存在";
            }
            
            fail(code, msg);
        }
    }];
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password succ:(TCLoginSuccess)succ fail:(TCLoginFail)fail {
    NSString* pwdMD5 = [password md5];
    NSString* hashPwd = [[pwdMD5 stringByAppendingString:username] md5];
    
    [self loginByToken:username hashPwd:hashPwd succ:succ fail:fail];
}

- (void)loginByToken:(NSString*)username hashPwd:(NSString*)hashPwd succ:(TCLoginSuccess)succ fail:(TCLoginFail)fail {
    NSDictionary* params = @{@"userid": username, @"password": hashPwd};
    __weak typeof(self) weakSelf = self;

    [TCUtil asyncSendHttpRequest:@"login" params:params handler:^(int resultCode, NSString *message, NSDictionary *resultDict) {
        __strong typeof(weakSelf) self = weakSelf;
        
        if (resultCode == 200) {
            self.token = resultDict[@"token"];
            self.expires = ((NSNumber*)resultDict[@"expires"]).unsignedLongLongValue;
            self.expireTime = [NSDate dateWithTimeIntervalSinceNow:self.expires];
            self.refreshToken = resultDict[@"refresh_token"];
            if (resultDict[@"roomservice_sign"]) {
                self.sign = resultDict[@"roomservice_sign"][@"userSig"];
                self.accountType = resultDict[@"roomservice_sign"][@"accountType"];
                self.sdkAppID = ((NSNumber*)resultDict[@"roomservice_sign"][@"sdkAppID"]).intValue;
            }
            
            if (resultDict[@"cos_info"]) {
                [[TCUserProfileModel sharedInstance] setBucket:resultDict[@"cos_info"][@"Bucket"] secretId:resultDict[@"cos_info"][@"SecretId"]
                                        appid:[resultDict[@"cos_info"][@"Appid"] longValue] region:resultDict[@"cos_info"][@"Region"] accountType:self.accountType];
            }

            self.loginParam = [TCLoginParam new];
            self.loginParam.identifier = username;
            self.loginParam.hashedPwd = hashPwd;

            [TCAccountMgrModel setAutoLogin:YES];
            [[TCUserProfileModel sharedInstance] setIdentifier:username expires:@(self.expires) token:self.token completion:^(int code, NSString *errMsg, NSString *nickname, NSString *avatar) {
                [[TCRoomListMgr sharedMgr] setUserId:username expires:@(self.expires) token:self.token];
                
                MLVBLoginInfo* loginInfo = [MLVBLoginInfo new];
                loginInfo.sdkAppID = self.sdkAppID;
                loginInfo.userID = username;
                loginInfo.userName = nickname;
                NSString *userAvatar = avatar;
                loginInfo.userAvatar = (userAvatar == nil ? @"" : userAvatar);
                loginInfo.userSig = self.sign;
                [[MLVBLiveRoom sharedInstance] loginWithInfo:loginInfo completion:^(int errCode, NSString *errMsg) {
                    NSLog(@"errCode:%d, errMsg:%@", errCode, errMsg);
                    if (errCode == ROOM_SUCCESS) {
                        succ(username, hashPwd);
                    }
                    else {
                        fail(errCode, errMsg);
                    }
                }];
            }];
        } else {
            int code = resultCode;
            NSString *msg = message;
            
            if (resultCode == 620) {
                code = -1;
                msg = @"用户不存在";
            } else if (resultCode == 621) {
                code = -2;
                msg = @"密码错误";
            }
            
            fail(code, msg);
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
    
    __weak __typeof(self) weakSelf = self;
    [self loginByToken:_loginParam.identifier hashPwd:_loginParam.hashedPwd succ:^(NSString *userName, NSString *md5pwd) {
        __strong __typeof(weakSelf) self = weakSelf;
        if (self == nil) {
            return;
        }
        
        DebugLog(@"relogin success,id:%@", self->_loginParam.identifier);
        if (succ) {
            succ(self->_loginParam.identifier, nil);
        }
    } fail:^(int errCode, NSString *errMsg) {
        DebugLog(@"relogin failed,code:%d, msg:%@", errCode, errMsg);
        if (fail) {
            fail(errCode, errMsg);
        }
    }];
}

- (void)logout:(TCLogoutComplete)completion {
    [TCAccountMgrModel setAutoLogin:NO];
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

- (void)getCosSign:(void (^)(int, NSString *, NSDictionary *))completion {
    NSDictionary* params = @{@"userid": _loginParam.identifier, @"timestamp":@([[NSDate date] timeIntervalSince1970] * 1000), @"expires":@(self.expires)};
    
    [TCUtil asyncSendHttpRequest:@"get_cos_sign" token:self.token params:params handler:^(int resultCode, NSString *message, NSDictionary *resultDict) {
        completion(resultCode, message, resultDict);
    }];
}

- (void)getVodSign:(void (^)(int, NSString *, NSDictionary *))completion {
    NSDictionary* params = @{@"userid": _loginParam.identifier, @"timestamp":@([[NSDate date] timeIntervalSince1970] * 1000), @"expires":@(self.expires)};
    [TCUtil asyncSendHttpRequest:@"get_vod_sign" token:self.token params:params handler:^(int resultCode, NSString *message, NSDictionary *resultDict) {
        completion(resultCode, message, resultDict);
    }];
}

- (void)uploadUGC:(NSDictionary *)params completion:(void (^)(int, NSString *, NSDictionary *))completion {
    NSDictionary* hparams = @{@"userid": _loginParam.identifier, @"timestamp":@([[NSDate date] timeIntervalSince1970] * 1000), @"expires":@(self.expires)};

    NSMutableDictionary* mparams = [NSMutableDictionary dictionaryWithDictionary:hparams];
    [mparams addEntriesFromDictionary:params];
    
    [TCUtil asyncSendHttpRequest:@"upload_ugc" token:self.token params:mparams handler:^(int resultCode, NSString *message, NSDictionary *resultDict) {
        completion(resultCode, message, resultDict);
    }];
}

@end
