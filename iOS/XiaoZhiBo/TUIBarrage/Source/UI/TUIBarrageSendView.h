//
//  TUIBarrageSendView.h
//  TUIBarrageService
//
//  Created by WesleyLei on 2021/9/22.
//

#import <UIKit/UIKit.h>
#import "TUIBarrageSendBaseView.h"
NS_ASSUME_NONNULL_BEGIN

@interface TUIBarrageSendView : TUIBarrageSendBaseView
/**
* 键盘弹起
*
*/
- (void)becomeFirstResponder;

/**
* 键盘回落
*
*/
- (void)resignFirstResponder;
@end

NS_ASSUME_NONNULL_END
