//
//  TCEditUserInfoController.h
//  TCLVBIMDemo
//
//  Created by jemilyzhou on 16/8/1.
//  Copyright © 2016年 tencent. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


/*
 * TCEditUserInfoController 类说明 : 该类显示用户点击编辑个人信息后显示页面
 * 页面上只有一个tableview控件
 *
 * tableview上显示三行元素:
 * 第一个cell显示 : 头像, 点击后显示选择相机或者相册
 * 第二个cell显示 : 昵称, 点击后可以显示键盘并直接编辑
 * 第三个cell显示 : 性别, 点击后选择男 or 女
 */

@interface TCEditUserInfoViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView      *tableView;

@property (strong, nonatomic) NSMutableArray   *userInfoArry;

@end
