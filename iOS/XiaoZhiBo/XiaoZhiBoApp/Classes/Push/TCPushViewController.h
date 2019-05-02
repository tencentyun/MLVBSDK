//
//  TCPushViewController.h
//  RTMPiOSDemo
//
//  Created by 蓝鲸 on 16/4/1.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "TCPushDecorateView.h"
#import "TCLiveListModel.h"
#import "MediaPlayer/MediaPlayer.h"
#import "TCUtil.h"

/**
 *  推流模块主控制器，里面承载了渲染view，逻辑view，以及推流相关逻辑，同时也是SDK层事件通知的接收者
 */
@interface TCPushViewController : UIViewController

- (instancetype)initWithPublishInfo:(TCLiveInfo *)publishInfo;

@property (nonatomic, strong)  TCPushDecorateView *logicView;
@property (nonatomic, strong)  MLVBLiveRoom*   liveRoom;
@property (nonatomic, assign)  TCSocialPlatform platformType;
@property (nonatomic, assign)  BOOL log_switch;
@property (nonatomic, strong)  NSMutableSet*  setLinkMemeber;

@end
