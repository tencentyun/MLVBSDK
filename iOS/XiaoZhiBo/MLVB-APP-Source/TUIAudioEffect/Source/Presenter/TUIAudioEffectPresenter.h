//
//  TUIAudioEffectPresenter.h
//  TUIAudioEffect
//
//  Created by jack on 2021/9/27.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TUIAudioEffectView.h"
#import "TUIAudioEffectBGMView.h"

@class TUILiveThemeConfig, TXAudioEffectManager, TUIAudioEffectModel;

@protocol TUIAudioEffectPresenterDelegate <NSObject>

// 展示音乐选择视图
- (void)audioEffectPresenterBGMSelectAlertShow;

// 音乐选择视图消失
- (void)audioEffectPresenterBGMSelectAlertDidHide;

@end

@interface TUIAudioEffectPresenter : NSObject<TUIAudioEffectBGMSelectDelegate>

@property (nonatomic, weak) UITableView *tableView;

// TXAudioEffectManager
@property (nonatomic, strong) TXAudioEffectManager *audioEffectManager;

// 音效控制数据模型
@property (nonatomic, strong) TUIAudioEffectModel *effectModel;

// 设置UI配置，每次设置均会自动调用|prepare|刷新视图
@property (nonatomic, strong) TUILiveThemeConfig *themeConfig;

@property (nonatomic, weak) id <TUIAudioEffectPresenterDelegate> delegate;

/// TUIAudioEffectPresenter 构造器
/// @param tableView  内容视图
/// @param audioEffectManager TRTC 背景音乐、短音效和人声特效的管理类
- (instancetype)initWithTableView:(UITableView *)tableView audioEffectManager:(TXAudioEffectManager *)audioEffectManager;

/// TUIAudioEffectPresenter 构造器
/// @param tableView  内容视图
/// @param audioEffectManager TRTC 背景音乐、短音效和人声特效的管理类
/// @param audioEffectModel 音效控制数据模型
- (instancetype)initWithTableView:(UITableView *)tableView
               audioEffectManager:(TXAudioEffectManager *)audioEffectManager
                 audioEffectModel:(TUIAudioEffectModel *)audioEffectModel;

/// 视图刷新
- (void)prepare;

/// 状态清除 Dealloc调用
- (void)clearStatus;

@end


