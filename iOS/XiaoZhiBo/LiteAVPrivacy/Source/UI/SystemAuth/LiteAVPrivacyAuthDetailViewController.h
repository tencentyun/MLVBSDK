//
//  LiteAVPrivacyAuthDetailViewController.h
//  LiteAVPrivacy
//
//  Created by jack on 2022/2/10.
//

#import <UIKit/UIKit.h>
#import "LiteAVPrivacyBaseViewController.h"

typedef NS_ENUM(NSUInteger, LiteAVPrivacyAuthType) {
    LiteAVPrivacyAuthTypeCamera,
    LiteAVPrivacyAuthTypeMicrophone,
    LiteAVPrivacyAuthTypePhotos,
};

NS_ASSUME_NONNULL_BEGIN
@interface LiteAVPrivacyAuthDetailViewController : LiteAVPrivacyBaseViewController

/// 系统权限控制器初始化
/// @param authType 系统权限类型
/// @param config 合规配置文件
- (instancetype)initWithAuthType:(LiteAVPrivacyAuthType)authType privacyConfig:(LiteAVPrivacyConfig *)config;

@end

NS_ASSUME_NONNULL_END
