     //
//  TCUserInfoController.m
//  TCLVBIMDemo
//
//  Created by jemilyzhou on 16/8/1.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "TCUserInfoViewController.h"
#import "TCEditUserInfoViewController.h"
#import "TCUserInfoCell.h"
#import <ImSDK/ImSDK.h>
//#import "ImSDK/TIMFriendshipManager.h"//imTODO:
#import "TCUserInfoModel.h"
#import "TCLoginModel.h"
#import "TCConstants.h"
#import "TXLivePlayer.h"
#import <UIKit/UIKit.h>
#import <mach/mach.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "TCLVBWebViewController.h"
#import "AppDelegate.h"
#import "ColorMacro.h"
#import "TCUtil.h"
#import "UIView+Additions.h"

#if YOUTU_AUTH
#import "TCYTRealNameAuthViewController.h"
#endif

static NSString * const HomePageURL = @"https://cloud.tencent.com/product/mlvb";
#define L(X) NSLocalizedString((X), nil)

extern BOOL g_bNeedEnterPushSettingView;

@implementation TCUserInfoViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KReloadUserInfoNotification object:nil];
}

/**
 *  用于点击 退出登录 按钮后的回调,用于登录出原界面
 *
 *  @param sender 无意义
 */
- (void)logout:(id)sender
{
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    
//    [[TCLoginModel sharedInstance] logout:^{
//        [app enterLoginUI];
//        DebugLog(@"退出登录成功");
//    } fail:^(int code, NSString *msg) {
//        [app enterLoginUI];
//        DebugLog(@"退出登录失败 errCode = %d, errMsg = %@", code, msg);
//    }];
    [[TCLoginModel sharedInstance] logout:^{
         [app enterLoginUI];
        DebugLog(@"退出登录成功");
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *viewBack=[[UIView alloc] init];
    viewBack.frame = self.view.frame;
    viewBack.backgroundColor= RGB(0xF3,0xF3,0xF3);
    [self.view addSubview:viewBack];
    
    // 初始化需要绘制在tableview上的数据
    __weak typeof(self) ws = self;
    TCUserInfoCellItem *backFaceItem = [[TCUserInfoCellItem alloc] initWith:@"" value:@"" type:TCUserInfo_View action:^(TCUserInfoCellItem *menu, TCUserInfoTableViewCell *cell) {
        nil; }];
    
    TCUserInfoCellItem *setItem = [[TCUserInfoCellItem alloc] initWith:@"编辑个人信息" value:nil type:TCUserInfo_Edit action:^(TCUserInfoCellItem *menu, TCUserInfoTableViewCell *cell) {
        [ws onEditUserInfo:menu cell:cell]; } ];
    
    TCUserInfoCellItem *aboutItem = [[TCUserInfoCellItem alloc] initWith:@"关于小直播" value:nil type:TCUserInfo_About action:^(TCUserInfoCellItem *menu, TCUserInfoTableViewCell *cell) { [ws onShowAppVersion:menu cell:cell]; } ];
    
    TCUserInfoCellItem *getSupportItem = [[TCUserInfoCellItem alloc] initWith:NSLocalizedString(@"获取技术支持服务", nil) value:nil type:TCUserInfo_About action:^(TCUserInfoCellItem *menu, TCUserInfoTableViewCell *cell) { [ws onShowAppSupport:menu cell:cell]; } ];
    
    TCUserInfoCellItem *aboutSDKItem = [[TCUserInfoCellItem alloc] initWith:NSLocalizedString(@"产品介绍", nil) value:nil type:TCUserInfo_About action:^(TCUserInfoCellItem *menu, TCUserInfoTableViewCell *cell) { [ws onShowSDKInfo:menu cell:cell]; } ];

#if YOUTU_AUTH
    CGFloat quitBtnYSpace = 425;
    TCUserInfoCellItem *authItem = [[TCUserInfoCellItem alloc] initWith:@"实名认证" value:nil type:TCUserInfo_Authenticate action:^(TCUserInfoCellItem *menu,
                                                                                                                                TCUserInfoTableViewCell *cell) { [ws onAuthenticate:menu cell:cell]; } ];
    
    _userInfoUISetArry = [NSMutableArray arrayWithArray:@[backFaceItem,setItem, aboutItem, authItem,getSupportItem, aboutSDKItem]];
#else
    CGFloat quitBtnYSpace = 385;
    _userInfoUISetArry = [NSMutableArray arrayWithArray:@[backFaceItem,setItem, aboutItem,getSupportItem, aboutSDKItem]];
#endif
    
    //设置tableview属性
    CGRect frame = self.view.bounds;//CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, tableHeight);
    _dataTable = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    [_dataTable setDelegate:self];
    [_dataTable setDataSource:self];
    [_dataTable setScrollEnabled:NO];
    [_dataTable setSeparatorColor:RGB(0xD8,0xD8,0xD8)];
    _dataTable.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_dataTable];
    
    //计算退出登录按钮的位置和显示
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(0, quitBtnYSpace, self.view.frame.size.width, 45);
    button.backgroundColor = [UIColor whiteColor];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button setTitle:@"退出登录" forState: UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    [button addTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *wrapper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 75)];
    wrapper.backgroundColor = UIColor.clearColor;
    [wrapper addSubview:button];
    button.bottom = wrapper.height;
    _dataTable.tableFooterView = wrapper;

    // 设置通知消息,接受到通知后重绘cell,确保更改后的用户资料能同步到用户信息界面
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KReloadUserInfoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserInfoOnController:) name:KReloadUserInfoNotification object:nil];
    
    return;
}
#pragma mark 与view界面相关
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
}
/**
 *  用于接受头像下载成功后通知,因为用户可能因为网络情况下载头像很慢甚至失败数次,导致用户信息页面显示默认头像
 *  当用户头像下载成功后刷新tableview,使得头像信息得以更新
 *  另外如果用户在 编辑个人页面 修改头像或者修改昵称,也会发送通知,通知用户信息界面信息变更
 *
 *  @param notification 无意义
 */
