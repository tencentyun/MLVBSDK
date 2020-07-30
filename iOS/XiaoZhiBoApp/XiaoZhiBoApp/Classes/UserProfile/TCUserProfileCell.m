/**
 * Module: TCUserProfileCell
 *
 * Function: 用户信息Cell
 */

#import "TCUserProfileCell.h"
#import "TCUserProfileModel.h"
#import "TCUserProfileEditViewController.h"
#import "TCUtil.h"

#import <UIKit/UIKit.h>
#import <mach/mach.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIImageView+WebCache.h>
#import "ColorMacro.h"
#import "HUDHelper.h"

#pragma mark 存储用户个人信息item
@implementation TCUserProfileCellItem

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (instancetype)initWith:(NSString *)key value:(NSString *)value type:(TCUserProfileCellType)type action:(TCUserProfileCellAction)action {
    if (self = [self init]) {
        _tip    = key;
        _type   = type;
        _value  = value;
        _action = action;
    }
    return self;
}

/**
 *  在绘制cell的时候获取cell的高度,在用户信息界面第一个cell取275,编辑个人信息 界面第一个cell取65,其他都是45
 *
 *  @param item 用于cell数据结构体
 *
 *  @return cell的高度
 */
+ (NSInteger)heightOf:(TCUserProfileCellItem *)item {
    if (TCUserProfile_EditFace == item.type ) {
        return 65;
    }
    else if (TCUserProfile_View == item.type) {
        return 275;
    }
    
    return 45;
}

@end

#pragma mark 点击个人信息页面,显示在个人页面上的tableview
@implementation TCUserInfoTableViewCell

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    }
    return self;
}
/**
 *  用于初始化数据 目前只用于当在 用户信息界面 上的第一个组合cell
 *
 *  @param item cell信息结构体指针
 */
- (void)initUserinfoViewCellData:(TCUserProfileCellItem *)item {
    if (TCUserProfile_View == item.type) {
        UIView* bgview = [[UIView alloc] init];
        bgview.opaque = YES;
        bgview.backgroundColor = RGB(0x22,0x2B,0x48);
        [self setBackgroundView:bgview];
        
        UIColor *uiBorderColor = RGB(0x0A,0xCC,0xAC);
        faceImage = [[UIImageView alloc ] init];
        faceImage.layer.masksToBounds = YES;
        faceImage.layer.borderWidth   = 2;
        faceImage.layer.borderColor   = uiBorderColor.CGColor;
        
        nickText = [[UILabel alloc] init];
        nickText.textAlignment = NSTextAlignmentCenter;
        nickText.textColor     = [UIColor whiteColor];
        nickText.font          = [UIFont systemFontOfSize:18];
        nickText.lineBreakMode = NSLineBreakByWordWrapping;
        
        identifierText = [[UILabel alloc] init];
        identifierText.textColor     = [UIColor whiteColor];
        identifierText.font          = [UIFont systemFontOfSize:14];
        identifierText.textAlignment = NSTextAlignmentCenter;
        identifierText.lineBreakMode = NSLineBreakByWordWrapping;
        
        [self addSubview:nickText];
        [self addSubview:identifierText];
        [self addSubview:faceImage];
    }
}

//绘制 用于信息界面 中的tableview的cell
- (void)drawRichCell:(TCUserProfileCellItem *)item {
    _item = item;
    switch (item.type) {
        case TCUserProfile_View:
        {
            self.textLabel.text = nil;
            self.userInteractionEnabled = NO;
            self.accessoryType = UITableViewCellAccessoryNone;
            TCUserProfileData  *_profile = [[TCUserProfileModel sharedInstance] getUserProfile ];
            CGRect mainScreenSize = [ UIScreen mainScreen ].applicationFrame;
            CGSize titleTextSize  = [_profile.nickName sizeWithAttributes:@{NSFontAttributeName:nickText.font}];
            [faceImage sd_setImageWithURL:[NSURL URLWithString:[TCUtil transImageURL2HttpsURL:_profile.faceURL]] placeholderImage:[UIImage imageNamed:@"default_user"]];
            faceImage.frame = CGRectMake((mainScreenSize.size.width-100)/2, 50,100, 100);
            faceImage.layer.cornerRadius = 50;
            nickText.text  = _profile.nickName;
            nickText.frame = CGRectMake(0, 175,mainScreenSize.size.width,titleTextSize.height);
            identifierText.text  = [NSString stringWithFormat:@"ID:%@",_profile.identifier];
            identifierText.frame = CGRectMake(0, 175+10+titleTextSize.height,mainScreenSize.size.width, titleTextSize.height);
        }
        break;
        case TCUserProfile_About:
        case TCUserProfile_Edit:
        {
            self.textLabel.text      = item.tip;
            self.textLabel.textColor = [UIColor blackColor];
            self.textLabel.font      = [UIFont systemFontOfSize:16];
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        break;
        default:
        break;
    }
}
@end


#pragma mark 点击编辑个人信息 弹出来的页面上显示的tableview
@implementation TCEditUserInfoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    }
    return self;
}

- (void)dealloc {
    if (TCUserProfile_EditNick == _item.type) {
        [[NSNotificationCenter defaultCenter]removeObserver:self name:@"UITextFieldTextDidChangeNotification" object:nickText];
    }
}
/**
 *  用户初始化 编辑个人信息 界面上的tableview空间属性,优化滑动刷新时的性能
 *
 *  @param item cell信息结构体指针
 */
