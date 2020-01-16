//
//  PublishViewController.h
//  RTMPiOSDemo
//
//  Created by 蓝鲸 on 16/4/1.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "TXLivePush.h"
//#import "TXUGCRecord.h"
#import "BeautySettingPanel.h"

@interface PushMusicInfo : NSObject
@property (nonatomic, copy) NSString* filePath;
@property (nonatomic, copy) NSString* soneName;
@property (nonatomic, copy) NSString* singerName;
@property (nonatomic, assign) CGFloat duration;
@end

@interface PublishViewController : UIViewController
{
    BOOL _publish_switch;
    BOOL _hardware_switch;
    BOOL _log_switch;
    BOOL _camera_switch;
    CGFloat _specia_level;
 
    int  _hd_level;
    BOOL _screenPortrait;
    BOOL _isMirror;
    
    UIButton*    _btnPublish;
    UIButton*    _btnCamera;
    UIButton*    _btnBeauty;
    UIButton*    _btnHardware;
    UIButton*    _btnLog;
    UIButton*    _btnResolution;
    UIButton*    _btnScreenOrientation;
    UIButton*    _btnMirror;
    UIButton*    _btnBgm;
    
    BOOL         _autoBitrate;
    BOOL         _autoResolution;
    UIButton*    _btnAutoBitrate;
    UIButton*    _btnAutoResolution;
    
    UIButton*    _radioBtnFHD;
    UIButton*    _radioBtnHD;
    UIButton*    _radioBtnSD;
    UIButton*    _radioBtnLinkmicBig;
    UIButton*    _radioBtnLinkmicSmall;
    UIButton*    _radioBtnVideoChat;
    
    BeautySettingPanel*   _vBeauty;

    UIControl*   _vHD;
    
    unsigned long long  _startTime;
    unsigned long long  _lastTime;
    
    NSString*       _tipsMsg;
    NSString*       _testPath;
    BOOL            _isPreviewing;
    
    
    UIButton    *_btnRecordVideo;
    UILabel     *_labProgress;
    
    BOOL                _recordStart;
    float               _recordProgress;
//    TXPublishParam       *_publishParam;
    BOOL                _isPlayBgm;
}

@end
