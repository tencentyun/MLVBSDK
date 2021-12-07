// Copyright (c) 2020 Tencent. All rights reserved.

#import "ViewController.h"

NS_ASSUME_NONNULL_BEGIN
/**
  Link或者Pk 角色选择页面
 */
@interface LiveLinkOrPkSwitchRoleViewController : ViewController
/// 点击事件回调
@property(nonatomic, copy)void (^didClickNextBlock)(NSString *userId, BOOL isAnchor);
- (instancetype)initWithUserId:(NSString *)userId title:(NSString *)title;
@end
NS_ASSUME_NONNULL_END
