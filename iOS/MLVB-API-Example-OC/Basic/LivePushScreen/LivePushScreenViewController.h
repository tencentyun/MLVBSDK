//
//  LivePushScreenViewController.h
//  MLVB-API-Example-OC
//
//  Created by bluedang on 2021/6/28.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LivePushScreenViewController : UIViewController
- (instancetype)initWithStreamId:(NSString*)streamId isRTCPush:(BOOL)value audioQulity:(V2TXLiveAudioQuality)quality;
@end

NS_ASSUME_NONNULL_END
