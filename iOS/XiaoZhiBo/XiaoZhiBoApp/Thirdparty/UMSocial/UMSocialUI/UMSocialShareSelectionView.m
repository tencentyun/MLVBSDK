//
//  UMSocialShareSelectionView.m
//  SocialSDK
//
//  Created by umeng on 16/4/24.
//  Copyright © 2016年 dongjianxiong. All rights reserved.
//

#import "UMSocialShareSelectionView.h"
#import "UMSocialShareSelectionViewCell.h"
#import "UMSocialCollectionPageView.h"
#import "UMSocialCollectionCell.h"


static NSString *UMSplatformTypeKey = @"UMSplatformTypeKey";
static NSString *UMSSharePlatformTypeKey = @"UMSSharePlatformTypeKey";
static NSString *UMSSharePlatformIconNameKey = @"UMSSharePlatformIconNameKey";

#define UMSocial_Max_Row_Count 3 //最大行数（计算高度时会用到）
#define UMSocial_Item_Count_PerRow 4 //列数 （计算高度时会用到）
#define UMSocial_Line_Space 10 //行间距（计算高度时会用到）

#define UMSocial_Item_Width 70
#define UMSocial_Left_Space 10
#define UMSocial_Menu_CornerRadius 10
#define UMSocial_MenuAndCancel_Space 10
#define UMSocial_BgGray_View_Alpha 0.3

@interface UMSocialShareSelectionView ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, assign, readwrite) UMSocialPlatformType selectionPlatform;

@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) UIView *shareSuperView;

@property (nonatomic, assign) CGSize itemSize;

@property (nonatomic, assign) CGFloat lineSpace;//

@property (nonatomic, strong) UMSocialCollectionPageView *pageView;

@end


@implementation UMSocialShareSelectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewFlowLayout *)layout
{
    //获取可分享平台
    NSMutableArray *platformArray = [[NSMutableArray alloc] init];
    for (NSNumber *platformType in [UMSocialManager defaultManager].platformTypeArray) {
        NSMutableDictionary *dict = [self dictWithPlatformName:platformType];
        [dict setObject:platformType forKey:UMSSharePlatformTypeKey];
        if (dict) {
            [platformArray addObject:dict];
        }
    }
    
    if (platformArray.count == 0) {//如果没有有效的分享平台，则不创建分享菜单
        UMSocialLogDebug(@"There is no any valid platform");
        return nil;
    }
    [platformArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ([[obj1 valueForKey:UMSSharePlatformTypeKey] integerValue] > [[obj2 valueForKey:UMSSharePlatformTypeKey] integerValue]) {
            return NSOrderedDescending;
        }else{
            return NSOrderedAscending;
        }
    }];
//    UMSocialPlatformType
    UIView *shareSuperView = [UIApplication sharedApplication].keyWindow;
    CGSize itemSize = CGSizeMake(UMSocial_Item_Width, UMSocial_Item_Width);
    frame = shareSuperView.frame;
    frame.origin.x = UMSocial_Left_Space;
    frame.size.width = frame.size.width - frame.origin.x*2;
    
    NSInteger itemCountPerrow;
    if (platformArray.count > UMSocial_Item_Count_PerRow) {
        itemCountPerrow = UMSocial_Item_Count_PerRow;
    }else{
        itemCountPerrow = platformArray.count;
    }
    //先判断是横竖屏，再进行计算
    CGFloat itemSpace;
    if (shareSuperView.frame.size.width > shareSuperView.frame.size.height) {
        frame.size.height = frame.size.height - UMSocial_Left_Space*2;
        itemSpace = (frame.size.height - itemSize.width * itemCountPerrow) / (itemCountPerrow );
    }else{
        frame.size.width = frame.size.width - UMSocial_Left_Space*2;
        itemSpace = (frame.size.width - itemSize.width * itemCountPerrow) / (itemCountPerrow);
    }

    layout.itemSize = itemSize;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumInteritemSpacing = 0;
