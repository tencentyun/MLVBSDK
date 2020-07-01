/**
 * Module: TCRoomListViewController
 *
 * Function: 负责展示直播、点播列表，点击后跳转播放界面
 */

#import <UIKit/UIKit.h>

@protocol TCRoomListDelegate <NSObject>

- (void)onEnterPlayViewController;

@end

@interface TCRoomListViewController : UIViewController

@property(nonatomic, weak)  id<TCRoomListDelegate> delegate;
@property(nonatomic,strong) UIViewController *playVC;

@end
