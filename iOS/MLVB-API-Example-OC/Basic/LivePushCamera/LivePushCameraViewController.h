//
//  LivePushCameraViewController.h
//  MLVB-API-Example-OC
//
//  Created by bluedang on 2021/6/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LivePushCameraViewController : UIViewController
- (instancetype)initWithStreamId:(NSString*)streamId isRTCPush:(BOOL)value audioQulity:(V2TXLiveAudioQuality)quality;
@end

NS_ASSUME_NONNULL_END
