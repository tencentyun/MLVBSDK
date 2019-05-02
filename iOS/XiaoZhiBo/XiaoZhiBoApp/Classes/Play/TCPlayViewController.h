//
//  PlayController.h
//  RTMPiOSDemo
//
//  Created by 蓝鲸 on 16/4/1.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "TCPlayDecorateView.h"
#import "TXLiveRecordListener.h"
#import "TCUtil.h"
#import "TCLiveListModel.h"

#define FULL_SCREEN_PLAY_VIDEO_VIEW     10000
/**
 *  播放模块主控制器，里面承载了渲染view，逻辑view，以及播放相关逻辑，同时也是SDK层事件通知的接收者
 */

@interface TCPlayViewController : UIViewController<UITextFieldDelegate,TCPlayDecorateDelegate, TXLiveRecordListener, MLVBLiveRoomDelegate>

@property (nonatomic, retain) TCLiveInfo  *liveInfo;
@property (nonatomic, copy)   videoIsReadyBlock   videoIsReady;
@property (nonatomic, copy)  void(^onPlayError)(void);
@property (nonatomic, retain) TCPlayDecorateView *logicView;
@property (nonatomic, retain) MLVBLiveRoom* liveRoom;
@property (nonatomic, assign) BOOL  log_switch;

- (id)initWithPlayInfo:(TCLiveInfo *)info  videoIsReady:(videoIsReadyBlock)videoIsReady;

- (BOOL)startRtmp;

- (void)stopRtmp;

- (void)clickScreen:(CGPoint)position;

@end
