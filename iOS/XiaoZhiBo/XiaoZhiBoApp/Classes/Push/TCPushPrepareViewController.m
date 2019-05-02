//
//  TCPushPrepareViewController.m
//  TCLVBIMDemo
//
//  Created by annidyfeng on 16/8/3.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import "TCPushPrepareViewController.h"
#import <BlocksKit/BlocksKit+UIKit.h>
#import "UIPlaceHolderTextView.h"
#import <UIImageView+WebCache.h>
#import "UIImage+Additions.h"
#import "TCPushViewController.h"
#import "TCUploadHelper.h"
#import "TCLoginModel.h"
#import "TCUserInfoModel.h"
#import "TCLiveListModel.h"
#import "UIView+Additions.h"
#import "TCUtil.h"
#import "TCPushViewController.h"
#import "NSString+Common.h"
#import "HUDHelper.h"
#import "AppDelegate.h"
#import "ColorMacro.h"
#import "CommonMacro.h"

#if YOUTU_AUTH
#import "TCYTRealNameAuthViewController.h"
#endif

BOOL g_bNeedEnterPushSettingView = NO;

#define kTCMaxPushTitleLen        30


@import AVFoundation;
@import CoreLocation;

@interface TCPushPrepareViewController ()<UITextViewDelegate, UINavigationControllerDelegate ,UIImagePickerControllerDelegate, CLLocationManagerDelegate>

@property (weak) IBOutlet UIPlaceHolderTextView *titleTextView;
@property (weak) IBOutlet UIImageView           *coverImageView;
@property (weak) IBOutlet UILabel               *locationLabel;
@property (weak) IBOutlet UIImageView           *locationImageView;
@property (weak) IBOutlet UISwitch              *locationSwitch;
@property (nonatomic , retain)  UIButton        *publishBtn;

@property (strong) UIImage                      *selectedCoverImage;

@property (copy)   NSString                     *coverPic;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTextViewTopConstraint;


- (IBAction)onShowLocationSwitch:(id)sender;
- (IBAction)onSelectImage:(id)sender;
- (IBAction)onSelectSharePlatform:(UIButton *)sender;
@end

@implementation TCPushPrepareViewController {
    CLLocationManager   *_lbsManager;
    __weak UIButton     *_selectShare;
    TCLiveInfo          *_liveInfo;
    BOOL                _isLogining;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"发布直播";
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(onClose:)];
    //item.tintColor = RGB(58, 153, 249);
    self.navigationItem.rightBarButtonItem = item;
    self.titleTextView.delegate = self;
    
    TCUserInfoData  *profile = [[TCUserInfoModel sharedInstance] getUserProfile];
    self.coverPic = profile.coverURL;
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:[TCUtil transImageURL2HttpsURL:profile.coverURL]] placeholderImage:[UIImage imageNamed:@"defaul_publishcover"]];
    
    //[self showYTAuthAlertDlg];
}

