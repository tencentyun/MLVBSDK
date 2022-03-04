//
//  LiteAVPrivacyMyInfoTableCell.h
//  LiteAVPrivacy
//
//  Created by jack on 2022/2/10.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LiteAVPrivacyMyInfoUIStyle) {
    LiteAVPrivacyMyInfoUIStyleDefault = 0,
    LiteAVPrivacyMyInfoUIStyleAvatar = 1,
};

NS_ASSUME_NONNULL_BEGIN

@interface LiteAVPrivacyMyInfoTableCell : UITableViewCell

@property (nonatomic, assign) LiteAVPrivacyMyInfoUIStyle cellStyle;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *descLabel;

@property (nonatomic, strong) UIImageView *avatarImageView;
@end

NS_ASSUME_NONNULL_END
