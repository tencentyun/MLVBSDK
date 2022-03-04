//
//  LiteAVPrivacyConfig.h
//  LiteAVPrivacy
//
//  Created by jack on 2022/2/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/// UI显示样式
typedef NS_ENUM(NSUInteger, LiteAVPrivacyUIStyle) {
    /// 白天模式
    LiteAVPrivacyUIStyleLight,
    /// 黑夜模式
    LiteAVPrivacyUIStyleDark,
};

/// 隐私协议地址索引
extern NSString *const kLiteAVPrivacyURLKey;
/// 用户协议地址索引
extern NSString *const kLiteAVPrivacyUserProtocolKey;
/// 隐私协议版本索引
extern NSString *const kLiteAVPrivacyVersionKey;
/// 个人信息与权限索引
extern NSString *const kLiteAVPrivacyPersonalAuthKey;
/// 个人信息收集清单索引
extern NSString *const kLiteAVPrivacyDataCollectionKey;
/// 第三方信息共享清单索引
extern NSString *const kLiteAVPrivacyThirdShareKey;

@interface LiteAVPrivacyConfig : NSObject

@property (nonatomic, assign) LiteAVPrivacyUIStyle style;

@property (nonatomic, strong) NSString *userName;

@property (nonatomic, strong) NSString *userID;

@property (nonatomic, strong) NSString *userAvatar;

@property (nonatomic, strong) NSString *phone;

@property (nonatomic, strong) NSString *email;

/// 合规文件配置路径
@property (nonatomic, strong) NSString *plistPath;
/// 合规配置文件信息
@property (nonatomic, readonly) NSDictionary *plistInfo;

@end

@interface LiteAVPrivacyConfig (UIMode)

@property (nonatomic, readonly) UIColor *backgroundColor;

@property (nonatomic, readonly) UIColor *textColor;

@property (nonatomic, readonly) UIColor *detailColor;
@end

NS_ASSUME_NONNULL_END