-(void)showYTAuthAlertDlg
{
#if YOUTU_AUTH
    if (NO == [[[NSUserDefaults standardUserDefaults] objectForKey:@"Recommend_YOUTU_AUTH"] boolValue] &&
       NO == [[[NSUserDefaults standardUserDefaults] objectForKey:@"kAuthenticationResult"] boolValue])
    {
        UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:@"智能身份认证" message:@"体验基于万象优图服务实现的人脸识别身份认证，助您大幅缩减人工审核成本" cancelButtonTitle:@"先跳过" otherButtonTitles:@[@"去认证"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
            // 只有第一次使用小直播推流时才弹框提醒使用身份认证
            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"Recommend_YOUTU_AUTH"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if (buttonIndex == 1) {
                g_bNeedEnterPushSettingView = YES;
                self.hidesBottomBarWhenPushed = YES;
                TCYTRealNameAuthViewController *vc = [[TCYTRealNameAuthViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
                self.hidesBottomBarWhenPushed = NO;
            }
        }];
        [alert show];
        return;
    }
#endif
}

//监听键盘高度变化
-(void)keyboardFrameDidChange:(NSNotification*)notice
{
    NSDictionary * userInfo = notice.userInfo;
    NSValue * endFrameValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect endFrame = endFrameValue.CGRectValue;
    
    [UIView animateWithDuration:0.25 animations:^{
        if (endFrame.origin.y == self.view.height) {
            self->_titleTextViewTopConstraint.constant = 3;
        }else{
            if (endFrame.origin.y - self->_titleTextView.height < self->_titleTextView.y) {
                self->_titleTextViewTopConstraint.constant +=  endFrame.origin.y - self->_titleTextView.height - self->_titleTextView.y;
            }
        }
    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.publishBtn) {
        [self.publishBtn removeFromSuperview];
    }
    CGFloat bottom = 0;
    if (@available(iOS 11, *)) {
        bottom = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    }
    self.publishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.publishBtn setTitle:@"开始直播" forState:UIControlStateNormal];
    [self.publishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.publishBtn setBackgroundColor:[UIColor colorWithRed:51/255.0 green:139/255.0 blue:255/255.0 alpha:1.0]];
    [self.publishBtn setFrame:CGRectMake(0, self.view.bottom - 55 - bottom, self.view.width, 55)];
    [self.publishBtn addTarget:self action:@selector(onStartPublish:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.publishBtn];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardFrameDidChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onShowLocationSwitch:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    if ([sw isOn]) {
        [self startLbs];
    } else {
        self.locationLabel.text = @"不显示地理位置";
        self.locationImageView.image = [UIImage imageNamed:@"position_gray"];
        [self stopLbs];
    }
}

- (IBAction)onRecordSwitch:(id)sender {

}

- (IBAction)onStartPublish:(id)sender {
//    if (_coverImageView.image == nil) {
//        [HUDHelper alert:@"封面不能为空"];
//        return;
//    }
    
    _titleTextView.text = [_titleTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (_titleTextView.text.length == 0) {
        [HUDHelper alert:@"请输入标题"];
        return;
    }
    
    if ([self.locationSwitch isOn]) {
        if ([_locationLabel.text hasPrefix:@"正在定位"]) {
            [HUDHelper alert:@"正在定位,请稍候"];
            return;
        }
    }
    
    [self startPush];
}

- (IBAction)onSelectImage:(id)sender {
    __weak typeof(self) ws = self;
    UIActionSheet *testSheet = [[UIActionSheet alloc] init];
    [testSheet bk_addButtonWithTitle:@"拍照" handler:^{
        [ws openCamera];
    }];
    [testSheet bk_addButtonWithTitle:@"相册" handler:^{
        [ws openPhotoLibrary];
    }];
    [testSheet bk_setCancelButtonWithTitle:@"取消" handler:nil];
    [testSheet showInView:self.view];
}

- (void)onClose:(id)sender {
    [self.titleTextView resignFirstResponder];
    [[AppDelegate sharedAppDelegate] dismissViewController:self animated:YES completion:nil];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text length] > 0)
    {
        NSString* txtStr = self.titleTextView.text;
        txtStr = [txtStr stringByReplacingCharactersInRange:range withString:text];
        NSUInteger textLen = txtStr.length;
        if (textLen > kTCMaxPushTitleLen)
        {
            [[HUDHelper sharedInstance] tipMessage:@"已达到最大限制字数"];
            [textView resignFirstResponder];
            return NO;
        }
    }
    
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (self.titleTextView.markedTextRange == nil && [TCUtil getContentLength:self.titleTextView.text] > kTCMaxPushTitleLen) {      
        [[HUDHelper sharedInstance] tipMessage:@"已达到最大限制字数"];
        self.titleTextView.text = [self.titleTextView.text substringToIndex:(self.titleTextView.text.length-1)];
        
        [textView resignFirstResponder];
    }
    
}

#pragma mark - 头像选择
- (void)openCamera
{
    // 暂时弃用自定义相机
    // 打开系统相机拍照
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
    {
        UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:nil message:@"您没有相机使用权限,请到设置->隐私中开启权限" cancelButtonTitle:@"确定" otherButtonTitles:nil handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
        }];
        [alert show];
        return;
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *cameraIPC = [[UIImagePickerController alloc] init];
        cameraIPC.delegate = self;
        cameraIPC.allowsEditing = YES;
        cameraIPC.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:cameraIPC animated:YES completion:nil];
        return;
    }
}

