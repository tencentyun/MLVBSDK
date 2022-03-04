//
//  TUIAudioEffectModel.m
//  TUIAudioEffect
//
//  Created by jack on 2021/9/27.
//

#import "TUIAudioEffectModel.h"
#import "TUIAudioEffectDefine.h"

@implementation TUIAudioEffectSongModel

- (instancetype)init{
    if (self = [super init]) {
        // 初始化配置
        self.name = @"";
        self.currentProgressMs = 0;
        self.totalDurationMs = 0;
    }
    return self;
}

@end

@interface TUIAudioEffectModel ()

// 支持的变声数据集 TXVoiceChangeType
@property (nonatomic, strong, readwrite) NSArray <NSNumber *>*voiceChanges;

// 支持的混响数据集 TXVoiceReverbType
@property (nonatomic, strong, readwrite) NSArray <NSNumber *>*voiceReverbs;

@end

@implementation TUIAudioEffectModel

- (instancetype)init{
    if (self = [super init]) {
        
        self.musicBackgroundStatus = NO;
        
        self.musicVolume = 100;
        self.voiceVolume = 100;
        self.musicRiseFallValue = 0.00;
        
        self.voiceChanges = @[
            @(TXVoiceChangeType_0),
            @(TXVoiceChangeType_1),
            @(TXVoiceChangeType_2),
            @(TXVoiceChangeType_3),
            @(TXVoiceChangeType_11),
        ];
        self.currentVoiceChangeType = TXVoiceChangeType_0;
        self.voiceReverbs = @[
            @(TXVoiceReverbType_0),
            @(TXVoiceReverbType_1),
            @(TXVoiceReverbType_6),
            @(TXVoiceReverbType_4),
            @(TXVoiceReverbType_5),
        ];
        self.currentVoiceReverbType = TXVoiceReverbType_0;
        
        NSArray *bgmURLs = @[
        @"https://sdk-liteav-1252463788.cos.ap-hongkong.myqcloud.com/app/res/bgm/trtc/PositiveHappyAdvertising.mp3",
        @"https://sdk-liteav-1252463788.cos.ap-hongkong.myqcloud.com/app/res/bgm/trtc/SadCinematicPiano.mp3",
        @"https://sdk-liteav-1252463788.cos.ap-hongkong.myqcloud.com/app/res/bgm/trtc/WonderWorld.mp3"
        ];
        NSArray *bgmNames = @[
        @"TUIKit.AudioEffectView.MusicSelect.musicname1",
        @"TUIKit.AudioEffectView.MusicSelect.musicname2",
        @"TUIKit.AudioEffectView.MusicSelect.musicname3"
        ];
        
        NSMutableArray *datas = [NSMutableArray array];
        for (int32_t i = 0; i < 3; i++) {
            TUIAudioEffectSongModel *model = [[TUIAudioEffectSongModel alloc] init];
            model.ID = 1000 + i;
            model.path = bgmURLs[i];
            model.name = AudioEffectLocalize(bgmNames[i]);
            [datas addObject:model];
        }
        self.bgmDataSource = datas;
        self.selectBGMModel = nil;
        self.playingComplete = NO;
    }
    return self;
}

@end
