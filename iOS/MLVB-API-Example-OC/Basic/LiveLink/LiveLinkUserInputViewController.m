// Copyright (c) 2020 Tencent. All rights reserved.

#import "LiveLinkUserInputViewController.h"
#import "LiveLinkOrPkSwitchRoleViewController.h"
#import "LiveLinkOrPkStreamInputViewController.h"
#import "LiveLinkAnchorViewController.h"
#import "LiveLinkAudienceViewController.h"

@interface LiveLinkUserInputViewController ()

@end

@implementation LiveLinkUserInputViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [super initWithNibName:@"LiveInputBaseViewController" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUIString];
    [self.button addTarget:self
                    action:@selector(onButtonClick:)
          forControlEvents:UIControlEventTouchUpInside];
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
                                                title:localize(@"MLVB-API-Example.LiveLink.title")];
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
                                                 title:localize(@"MLVB-API-Example.LiveLink.title")];
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
    LiveLinkAnchorViewController* vc = [[LiveLinkAnchorViewController alloc] initWithStreamId:streamId userId:userId];
    [self.navigationController pushViewController:vc animated:true];
}

- (void)enterAudienceViewController:(NSString *)streamId userId:(NSString *)userId {
    LiveLinkAudienceViewController* vc = [[LiveLinkAudienceViewController alloc] initWithStreamId:streamId userId:userId];
    [self.navigationController pushViewController:vc animated:true];
}

@end
