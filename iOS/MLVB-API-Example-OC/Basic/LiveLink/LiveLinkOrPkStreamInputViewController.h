// Copyright (c) 2020 Tencent. All rights reserved.

#import "LiveInputBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
/**
  Link或者Pk Stream输入页面
 */
@interface LiveLinkOrPkStreamInputViewController : LiveInputBaseViewController
/// 点击事件回调
@property(nonatomic, copy)void (^didClickNextBlock)(NSString *streamId,
                                                    NSString *userId,
                                                    BOOL isAnchor);
- (instancetype)initWithUserId:(NSString *)userId
                      isAnchor:(BOOL)isAnchor
                         title:(NSString *)title;
@end

NS_ASSUME_NONNULL_END
