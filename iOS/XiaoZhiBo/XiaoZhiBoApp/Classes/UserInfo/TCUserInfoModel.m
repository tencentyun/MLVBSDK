//
//  TCUserInfoModel+TCUserInfoModel.m
//  TCLVBIMDemo
//
//  Created by jemilyzhou on 16/8/2.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "TCUserInfoModel.h"
#import "TCLoginModel.h"
#ifndef APP_EXT
#import <UIImageView+WebCache.h>
#endif
#import "TCConstants.h"
#import "TCUtil.h"
#define kUserInfoKey     @"kUserInfoKey"

static TCUserInfoModel *_shareInstance = nil;

@implementation TCUserInfoData

- (instancetype)init
{
    if (self = [super init])
    {
        
    }
    return self;
}
@end

@interface TCUserInfoModel()
{
}

@property(nonatomic, copy) NSString   *identifier;
@property(nonatomic, strong) NSNumber*       expires;
@property(nonatomic, copy) NSString*   token;
@property(nonatomic, strong) TCUserInfoData  *userInfo;
@end

@implementation TCUserInfoModel

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _userInfo   = [[TCUserInfoData alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
}

+ (instancetype)sharedInstance;
{
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        _shareInstance = [[TCUserInfoModel alloc] init];
    });
    return _shareInstance;
}
/**
 *  保存用户ID信息,并且注册回调通知,当收到登陆成功通知后拉取用户信息
 *  数据拉取成功后存入 userInfo  结构当中
 *
 *  @param identifier  用户ID信息
 */
- (void)setIdentifier:(NSString *)identifier expires:(NSNumber *)expires token:(NSString *)token completion:(void(^)(int code, NSString *errMsg, NSString *nickname, NSString *avatar))completion;
{
    _identifier = identifier;
    _expires = expires;
    _token = token;
#ifndef APP_EXT
    [self fetchUserInfo:completion];
#endif
}

- (void)setBucket:(NSString *)bucket secretId:(NSString*)secretId appid:(long)appid region:(NSString *)region accountType:(NSString *)accountType
{
    _userInfo.bucket = bucket;
    _userInfo.secretId = secretId;
    _userInfo.appid = [NSString stringWithFormat:@"%lu",appid];
    _userInfo.region = region;
    _userInfo.accountType = accountType;
}

#pragma mark 从服务器上拉取信息

#ifndef APP_EXT
/**
 *  通过id信息从服务器上拉取用户信息
 */
-(void)fetchUserInfo:(void(^)(int code, NSString *errMsg, NSString *nickname, NSString *avatar))completion
{
    DebugLog(@"开始通过用户id拉取用户资料信息");
//    NSArray *arr = [NSArray arrayWithObject:_identifier];
//    [[TIMFriendshipManager sharedInstance] GetUsersProfile:arr succ:^(NSArray *friends)
//    {
//        DebugLog(@"从服务器上拉取用户资料信息成功 count = %lu ", (unsigned long)friends.count);
//        if (friends.count)
//        {
//            [self setUserProfile:friends[0]];
//        }
//    }
//    fail:^(int code, NSString *msg)
//    {
//        DebugLog(@"从服务器上拉取用户资料信息失败 errCode = %d, errMsg = %@", code, msg);
//    }];
    __weak typeof(self) weakSelf = self;

    NSDictionary* params = @{@"userid": _identifier, @"timestamp":@([[NSDate date] timeIntervalSince1970] * 1000), @"expires":_expires};
    [TCUtil asyncSendHttpRequest:@"get_user_info" token:_token params:params handler:^(int resultCode, NSString *message, NSDictionary *resultDict) {
        if (resultCode == 200) {
            DebugLog(@"从服务器上拉取用户资料信息成功%@", resultDict);
            weakSelf.userInfo.identifier = weakSelf.identifier;
            weakSelf.userInfo.nickName = resultDict[@"nickname"];
            weakSelf.userInfo.gender = [((NSNumber*)resultDict[@"sex"]) intValue];
            weakSelf.userInfo.faceURL = resultDict[@"avatar"];
            weakSelf.userInfo.coverURL = resultDict[@"frontcover"];
            
            [weakSelf saveToLocal];
            if (completion) {
                completion(0, nil, weakSelf.userInfo.nickName, weakSelf.userInfo.faceURL);
            }
        }
        else {
            DebugLog(@"从服务器上拉取用户资料信息失败 errCode = %d, errMsg = %@", resultCode, message);
            if (completion) {
                completion(resultCode, message, nil, nil);
            }
        }
    }];
}

