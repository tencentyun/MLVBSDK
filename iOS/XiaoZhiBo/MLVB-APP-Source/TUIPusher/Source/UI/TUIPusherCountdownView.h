//
//  TUIPusherCountdownView.h
//  TUIPusher
//
//  Created by gg on 2021/9/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIPusherCountdownView : UIView

- (void)start;

@property (nonatomic, readonly) BOOL isInCountdown;

@property (nonatomic,  copy ) void (^willDismiss) (void);
@property (nonatomic,  copy ) void (^didDismiss) (void);

@end

NS_ASSUME_NONNULL_END
