/**
 * Module: TCUserProfileModel
 *
 * Function: 用户信息管理
 */

#import "TCUserProfileModel.h"
#import "TCAccountMgrModel.h"
#import <UIImageView+WebCache.h>
#import "TCConfig.h"
#import "TCUtil.h"

#define kUserInfoKey     @"kUserInfoKey"

static TCUserProfileModel *_shareInstance = nil;

@implementation TCUserProfileData

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}
@end

@interface TCUserProfileModel() {
    NSArray<NSString*>       *_userNameArray;
}
@property(nonatomic, copy) NSString            *identifier;
@property(nonatomic, strong) NSNumber          *expires;
@property(nonatomic, copy) NSString            *token;
@property(nonatomic, strong) TCUserProfileData *userInfo;
@end

@implementation TCUserProfileModel

- (instancetype)init {
    if (self = [super init]) {
        _userInfo   = [[TCUserProfileData alloc] init];
        _userNameArray = [[NSArray alloc] initWithObjects:@"李元芳", @"刘备", @"梦奇", @"王昭君", @"周瑜", @"鲁班", @"后裔", @"安其拉", @"亚瑟", @"曹操",
        @"百里守约", @"东皇太一", @"花木兰", @"诸葛亮", @"黄忠", @"不知火舞", @"钟馗", @"李白", @"娜可露露", @"张飞", nil];
    }
    
    return self;
}

- (void)dealloc {
}

+ (instancetype)sharedInstance; {
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        _shareInstance = [[TCUserProfileModel alloc] init];
    });
    return _shareInstance;
}
/**
 *  保存用户ID信息,并且注册回调通知,当收到登陆成功通知后拉取用户信息
 *  数据拉取成功后存入 userInfo  结构当中
 *
 *  @param identifier  用户ID信息
 */
- (void)setIdentifier:(NSString *)identifier expires:(NSNumber *)expires token:(NSString *)token completion:(void(^)(int code, NSString *errMsg, NSString *nickname, NSString *avatar))completion {
    _identifier = identifier;
    _expires = expires;
    _token = token;
    [self fetchUserInfo:completion];
}

- (void)setIdentifier:(NSString *)identifier expires:(NSNumber*)expires {
    _identifier = identifier;
    _expires = expires;
    [self loadUserProfile];
    [self saveToLocal];
}

- (void)setBucket:(NSString *)bucket secretId:(NSString*)secretId appid:(long)appid region:(NSString *)region accountType:(NSString *)accountType {
    _userInfo.bucket = bucket;
    _userInfo.secretId = secretId;
    _userInfo.appid = [NSString stringWithFormat:@"%lu",appid];
    _userInfo.region = region;
    _userInfo.accountType = accountType;
}

#pragma mark 从服务器上拉取信息

/**
 *  通过id信息从服务器上拉取用户信息
 */
- (void)fetchUserInfo:(void(^)(int code, NSString *errMsg, NSString *nickname, NSString *avatar))completion {
    DebugLog(@"开始通过用户id拉取用户资料信息");
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

- (void)uploadUserInfo:(TCUserProfileSaveHandle)handle {
    NSString* nickname = _userInfo.nickName.length < 1 ? _userInfo.identifier : _userInfo.nickName;
    NSString* avatar = _userInfo.faceURL == nil ? @"" : _userInfo.faceURL;
    NSString* frontcover = _userInfo.coverURL == nil ? @"" : _userInfo.coverURL;
    
    NSDictionary* params = @{@"userid": _identifier, @"timestamp":@([[NSDate date] timeIntervalSince1970] * 1000), @"expires":_expires, @"nickname": nickname, @"avatar": avatar, @"frontcover": frontcover, @"sex": @(_userInfo.gender)};
    
    [[MLVBLiveRoom sharedInstance] setSelfProfile:nickname avatarURL:avatar completion:nil];

    __weak typeof(self) weakSelf = self;
    [TCUtil asyncSendHttpRequest:@"upload_user_info" token:self.token params:params handler:^(int resultCode, NSString *message, NSDictionary *resultDict) {
        if (resultCode == kError_NotSupport) {
            [weakSelf saveToLocal];
        }
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
- (void)saveUserCover:(NSString *)coverURL handler:(TCUserProfileSaveHandle)handle {
    DebugLog(@"开始保存用户封面Url地址到服务器 \n");
    __weak typeof(self) weakSelf = self;

    NSString* oldCoverURL = _userInfo.coverURL;
    _userInfo.coverURL = coverURL;
    [self uploadUserInfo:^(int errCode, NSString *strMsg) {
        if (errCode != ERROR_SUCESS && errCode != kError_NotSupport) {
            weakSelf.userInfo.coverURL = oldCoverURL;
        }
        handle(errCode, strMsg);
    }];
}

/**
 *  saveUserNickName 用户保存用户修改后的昵称到服务器上
 *
 *  @param nickName 用户的昵称
 *  @param handle   保存成功或者失败后的回调block
 */
- (void)saveUserNickName:(NSString*)nickName handler:(TCUserProfileSaveHandle)handle {
    DebugLog(@"开始保存用户昵称信息到服务器 \n");
    __weak typeof(self) weakSelf = self;
    
    NSString *oldNickname = _userInfo.nickName;
    _userInfo.nickName = nickName;
    [self uploadUserInfo:^(int errCode, NSString *strMsg) {
        if (errCode != ERROR_SUCESS && errCode != kError_NotSupport) {
            weakSelf.userInfo.nickName = oldNickname;
        }
        handle(errCode, strMsg);
    }];
}

/**
 *  saveUserFace 当吧用户修改后的头像图片上传到服务器后会返回头像url地址信息
                此时再把头像的url地址上传到服务器上
 *
 *  @param faceURL 用户头像的url地址
 *  @param handle  保存成功或者失败后的回调block
 */
- (void)saveUserFace:(NSString*)faceURL handler:(TCUserProfileSaveHandle)handle {
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
}

/**
 *  saveUserGender 用于保存用户性别到服务器
 *
 *  @param gender 用户性别信息,根据男 or 女取不同结构体,可查询TIMGender结构体定义
 *  @param handle 保存成功或者失败后的回调block
 */
- (void)saveUserGender:(int)gender handler:(TCUserProfileSaveHandle)handle {
    DebugLog(@"开始保存用户性别信息到服务器 \n");
    
    __weak typeof(self) weakSelf = self;
    
    int oldGender = _userInfo.gender;
    _userInfo.gender = gender;
    [self uploadUserInfo:^(int errCode, NSString *strMsg) {
        if (errCode != ERROR_SUCESS && errCode != kError_NotSupport) {
            weakSelf.userInfo.gender = oldGender;
        }
        handle(errCode, strMsg);
    }];
}

#pragma mark 内存中查询或者修改数据

/**
 *  用于获取用户资料信息借口
 *
 *  @return 用户资料信息结构体指针
 */
- (TCUserProfileData*)getUserProfile {
    return _userInfo;
}

- (void)loadUserProfile {
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
            _userInfo.identifier = [_identifier copy];
            _userInfo.nickName = [dic objectForKey:@"nickName"];
            _userInfo.faceURL = [dic objectForKey:@"faceURL"];
            _userInfo.coverURL = [dic objectForKey:@"coverURL"];
            _userInfo.gender = [[dic objectForKey:@"gender"] intValue];
        } else {
            _userInfo.identifier = [_identifier copy];
            _userInfo.nickName = _userNameArray[arc4random() % _userNameArray.count];
            _userInfo.faceURL = @"";
            _userInfo.coverURL = @"";
            _userInfo.gender = -1;
        }
    }
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