//    layout.minimumLineSpacing = UMSocial_Line_Space;
    layout.sectionInset = UIEdgeInsetsMake(UMSocial_Line_Space/2, itemSpace/2, UMSocial_Line_Space/2, itemSpace/2);
    
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
    
        self.layer.cornerRadius = UMSocial_Menu_CornerRadius;
        self.backgroundColor = [UIColor whiteColor];
        self.lineSpace = UMSocial_Line_Space;
        self.shareSuperView = shareSuperView;
        self.sharePaltformNames = platformArray;
        self.itemSize = itemSize;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        [self registerNib:[UINib nibWithNibName:@"UMSocialShareSelectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"UMSocialShareSelectionViewCell"];
        self.delegate = self;
        self.dataSource = self;

        [self creatBackgroundGrayView];
        [self creatCancelButton];
        
        //监听横竖屏切换的通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(doRotateAction:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        
//        self.pageView = [[UMSocialCollectionPageView alloc] init];
//        self.pageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
//        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:10];
//        for (int index = 0; index < 10; index ++) {
//            UMSocialCollectionCell *cell = [[UMSocialCollectionCell alloc] init];
////            [dict setValue:UMSocialPlatformIconWithName(imageName) forKey:UMSSharePlatformIconNameKey];
////            [dict setValue:paltFormName forKey:UMSplatformTypeKey];
//            NSString *platformName = [self.sharePaltformNames[index] objectForKey:UMSplatformTypeKey];
//            NSString *iconName = [self.sharePaltformNames[index] objectForKey:UMSSharePlatformIconNameKey];
//            [cell reloadDataWithImage:[UIImage imageNamed:iconName] platformName:platformName];
//            [arr addObject:cell];
//        }
//        [self.pageView reloadPageViewWithCells:arr];
//        [self.shareSuperView addSubview:self.pageView];
//        
    }
    return self;
}

- (void)doRotateAction:(NSNotification *)notification {
    
    //重新布局
    [self resetSubviews];
    [self reloadData];
}


#pragma mark - 创建子视图
//创建取消按钮
- (void)creatCancelButton
{
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(0, 0, self.frame.size.width, 40);
    [cancelButton addTarget:self action:@selector(hiddenShareMenuView) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    cancelButton.backgroundColor = [UIColor whiteColor];
    cancelButton.layer.cornerRadius = UMSocial_Menu_CornerRadius;
    self.cancelButton = cancelButton;
}

//创建半透明背景视图
- (void)creatBackgroundGrayView
{
    self.backgroundGrayView = [[UIView alloc] init];
    self.backgroundGrayView.backgroundColor = [UIColor blackColor];
    self.backgroundGrayView.alpha = UMSocial_BgGray_View_Alpha;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenShareMenuView)];
    [self.backgroundGrayView addGestureRecognizer:tap];
}


- (void)willMoveToSuperview:(UIView *)newSuperview
{
    //在菜单视图（self）添加到父视图之前先add半透明的背景视图和取消按钮
    if (self.backgroundGrayView.superview != newSuperview) {
        [self.backgroundGrayView removeFromSuperview];
        [newSuperview addSubview:self.backgroundGrayView];
    }
    
    if (self.cancelButton.superview != newSuperview) {
        [self.cancelButton removeFromSuperview];
        [newSuperview addSubview:self.cancelButton];
    }
    [self resetSubviews];
}


#pragma mark -  reset subviews
//重新布局菜单栏
- (void)resetSelfFrame
{
    UIView *superView = self.shareSuperView;
    CGRect selfFrame = superView.frame;
    selfFrame.origin.x = UMSocial_Left_Space;
    selfFrame.size.width = superView.frame.size.width - selfFrame.origin.x*2;
    CGSize itemSize = self.itemSize;
    //获取行数
    NSInteger rowCount = [self rowCountWithPlatformArray:self.sharePaltformNames];
    
    //计算高度增加间距
    selfFrame.size.height = rowCount * itemSize.height + self.lineSpace*(rowCount + 2);
    //设置偏移
    selfFrame.origin.y = superView.frame.size.height - selfFrame.size.height - self.cancelButton.frame.size.height - UMSocial_MenuAndCancel_Space;
    self.frame = selfFrame;
    
    self.pageView.frame = selfFrame;
}

