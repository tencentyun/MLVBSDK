//
//  PlayController.h
//  RTMPiOSDemo
//
//  Created by 蓝鲸 on 16/4/1.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TXLivePlayer.h"
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface PlayViewController : UIViewController<UIAlertViewDelegate>
{
    TXLivePlayer *      _txLivePlayer;

    unsigned long long  _startTime;
    unsigned long long  _lastTime;
    
    UIButton*           _btnPlay;
    UIButton*           _btnClose;
    
    BOOL                _screenPortrait;
    BOOL                _renderFillScreen;
    BOOL                _log_switch;
    BOOL                _play_switch;
    AVCaptureSession *  _VideoCaptureSession;
    
    NSString*           _logMsg;
    NSString*           _tipsMsg;
    NSString*           _testPath;
    NSInteger           _cacheStrategy;
    
    UIButton*           _btnCacheStrategy;
    UIView*             _vCacheStrategy;
    UIButton*           _radioBtnFast;
    UIButton*           _radioBtnSmooth;
    UIButton*           _radioBtnAUTO;
    UIButton*           _helpBtn;
    
    TXLivePlayConfig*   _config;
}

@property (nonatomic, assign) BOOL isLivePlay;
@property (nonatomic, assign) BOOL isRealtime;

@end
