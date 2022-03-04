//
//  LiteAVPrivacyDataCollectedTableCell.h
//  LiteAVPrivacy
//
//  Created by jack on 2022/2/10.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LiteAVPrivacyDataCollectedUIStyle) {
    LiteAVPrivacyDataCollectedUIStyleDefault = 0,
    LiteAVPrivacyDataCollectedUIStyleAvatar = 1,
};

NS_ASSUME_NONNULL_BEGIN

@interface LiteAVPrivacyDataCollectedTableCell : UITableViewCell

@property (nonatomic, assign) LiteAVPrivacyDataCollectedUIStyle cellStyle;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *descLabel;

@property (nonatomic, strong) UILabel *purposeTitleLabel;

@property (nonatomic, strong) UILabel *purposeTextLabel;

@property (nonatomic, strong) UIImageView *avatarImageView;

@end

NS_ASSUME_NONNULL_END
