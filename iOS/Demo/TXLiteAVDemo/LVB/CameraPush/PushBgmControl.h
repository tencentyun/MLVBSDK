/**
 * Module:   PushBgmControl
 *
 * Function: BGM控制组件
 */

#import <UIKit/UIKit.h>

@class PushBgmControl;

@protocol PushBgmControlDelegate <NSObject>
/**
 * 开始播放
 * @param loopTimes 单曲循环播放次数
 * @param online YES: 播放在线音乐  NO: 播放本地音乐
 */
- (void)onBgmStart:(int)loopTimes online:(BOOL)online;

- (void)onBgmStop;

- (void)onBgmPause;

- (void)onBgmResume;

- (void)onMicVolume:(float)volume;

- (void)onBgmVolume:(float)volume;

- (void)onBgmPitch:(float)pitch;

@end


@interface PushBgmControl : UIView
@property (nonatomic, weak) id<PushBgmControlDelegate> delegate;

@end
