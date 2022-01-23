//
//  TUIAppDelegate.h
//  TUIAudioEffect
//
//  Created by jackyixue on 09/29/2021.
//  Copyright (c) 2021 jackyixue. All rights reserved.
//

@import UIKit;

@interface TUIAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

@interface TUIAppDelegate (RootController)

- (void)showMainViewController;

- (void)showLoginViewController;

@end
