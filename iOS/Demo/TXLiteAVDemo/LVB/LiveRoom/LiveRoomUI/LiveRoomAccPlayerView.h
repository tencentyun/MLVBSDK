//
//  LiveRoomAccPlayerView.h
//  TXLiteAVDemo
//
//  Created by cui on 2019/5/7.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveRoomAccPlayerView : UIView
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign) BOOL closeEnabled;
@property (nonatomic, copy) void(^onClose)(LiveRoomAccPlayerView *view);
@end

NS_ASSUME_NONNULL_END
