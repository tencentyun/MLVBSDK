//
//  TUIAudioEffectPresenter.m
//  TUIAudioEffect
//
//  Created by jack on 2021/9/27.
//

#import "TUIAudioEffectPresenter.h"
#import "TUIAudioEffectDefine.h"
#import "TXAudioEffectManager.h"

#import "TUIAudioEffectTableCell.h"

@interface TUIAudioEffectPresenter ()<UITableViewDelegate, UITableViewDataSource, TUIAudioEffectUIDelegate>

// 是否开启选择背景音乐、音乐音量调节功能
@property (nonatomic, assign) BOOL enableSelectBGM;

// TableView 数据源
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation TUIAudioEffectPresenter

- (instancetype)initWithTableView:(UITableView *)tableView audioEffectManager:(TXAudioEffectManager *)audioEffectManager{
    return [self initWithTableView:tableView audioEffectManager:audioEffectManager audioEffectModel:nil];
}

- (instancetype)initWithTableView:(UITableView *)tableView audioEffectManager:(TXAudioEffectManager *)audioEffectManager audioEffectModel:(TUIAudioEffectModel *)audioEffectModel{
    if (self = [super init]) {
        self.effectModel = audioEffectModel;
        self.audioEffectManager = audioEffectManager;
        // 1. 数据源初始化
        [self initDataSource];
        // 2. 视图配置
        self.tableView = tableView;
        // 3. Cell注册
        [self registerCell];
        // 4. 代理设置
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
    }
    return self;
}

- (void)clearStatus{
    if (self.effectModel.selectBGMModel) {
        int32_t bgmID = _effectModel.selectBGMModel.ID;
        [_audioEffectManager pausePlayMusic:bgmID];
        [_audioEffectManager setMusicPitch:bgmID pitch:0.0];
        
        [_audioEffectManager setMusicPlayoutVolume:bgmID volume:100];
        [_audioEffectManager setMusicPublishVolume:bgmID volume:100];
        
        [_audioEffectManager stopPlayMusic:bgmID];
        // 音乐音量
        _effectModel.selectBGMModel = nil;
    }
    // 耳返
    [_audioEffectManager enableVoiceEarMonitor:NO];
    // 人声音量
    [_audioEffectManager setVoiceVolume:100];
    // 变声
    [_audioEffectManager setVoiceChangerType:TXVoiceChangeType_0];
    // 混响1
    [_audioEffectManager setVoiceReverbType:TXVoiceReverbType_0];
}

#pragma mark - 数据源初始化
- (void)initDataSource{
    NSArray *effectTypes = @[
        @(TUIAudioEffectTypeMusicBackground), // 背景音乐
        @(TUIAudioEffectTypeCopyrightLibrary), // 版权曲库
        @(TUIAudioEffectTypeMusicVolume), // 音乐音量
        @(TUIAudioEffectTypeVoiceVolume), // 人声音量
        @(TUIAudioEffectTypeMusicRiseFall),  // 音乐升降调
        @(TUIAudioEffectTypeVoiceChange), // 变声
        @(TUIAudioEffectTypeVoiceReverb) // 混响
    ];
    // 数据源
    _dataSource = [NSMutableArray arrayWithArray:effectTypes];
    
    // 数据模型初始化
    if (!_effectModel) {
        _effectModel = [[TUIAudioEffectModel alloc] init];
    }
}

#pragma mark - 注册Cell
/// TableView Cell注册
- (void)registerCell{
    [_tableView registerClass:[TUIAudioEffectBGMSelectTableCell class] forCellReuseIdentifier:TUIAudioEffectBGMSelectTableCell.reuseId];
    [_tableView registerClass:[TUIAudioEffectSwitchTableCell class] forCellReuseIdentifier:TUIAudioEffectSwitchTableCell.reuseId];
    [_tableView registerClass:[TUIAudioEffectSliderTableCell class] forCellReuseIdentifier:TUIAudioEffectSliderTableCell.reuseId];
    [_tableView registerClass:[TUIAudioEffectCollectionTableCell class] forCellReuseIdentifier:TUIAudioEffectCollectionTableCell.reuseId];
    // None 未识别-兼容性支持
    [_tableView registerClass:[TUIAudioEffectNoneTableCell class] forCellReuseIdentifier:TUIAudioEffectNoneTableCell.reuseId];
}

