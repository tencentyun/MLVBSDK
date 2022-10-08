//
//  LivePkAudienceViewController.m
//  MLVB-API-Example-OC
//
//  Created by bluedang on 2021/7/1.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "LivePkAudienceViewController.h"

@interface LivePkAudienceViewController ()

@property (strong, nonatomic) NSString* streamId;
@property (strong, nonatomic) V2TXLivePlayer *livePlayer;

@end

@implementation LivePkAudienceViewController

- (instancetype)initWithStreamId:(NSString *)streamId userId:(NSString *)userId {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    self.streamId = streamId;
    return self;
}

- (V2TXLivePlayer *)livePlayer {
    if (!_livePlayer) {
        _livePlayer = [[V2TXLivePlayer alloc] init];
    }
    return _livePlayer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDefaultUIConfig];
    [self startLebPlay:self.streamId];
}

- (void)setupDefaultUIConfig {
    self.title = self.streamId;
}

- (void)startLebPlay:(NSString*)streamId {
    NSString *url = [URLUtils generateLebPlayUrl:streamId];
    [self.livePlayer setRenderView:self.view];
    [self.livePlayer startLivePlay:url];

}

- (void)stopPlay {
    [self.livePlayer stopPlay];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:true];
}

@end
