//
//  LivePlayViewController.h
//  MLVB-API-Example-OC
//
//  Created by bluedang on 2021/6/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LivePlayMode) {
    StandPlay,
    RTCPlay,
    LebPlay,
};

@interface LivePlayViewController : UIViewController
- (instancetype)initWithStreamId:(NSString*)streamId playMode:(LivePlayMode)mode;
@end

NS_ASSUME_NONNULL_END
