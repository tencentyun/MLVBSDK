/**
 * Module: TCUserProfileEditViewController
 *
 * Function: 用户信息编辑
 */

#import "TCUserProfileEditViewController.h"
#import "TCUserProfileCell.h"
#import "TCUserProfileModel.h"
#import "TCAccountMgrModel.h"
#import "TCUploadHelper.h"

#import <UIKit/UIKit.h>
#import <mach/mach.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "UIActionSheet+BlocksKit.h"
#import "ColorMacro.h"
#import "HUDHelper.h"

#define OPEN_CAMERA  0
#define OPEN_PHOTO   1


@interface TCUserProfileEditViewController() <
    UITableViewDelegate,
    UITableViewDataSource,
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate>


@end


@implementation TCUserProfileEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.navigationController.navigationBar.tintColor = RGB(58, 153, 249);
    self.title = @"编辑个人信息";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18],NSForegroundColorAttributeName:[UIColor whiteColor]}] ;
    
    self.view.backgroundColor = RGB(0xF3,0xF3,0xF3);
    
    __weak typeof(self) ws = self;
    TCUserProfileData  *_profile = [[TCUserProfileModel sharedInstance] getUserProfile ];
    TCUserProfileCellItem *faceItem = [[TCUserProfileCellItem alloc] initWith:@"头像" value:nil type:TCUserProfile_EditFace action:^(TCUserProfileCellItem *menu, TCEditUserInfoTableViewCell *cell) {
        [ws modifyUserInfoFaceImage:menu cell:cell]; } ];
    
    TCUserProfileCellItem *nickItem = [[TCUserProfileCellItem alloc] initWith:@"昵称" value:_profile.nickName type:TCUserProfile_EditNick action:^(TCUserProfileCellItem *menu, TCEditUserInfoTableViewCell *cell) {
        nil; }];
    
    TCUserProfileCellItem *genderItem = [[TCUserProfileCellItem alloc] initWith:@"性别" value:(USERINFO_MALE == _profile.gender ? @"男":@"女") type:TCUserProfile_EditGender action:^(TCUserProfileCellItem *menu, TCEditUserInfoTableViewCell *cell) {
        [ws modifyUserInfoGender:menu cell:cell]; }];
    
    _userInfoArry = [NSMutableArray arrayWithArray:@[faceItem, nickItem, genderItem]];
    
    NSInteger nHeighNavigationBar = self.navigationController.navigationBar.frame.size.height;
    NSInteger nStatusBarFrame     =[[UIApplication sharedApplication] statusBarFrame].size.height;
    CGRect tableViewFrame  = CGRectMake(0, nHeighNavigationBar+nStatusBarFrame+20, self.view.frame.size.width, 155);
    _tableView    = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate   = self;
    [_tableView setSeparatorColor:RGB(0xD8,0xD8,0xD8)];
    
    //设置tableView不能滚动
    [self.tableView setScrollEnabled:NO];
    
    //去掉多余的分割线
    [self setExtraCellLineHidden:self.tableView];
    [self.view addSubview:_tableView];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    // 点击空白处键盘消失
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard:)];
    singleTap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:singleTap];
    return;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}
#pragma mark 绘制view
/**
 *  用于去掉界面上多余的横线
 *
 *  @param tableView 无意义
 */
- (void)setExtraCellLineHidden: (UITableView *)tableView {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [_tableView setTableFooterView:view];
}

//获取需要绘制的cell数目
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _userInfoArry.count;
}

//获取需要绘制的cell高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCUserProfileCellItem *item = _userInfoArry[indexPath.row];
    return [TCUserProfileCellItem heightOf:item];
}

//绘制cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCEditUserInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    TCUserProfileCellItem *item = _userInfoArry[indexPath.row];
    if (!cell) {
        cell = [[TCEditUserInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        [cell initUserinfoViewCellData:item];
    }
    
    [cell drawRichCell:item delegate:self];
    return cell;
}

#pragma mark 响应用户点击消息以及对应处理
/**
 *  点击空白处回调,主要用户编辑昵称时,不点击键盘上的完成按钮而点击空白处关闭键盘后保存昵称
 *
 *  @param gestureRecognizer 无意义
 */
- (void)closeKeyboard:(UITapGestureRecognizer *)gestureRecognizer {
    [self modifyUserInfoNick];
}

/**
 *  打开键盘编辑后,点击完成后的回调--这里暂时只保存昵称
 *
 *  @param textField 在编辑的控件
 *
 *  @return 返回YES关闭键盘
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self modifyUserInfoNick];
    [textField resignFirstResponder];
    return YES;
}

/**
 *  用户点击tableview上的cell后,找到对应的回到函数并执行
 *
 *  @param tableView 对应的tableview
 *  @param indexPath 对应的cell索引
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TCUserProfileCellItem *item = _userInfoArry[indexPath.row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (item.action) {
        item.action(item, cell);
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

/**
 *  用于修改用户昵称
 */
- (void)modifyUserInfoNick {
    NSInteger sections = _tableView.numberOfSections;
    for (int section = 0; section < sections; section++)
    {
        NSInteger rows =  [_tableView numberOfRowsInSection:section];
        for (int row = 0; row < rows; row++)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            TCEditUserInfoTableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
            if (TCUserProfile_EditNick == cell.item.type)
            {
                [self uploadUserInfoNick:cell];
                break;
            }
        }
    }
    
    [self.view endEditing:YES];
}

