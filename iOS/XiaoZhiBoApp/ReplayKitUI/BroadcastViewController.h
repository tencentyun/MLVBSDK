//
//  BroadcastViewController.h
//  TCLVBIMDemoUploadUI
//
//  Created by annidyfeng on 16/9/5.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReplayKit/ReplayKit.h>

@interface UITextFieldEx : UITextField

@end

@interface BroadcastViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;

- (IBAction)startBroadcast:(id)sender;
- (IBAction)cancelBroadcast:(id)sender;

@end
