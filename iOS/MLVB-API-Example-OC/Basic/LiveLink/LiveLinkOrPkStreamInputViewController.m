// Copyright (c) 2020 Tencent. All rights reserved.

#import "LiveLinkOrPkStreamInputViewController.h"

@interface LiveLinkOrPkStreamInputViewController ()
/// 用户id
@property (nonatomic, strong) NSString *userId;
/// 是否是主播
@property (nonatomic, assign) BOOL isAnchor;
/// 页面titleStr
@property (nonatomic, strong) NSString *titleStr;
@end

@implementation LiveLinkOrPkStreamInputViewController

- (instancetype)initWithUserId:(NSString *)userId
                      isAnchor:(BOOL)isAnchor
                         title:(NSString *)title {
    self = [super initWithNibName:@"LiveInputBaseViewController" bundle:nil];
    if (self) {
        self.userId = userId;
        self.isAnchor = isAnchor;
        self.titleStr = title;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.titleStr;
    [self setupUIString];
    [self.button addTarget:self
                    action:@selector(onButtonClick:)
          forControlEvents:UIControlEventTouchUpInside];
}


- (void)setupUIString {
    self.label.text = Localize(@"MLVB-API-Example.LiveLink.streamIdInput");
    if (_isAnchor) {
        [self.button setTitle:Localize(@"MLVB-API-Example.LiveLink.startPush")
                     forState:UIControlStateNormal];
    } else {
        [self.button setTitle:Localize(@"MLVB-API-Example.LiveLink.startPlay")
                     forState:UIControlStateNormal];
    }
}


- (void)onButtonClick:(UIButton *)button {
    [self.view endEditing:true];
    if (self.didClickNextBlock) {
        self.didClickNextBlock(self.textField.text, self.userId, self.isAnchor);
    }
}

@end