- (void)uploadUserInfo:(TCUserInfoSaveHandle)handle
{
    NSString* nickname = _userInfo.nickName.length < 1 ? _userInfo.identifier : _userInfo.nickName;
    NSString* avatar = _userInfo.faceURL == nil ? @"" : _userInfo.faceURL;
    NSString* frontcover = _userInfo.coverURL == nil ? @"" : _userInfo.coverURL;
    
    NSDictionary* params = @{@"userid": _identifier, @"timestamp":@([[NSDate date] timeIntervalSince1970] * 1000), @"expires":_expires, @"nickname": nickname, @"avatar": avatar, @"frontcover": frontcover, @"sex": @(_userInfo.gender)};
    
    [[MLVBLiveRoom sharedInstance] setSelfProfile:nickname avatarURL:avatar completion:nil];

    [TCUtil asyncSendHttpRequest:@"upload_user_info" token:self.token params:params handler:^(int resultCode, NSString *message, NSDictionary *resultDict) {
        handle(resultCode, message);
    }];
}

#pragma mark 上传更改后的用户信息
/**
 *  saveUserCover 用于保存用户封面url到服务器,当用户把封面图片上传后会拿到图片url地址
                  此函数用户将url信息上传到服务器上
 *
 *  @param coverURL 封面图片的url地址
 *  @param handle   保存成功或者失败后的回调block
 */
-(void)saveUserCover:(NSString*)coverURL handler:(TCUserInfoSaveHandle)handle
{
    DebugLog(@"开始保存用户封面Url地址到服务器 \n");
    __weak typeof(self) weakSelf = self;

    NSString* oldCoverURL = _userInfo.coverURL;
    _userInfo.coverURL = coverURL;
    [self uploadUserInfo:^(int errCode, NSString *strMsg) {
        if (errCode != ERROR_SUCESS) {
            weakSelf.userInfo.coverURL = oldCoverURL;
        }
        handle(errCode, strMsg);
    }];
//    NSData* data = [coverURL dataUsingEncoding:NSUTF8StringEncoding];
//    NSDictionary *dic = @{USER_COSTOMINFO_PARAM:data};
    
//    [[TIMFriendshipManager sharedInstance] SetCustom:dic succ:^{
//        _userInfo.coverURL = coverURL;
//        [self saveToLocal];
//        DebugLog(@"保存用户封面Url信息成功 \n");
//        handle(ERROR_SUCESS, @"");
//    } fail:^(int code, NSString *msg) {
//        DebugLog(@"保存用户封面Url信息失败 errCode = %d, errMsg = %@", code, msg);
//        handle(code, msg);
//    }];
}
/**
 *  saveUserNickName 用户保存用户修改后的昵称到服务器上
 *
 *  @param nickName 用户的昵称
 *  @param handle   保存成功或者失败后的回调block
 */
-(void)saveUserNickName:(NSString*)nickName handler:(TCUserInfoSaveHandle)handle
{
    DebugLog(@"开始保存用户昵称信息到服务器 \n");
    __weak typeof(self) weakSelf = self;
    
    NSString* oldNickname = _userInfo.nickName;
    _userInfo.nickName = nickName;
    [self uploadUserInfo:^(int errCode, NSString *strMsg) {
        if (errCode != ERROR_SUCESS) {
            weakSelf.userInfo.nickName = oldNickname;
        }
        handle(errCode, strMsg);
    }];
//    [[TIMFriendshipManager sharedInstance] SetNickname:nickName succ:^{
//        _userInfo.nickName = nickName;
//        [self saveToLocal];
//        DebugLog(@"保存用户昵称信息成功 \n");
//        handle(ERROR_SUCESS, @"");
//    } fail:^(int code, NSString *msg) {
//        DebugLog(@"保存用户昵称信息失败 errCode = %d, errMsg = %@", code, msg);
//        handle(code, msg);
//    }];
}
/**
 *  saveUserFace 当吧用户修改后的头像图片上传到服务器后会返回头像url地址信息
                此时再把头像的url地址上传到服务器上
 *
 *  @param faceURL 用户头像的url地址
 *  @param handle  保存成功或者失败后的回调block
 */
