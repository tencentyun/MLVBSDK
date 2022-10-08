//
//  ThirdBeautyEntranceViewController.m
//  MLVB-API-Example-OC
//
//  Created by summer on 2022/5/11.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "ThirdBeautyEntranceViewController.h"
#import "ThirdBeautyFaceunityViewController.h"
#import "ThirdBeautyTencentEffectViewController.h"
@interface ThirdBeautyEntranceViewController ()
@property(nonatomic, strong) UIButton *faceunityButton;
@property(nonatomic, strong) UIButton *xMagicButton;
@end

@implementation ThirdBeautyEntranceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = localize(@"MLVB-API-Example.Home.ThirdBeauty");
    self.view.backgroundColor = [UIColor blackColor];
    [self setupUI];
}

- (void)setupUI{
    self.faceunityButton.frame = CGRectMake(22,
                                            self.view.frame.size.height * 0.5 - 75, UIScreen.mainScreen.bounds.size.width-44, 50);
    self.xMagicButton.frame = CGRectMake(22,
                                         self.view.frame.size.height * 0.5 + 15, UIScreen.mainScreen.bounds.size.width-44, 50);
    [self.view addSubview:self.faceunityButton];
    [self.view addSubview:self.xMagicButton];
}

#pragma mark - Touch Event
- (void)clickBeautyButton {
    UIViewController *controller =
    [[ThirdBeautyFaceunityViewController alloc] initWithNibName:@"ThirdBeautyFaceunityViewController"
                                                         bundle:nil];
    [self.navigationController pushViewController:controller animated:true];
}

- (void)clickBytedButton {
    UIViewController *controller =
    [[ThirdBeautyTencentEffectViewController alloc] initWithNibName:@"ThirdBeautyTencentEffectViewController"
                                                             bundle:nil];
    [self.navigationController pushViewController:controller animated:true];
}

#pragma mark - Gettter
- (UIButton *)faceunityButton {
    if (!_faceunityButton) {
        _faceunityButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        _faceunityButton.layer.cornerRadius = 5;
        [_faceunityButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _faceunityButton.backgroundColor = [UIColor blueColor];
        [_faceunityButton setTitle:localize(@"MLVB-API-Example.ThirdBeauty.faceunity") forState:UIControlStateNormal];
        [_faceunityButton addTarget:self
                             action:@selector(clickBeautyButton)
                   forControlEvents:UIControlEventTouchUpInside];
    }
    return _faceunityButton;
}

- (UIButton *)xMagicButton {
    if (!_xMagicButton) {
        _xMagicButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_xMagicButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _xMagicButton.layer.cornerRadius = 5;
        _xMagicButton.backgroundColor = [UIColor blueColor];
        [_xMagicButton setTitle:localize(@"MLVB-API-Example.ThirdBeauty.xmagic") forState:UIControlStateNormal];
        [_xMagicButton addTarget:self
                          action:@selector(clickBytedButton)
                forControlEvents:UIControlEventTouchUpInside];
    }
    return _xMagicButton;
}

@end

