//
//  TUIGiftView.h
//  TUIGiftView
//
//  Created by WesleyLei on 2021/9/16.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@class TUIGiftModel;
typedef  void (^TUIActionSendBlock)(TUIGiftModel *giftModel);

@interface TUIGiftView : UIView

@property (nonatomic, strong) TUIGiftModel *giftModel;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, copy) TUIActionSendBlock sendBlock;

@end

NS_ASSUME_NONNULL_END
