// Copyright (c) 2021 Tencent. All rights reserved.

#import "LivePkFindPkUserController.h"
@interface LivePkFindPkUserController ()

@end

@implementation LivePkFindPkUserController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [super initWithNibName:@"LiveInputBaseViewController" bundle:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = localize(@"MLVB-API-Example.LivePk.title");
    [self setupUIString];
    [self.button addTarget:self
                    action:@selector(onButtonClick:)
          forControlEvents:UIControlEventTouchUpInside];
}

- (void)setupUIString {
    self.label.text = localize(@"MLVB-API-Example.LivePk.roomName");
    [self.button setTitle:localize(@"MLVB-API-Example.LivePk.startPK") forState:UIControlStateNormal];
}

- (void)onButtonClick:(UIButton *)button {
    if (self.didClickNextBlock) {
        self.didClickNextBlock(self.textField.text ? : @"");
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
