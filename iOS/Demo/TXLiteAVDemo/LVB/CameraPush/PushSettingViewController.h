/**
 * Module:   PushSettingViewController
 *
 * Function: 推流相关的主要设置项
 */

#import <UIKit/UIKit.h>
#import "TXLiveSDKTypeDef.h"

@class PushSettingViewController;

@protocol PushSettingDelegate <NSObject>

// 是否开启带宽适应
- (void)onPushSetting:(PushSettingViewController *)vc enableBandwidthAdjust:(BOOL)enableBandwidthAdjust;

// 是否开启硬件加速
- (void)onPushSetting:(PushSettingViewController *)vc enableHWAcceleration:(BOOL)enableHWAcceleration;

// 是否开启耳返
- (void)onPushSetting:(PushSettingViewController *)vc enableAudioPreview:(BOOL)enableAudioPreview;

// 画质类型
- (void)onPushSetting:(PushSettingViewController *)vc videoQuality:(TX_Enum_Type_VideoQuality)videoQuality;

// 混响效果
- (void)onPushSetting:(PushSettingViewController *)vc reverbType:(TXReverbType)reverbType;

// 变声类型
- (void)onPushSetting:(PushSettingViewController *)vc voiceChangerType:(TXVoiceChangerType)voiceChangerType;

@end


@interface PushSettingViewController : UIViewController
@property (nonatomic, weak) id<PushSettingDelegate> delegate;

/*** 从文件中读取配置 ***/
+ (BOOL)getBandWidthAdjust;
+ (BOOL)getEnableHWAcceleration;
+ (BOOL)getEnableAudioPreview;
+ (TX_Enum_Type_VideoQuality)getVideoQuality;
+ (TXReverbType)getReverbType;
+ (TXVoiceChangerType)getVoiceChangerType;

@end

