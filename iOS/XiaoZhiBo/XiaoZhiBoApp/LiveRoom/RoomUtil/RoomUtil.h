//
//  RoomUtil.h
//  TXLiteAVDemo
//
//  Created by lijie on 2017/12/11.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TXLivePlayListener.h"
#import "TXLivePlayer.h"

@interface RoomUtil : NSObject
+ (NSString *)getDeviceModelName;
@end

/**
   播放开始的回调
 */
typedef void (^IPlayBeginBlock)(void);

/**
   播放过程中发生错误时的回调
 */
typedef void (^IPlayErrorBlock)(int errCode, NSString *errMsg);

/// 播放事件回调
typedef void (^IPlayEventBlock)(int event, NSDictionary *param);


@protocol IRoomLivePlayListener <NSObject>
@optional
-(void)onLivePlayNetStatus:(NSString*) userID withParam: (NSDictionary*) param;
@end


@interface RoomLivePlayerWrapper : NSObject <TXLivePlayListener>
@property (nonatomic, strong) TXLivePlayer *player;
@property (nonatomic, strong) NSString  *userID;
@property (nonatomic, weak) id<IRoomLivePlayListener> delegate;
@property (nonatomic, copy) IPlayBeginBlock playBeginBlock;
@property (nonatomic, copy) IPlayErrorBlock playErrorBlock;
@property (nonatomic, copy) IPlayEventBlock playEventBlock;

- (void)clear;

@end
