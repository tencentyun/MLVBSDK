/**
 * Module: TCAccountMgrModel
 *
 * Function: 账号管理模块
 */

#import <Foundation/Foundation.h>
#import "TCAccountMgrModel.h"
#import <Foundation/Foundation.h>
#import "MLVBLiveRoom.h"
#import <ImSDK/ImSDK.h>

#define  logoutNotification  @"logoutNotification"

typedef void (^TCRegistSuccess)(NSString* userName, NSString* md5pwd);
typedef void (^TCRegistFail)(int errCode, NSString* errMsg);

typedef void (^TCLoginSuccess)(NSString* userName, NSString* md5pwd);
typedef void (^TCLoginFail)(int errCode, NSString* errMsg);

typedef void (^TCLogoutSuccess)(void);
typedef void (^TCLogoutFail) (void);
typedef void (^TCLogoutComplete)(void);


// 登录参数
@interface TCLoginParam : NSObject

@property (nonatomic, assign) NSInteger tokenTime;
@property (nonatomic, assign) BOOL      isLastAppExt;
@property (nonatomic, copy) NSString*   identifier;
@property (nonatomic, copy) NSString*   hashedPwd;

+ (instancetype)shareInstance;
+ (instancetype)loadFromLocal;
- (void)saveToLocal;
- (BOOL)isExpired;
- (BOOL)isValid;

@end


@protocol TCLoginDelegate <NSObject>
/**
 * 登录成功的回调
 *  @param userinfo 登录成功的用户
 */
- (void)loginSuccess:(NSString*)userName hashedPwd:(NSString*)pwd;
@end


/**
 *  业务server登录
 */
@interface TCAccountMgrModel : NSObject <TIMUserStatusListener>

@property(nonatomic, strong) MLVBLoginInfo *imLoginInfo;

@property (nonatomic, copy) NSString* token;

+ (instancetype)sharedInstance;

+ (BOOL)isAutoLogin;

+ (void)setAutoLogin:(BOOL)autoLogin;

- (void)registerWithUsername:(NSString *)username password:(NSString *)password succ:(TCRegistSuccess)succ fail:(TCRegistFail)fail;

- (void)loginWithUsername:(NSString*)username password:(NSString*)password succ:(TCLoginSuccess)succ fail:(TCLoginFail)fail;
- (void)loginByToken:(NSString*)username hashPwd:(NSString*)hashPwd succ:(TCLoginSuccess)succ fail:(TCLoginFail)fail;

- (void)logout:(TCLogoutComplete)completion;

// 获取login传入的login param参数
//- (TIMLoginParam *)getLoginParam;
- (TCLoginParam *)getLoginParam;

- (void)getCosSign:(void (^)(int errCode, NSString* msg, NSDictionary* resultDict))completion;
- (void)getVodSign:(void (^)(int errCode, NSString* msg, NSDictionary* resultDict))completion;
- (void)uploadUGC:(NSDictionary*)params completion:(void (^)(int errCode, NSString* msg, NSDictionary* resultDict))completion;

- (void)reLoginIfNeeded:(TCLoginSuccess)succ fail:(TCLoginFail)fail;
- (void)reLogin:(TCLoginSuccess)succ fail:(TCLoginFail)fail;

@end
