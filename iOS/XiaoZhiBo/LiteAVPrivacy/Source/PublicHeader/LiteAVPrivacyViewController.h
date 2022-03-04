//
//  LiteAVPrivacyViewController.h
//  LiteAVPrivacy-LiteAVPrivacyKitBundle
//
//  Created by jack on 2022/2/10.
//

#import <UIKit/UIKit.h>
#import "LiteAVPrivacyConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface LiteAVPrivacyViewController : UITableViewController

/// 视图控制器初始化
/// @param config 合规配置文件
- (instancetype)initWithPrivacyConfig:(LiteAVPrivacyConfig *)config;

@end

NS_ASSUME_NONNULL_END
