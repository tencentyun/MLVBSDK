// Copyright (c) 2021 Tencent. All rights reserved.

#import "LivePkUserInputViewController.h"
#import "LiveLinkOrPkSwitchRoleViewController.h"
#import "LiveLinkOrPkStreamInputViewController.h"
#import "LivePkAnchorViewController.h"
#import "LivePkAudienceViewController.h"

@interface LivePkUserInputViewController ()

@end

@implementation LivePkUserInputViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [super initWithNibName:@"LiveInputBaseViewController" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = localize(@"MLVB-API-Example.LivePk.title");
    [self setupUIString];
    [self.button addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupUIString {
    self.label.text = localize(@"MLVB-API-Example.LiveLink.userIdInput");
    self.tips.text = localize(@"MLVB-API-Example.LiveLink.tips");
    [self.button setTitle:localize(@"MLVB-API-Example.LiveLink.nextStep") forState:UIControlStateNormal];
}

- (void)onButtonClick:(UIButton *)button {
    [self.view endEditing:true];
    [self enterSwitchRoleViewController];
}

- (void)enterSwitchRoleViewController {
    LiveLinkOrPkSwitchRoleViewController *vc = [[LiveLinkOrPkSwitchRoleViewController alloc]
                                                initWithUserId:self.textField.text
                                                title:localize(@"MLVB-API-Example.LivePk.title")];
    __weak typeof(self) wealSelf = self;
    vc.didClickNextBlock = ^(NSString * _Nonnull userId, BOOL isAnchor) {
        __strong typeof(wealSelf) strongSelf = wealSelf;
        [strongSelf enterStreamInputViewController:userId isAnchor:isAnchor];
    };
    [self.navigationController pushViewController:vc animated:true];
}

- (void)enterStreamInputViewController:(NSString *)userId isAnchor:(BOOL)isAnchor {
    LiveLinkOrPkStreamInputViewController *vc = [[LiveLinkOrPkStreamInputViewController alloc]
                                                 initWithUserId:userId
                                                 isAnchor:isAnchor
                                                 title:localize(@"MLVB-API-Example.LivePk.title")];
    __weak typeof(self) wealSelf = self;
    vc.didClickNextBlock = ^(NSString * _Nonnull streamId, NSString * _Nonnull userId, BOOL isAnchor) {
        __strong typeof(wealSelf) strongSelf = wealSelf;
        if (isAnchor) {
            [strongSelf enterAnchorViewController:streamId userId:userId];
        } else {
            [strongSelf enterAudienceViewController:streamId userId:userId];
        }
    };
    [self.navigationController pushViewController:vc animated:true];
}

- (void)enterAnchorViewController:(NSString *)streamId userId:(NSString *)userId {
    LivePkAnchorViewController* vc = [[LivePkAnchorViewController alloc] initWithStreamId:streamId userId:userId];
    [self.navigationController pushViewController:vc animated:true];
}

- (void)enterAudienceViewController:(NSString *)streamId userId:(NSString *)userId {
    LivePkAudienceViewController* vc = [[LivePkAudienceViewController alloc] initWithStreamId:streamId userId:userId];
    [self.navigationController pushViewController:vc animated:true];
}

@end
