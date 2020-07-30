/**
 * Module: TCUserProfileModel
 *
 * Function: 用户信息管理
 */

#import <ImSDK/ImSDK.h>

#define ERROR_SUCESS 200
#define KReloadUserInfoNotification @"KReloadUserInfoNotification"
#define USER_COSTOMINFO_PARAM @"Tag_Profile_IM_SelfSignature"

/*
 *  TCUserProfileData 类说明 : 该类用于存放用户资料信息,目前只包括: 昵称 封面 头像 性别
 *
 *  在用户登录成功后会发送通知拉取用户信息,拉取到的信息存放在此类成员变量中
 */

#define USERINFO_MALE   0
#define USERINFO_FEMALE 1

@interface TCUserProfileData : NSObject

@property (assign, nonatomic)  int gender;//imTODO:
@property (strong, nonatomic) NSString* nickName;
@property (strong, nonatomic) NSString* identifier;
@property (strong, nonatomic) NSString* faceURL;
@property (strong, nonatomic) NSString* coverURL;
@property (strong, nonatomic) NSString* bucket;
@property (strong, nonatomic) NSString* secretId;
@property (strong, nonatomic) NSString* appid;
@property (strong, nonatomic) NSString* region;
@property (strong, nonatomic) NSString* accountType;
@end


typedef void (^TCUserProfileSaveHandle)(int errCode,NSString *strMsg);

/*
 *  TCUserProfileModel 类说明 : 该类用于管理用户资料信息,目前只包括: 昵称 封面 头像 性别
 *
 *  该类为单例,外部只能通过类似[[TCUserProfileModel sharedInstance] getUserProfile];这样调用,不能创建对象
 *
 *  在用户登录成功后,setIdentifier函数就会被外部调用,传入用户ID, 然后拉取用户信息
 *
 *  如果要获取用户资料信息,只需要调用getUserProfile即可
 *   
 *  要更改用户信息(昵称 封面 头像 性别)并上传服务器,可调用本头文件对外暴露的对应接口
 *
 *  TCUserProfileSaveHandle代表更改用户资料信息回调接口定义,errCode为0(ERROR_SUCESS)时代表成功,否则失败
 */
@interface TCUserProfileModel : NSObject

+ (instancetype)sharedInstance;

- (void)setIdentifier:(NSString *)identifier
              expires:(NSNumber*)expires
                token:(NSString*)token
           completion:(void(^)(int code, NSString *errMsg, NSString *nickname, NSString *avatar))completion;

- (void)setBucket:(NSString *)bucket secretId:(NSString*)secretId appid:(long)appid region:(NSString *)region accountType:(NSString *)accountType;

- (TCUserProfileData*)getUserProfile;  // 从内存中读取

- (TCUserProfileData*)loadUserProfile;  // 从文件中读取

//- (void)setUserProfile:(TIMUserProfile *)profile; //imTODO:

- (void)saveUserCover:(NSString*)IMUserCover handler:(TCUserProfileSaveHandle)handle;

- (void)saveUserNickName:(NSString*)nickName handler:(TCUserProfileSaveHandle)handle;

- (void)saveUserFace:(NSString*)faceURL handler:(TCUserProfileSaveHandle)handle;

- (void)saveUserGender:(int)gender handler:(TCUserProfileSaveHandle)handle;//imTODO:

@end
