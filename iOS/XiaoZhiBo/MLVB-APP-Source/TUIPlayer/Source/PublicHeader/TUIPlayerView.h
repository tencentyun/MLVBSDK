//
//  TUIPlayerView.h
//  TUIPlayer
//
//  Created by gg on 2021/9/14.
//

#import <UIKit/UIKit.h>
#import "TUIPlayerViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN
/// @brief TUIPlayerView UI显示状态
typedef NS_ENUM(NSUInteger, TUIPlayerUIState) {
    TUIPLAYER_UISTATE_DEFAULT = 0,        // 默认，展示全部视图
    TUIPLAYER_UISTATE_VIDEOONLY = 1,      // 只展示视频播放View
};

@interface TUIPlayerView : UIView

/// 设置代理对象
- (void)setDelegate:(id <TUIPlayerViewDelegate>)delegate;

/// 更新PlayerView UI显示状态
/// @param state TUIPlayerView UI显示状态
///              - TUIPLAYER_UISTATE_DEFAULT: 【默认值】展示全部UI视图
///              - TUIPLAYER_UISTATE_VIDEOONLY: 只展示视频播放预览画面。
- (void)updatePlayerUIState:(TUIPlayerUIState)state;

/// 开始拉流
/// @param url 流地址
/// @return 返回值 {@link V2TXLiveCode}
///         - 0 成功
- (NSInteger)startPlay:(NSString *)url;

/// 停止拉流
- (void)stopPlay;

/// 暂停视频流。
- (void)pauseVideo;

/// 恢复视频流。
- (void)resumeVideo;

/// 暂停音频流。
- (void)pauseAudio;

/// 恢复音频流
- (void)resumeAudio;

/// 加载挂件时可能会需要使用（TUIBarrage / TUIGift）
/// @param groupId 创建群组的 group id
- (void)setGroupId:(NSString *)groupId;

/// 关闭连麦功能
- (void)disableLinkMic;

@end

NS_ASSUME_NONNULL_END
