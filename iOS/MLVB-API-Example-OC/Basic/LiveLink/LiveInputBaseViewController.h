// Copyright (c) 2020 Tencent. All rights reserved.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/**
  Link和Pk输入页面基类
 */
@interface LiveInputBaseViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *tips;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

- (instancetype)initWithLabelName:(NSString *)label buttonName:(NSString *)button;
@end

NS_ASSUME_NONNULL_END
