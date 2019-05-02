//
//  TCRegisterViewController.h
//  TCLVBIMDemo
//
//  Created by dackli on 16/10/1.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCLoginModel.h"

@interface TCRegisterViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, weak) id<TCLoginListener> loginListener;

@end