- (NSInteger)rowCountWithPlatformArray:(NSArray *)paltformArr
{
    NSInteger rowCount = ceilf(paltformArr.count/UMSocial_Item_Count_PerRow);
    if (rowCount > UMSocial_Max_Row_Count) {
        rowCount = UMSocial_Max_Row_Count;
    }
    return rowCount;
}

- (void)resetSubviews
{
    [self resetSelfFrame];
    
//设置取消按钮的的大小和位置
    UIView *superView = self.shareSuperView;
    self.backgroundGrayView.frame = superView.bounds;
    CGRect cancelButtonFrame = self.cancelButton.frame;
    cancelButtonFrame.size.width = self.frame.size.width;
    cancelButtonFrame.origin.y = superView.frame.size.height - cancelButtonFrame.size.height;
    cancelButtonFrame.origin.x = self.frame.origin.x;
    self.cancelButton.frame = cancelButtonFrame;
}

#pragma mark - UICollectionView DataSource and  Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.sharePaltformNames.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"UMSocialShareSelectionViewCell";
    UMSocialShareSelectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    NSDictionary *dict = self.sharePaltformNames[indexPath.row];
    cell.platformNameLabel.text = [dict objectForKey:UMSplatformTypeKey];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.logoImageView.image = [UIImage imageNamed:[dict objectForKey:UMSSharePlatformIconNameKey]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectionPlatform = [[self.sharePaltformNames[indexPath.row] valueForKey:UMSSharePlatformTypeKey] integerValue];
    if (self.shareSelectionBlock) {
        [self hiddenShareMenuView];
        self.shareSelectionBlock(self, indexPath, self.selectionPlatform);
    }
}

#pragma mark - get platform Info
- (NSMutableDictionary *)dictWithPlatformName:(NSNumber *)platformType
{
    UMSocialPlatformType platformType_int = [platformType integerValue];
    NSString *imageName = nil;
    NSString *paltFormName = nil;
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:1];
    switch (platformType_int) {
        case UMSocialPlatformType_Sina:
            imageName = @"UMS_sina_icon";
            paltFormName = @"新浪";
            break;
        case UMSocialPlatformType_WechatSession:
            imageName = @"UMS_wechat_session_icon";
            paltFormName = @"微信";
            break;
        case UMSocialPlatformType_WechatTimeLine:
            imageName = @"UMS_wechat_timeline_icon";
            paltFormName = @"微信朋友圈";
            break;
        case UMSocialPlatformType_WechatFavorite:
            imageName = @"UMS_wechat_favorite_icon";
            paltFormName = @"微信收藏";
            break;
        case UMSocialPlatformType_QQ:
            imageName = @"UMS_qq_icon";
            paltFormName = @"QQ";
            break;
        case UMSocialPlatformType_Qzone:
            imageName = @"UMS_qzone_icon";
            paltFormName = @"QQ空间";
            break;
        case UMSocialPlatformType_TencentWb:
            imageName = @"UMS_tencent_icon";
            paltFormName = @"腾讯微博";
            break;
        case UMSocialPlatformType_AlipaySession:
            imageName = @"UMS_alipay_session_icon";
            paltFormName = @"支付宝";
            break;
        case UMSocialPlatformType_LaiWangSession:
            imageName = @"UMS_laiwang_session";
            paltFormName = @"点点虫";
            break;
        case UMSocialPlatformType_LaiWangTimeLine:
            imageName = @"UMS_laiwang_timeline";
            paltFormName = @"点点虫动态";
            break;
        case UMSocialPlatformType_YixinSession:
            imageName = @"UMS_yixin_session";
            paltFormName = @"易信聊天";
            break;
        case UMSocialPlatformType_YixinTimeLine:
            imageName = @"UMS_yixin_timeline";
            paltFormName = @"易信朋友圈";
            break;
        case UMSocialPlatformType_Douban:
            imageName = @"UMS_douban_icon";
            paltFormName = @"豆瓣";
            break;
        case UMSocialPlatformType_Renren:
            imageName = @"UMS_renren_icon";
            paltFormName = @"人人";
            break;
        case UMSocialPlatformType_Email:
            imageName = @"UMS_email_icon";
            paltFormName = @"邮件";
            break;
        case UMSocialPlatformType_Sms:
            imageName = @"UMS_sms_icon";
            paltFormName = @"短信";
            break;
        case UMSocialPlatformType_Facebook:
            imageName = @"UMS_facebook_icon";
            paltFormName = @"Facebook";
            break;
        case UMSocialPlatformType_Twitter:
            imageName = @"UMS_twitter_icon";
            paltFormName = @"Twitter";
            break;
        case UMSocialPlatformType_Instagram:
            imageName = @"UMS_instagram_icon";
            paltFormName = @"Instagram";
            break;
        case UMSocialPlatformType_Line:
            imageName = @"UMS_line_icon";
            paltFormName = @"Line";
            break;
        case UMSocialPlatformType_Flickr:
            imageName = @"UMS_flickr_icon";
            paltFormName = @"Flickr";
            break;
        case UMSocialPlatformType_KakaoTalk:
            imageName = @"UMS_kakao_icon";
            paltFormName = @"KakaoTalk";
            break;
        case UMSocialPlatformType_Pinterest:
            imageName = @"UMS_pinterest_icon";
            paltFormName = @"Pinterest";
            break;
        case UMSocialPlatformType_Tumblr:
            imageName = @"UMS_tumblr_icon";
            paltFormName = @"Tumblr";
            break;
        case UMSocialPlatformType_Linkedin:
            imageName = @"UMS_linkedin_icon";
            paltFormName = @"Linkedin";
            break;
        case UMSocialPlatformType_Whatsapp:
            imageName = @"UMS_whatsapp_icon";
            paltFormName = @"Whatsapp";
            break;
            
        default:
            break;
    }
    [dict setValue:UMSocialPlatformIconWithName(imageName) forKey:UMSSharePlatformIconNameKey];
    [dict setValue:paltFormName forKey:UMSplatformTypeKey];
    return dict;
}