/**
 *  用于点击 编辑个人信息 界面上的头像栏后弹出alert选择栏,显示选择相机or相册,然后执行相应的毁掉
 *
 *  @param menu 无意义
 *  @param cell 无意义
 */
- (void)modifyUserInfoFaceImage:(TCUserProfileCellItem *)menu cell:(TCEditUserInfoTableViewCell *)cell {
    __weak typeof(self) ws = self;
    UIActionSheet *testSheet = [[UIActionSheet alloc] init];
    [testSheet bk_addButtonWithTitle:@"拍照" handler:^{[ws openCameraPhoto:OPEN_CAMERA];}];
    [testSheet bk_addButtonWithTitle:@"相册" handler:^{[ws openCameraPhoto:OPEN_PHOTO];}];
    [testSheet bk_setCancelButtonWithTitle:@"取消" handler:nil];
    [testSheet showInView:self.view];
}

/**
 *  用于点击 编辑个人信息 界面上的性别栏后弹出alert选择栏,选中后在block中响应回调并判断设置信息
 *
 *  @param menu 无意义
 *  @param cell cell指针,用于获取和设置值
 */
- (void)modifyUserInfoGender:(TCUserProfileCellItem *)menu cell:(TCEditUserInfoTableViewCell *)cell {
    __weak typeof(self) ws = self;
    UIActionSheet *testSheet = [[UIActionSheet alloc] init];
    [testSheet bk_addButtonWithTitle:@"男" handler:^{
        cell->genderText.text = @"男";
        [ws uploadUserGenderInfo:cell->genderText.text];
    }];
    [testSheet bk_addButtonWithTitle:@"女" handler:^{
        cell->genderText.text = @"女";
        [ws uploadUserGenderInfo:cell->genderText.text];
    }];
    [testSheet bk_setCancelButtonWithTitle:@"取消" handler:nil];
    [testSheet showInView:self.view];
}

#pragma mark 上传更改后的用户信息
/**
 *  修改用户性别信息外层封装,包括调用用户信息管理模块更新信息到服务器,并且包含结果回调
 *
 *  @param strSexText 用户性别Text
 */
- (void)uploadUserGenderInfo:(NSString*)strSexText {
    int gender = USERINFO_FEMALE;
    if ([strSexText isEqualToString:@"男"])
    {
        gender = USERINFO_MALE;
    }
    //先判断值是否发生改变
    TCUserProfileData  *_profile = [[TCUserProfileModel sharedInstance] getUserProfile ];
    if (gender != _profile.gender)
    {
        [[TCUserProfileModel sharedInstance] saveUserGender:gender handler:^(int code, NSString *msg)
         {
             if (ERROR_SUCESS != code)
             {
                 [[HUDHelper sharedInstance] tipMessage:@"上传用户性别信息失败"];
             }
         }];
    }
}

/**
 *  上传用户头像到服务器,并且返回用户头像url,拿到url后再将url上传到服务器,并且包含结果回调
 *   上传成功后会发送通知,使得用户信息界面更新头像信息
 *
 *  @param image 图片信息
 *
 */
- (void)uploadUserFaceImage:(UIImage*)image {
    TCUserProfileData  *profile = [[TCUserProfileModel sharedInstance] getUserProfile ];
    [[TCUploadHelper shareInstance] upload:profile.identifier image:image completion:^(int errCode, NSString *imageSaveUrl)
     {
         if (0 == errCode)
         {
             [[TCUserProfileModel sharedInstance] saveUserFace:imageSaveUrl handler:^(int code, NSString *msg)
              {
                  if (0 != errCode)
                  {
                      [[HUDHelper sharedInstance] tipMessage:@"上传头像失败"];
                  }
                  else
                  {
                      //将图片同步到用户主界面显示
                      [[NSNotificationCenter defaultCenter] postNotificationName:KReloadUserInfoNotification object:nil];
                      //NSArray*paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
                      //NSString *documentsDirectory=[paths objectAtIndex:0];
                      //NSString *savedImagePath=[documentsDirectory stringByAppendingPathComponent:@"saveFore.png"];
                      //[UIImagePNGRepresentation(image) writeToFile:savedImagePath atomically:YES];
                  }
              }];
         }
         else
         {
             [[HUDHelper sharedInstance] tipMessage:@"上传头像失败"];
         }
     }];
}

