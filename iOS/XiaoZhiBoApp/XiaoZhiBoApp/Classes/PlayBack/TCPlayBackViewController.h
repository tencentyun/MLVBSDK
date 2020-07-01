/**
 * Module: TCPlayBackViewController
 *
 * Function: 视频回放
 */

#import "TCAudienceToolbarView.h"
#import "TCUtil.h"

@interface TCPlayBackViewController : UIViewController

@property  TCRoomInfo  *liveInfo;
@property (nonatomic, copy)   videoIsReadyBlock   videoIsReady;
@property (nonatomic, copy)   void(^onPlayError)(void);
@property (nonatomic, assign) BOOL  log_switch;
@property (nonatomic, retain) TCAudienceToolbarView *logicView;

- (id)initWithPlayInfo:(TCRoomInfo *)info videoIsReady:(videoIsReadyBlock)videoIsReady;

- (void)stopRtmp;

- (void)onAppDidEnterBackGround:(UIApplication *)app;

- (void)onAppWillEnterForeground:(UIApplication *)app;

@end