-(void)saveUserFace:(NSString*)faceURL handler:(TCUserInfoSaveHandle)handle
{
    DebugLog(@"开始保存用户头像Url地址到服务器 \n");
    __weak typeof(self) weakSelf = self;
    
    NSString* oldFaceURL = _userInfo.faceURL;
    _userInfo.faceURL = faceURL;
    [self uploadUserInfo:^(int errCode, NSString *strMsg) {
        if (errCode != ERROR_SUCESS) {
            weakSelf.userInfo.faceURL = oldFaceURL;
        }
        handle(errCode, strMsg);
    }];
//    [[TIMFriendshipManager sharedInstance] SetFaceURL:faceURL succ:^{
//        _userInfo.faceURL = faceURL;
//        [self saveToLocal];
//        DebugLog(@"保存用户头像Url信息成功 \n");
//        handle(ERROR_SUCESS, @"");
//    } fail:^(int code, NSString *msg) {
//        DebugLog(@"保存用户头像Url信息失败 errCode = %d, errMsg = %@", code, msg);
//        handle(code, msg);
//    }];
}
/**
 *  saveUserGender 用于保存用户性别到服务器
 *
 *  @param gender 用户性别信息,根据男 or 女取不同结构体,可查询TIMGender结构体定义
 *  @param handle 保存成功或者失败后的回调block
 */
-(void)saveUserGender:(int)gender handler:(TCUserInfoSaveHandle)handle
{
    DebugLog(@"开始保存用户性别信息到服务器 \n");
    
    __weak typeof(self) weakSelf = self;
    
    int oldGender = _userInfo.gender;
    _userInfo.gender = gender;
    [self uploadUserInfo:^(int errCode, NSString *strMsg) {
        if (errCode != ERROR_SUCESS) {
            weakSelf.userInfo.gender = oldGender;
        }
        handle(errCode, strMsg);
    }];
    
//    [[TIMFriendshipManager sharedInstance] SetGender:gender succ:^{
//        _userInfo.gender = gender;
//        [self saveToLocal];
//        DebugLog(@"保存用户性别信息成功 \n");
//        handle(ERROR_SUCESS, @"");
//    } fail:^(int code, NSString *msg) {
//        DebugLog(@"保存用户性别信息失败 errCode = %d, errMsg = %@", code, msg);
//        handle(code, msg);
//    }];
}
#endif

#pragma mark 内存中查询或者修改数据

/**
 *  该函数用户在内存中存放用户信息,包括id,封面url,头像url,性别,昵称
 *
 *  @param Profile 通过id信息从服务器上获取的数据结构体指针
 */
//- (void)setUserProfile:(TIMUserProfile *)profile;
//{
//    NSString *coverURL = [[NSString alloc] initWithData:profile.selfSignature encoding:NSUTF8StringEncoding];
//
//    if ( 0 == profile.nickname.length)
//    {
//        _userInfo.nickName   = profile.identifier;
//    }
//    else
//    {
//        _userInfo.nickName   = profile.nickname;
//    }
//
//    _userInfo.identifier = profile.identifier;
//    _userInfo.faceURL    = profile.faceURL;
//    _userInfo.gender     = profile.gender;
//    _userInfo.coverURL   = coverURL;
//
//    [self saveToLocal];
//}

/**
 *  用于获取用户资料信息借口
 *
 *  @return 用户资料信息结构体指针
 */
- (TCUserInfoData*)getUserProfile
{
    return _userInfo;
}

- (TCUserInfoData*)loadUserProfile {
    TCUserInfoData *info = [[TCUserInfoData alloc] init];
    
    // 从文件中读取
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP];
    if (defaults == nil) {
        defaults = [NSUserDefaults standardUserDefaults];
    }
    
    NSString *useridKey = [NSString stringWithFormat:@"%@_UserInfo", _identifier];
    if (useridKey) {
        NSString *strUserInfo = [defaults objectForKey:useridKey];
        NSDictionary *dic = [TCUtil jsonData2Dictionary: strUserInfo];
        if (dic) {
            info.identifier = [_identifier copy];
            info.nickName = [dic objectForKey:@"nickName"];
            info.faceURL = [dic objectForKey:@"faceURL"];
            info.coverURL = [dic objectForKey:@"coverURL"];
            info.gender = [[dic objectForKey:@"gender"] intValue];
        }
    }
    return info;
}

- (void)saveToLocal {
    // 保存昵称，头像，封页, 性别 到本地，方便其他进程读取
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:_userInfo.nickName forKey:@"nickName"];
    [dic setObject:_userInfo.faceURL forKey:@"faceURL"];
    [dic setObject:_userInfo.coverURL forKey:@"coverURL"];
    [dic setObject:@(_userInfo.gender) forKey:@"gender"];
    
    NSData *data = [TCUtil dictionary2JsonData: dic];
    NSString *strUserInfo = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *useridKey = [NSString stringWithFormat:@"%@_UserInfo", _identifier];
    
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:APP_GROUP];
    if (defaults == nil) {
        defaults = [NSUserDefaults standardUserDefaults];
    }
    [defaults setObject:useridKey forKey:kUserInfoKey];
    
    [defaults setObject:strUserInfo forKey:useridKey];
    [defaults synchronize];
}

@end