- (void)initUserinfoViewCellData:(TCUserProfileCellItem *)item {
    switch (item.type)
    {
        case TCUserProfile_EditFace:
        {
            faceImage = [[UIImageView alloc ] init];
            faceImage.layer.masksToBounds = YES;
            faceImage.layer.cornerRadius  = 25;
            [self addSubview:faceImage];
        }
        break;
        case TCUserProfile_EditGender:
        {
            genderText = [[UILabel alloc] init];
            genderText.numberOfLines = 0;
            genderText.textColor = RGB(0x77,0x77,0x77);
            genderText.font = [UIFont systemFontOfSize:16];
            genderText.lineBreakMode = NSLineBreakByWordWrapping;
            genderText.textAlignment =NSTextAlignmentRight;
            [self addSubview:genderText];
        }
        break;
        case TCUserProfile_EditNick:
        {
            nickText  = [[UITextField alloc] init];
            nickText.text          = item.value;
            nickText.textColor     = RGB(0x77,0x77,0x77);
            nickText.returnKeyType = UIReturnKeyDone;
            nickText.font = [UIFont systemFontOfSize:16];
            nickText.textAlignment =NSTextAlignmentRight;
            [[NSNotificationCenter defaultCenter]removeObserver:self name:@"UITextFieldTextDidChangeNotification" object:nickText];
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                        name:@"UITextFieldTextDidChangeNotification"
                                                      object:nickText];
            [self addSubview:nickText];
        }
        break;
        default:
            break;
    }
}

/**
 *  绘制 编辑个人信息 界面上的tableview
 *
 *  @param item cell信息结构体指针
 *  @param view 主界面的self指针
 */
- (void)drawRichCell:(TCUserProfileCellItem *)item  delegate:(id)view {
    _item = item;
    self.textLabel.text      = item.tip;
    self.textLabel.textColor = [UIColor blackColor];
    self.textLabel.font      = [UIFont systemFontOfSize:16];
    
    CGRect mainScreenSize = [ UIScreen mainScreen ].applicationFrame;
    CGSize size = [self.textLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    switch (item.type)
    {
        case TCUserProfile_EditFace:
        {
            int xPos = self.frame.origin.x + mainScreenSize.size.width - mainScreenSize.size.width/10 - 50;
            TCUserProfileData  *_profile   = [[TCUserProfileModel sharedInstance] getUserProfile ];
            faceImage.frame = CGRectMake(xPos, self.frame.origin.y+7,50, 50);
            [faceImage sd_setImageWithURL:[NSURL URLWithString:[TCUtil transImageURL2HttpsURL:_profile.faceURL]] placeholderImage:[UIImage imageNamed:@"default_user"]];
            
            self.accessoryType = UITableViewCellAccessoryNone;
        }
        break;
        case TCUserProfile_EditGender:
        {
            genderText.text  = item.value;
            genderText.frame = CGRectMake(self.frame.origin.x + size.width, self.frame.origin.y,mainScreenSize.size.width - size.width - mainScreenSize.size.width/10, self.frame.size.height);
        }
        break;
        case TCUserProfile_EditNick:
        {
            nickText.text     = item.value;
            nickText.delegate = view;
            nickText.frame = CGRectMake(self.frame.origin.x + size.width, self.frame.origin.y,mainScreenSize.size.width - size.width - mainScreenSize.size.width/10, self.frame.size.height);
            self.accessoryType = UITableViewCellAccessoryNone;
        }
        break;
        default:
        break;
    }
}

/**
 *  当用户通过高亮输入大量字母汉子等信息时,由于长度不能超过20字节,此函数用户计算截断位置
 *
 *  @param string 用于输入的高长度昵称
 *
 *  @return 需要截断的位置索引
 */
- (NSUInteger)getNickIndex:(NSString *)string {
    size_t inIndex = 0;
    size_t length  = 0;
    for (int i = 0; i < [string length]; i++) {
        unichar ch = [string characterAtIndex:i];
        if (0x4e00 < ch  && ch < 0x9fff) {
            length += 2;
        }
        else {
            length++;
        }
        
        if (length >= kNicknameMaxLength) {
            break;
        }
        
        inIndex++;
    }
    
    return inIndex;
}

/**
 *  编辑昵称时每一次按键后的回调,每次回调都会检查输入的昵称长度是否适中
 *
 *  @param obj 用于获取输入的控件指针
 */
- (void)textFiledEditChanged:(NSNotification *)obj {
    UITextField *textField = (UITextField *)obj.object;
    NSString *toBeString = textField.text;
    NSString *lang = [[textField textInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) {
        // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        // 获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if (!position)   // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        {
            if ([TCUtil getContentLength:toBeString] > kNicknameMaxLength)
            {
                [[HUDHelper sharedInstance] tipMessage:[NSString stringWithFormat:@"%@%d",@"昵称长度不能超过", kNicknameMaxLength/2]];
                textField.text = [toBeString substringToIndex:[self getNickIndex:textField.text]];
            }
        }
    }
    else {
        // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
        if ([TCUtil getContentLength:toBeString] > kNicknameMaxLength)
        {
            [[HUDHelper sharedInstance] tipMessage:[NSString stringWithFormat:@"%@%d",@"昵称长度不能超过", kNicknameMaxLength/2]];
            textField.text = [toBeString substringToIndex:[self getNickIndex:textField.text]];
        }
    }
}

@end
