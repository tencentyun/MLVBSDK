//
//  TUIPusherRenderView.h
//  TUIPusher
//
//  Created by gg on 2021/10/12.
//

#import <UIKit/UIKit.h>
#import "TUIPusherViewDelegate.h"
#import "TUIPusherPresenter.h"

NS_ASSUME_NONNULL_BEGIN

@class TUIPusherPresenter, TUIPusherView;

@interface TUIPusherRenderView : UIView

@property (nonatomic, readonly) UIView *previewView;
@property (nonatomic, readonly) UIView *remoteView;

@property (nonatomic, weak) TUIPusherView *pusherView;

- (instancetype)initWithFrame:(CGRect)frame presenter:(TUIPusherPresenter *)presenter;

- (void)setDelegate:(id <TUIPusherViewDelegate>)delegate;

- (BOOL)start:(NSString *)url;

- (void)stop;

- (BOOL)sendPKRequest:(NSString *)userID;

- (void)cancelPKRequest;

- (void)stopPK;

- (void)stopJoinAnchor;

// 设置选项
- (void)setMirror:(BOOL)isMirror;

- (void)switchCamera:(BOOL)isFrontCamera;

- (void)setVideoResolution:(VideoResolution)resolution;

@end

NS_ASSUME_NONNULL_END