#pragma mark - show and hidden
- (void)show
{
    if (self.superview != self.shareSuperView) {
        [self removeFromSuperview];
        [self.shareSuperView addSubview:self];
    }
    
    CGRect frame = self.frame;
    if (frame.origin.y != self.superview.frame.size.height) {
        frame.origin.y = self.superview.frame.size.height;
        self.frame = frame;
    }
    
    CGRect cancelButtonFrame = self.cancelButton.frame;
    if (cancelButtonFrame.origin.y != self.superview.frame.size.height*2-cancelButtonFrame.size.height) {
        cancelButtonFrame.size.width = self.frame.size.width;
        cancelButtonFrame.origin.y = self.superview.frame.size.height*2-cancelButtonFrame.size.height;
        self.cancelButton.frame = cancelButtonFrame;
        
    }
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.frame;
        frame.origin.y = self.superview.frame.size.height - frame.size.height - self.cancelButton.frame.size.height - UMSocial_MenuAndCancel_Space;
        self.frame = frame;

        CGRect cancelButtonFrame = self.cancelButton.frame;
        cancelButtonFrame.size.width = self.frame.size.width;
        cancelButtonFrame.origin.y = self.superview.frame.size.height-cancelButtonFrame.size.height;
        self.cancelButton.frame = cancelButtonFrame;
        self.backgroundGrayView.alpha = UMSocial_BgGray_View_Alpha;
        
    } completion:^(BOOL finished) {
        
    }];
}

//隐藏视图
- (void)hiddenShareMenuView
{
    if (self.dismissBlock) {
        self.dismissBlock();
    }
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frame = self.frame;
        frame.origin.y = self.superview.frame.size.height;
        self.frame = frame;
        
        CGRect cancelFrame = self.cancelButton.frame;
        cancelFrame.origin.y = self.superview.frame.size.height*2-cancelFrame.size.height;
        self.cancelButton.frame = cancelFrame;
        
        self.backgroundGrayView.alpha = 0;
        
    } completion:^(BOOL finished) {
        [self.backgroundGrayView removeFromSuperview];
        [self removeFromSuperview];
    }];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

