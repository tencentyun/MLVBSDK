//
//  TUIPlayerContainerView.h
//  TUIPlayer
//
//  Created by gg on 2021/9/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIPlayerContainerView : UIView
- (instancetype)initWithFrame:(CGRect)frame groupId:(NSString * _Nullable)groupId;

- (void)setLinkMicBtn:(UIButton *)btn;
@end

NS_ASSUME_NONNULL_END
