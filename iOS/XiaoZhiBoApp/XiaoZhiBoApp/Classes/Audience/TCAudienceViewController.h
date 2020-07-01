/**
 * Module: TCAudienceViewController
 *
 * Function: 观众播放模块主控制器，里面承载了渲染view，逻辑view，以及播放相关逻辑，同时也是SDK层事件通知的接收者
 */

#import "TCAudienceToolbarView.h"
#import "TXLiveRecordListener.h"
#import "TCUtil.h"
#import "TCRoomListModel.h"

#define FULL_SCREEN_PLAY_VIDEO_VIEW     10000

@interface TCAudienceViewController : UIViewController

@property (nonatomic, retain) TCRoomInfo  *liveInfo;
@property (nonatomic, copy)   videoIsReadyBlock   videoIsReady;
@property (nonatomic, copy)  void(^onPlayError)(void);
@property (nonatomic, retain) TCAudienceToolbarView *logicView;
@property (nonatomic, retain) MLVBLiveRoom* liveRoom;
@property (nonatomic, assign) BOOL  log_switch;

- (id)initWithPlayInfo:(TCRoomInfo *)info videoIsReady:(videoIsReadyBlock)videoIsReady;

- (BOOL)startRtmp;

- (void)stopRtmp;

- (void)clickScreen:(CGPoint)position;

@end