#pragma mark - 视图刷新
- (void)prepare{
    [self.tableView reloadData];
}

#pragma mark - Music相关控制
- (void)stopMusic{
    LOGD("[TUIAudioEffect] BGM status: stop");
    if (_effectModel.selectBGMModel) {
        int32_t bgmID = _effectModel.selectBGMModel.ID;
        [_audioEffectManager stopPlayMusic:bgmID];
    }
    // 播放状态
    _effectModel.musicPlaying = NO;
    // 重置播放时长
    _effectModel.selectBGMModel.currentProgressMs = 0;
    // 重置所选中的音乐
    _effectModel.selectBGMModel = nil;
    // 刷新UI
    [self reloadBGMCellStatus];
}

- (void)playMusicWithSong:(TUIAudioEffectSongModel *)song{
    if (_effectModel.selectBGMModel) {
        if (_effectModel.selectBGMModel.ID == song.ID) {
            [self resumePlay];
            return;
        } else {
            [self stopMusic];
        }
    }
    // 更新当前播放的音乐
    _effectModel.selectBGMModel = song;
    // 更新播放状态
    _effectModel.musicPlaying = YES;
    _effectModel.playingComplete = NO;
    // 刷新UI
    [self reloadBGMCellStatus];
    // 更新播放进度
    [self musicPlayingWithProgressMs:0 durationMs:song.totalDurationMs];
    LOGD("[TUIAudioEffect] BGM status: start play %@", song.name);
    __weak typeof(self) weakSelf = self;
    // 开始播放音乐
    [_audioEffectManager startPlayMusic:song onStart:^(NSInteger errCode) {
        // 开始播放回调
        dispatch_async(dispatch_get_main_queue(), ^{
            // 更新音量大小设置
            NSInteger value = weakSelf.effectModel.musicVolume;
            int32_t songId = weakSelf.effectModel.selectBGMModel.ID;
            [weakSelf.audioEffectManager setMusicPlayoutVolume:songId volume:value];
            [weakSelf.audioEffectManager setMusicPublishVolume:songId volume:value];
        });
    } onProgress:^(NSInteger progressMs, NSInteger durationMs) {
        // 播放进度回调
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.effectModel.musicPlaying = YES;
            [weakSelf musicPlayingWithProgressMs:progressMs durationMs:durationMs];
        });
    } onComplete:^(NSInteger errCode) {
        // 播放完成回调
        dispatch_async(dispatch_get_main_queue(), ^{
            // 更新播放状态
            weakSelf.effectModel.musicPlaying = NO;
            weakSelf.effectModel.playingComplete = YES;
            // 刷新UI
            [weakSelf reloadBGMCellStatus];
        });
    }];
}

/// 恢复播放
- (void)resumePlay{
    LOGD("[TUIAudioEffect] BGM status: resume play");
    if (_effectModel.selectBGMModel) {
        int32_t bgmID = _effectModel.selectBGMModel.ID;
        [_audioEffectManager resumePlayMusic:bgmID];
    }
    _effectModel.musicPlaying = YES;
    [self reloadBGMCellStatus];
}

/// 暂停播放
- (void)pausePlay{
    LOGD("[TUIAudioEffect] BGM status: pause");
    if (_effectModel.selectBGMModel) {
        int32_t bgmID = _effectModel.selectBGMModel.ID;
        [_audioEffectManager pausePlayMusic:bgmID];
    }
    _effectModel.musicPlaying = NO;
    [self reloadBGMCellStatus];
}

#pragma mark - 音乐播放回调
/// 刷新播放UI状态
- (void)reloadBGMCellStatus{
    NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
}

