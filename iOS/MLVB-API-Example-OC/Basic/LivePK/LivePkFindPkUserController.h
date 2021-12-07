// Copyright (c) 2021 Tencent. All rights reserved.

#import "LiveInputBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
/**
  寻找pk对象，输入页面
 */
@interface LivePkFindPkUserController : LiveInputBaseViewController
/// 点击事件回调
@property(nonatomic, copy)void (^didClickNextBlock)(NSString *streamId);
@end

NS_ASSUME_NONNULL_END
