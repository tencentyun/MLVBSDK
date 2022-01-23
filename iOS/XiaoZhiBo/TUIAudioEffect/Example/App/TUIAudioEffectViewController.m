//
//  TUIAudioEffectController.m
//  TUIAudioEffect_Example
//
//  Created by jack on 2021/9/29.
//  Copyright © 2021 jackyixue. All rights reserved.
//

#import "TUIAudioEffectViewController.h"
#import "TUIAudioEffectView.h"
#import "TUIAudioEffectViewKit.h"
#import <Masonry/Masonry.h>

@interface TUIAudioEffectViewController ()
@property (strong, nonatomic) V2TXLivePusher *pusher;
@property (strong, nonatomic) TUIAudioEffectView *audioEffectView;
@end

@implementation TUIAudioEffectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    // 布局测试按钮(触发AudioEffect)
    UIButton *audioEffectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [audioEffectButton setImage:[UIImage imageNamed:@"audioEffect_icon"] forState:UIControlStateNormal];
    [audioEffectButton addTarget:self action:@selector(controlAudioEffect) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:audioEffectButton];
    [audioEffectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(40);
        make.center.mas_equalTo(0);
    }];
    
    // step1: 获取AudioEffectManager
    _pusher = [[V2TXLivePusher alloc] initWithLiveMode:V2TXLiveMode_RTC];
    [_pusher setRenderView:self.view];
    [_pusher startMicrophone];
    
    TXAudioEffectManager *audioEffectManager = [_pusher getAudioEffectManager];
    if (!audioEffectManager) {
        NSLog(@"get audioEffectManager fail");
        return;
    }
    
    // step2: 加载音效控制面板组件
    _audioEffectView = [[TUIAudioEffectView alloc] initWithFrame:[UIScreen mainScreen].bounds audioEffectManager:audioEffectManager];
    [self.view addSubview:_audioEffectView];
    [_audioEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

- (void)controlAudioEffect {
    // step 3: 在需要使用的地方调用[show]即可弹出音效面板
    [_audioEffectView show];
}

@end