/// 播放进度更新
- (void)musicPlayingWithProgressMs:(NSInteger)progressMs durationMs:(NSInteger)durationMs{
    if (!_effectModel.musicPlaying) {
        return;
    }
    _effectModel.selectBGMModel.currentProgressMs = progressMs;
    _effectModel.selectBGMModel.totalDurationMs = durationMs;
    NSIndexPath *cellIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    TUIAudioEffectBGMSelectTableCell *cell = [self.tableView cellForRowAtIndexPath:cellIndexPath];
    if (cell) {
        [cell updatePlayingTimeWithProgressMs:progressMs durationMs:durationMs];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < _dataSource.count) {
        TUIAudioEffectType effectType = ((NSNumber *)_dataSource[indexPath.row]).integerValue;
        TUIAudioEffectBaseTableCell *cell = [self cellForEffectType:effectType tableView:tableView atIndexPath:indexPath];
        [cell updateUIWithThemeConfig:_themeConfig];
        [cell updateUIWithData:_effectModel type:effectType];
        cell.delegate = self;
        return cell;
    }
    TUIAudioEffectNoneTableCell *cell = [tableView dequeueReusableCellWithIdentifier:TUIAudioEffectNoneTableCell.reuseId forIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < _dataSource.count) {
        TUIAudioEffectType effectType = ((NSNumber *)_dataSource[indexPath.row]).integerValue;
        if (effectType == TUIAudioEffectTypeVoiceChange || effectType == TUIAudioEffectTypeVoiceReverb) {
            return TUIAudioEffectTableCellCollectionHeight;
        }
        return TUIAudioEffectTableCellDefaultHeight;
    }
    return 0.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < _dataSource.count) {
        TUIAudioEffectType effectType = ((NSNumber *)_dataSource[indexPath.row]).integerValue;
        if (effectType == TUIAudioEffectTypeCopyrightLibrary) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(audioEffectPresenterBGMSelectAlertShow)]) {
                [self.delegate audioEffectPresenterBGMSelectAlertShow];
            }
        }
    }
}

#pragma mark - TUIAudioEffectUIDelegate
// 控制耳返开关
- (void)audioEffectControlWithModel:(TUIAudioEffectModel *)model enableVoiceEarMonitor:(BOOL)enable{
    LOGD("[TUIAudioEffect] enableVoiceEarMonitor: %@", @(enable));
    [_audioEffectManager enableVoiceEarMonitor:enable];
    _effectModel.enableVoiceEarMonitor = enable;
}

// 控制音乐播放状态
- (void)audioEffectControlWithModel:(TUIAudioEffectModel *)model musicPlaying:(BOOL)musicPlaying {
    if (!_effectModel.selectBGMModel) {
        return;
    }
    if (_effectModel.musicPlaying) {
        // 暂停播放
        [self pausePlay];
    } else if (_effectModel.isPlayingComplete) {
        // 播放已结束，重新开始播放
        TUIAudioEffectSongModel *currentSong = _effectModel.selectBGMModel;
        // 重置当前播放Model
        _effectModel.selectBGMModel = nil;
        // 重新播放
        [self playMusicWithSong:currentSong];
    } else {
        // 恢复播放
        [self resumePlay];
    }
}

// 控制音乐升降调
- (void)audioEffectControlWithModel:(TUIAudioEffectModel *)model musicRiseFallChanged:(double)value {
    if (!_effectModel.selectBGMModel) {
        return;
    }
    LOGD("[TUIAudioEffect] musicRiseFallChanged: %@", @(value));
    [_audioEffectManager setMusicPitch:model.selectBGMModel.ID pitch:value];
    _effectModel.musicRiseFallValue = value;
}

// 控制音乐音量
- (void)audioEffectControlWithModel:(TUIAudioEffectModel *)model musicVolumeChanged:(NSInteger)value {
    if (!_effectModel.selectBGMModel) {
        return;
    }
    LOGD("[TUIAudioEffect] musicVolumeChanged: %@", @(value));
    [_audioEffectManager setMusicPlayoutVolume:_effectModel.selectBGMModel.ID volume:value];
    [_audioEffectManager setMusicPublishVolume:_effectModel.selectBGMModel.ID volume:value];
    _effectModel.musicVolume = value;
}

