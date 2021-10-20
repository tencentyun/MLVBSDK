/**
 * Module:   PushBgmControl
 *
 * Function: BGM控制组件
 */

#import "PushBgmControl.h"
#import "UIView+Additions.h"
#import "AppLocalized.h"

@interface PushBgmControl() <UITextFieldDelegate> {
    UISwitch    *_onlineSwitch;
    UITextField *_loopTimesFiled;
    UIButton    *_pauseBtn;
    UIButton    *_startBtn;
}
@end

@implementation PushBgmControl

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.3];
        
        int offsetX = 5;
        int offsetY = 5;
        int height = 30;
        
        UILabel *loopTimesLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, offsetY, 100, height)];
        loopTimesLabel.text = LivePlayerLocalize(@"LivePusherDemo.PushBgm.numberofcycles");
        loopTimesLabel.textColor = [UIColor whiteColor];
        _loopTimesFiled = [[UITextField alloc] initWithFrame:CGRectMake(loopTimesLabel.right, loopTimesLabel.top,
                                                                        50, height)];
        _loopTimesFiled.text = @"1";
        _loopTimesFiled.textColor = [UIColor whiteColor];
        _loopTimesFiled.delegate = self;
        
        UILabel *onlineLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.width - 160, loopTimesLabel.top,
                                                                         100, height)];
        onlineLabel.text = LivePlayerLocalize(@"LivePusherDemo.PushBgm.onlinemusic");
        onlineLabel.textColor = [UIColor whiteColor];
        _onlineSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.width - 55, loopTimesLabel.top, 50, height)];
        _onlineSwitch.on = NO;
        
        UILabel *micVolumeLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, loopTimesLabel.bottom + 10, loopTimesLabel.width, height)];
        micVolumeLabel.text = LivePlayerLocalize(@"LivePusherDemo.PushBgm.micvolume");
        micVolumeLabel.textColor = [UIColor whiteColor];
        UISlider *micVolumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(micVolumeLabel.right, micVolumeLabel.top,
                                                                               self.width - micVolumeLabel.right - offsetX, height)];
        micVolumeSlider.minimumValue = 0;
        micVolumeSlider.maximumValue = 2;
        micVolumeSlider.value = 1;
        [micVolumeSlider addTarget:self action:@selector(micVolume:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *bgmVolumeLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, micVolumeLabel.bottom + 10,
                                                                            micVolumeLabel.width, height)];
        bgmVolumeLabel.text = LivePlayerLocalize(@"LivePusherDemo.PushBgm.bgmvolume");
        bgmVolumeLabel.textColor = [UIColor whiteColor];
        UISlider *bgmVolumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(bgmVolumeLabel.right, bgmVolumeLabel.top,
                                                                               self.width - bgmVolumeLabel.right - offsetX, height)];
        bgmVolumeSlider.minimumValue = 0;
        bgmVolumeSlider.maximumValue = 2;
        bgmVolumeSlider.value = 1;
        [bgmVolumeSlider addTarget:self action:@selector(bgmVolume:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *bgmPitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, bgmVolumeLabel.bottom + 10,
                                                                           bgmVolumeLabel.width, height)];
        bgmPitchLabel.text = LivePlayerLocalize(@"LivePusherDemo.PushBgm.bgmtone");
        bgmPitchLabel.textColor = [UIColor whiteColor];
        UISlider *bgmPitchSlider = [[UISlider alloc] initWithFrame:CGRectMake(bgmPitchLabel.right, bgmPitchLabel.top,
                                                                              self.width - bgmVolumeLabel.right - offsetX, height)];
        bgmPitchSlider.minimumValue = -1;
        bgmPitchSlider.maximumValue = 1;
        bgmPitchSlider.value = 0;
        [bgmPitchSlider addTarget:self action:@selector(bgmPitch:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *startBtn = [[UIButton alloc] initWithFrame:CGRectMake(60, bgmPitchLabel.bottom + 10,
                                                                        60, height)];
        [startBtn setTitle:LivePlayerLocalize(@"LivePusherDemo.PushBgm.start") forState:UIControlStateNormal];
        [startBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [startBtn addTarget:self action:@selector(clickStart:) forControlEvents:UIControlEventTouchUpInside];
        startBtn.tag = 0;
        _startBtn = startBtn;
        
        _pauseBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.width - 120, startBtn.top, startBtn.width, startBtn.height)];
        [_pauseBtn setTitle:LivePlayerLocalize(@"LivePusherDemo.PushBgm.pause") forState:UIControlStateNormal];
        [_pauseBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [_pauseBtn addTarget:self action:@selector(clickPause:) forControlEvents:UIControlEventTouchUpInside];
        _pauseBtn.tag = 0;
        
        
        [self addSubview:loopTimesLabel];
        [self addSubview:_loopTimesFiled];
        [self addSubview:onlineLabel];
        [self addSubview:_onlineSwitch];
        [self addSubview:micVolumeLabel];
        [self addSubview:micVolumeSlider];
        [self addSubview:bgmVolumeLabel];
        [self addSubview:bgmVolumeSlider];
        [self addSubview:bgmPitchLabel];
        [self addSubview:bgmPitchSlider];
        [self addSubview:startBtn];
        [self addSubview:_pauseBtn];
    }
    return self;
}

- (void)notifyBgmIsEnded {
    [_startBtn setTitle:LivePlayerLocalize(@"LivePusherDemo.PushBgm.start") forState:UIControlStateNormal];
    _startBtn.tag = 0;
}

- (void)clickStart:(UIButton *)btn {
    if (btn.tag == 0) {
        [btn setTitle:LivePlayerLocalize(@"LivePusherDemo.PushBgm.end") forState:UIControlStateNormal];
        btn.tag = 1;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onBgmStart:online:)]) {
            int loopTimes = 0;
            if ([_loopTimesFiled.text length]) {
                loopTimes = [_loopTimesFiled.text intValue];
            }
            [self.delegate onBgmStart:loopTimes online:_onlineSwitch.on];
        }
        
    } else {
        [btn setTitle: LivePlayerLocalize(@"LivePusherDemo.PushBgm.start") forState:UIControlStateNormal];
        btn.tag = 0;
        [_pauseBtn setTitle:LivePlayerLocalize(@"LivePusherDemo.PushBgm.pause") forState:UIControlStateNormal];
        _pauseBtn.tag = 0;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onBgmStop)]) {
            [self.delegate onBgmStop];
        }
    }
}

- (void)clickPause:(UIButton *)btn {
    if (btn.tag == 0) {
        [btn setTitle:LivePlayerLocalize(@"LivePusherDemo.PushBgm.restore") forState:UIControlStateNormal];
        btn.tag = 1;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onBgmPause)]) {
            [self.delegate onBgmPause];
        }
        
    } else {
        [btn setTitle:LivePlayerLocalize(@"LivePusherDemo.PushBgm.pause") forState:UIControlStateNormal];
        btn.tag = 0;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onBgmResume)]) {
            [self.delegate onBgmResume];
        }
    }
}

- (void)micVolume:(UISlider *)slider {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onMicVolume:)]) {
        [self.delegate onMicVolume:slider.value];
    }
}

- (void)bgmVolume:(UISlider *)slider {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onBgmVolume:)]) {
        [self.delegate onBgmVolume:slider.value];
    }
}

- (void)bgmPitch:(UISlider *)slider {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onBgmPitch:)]) {
        [self.delegate onBgmPitch:slider.value];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_loopTimesFiled resignFirstResponder];
    return YES;
}

@end