-(void)updateUserInfoOnController:(NSNotification *)notification
{
    [_dataTable reloadData];
}

/**
 *  用于去掉界面上多余的横线
 *
 *  @param tableView 无意义
 */
-(void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [_dataTable setTableFooterView:view];
}
#pragma mark 绘制用户信息页面上的tableview
//获取需要绘制的cell数目
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _userInfoUISetArry.count;
}
//获取需要绘制的cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCUserInfoCellItem *item = _userInfoUISetArry[indexPath.row];
    return [TCUserInfoCellItem heightOf:item];
}

//绘制Cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCUserInfoCellItem *item = _userInfoUISetArry[indexPath.row];
    TCUserInfoTableViewCell *cell = (TCUserInfoTableViewCell*)[tableView  dequeueReusableCellWithIdentifier:@"cell"];
    if(cell == nil)
    {
         cell = [[TCUserInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        [cell initUserinfoViewCellData:item];
    }
    
    [cell drawRichCell:item];
    return cell;
}
#pragma mark 点击用户信息页面上的tableview的回调
/**
 *  用于点击tableview中的cell后的回调相应
 *
 *  @param tableView tableview变量
 *  @param indexPath cell的某行
 */
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TCUserInfoCellItem *item = _userInfoUISetArry[indexPath.row];
    TCUserInfoTableViewCell *cell = [_dataTable cellForRowAtIndexPath:indexPath];
    if (item.action)
    {
        item.action(item, cell);
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
/**
 *  用于显示 编辑个人信息 页面
 *
 *  @param menu 无意义
 *  @param cell 无意义
 */
- (void)onEditUserInfo:(TCUserInfoCellItem *)menu cell:(TCUserInfoTableViewCell *)cell
{
    TCEditUserInfoViewController *vc = [[TCEditUserInfoViewController alloc] init];
    [self.navigationController pushViewController:vc animated:true];
}

/// 获取技术支持按钮事件
- (void)onShowAppSupport:(id)menu cell:(id)cell
{
    NSString *message = [@[L(@"关注公众号“腾讯云视频”"), L(@"给公众号发送“小直播”")] componentsJoinedByString:@"\n"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"获取技术支持服务", nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"关闭", nil) otherButtonTitles:nil, nil];
    [alert show];
}

/**
 *  用户显示小直播的版本号信息
 *
 *  @param menu 无意义
 *  @param cell 无意义
 */
- (void)onShowAppVersion:(TCUserInfoCellItem *)menu cell:(TCUserInfoTableViewCell *)cell
{
    NSString* rtmpSDKVersion = [NSString stringWithFormat:@"RTMP SDK版本号: %@",[TXLiveBase getSDKVersionStr]];
    NSString* appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
        NSString *info = [NSString stringWithFormat:@"App版本号：%@\n%@\n", appVersion, rtmpSDKVersion/*, [[TIMManager sharedInstance] GetVersion]*/]; //imTODO:
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"关于小直播" message:info delegate:nil cancelButtonTitle:@"关闭" otherButtonTitles:nil, nil];
    [alert show];
}

/**
 *  用户显示SDK信息
 *
 *  @param menu 无意义
 *  @param cell 无意义
 */
- (void)onShowSDKInfo:(TCUserInfoCellItem *)menu cell:(TCUserInfoTableViewCell *)cell
{
    TCLVBWebViewController *next = [[TCLVBWebViewController alloc] initWithURL:HomePageURL];
    next.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:next animated:YES];
    //    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://cloud.tencent.com/product/UGSV"]];
}

/**
 *  用于显示 实名认证 页面
 *
 *  @param menu 无意义
 *  @param cell 无意义
 */
- (void)onAuthenticate:(TCUserInfoCellItem *)menu cell:(TCUserInfoTableViewCell *)cell {
#if YOUTU_AUTH
    if (YES == [[[NSUserDefaults standardUserDefaults] objectForKey:@"kAuthenticationResult"] boolValue]) {
        [HUDHelper alert:@"您已认证成功，无需重复认证" cancel:@"确定"];
        return;
    }
    
    g_bNeedEnterPushSettingView = NO;
    self.hidesBottomBarWhenPushed = YES;
    TCYTRealNameAuthViewController *vc = [[TCYTRealNameAuthViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    self.hidesBottomBarWhenPushed = NO;
#endif
}


@end