// 控制人声音量
- (void)audioEffectControlWithModel:(TUIAudioEffectModel *)model voiceVolumeChanged:(NSInteger)value {
    LOGD("[TUIAudioEffect] voiceVolumeChanged: %@", @(value));
    [_audioEffectManager setVoiceVolume:value];
    _effectModel.voiceVolume = value;
}

// 变声
- (void)audioEffectControlWithModel:(TUIAudioEffectModel *)model voiceChangeChanged:(TUIAudioEffectVoiceChangeType)voiceChangeType{
    LOGD("[TUIAudioEffect] voiceChangeChanged: %@", @(voiceChangeType));
    [_audioEffectManager setVoiceChangerType:voiceChangeType];
    _effectModel.currentVoiceChangeType = voiceChangeType;
}

// 混响
- (void)audioEffectControlWithModel:(TUIAudioEffectModel *)model voiceReverbChanged:(TUIAudioEffectVoiceReverbType)voiceReverbType{
    LOGD("[TUIAudioEffect] voiceReverbChanged: %@", @(voiceReverbType));
    [_audioEffectManager setVoiceReverbType:voiceReverbType];
    _effectModel.currentVoiceReverbType = voiceReverbType;
}

#pragma mark - TUIAudioEffectBGMSelectDelegate
- (void)audioEffectBGMDidSelect:(TUIAudioEffectSongModel *)bgmModel{
    [self playMusicWithSong:bgmModel];
}

- (void)audioEffectBGMDidDismiss{
    if (_delegate && [_delegate respondsToSelector:@selector(audioEffectPresenterBGMSelectAlertDidHide)]) {
        [_delegate audioEffectPresenterBGMSelectAlertDidHide];
    }
}

#pragma mark - Get cell from AudioEffectModel
/// 便利获取Cell
/// @param type 音效数据类型
/// @param tableView tableView
///
/// @param indexPath 索引
- (TUIAudioEffectBaseTableCell *)cellForEffectType:(TUIAudioEffectType)type tableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath{
    if (type == TUIAudioEffectTypeMusicBackground) {
        return [tableView dequeueReusableCellWithIdentifier:TUIAudioEffectSwitchTableCell.reuseId forIndexPath:indexPath];
    }
    if (type == TUIAudioEffectTypeCopyrightLibrary) {
        return [tableView dequeueReusableCellWithIdentifier:TUIAudioEffectBGMSelectTableCell.reuseId forIndexPath:indexPath];
    }
    if (type == TUIAudioEffectTypeMusicVolume) {
        return [tableView dequeueReusableCellWithIdentifier:TUIAudioEffectSliderTableCell.reuseId forIndexPath:indexPath];
    }
    if (type == TUIAudioEffectTypeVoiceVolume) {
        return [tableView dequeueReusableCellWithIdentifier:TUIAudioEffectSliderTableCell.reuseId forIndexPath:indexPath];
    }
    if (type == TUIAudioEffectTypeMusicRiseFall) {
        return [tableView dequeueReusableCellWithIdentifier:TUIAudioEffectSliderTableCell.reuseId forIndexPath:indexPath];
    }
    if (type == TUIAudioEffectTypeVoiceChange) {
        return [tableView dequeueReusableCellWithIdentifier:TUIAudioEffectCollectionTableCell.reuseId forIndexPath:indexPath];
    }
    if (type == TUIAudioEffectTypeVoiceReverb) {
        return [tableView dequeueReusableCellWithIdentifier:TUIAudioEffectCollectionTableCell.reuseId forIndexPath:indexPath];
    }
    return [tableView dequeueReusableCellWithIdentifier:TUIAudioEffectNoneTableCell.reuseId forIndexPath:indexPath];
}

#pragma mark - Setter
- (void)setThemeConfig:(TUILiveThemeConfig *)themeConfig{
    _themeConfig = themeConfig;
    [self prepare];
}

@end
