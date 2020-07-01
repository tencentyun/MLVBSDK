/**
 * Module: TCUserProfileViewController
 *
 * Function: 用户信息展示
 */

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

/*
 * TCUserProfileViewController 类说明 : 该类显示用户点击右下角用户信息按钮后显示的界面
 * 界面上包括一个tableview和一个button
 *
 * tableview上显示三行元素:
 * 第一个cell显示 : 头像,昵称,ID信息,此cell不响应点击消息
 * 第二个cell显示 : 编辑个人信息,点击后进去编辑个人信息页面
 * 第三个cell显示 : 关于小直播,点击后显示版本号信息
 *
 * button是退出登陆按钮,点击后退出登陆并且返回到登录页面
 */
@interface TCUserProfileViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *dataTable;

@property (strong, nonatomic) NSMutableArray *userInfoUISetArry;

@end
