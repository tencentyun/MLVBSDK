//
//  TUIAudioEffectModel.h
//  TUIAudioEffect
//
//  Created by jack on 2021/9/27.
//

#import <Foundation/Foundation.h>
#import "TXAudioEffectManager.h"

typedef NS_ENUM(NSInteger, TUIAudioEffectType) {
    TUIAudioEffectTypeNone = -1,
    // 背景音乐
    TUIAudioEffectTypeMusicBackground = 0,
    // 版权曲库
    TUIAudioEffectTypeCopyrightLibrary,
    // 音乐音量
    TUIAudioEffectTypeMusicVolume,
    // 人声音量
    TUIAudioEffectTypeVoiceVolume,
    // 音乐升降调
    TUIAudioEffectTypeMusicRiseFall,
    // 变声
    TUIAudioEffectTypeVoiceChange,
    // 混响
    TUIAudioEffectTypeVoiceReverb
};

typedef TXVoiceChangeType TUIAudioEffectVoiceChangeType;
typedef TXVoiceReverbType TUIAudioEffectVoiceReverbType;


@interface TUIAudioEffectSongModel : TXAudioMusicParam

@property (nonatomic, strong) NSString *name;

@property (nonatomic, assign) NSInteger currentProgressMs;

@property (nonatomic, assign) NSInteger totalDurationMs;

@end

// 音效控制模型
@interface TUIAudioEffectModel : NSObject

// 背景音乐开关 Default is No
@property (nonatomic, assign) BOOL musicBackgroundStatus;
// 音乐升降调 取值范围-1.00~1.00，Default is 0.00
@property (nonatomic, assign) double musicRiseFallValue;
// 音乐音量 取值范围0~100，Default is 100
@property (nonatomic, assign) NSInteger musicVolume;
// 选中的曲子 Default is nil
@property (nonatomic, strong) TUIAudioEffectSongModel *selectBGMModel;
// 是否正在播放
@property (nonatomic, assign) BOOL musicPlaying;
// 是否播放完成
@property (nonatomic, getter=isPlayingComplete) BOOL playingComplete;

// 耳返开关 Default is NO
@property (nonatomic, assign) BOOL enableVoiceEarMonitor;
// 人声音量 取值范围0~100，Default is 100
@property (nonatomic, assign) NSInteger voiceVolume;

// 支持的变声数据集 @[@(TUIAudioEffectVoiceChangeType)] => [原声、熊孩子、萝莉、大叔、空灵]
@property (nonatomic, readonly) NSArray *voiceChanges;
// 当前变声类型 Default is TXVoiceChangeType_0
@property (nonatomic, assign) TUIAudioEffectVoiceChangeType currentVoiceChangeType;

// 支持的混响数据集 @[@TUIAudioEffectVoiceReverbType()] => [无效果、KTV、金属声、低沉、洪亮]
@property (nonatomic, readonly) NSArray *voiceReverbs;
// 当前混响类型 Default is TXVoiceReverbType_0
@property (nonatomic, assign) TUIAudioEffectVoiceReverbType currentVoiceReverbType;

// 背景音乐资源
@property (nonatomic, strong) NSArray *bgmDataSource;

@end


