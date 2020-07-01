/**
 * Module: TCAnchorViewController
 *
 * Function: 主播推流模块主控制器，里面承载了渲染view，逻辑view，以及推流相关逻辑，同时也是SDK层事件通知的接收者
 */

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "TCAnchorToolbarView.h"
#import "TCRoomListModel.h"
#import "MediaPlayer/MediaPlayer.h"
#import "TCUtil.h"

@interface TCAnchorViewController : UIViewController

- (instancetype)initWithPublishInfo:(TCRoomInfo *)publishInfo;

@property (nonatomic, strong)  TCAnchorToolbarView *logicView;
@property (nonatomic, strong)  MLVBLiveRoom*   liveRoom;
@property (nonatomic, assign)  BOOL log_switch;
@property (nonatomic, strong)  NSMutableSet*  setLinkMemeber;

@end
