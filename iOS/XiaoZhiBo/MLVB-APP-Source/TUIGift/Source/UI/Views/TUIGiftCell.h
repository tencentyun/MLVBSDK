//
//  TUIGiftCell.h
//  TUIGiftView
//
//  Created by WesleyLei on 2021/9/10.
//

#import <UIKit/UIKit.h>
#import "TUIGiftView.h"
NS_ASSUME_NONNULL_BEGIN

@class TUIGiftModel;
@interface TUIGiftCell : UICollectionViewCell

@property (nonatomic, strong) TUIGiftModel *giftModel;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, copy) TUIActionSendBlock sendBlock;

@end

NS_ASSUME_NONNULL_END
