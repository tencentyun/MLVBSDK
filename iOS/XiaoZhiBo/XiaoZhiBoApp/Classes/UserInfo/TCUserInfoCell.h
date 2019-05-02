//
//  TCUserInfoCell.h
//  TCLVBIMDemo
//
//  Created by jemilyzhou on 16/8/1.
//  Copyright © 2016年 tencent. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#import "TCUserInfoModel.h"
#import "TCEditUserInfoViewController.h"

@class TCUserInfoCellItem;
@class TCUserInfoTableViewCell;
@class TCEditUserInfoTableViewCell;

#define kNicknameMaxLength  20       //用户输入的昵称长度
typedef void (^TCUserInfoCellAction)(TCUserInfoCellItem *menu, id cell);

// 枚举,用于区分目前所有的tableview中的每一条cell
typedef NS_ENUM(NSInteger, TCUserInfoCellType)
{
    // 代表 编辑个人信息 页面上的元素,包括头像,昵称,性别
    TCUserInfo_EditFace,
    TCUserInfo_EditNick,
    TCUserInfo_EditGender,
    
    // 代表点击 用户信息 界面上的元素
    TCUserInfo_View,  // 展示个人信息cell(头像,昵称,id在此cell内部从上到下依次排列)
    TCUserInfo_Edit,  // 点击后切换到 编辑个人信息 页面
    TCUserInfo_About, // 点击后显示小直播版本号
    TCUserInfo_Authenticate,   // 实名认证
};
/*
 * TCUserInfoCellItem 类说明 : 该类用于存储tableview中每一条cell内容
 *
 * 包括点击后的回调函数,文字,cell类型信息
 *
 * 计算高度也在这里,根据item 中的 type计算
 *
 */
@interface TCUserInfoCellItem : NSObject

@property (nonatomic, assign) TCUserInfoCellType type;

@property (nonatomic, copy) NSString *tip;

@property (nonatomic, copy) NSString *value;

@property (nonatomic, copy) TCUserInfoCellAction action;

+ (NSInteger)heightOf:(TCUserInfoCellItem *)item;

- (instancetype)initWith:(NSString *)tip value:(NSString *)value type:(TCUserInfoCellType)type action:(TCUserInfoCellAction)action;

@end

/*
 * TCUserInfoTableViewCell 类说明 : 该类主要绘制用户点击个人信息页面后的tableview界面
 *
 * 目前该界面包含3个cell:
 *
 * 第一个cell由用户头像,昵称,id从上到下依次排列 背景色为深灰色,文字为白色,头像为圆形并且绿色边框
 *        该cell占据了iPhone屏幕大约40%的高度  不响应点击消息
 *
 * 第二个cell显示文字为 编辑个人信息  点击后切换到 编辑个人信息 页面,右边有个箭头
 *
 * 第三个cell显示文字为 关于小直播    点击后弹框显示版本号          右边有个小箭头
 */
@interface TCUserInfoTableViewCell : UITableViewCell
{
@public
    // 头像,昵称,id从上到下依次居中排列在第一个大cell内部
    UIImageView *faceImage;
    UILabel     *nickText;
    UILabel     *identifierText;
    
    __weak TCUserInfoCellItem *_item;
}

@property (nonatomic, weak) TCUserInfoCellItem *item;

- (void)initUserinfoViewCellData:(TCUserInfoCellItem *)item;

- (void)drawRichCell:(TCUserInfoCellItem *)item;

@end

/*
 * TCEditUserInfoTableViewCell 类说明 : 该类用于绘制 编辑个人信息 页面上的tableview,用户可直接编辑
 *
 * 目前该界面包含3个cell:
 *
 * 第一个cell显示头像,点击后可选择 相机 or 相册,然后选择图片,之后剪裁成200*200头像上传
 *
 * 第二个cell显示昵称,点击后可以直接在tableview中编辑,昵称最大长度为20字节,编辑完成后点击空白处键盘消失或者点击键盘上完成按钮保存上传
 *
 * 第三个cell显示性别,点击后弹框选择 男 or 女 选中后直接上传保存
 */
@interface TCEditUserInfoTableViewCell : UITableViewCell
{
@public
    // 用于显示 编辑个人信息 页面上的头像右侧图片
    UIImageView    *faceImage;
    // 用于显示 编辑个人信息 页面上的昵称右边的昵称文字,可点击后直接编辑
    UITextField    *nickText;
    // 用于显示 编辑个人信息 页面上的性别右边的性别文字(男 or 女)
    UILabel        *genderText;
    
    __weak TCUserInfoCellItem *_item;
}

@property (nonatomic, weak) TCUserInfoCellItem *item;

- (void)initUserinfoViewCellData:(TCUserInfoCellItem *)item;

- (void)drawRichCell:(TCUserInfoCellItem *)item delegate:(id)view;

@end

