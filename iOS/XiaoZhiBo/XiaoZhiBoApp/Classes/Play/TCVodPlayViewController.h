//
//  TCVodPlayViewController.h
//  TCLVBIMDemo
//
//  Created by annidyfeng on 2017/9/15.
//  Copyright © 2017年 tencent. All rights reserved.
//
#import "TCPlayDecorateView.h"
#import "TCUtil.h"

@interface TCVodPlayViewController:UIViewController <UITextFieldDelegate, TXVodPlayListener,TCPlayDecorateDelegate>

@property  TCLiveInfo  *liveInfo;
@property (nonatomic, copy)   videoIsReadyBlock   videoIsReady;
@property (nonatomic, copy)   void(^onPlayError)(void);
@property (nonatomic, assign) BOOL  log_switch;
@property (nonatomic, retain) TCPlayDecorateView *logicView;

- (id)initWithPlayInfo:(TCLiveInfo *)info  videoIsReady:(videoIsReadyBlock)videoIsReady;

- (void)stopRtmp;

- (void)onAppDidEnterBackGround:(UIApplication*)app;

- (void)onAppWillEnterForeground:(UIApplication*)app;
@end