/**
 *  用户保存用户昵称外层封装,保存到服务器后的结果回调
 *
 *  @param cell 包含用户昵称的tableview的cell项目,从中取得昵称Text
 */
- (void)uploadUserInfoNick:(TCEditUserInfoTableViewCell*)cell {
    TCUserProfileData  *_profile = [[TCUserProfileModel sharedInstance] getUserProfile ];
    if (0 == cell->nickText.text.length)
    {
        [[HUDHelper sharedInstance] tipMessage:@"昵称不能为空"];
        cell->nickText.text = _profile.nickName;
        return;
    }
    
    //先判断值是否发生改变
    if (![cell->nickText.text isEqualToString:_profile.nickName])
    {
        [[TCUserProfileModel sharedInstance] saveUserNickName:cell->nickText.text handler:^(int code, NSString *msg)
         {
             if (ERROR_SUCESS != code)
             {
                 [[HUDHelper sharedInstance] tipMessage:@"上传用户昵称信息失败"];
             }
             else
             {
                 //将信息同步到用户主界面显示
                 [[NSNotificationCenter defaultCenter] postNotificationName:KReloadUserInfoNotification object:nil];
             }
         }];
    }
}
#pragma mark 与选择相机or相册以及处理了图片相关
/**
 *  根据用户选择打开相机or相册
 *
 *  @param Picker 用户选择宏
 */
- (void)openCameraPhoto:(NSInteger)Picker {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate      = self;
    imagePicker.allowsEditing = YES;
    if (OPEN_CAMERA == Picker && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else if (OPEN_PHOTO == Picker && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image    = info[UIImagePickerControllerEditedImage];
    UIImage *cutImage = [TCUserProfileEditViewController cutImage:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSInteger sections = _tableView.numberOfSections;
    for (int section = 0; section < sections; section++)
    {
        NSInteger rows =  [_tableView numberOfRowsInSection:section];
        for (int row = 0; row < rows; row++)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
            TCEditUserInfoTableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
            if (TCUserProfile_EditFace == cell.item.type) {
                // 首先将突破同步到tableview上,然后上传,上传成功后同步到用户信息界面
                cell->faceImage.image = cutImage;
                [self uploadUserFaceImage:cutImage];
                break;
            }
        }
    }
}
#pragma mark 裁剪照片
+ (UIImage *)scaleToSize:(UIImage *)image size:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width,size.height)];
    UIImage *endImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return endImage;
}

+ (UIImage *)cutImage:(UIImage *)image {
    CGSize pubSize = CGSizeMake(200, 200);
    if (image) {
        CGSize imgSize = image.size;
        CGFloat pubRation = pubSize.height / pubSize.width;
        CGFloat imgRatio = imgSize.height / imgSize.width;
        if (fabs(imgRatio -  pubRation) < 0.01) {
            // 直接上传
            image = [TCUserProfileEditViewController scaleToSize:image size:pubSize];
            return image;
        }
        else {
            if (imgRatio > 1) {
                // 长图，截正中间部份
                CGSize upSize = CGSizeMake(imgSize.width, (NSInteger)(imgSize.width * pubRation));
                UIImage *upimg = [TCUserProfileEditViewController cropImage:image inRect:CGRectMake(0, (image.size.height - upSize.height)/2, upSize.width, upSize.height)];
                upimg = [TCUserProfileEditViewController scaleToSize:upimg size:pubSize];
                return upimg;
            }
            else {
                // 宽图，截正中间部份
                CGSize upSize = CGSizeMake(imgSize.height, (NSInteger)(imgSize.height * pubRation));
                UIImage *upimg = [TCUserProfileEditViewController cropImage:image inRect:CGRectMake((image.size.width - upSize.width)/2, 0, upSize.width, upSize.height)];
                upimg = [TCUserProfileEditViewController scaleToSize:upimg size:pubSize];
                return upimg;
            }
        }
    }
    
    return image;
}

+ (UIImage *)cropImage:(UIImage *)image inRect:(CGRect)rect {
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // translated rectangle for drawing sub image
    CGRect drawRect = CGRectMake(-rect.origin.x, -rect.origin.y, image.size.width, image.size.height);
    
    // clip to the bounds of the image context
    // not strictly necessary as it will get clipped anyway?
    CGContextClipToRect(context, CGRectMake(0, 0, rect.size.width, rect.size.height));
    
    // draw image
    [image drawInRect:drawRect];
    
    // grab image
    UIImage* croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return croppedImage;
}

@end
