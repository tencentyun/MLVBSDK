//
//  TUIAudioEffectTableCell.h
//  TUIAudioEffect
//
//  Created by jack on 2021/9/27.
//  音效控制视图TableCell合集

#import <UIKit/UIKit.h>
#import "TUIAudioEffectModel.h"

@class TUILiveThemeConfig;

static CGFloat TUIAudioEffectTableCellDefaultHeight = 52;
static CGFloat TUIAudioEffectTableCellCollectionHeight = 120;


@protocol TUIAudioEffectUIDelegate <NSObject>

@optional
// 背景音乐控制
- (void)audioEffectControlWithModel:(TUIAudioEffectModel *)model musicBackgroundStatus:(BOOL)isOn;

// 耳返控制
- (void)audioEffectControlWithModel:(TUIAudioEffectModel *)model enableVoiceEarMonitor:(BOOL)enable;

// 歌曲播放控制
- (void)audioEffectControlWithModel:(TUIAudioEffectModel *)model musicPlaying:(BOOL)musicPlaying;

/// 音乐音量
/// @param value 音量范围 0-100
- (void)audioEffectControlWithModel:(TUIAudioEffectModel *)model musicVolumeChanged:(NSInteger)value;

/// 人声音量
/// @param value 音量范围 0-100
- (void)audioEffectControlWithModel:(TUIAudioEffectModel *)model voiceVolumeChanged:(NSInteger)value;

/// 音乐升降调
/// @param value 音量范围 0-100
- (void)audioEffectControlWithModel:(TUIAudioEffectModel *)model musicRiseFallChanged:(double)value;

/// 变声
/// @param voiceChangeType 要设置的变声类型
- (void)audioEffectControlWithModel:(TUIAudioEffectModel *)model voiceChangeChanged:(TUIAudioEffectVoiceChangeType)voiceChangeType;

/// 混响
/// @param voiceReverbType 将要改变的混响类型
- (void)audioEffectControlWithModel:(TUIAudioEffectModel *)model voiceReverbChanged:(TUIAudioEffectVoiceReverbType)voiceReverbType;

@end

/// 音效控制Cell - Base
@interface TUIAudioEffectBaseTableCell : UITableViewCell

// Cell重用Id
@property (nonatomic, readonly, class) NSString *reuseId;

// 标题Label
@property (nonatomic, strong) UILabel *titleLabel;

// UI delegate
@property (nonatomic, weak) id<TUIAudioEffectUIDelegate> delegate;

// 1. 初始化配置视图: 布局、UI设置
- (void)setupUI;

// 2. 主题配置更新
- (void)updateUIWithThemeConfig:(TUILiveThemeConfig *)themeConfig;

// 3. 数据更新
- (void)updateUIWithData:(TUIAudioEffectModel *)data type:(TUIAudioEffectType)type;

@end

/// 音效控制Cell - Select  eg. 版权曲库
@interface TUIAudioEffectBGMSelectTableCell : TUIAudioEffectBaseTableCell

@property (nonatomic, strong) UILabel *detailLabel;

- (void)updatePlayingTimeWithProgressMs:(NSInteger)progressMs durationMs:(NSInteger)durationMs;

@end

/// 音效控制Cell - 开关Switch eg. 背景音乐
@interface TUIAudioEffectSwitchTableCell : TUIAudioEffectBaseTableCell
// 开关视图
@property (nonatomic, strong) UISwitch *switchView;
// 简介文本
@property (nonatomic, strong) UILabel *descLabel;
@end

@class TUIAudioEfectSlider;
/// 音效控制Cell - 滑动条Slider  eg. 音乐音量、人声音量、音乐升降调
@interface TUIAudioEffectSliderTableCell : TUIAudioEffectBaseTableCell
// 滑动视图
@property (nonatomic, strong) TUIAudioEfectSlider *sliderView;
// 显示Label
@property (nonatomic, strong) UILabel *valueLabel;
@end

/// 音效控制Cell - CollectionView eg. 变声、混响
@interface TUIAudioEffectCollectionTableCell : TUIAudioEffectBaseTableCell

@property (nonatomic, strong) UICollectionView *collectionView;

@end

/// 音效控制Cell - None(兼容)
@interface TUIAudioEffectNoneTableCell : TUIAudioEffectBaseTableCell

@end
