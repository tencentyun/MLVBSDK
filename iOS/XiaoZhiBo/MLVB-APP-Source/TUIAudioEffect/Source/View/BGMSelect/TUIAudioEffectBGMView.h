//
//  TUIAudioEffectBGMView.h
//  Masonry
//
//  Created by jack on 2021/9/29.
//

#import <UIKit/UIKit.h>
#import "TUIAudioEffectDefine.h"

@class TUIAudioEffectSongModel;
@protocol TUIAudioEffectBGMSelectDelegate <NSObject>

- (void)audioEffectBGMDidSelect:(TUIAudioEffectSongModel *)bgmModel;

- (void)audioEffectBGMDidDismiss;

@end

@interface TUIAudioEffectBGMView : UIView

- (instancetype)initWithFrame:(CGRect)frame bgmDataSource:(NSArray *)dataSource;

@property (nonatomic, weak) id <TUIAudioEffectBGMSelectDelegate> delegate;

/// 音乐选择视图，此方法调用前需确保已添加到父视图
- (void)show;


/// 音乐选择视图消失
- (void)dismiss;

@end