- (void)openPhotoLibrary
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePicker animated:YES completion:nil];
        return;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerEditedImage];
    UIImage *cutImage = [self cutImage:image];
    self.coverImageView.image = cutImage;
    self.selectedCoverImage = cutImage;
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [self uploadImage];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 图片剪裁
- (UIImage *)cutImage:(UIImage *)image
{
    CGSize pubSize = [self publishSize];
    if (image)
    {
        CGSize imgSize = image.size;
        CGFloat pubRation = pubSize.height / pubSize.width;
        CGFloat imgRatio = imgSize.height / imgSize.width;
        if (fabs(imgRatio -  pubRation) < 0.01)
        {
            // 直接上传
            return image;
        }
        else
        {
            if (imgRatio > 1)
            {
                // 长图，截正中间部份
                CGSize upSize = CGSizeMake(imgSize.width, (NSInteger)(imgSize.width * pubRation));
                UIImage *upimg = [self cropImage:image inRect:CGRectMake(0, (image.size.height - upSize.height)/2, upSize.width, upSize.height)];
                return upimg;
            }
            else
            {
                // 宽图，截正中间部份
                CGSize upSize = CGSizeMake(imgSize.height, (NSInteger)(imgSize.height * pubRation));
                UIImage *upimg = [self cropImage:image inRect:CGRectMake((image.size.width - upSize.width)/2, 0, upSize.width, upSize.height)];
                return upimg;
            }
        }
    }
    
    return image;
}

- (UIImage *)cropImage:(UIImage *)image inRect:(CGRect)rect
{
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

- (CGSize)publishSize
{
    return CGSizeMake(kMainScreenWidth, kMainScreenWidth * 0.732);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - 定位
- (void)startLbs
{
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationLabel.text = @"正在定位...";
        self.locationImageView.image = [UIImage imageNamed:@"position_gray" tintColor:[UIColor flatRedColor] style:UIImageTintedStyleKeepingAlpha];
        
        // 支持定位才开启lbs
        if (!_lbsManager)
        {
            _lbsManager = [[CLLocationManager alloc] init];
            [_lbsManager setDesiredAccuracy:kCLLocationAccuracyBest];
            _lbsManager.delegate = self;
            // 兼容iOS8定位
            SEL requestSelector = NSSelectorFromString(@"requestWhenInUseAuthorization");
            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined && [_lbsManager respondsToSelector:requestSelector]) {
                 [_lbsManager requestWhenInUseAuthorization];  //调用了这句,就会弹出允许框了.
            } else {
                [_lbsManager startUpdatingLocation];
            }
        }
    }
    else {
        UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:nil message:@"尚未开启位置定位服务" cancelButtonTitle:@"取消" otherButtonTitles:@[@"开启"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
        }];
        [alert show];
    }
}

- (void)stopLbs {
    [_lbsManager stopUpdatingHeading];
    _lbsManager.delegate = nil;
    _lbsManager = nil;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied) {
        [self stopLbs];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.locationLabel.text = @"定位失败";
            [self.locationSwitch setOn:NO];
            
            UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:nil message:@"尚未开启位置定位服务" cancelButtonTitle:@"取消" otherButtonTitles:@[@"开启"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if (buttonIndex == 1) {

                    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];

                    if ([[UIApplication sharedApplication] canOpenURL:url]) {
                        [[UIApplication sharedApplication] openURL:url];
                    }
                }
            }];
            [alert show];
            
        });
    } else {
        [_lbsManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self stopLbs];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.locationLabel.text = @"定位失败";
        [self.locationSwitch setOn:NO];
    });
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{

    CLLocation *newLocatioin = locations[0];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:newLocatioin completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error)
        {
            CLPlacemark *placeMark = placemarks[0];
            //记录地址
//            if (!_lbsInfo)
//            {
//                _lbsInfo = [[LocationItem alloc] init];
//            }
            
//            CLLocation *loc = placeMark.location;
//            _lbsInfo.latitude = loc.coordinate.latitude;
//            _lbsInfo.longitude = loc.coordinate.longitude;
            
            NSString *country   = placeMark.country;
            NSString *aa        = [placeMark administrativeArea];
            NSString *state     = aa.length ? aa : [placeMark subAdministrativeArea];
            NSString *city      = placeMark.locality;
            NSString *sub       = placeMark.subLocality;
            NSString *street    = placeMark.thoroughfare;
            NSString *subStreet = placeMark.subThoroughfare;
            
            NSString *address = [NSString stringWithFormat:@"%@%@%@%@%@%@", country ? country : @"", state ? state : @"", city ? city : @"", sub ? sub : @"", street ? street : @"", subStreet ? subStreet : @""];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.locationLabel.text = address;
            });
        }
    }];
    [self stopLbs];
}

