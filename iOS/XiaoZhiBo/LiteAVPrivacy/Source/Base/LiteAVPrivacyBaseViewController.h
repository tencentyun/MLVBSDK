//
//  LiteAVPrivacyBaseViewController.h
//  LiteAVPrivacy
//
//  Created by jack on 2022/2/11.
//

#import <UIKit/UIKit.h>
#import "LiteAVPrivacyConfig.h"
#import "LiteAVPrivacyLocalized.h"

NS_ASSUME_NONNULL_BEGIN
@interface LiteAVPrivacyBaseViewController : UITableViewController

/// 合规配置信息
@property (nonatomic, strong) LiteAVPrivacyConfig *config;

/// 视图控制器初始化
/// @param config 合规配置文件
- (instancetype)initWithPrivacyConfig:(LiteAVPrivacyConfig *)config;

/// 数据初始化
- (void)initData;

/// 设置导航栏标题
- (void)setNavigationTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
