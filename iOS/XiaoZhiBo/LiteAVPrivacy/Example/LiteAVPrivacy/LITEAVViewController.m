//
//  LITEAVViewController.m
//  LiteAVPrivacy
//
//  Created by jackyixue on 02/10/2022.
//  Copyright (c) 2022 jackyixue. All rights reserved.
//

#import "LITEAVViewController.h"
#import <LiteAVPrivacy/LiteAVPrivacy.h>

@interface LITEAVViewController ()

@end

@implementation LITEAVViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)privacyClick:(UIButton *)sender {
    LiteAVPrivacyConfig *config = [[LiteAVPrivacyConfig alloc] init];
    config.style = LiteAVPrivacyUIStyleDark;
    config.userName = @"jack";
    config.userID = @"123456";
    config.userAvatar = @"https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fup.enterdesk.com%2Fedpic%2F36%2Faf%2F84%2F36af84b51d35d4e560fb92fa065fe1d6.jpg&refer=http%3A%2F%2Fup.enterdesk.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1647078457&t=3e7c97231166f7a1854cebddb9391835";
    config.phone = @"1234567899";
    config.email = @"test@email.com";
    config.plistPath = [[NSBundle mainBundle] pathForResource:@"Privacy" ofType:@"plist"];
    LiteAVPrivacyViewController *controller = [[LiteAVPrivacyViewController alloc] initWithPrivacyConfig:config];
    [self.navigationController pushViewController:controller animated:YES];
    
}

@end