#pragma mark - 上传图片
- (void)uploadImage {
    
    TCUserInfoData  *profile = [[TCUserInfoModel sharedInstance] getUserProfile ];
    if (self.selectedCoverImage) {
        [[TCUploadHelper shareInstance] upload:profile.identifier image:self.selectedCoverImage completion:^(int errCode, NSString *imageSaveUrl) {
            if (errCode != 0) {
                [[HUDHelper sharedInstance] tipMessage:@"上传图片失败"];
                return;
            }
            
            self.coverPic = imageSaveUrl;
            [[TCUserInfoModel sharedInstance] saveUserCover:imageSaveUrl handler:^(int errCode, NSString *strMsg) {
                if (errCode != ERROR_SUCESS)
                {
                    [[HUDHelper sharedInstance] tipMessage:@"保存图片失败"];
                }
            }];
        }];
    } else {
        [[HUDHelper sharedInstance] tipMessage:@"请选择图片"];
    }
}

#pragma 启动推流界面
- (void)startPush
{
    if (_isLogining) {
        return;
    }
    _isLogining = YES;
    __block CFTimeInterval start = CFAbsoluteTimeGetCurrent();
    [[TCLoginModel sharedInstance] reLoginIfNeeded:^(NSString* username, NSString* pwd){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *myLocation = self.locationSwitch.isOn ? self.locationLabel.text : @"";
            NSString *myTitle = self.titleTextView.text;
            self.publishBtn.enabled = NO;
            //__weak typeof (self) weakSelf = self;
            NSString *userId = username;
            
            TCLiveInfo *publishInfo = [[TCLiveInfo alloc] init];
            publishInfo.userinfo = [[TCLiveUserInfo alloc] init];
            publishInfo.userinfo.location = myLocation;
            publishInfo.title = myTitle;
            publishInfo.userid = userId;
            publishInfo.userinfo.frontcover = (self.coverPic == nil ? @"" : self.coverPic);
            publishInfo.userinfo.headpic = [[TCUserInfoModel sharedInstance] getUserProfile].faceURL;
            publishInfo.userinfo.nickname = [[TCUserInfoModel sharedInstance] getUserProfile].nickName;
            _liveInfo = publishInfo;
            NSLog(@"[TIME] Login time: %.6f", CFAbsoluteTimeGetCurrent() - start);
            [self showPushController];
            _isLogining = NO;
        });
    } fail:^(int code, NSString *msg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *err = [NSString stringWithFormat:@"%@(%d)", msg, code];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登录失败"
                                                            message:err
                                                           delegate:self
                                                  cancelButtonTitle:@"确认"
                                                  otherButtonTitles:nil];
            [alert show];
            _isLogining = NO;
        });
    }];
    
}

- (IBAction)onSelectSharePlatform:(UIButton *)sender {
    _selectShare.highlighted = NO;
    if (_selectShare == sender) {
        _selectShare = nil;
        return;
    }
    _selectShare = sender;
    [self performSelector:@selector(doHighlight) withObject:nil afterDelay:0];
}

- (void)doHighlight {
    [_selectShare setHighlighted:YES];
}

- (void)showPushController {
    CFTimeInterval start = CFAbsoluteTimeGetCurrent();

    TCPushViewController *pubVC = [[TCPushViewController alloc] initWithPublishInfo:_liveInfo];

    NSString *str = _selectShare.titleLabel.text;
    

    if ([str equalsString:@"QQ"]) {
        pubVC.platformType = TCSocialPlatformQQ;
    }
    else if ([str equalsString:@"Qzone"]) {
        pubVC.platformType = TCSocialPlatformQZone;
    }
    else if ([str equalsString:@"WechatTimeLine"]) {
        pubVC.platformType = TCSocialPlatformWechatTimeline;
    }
    else if ([str equalsString:@"WechatSession"]) {
        pubVC.platformType = TCSocialPlatformWechatSession;
    }
    else if ([str equalsString:@"Sina"]) {
        pubVC.platformType = TCSocialPlatformSina;
    }
    
    NSLog(@"[TIME] TCPushViewController init time: %.6f", CFAbsoluteTimeGetCurrent() - start);
    start = CFAbsoluteTimeGetCurrent();
    [self presentViewController:pubVC animated:YES completion:^{
            NSLog(@"[TIME] presentViewController time: %.6f", CFAbsoluteTimeGetCurrent() - start);
    }];
    _liveInfo = nil;
}
@end
