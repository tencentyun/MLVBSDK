//
//  LiveRoomPusherViewController.h
//  TXLiteAVDemo
//
//  Created by lijie on 2017/11/22.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLVBLiveRoom.h"

/**
   这个类用于直播模式的大主播
 */
@interface LiveRoomPusherViewController : UIViewController

@property (nonatomic, weak)    MLVBLiveRoom*          liveRoom;
@property (nonatomic, copy)    NSString*          roomName;
@property (nonatomic, copy)    NSString*          userID;
@property (nonatomic, copy)    NSString*          userName;

@end
