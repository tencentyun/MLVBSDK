//
//  LiteAVPrivacyItemTableCell.h
//  LiteAVPrivacy
//
//  Created by jack on 2022/2/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class LiteAVPrivacyConfig;
@interface LiteAVPrivacyItemTableCell : UITableViewCell

- (void)updateUIData:(NSDictionary *)thirdData config:(LiteAVPrivacyConfig *)config;

@end

NS_ASSUME_NONNULL_END
