/**
 * Module: TCMainTabViewController
 *
 * Function: 主界面的Tab控件，用于切换列表、推流和个人资料页面
 */

#import "TCMainTabViewController.h"
#import "TCRoomListViewController.h"
#import "TCAnchorViewController.h"
#import "UIImage+Additions.h"
#import "TCAnchorPrepareViewController.h"
#import "TCUserProfileViewController.h"
#import "UIAlertView+BlocksKit.h"
#import "TCAccountMgrModel.h"
#import "UIView+Additions.h"

#define BOTTOM_VIEW_HEIGHT              225

typedef enum : NSUInteger {
    PickerCut = 1,
    PickerComposite = 2
} PickerType;

@interface TCMainTabViewController () <UITabBarControllerDelegate>

@property (nonatomic, strong) UIButton *liveBtn;
@property (nonatomic, strong) MLVBLiveRoom *liveRoom;
@property (nonatomic, assign) BOOL     initSucc;

@end

@implementation TCMainTabViewController
{
    TCRoomListViewController *_showVC;
    PickerType               _pickerType;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setup];
    [self initLiveRoom];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self addChildViewMiddleBtn];
}

- (void)setup {
    CGFloat bottom = 0;
    if (@available(iOS 11, *)) {
        bottom = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    }
    CGFloat hat = 16;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -hat, self.tabBar.width, self.tabBar.height+hat+bottom)];
    imageView.contentMode = UIViewContentModeScaleToFill;

    CGSize canvasSize = CGSizeMake(self.tabBar.width, self.tabBar.height+hat+bottom);
    UIImage *tabImage = [[UIImage imageNamed:@"tab_side"] stretchableImageWithLeftCapWidth:0 topCapHeight:18];
    UIGraphicsBeginImageContext(canvasSize);
    [tabImage drawInRect:(CGRect){CGPointZero, canvasSize}];
    UIImage *middle = [[UIImage imageNamed:@"tab_middle"] stretchableImageWithLeftCapWidth:0 topCapHeight:18];
    [middle drawInRect:CGRectMake(canvasSize.width/2 - middle.size.width/2, 0, middle.size.width, canvasSize.height)];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [imageView setImage:image];
    [self.tabBar insertSubview:imageView atIndex:0];
    self.tabBar.clipsToBounds = NO;
    self.tabBar.tintColor = [UIColor whiteColor];
    self.tabBar.shadowImage = [[UIImage alloc]init];
    _showVC = [TCRoomListViewController new];
    
    UIViewController *_ = [UIViewController new];
    UIViewController *v3 = [TCUserProfileViewController new];
    self.viewControllers = @[_showVC, _, v3];
    
    [self addChildViewController:_showVC imageName:@"video_normal" selectedImageName:@"video_click" title:nil];
    [self addChildViewController:_ imageName:nil selectedImageName:nil title:nil];
    [self addChildViewController:v3 imageName:@"User_normal" selectedImageName:@"User_click" title:nil];
    
    self.delegate = self; // this make tabBarController call
    [self setSelectedIndex:0];
}

//添加推流按钮
- (void)addChildViewMiddleBtn {
    self.liveBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.tabBar addSubview:btn];
        [btn setImage:[UIImage imageNamed:@"play_normal"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"play_click"] forState:UIControlStateSelected];
        btn.adjustsImageWhenHighlighted = NO;//去除按钮的按下效果（阴影）
        [btn addTarget:self action:@selector(onLiveButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(self.tabBar.frame.size.width/2-60, -8, 120, 120);
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, 35, 70, 35);
        btn;
    });
}

- (void)addChildViewController:(UIViewController *)childController imageName:(NSString *)normalImg selectedImageName:(NSString *)selectImg title:(NSString *)title {
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:childController];
    childController.tabBarItem.image = normalImg ? [[UIImage imageNamed:normalImg] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] : nil;
    childController.tabBarItem.selectedImage = selectImg ? [[UIImage imageNamed:selectImg] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] : nil;
    childController.title = title;

    [self addChildViewController:nav];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    return YES;
}

- (void)onLiveButtonClicked {
    if (_showVC != nil && _showVC.playVC != nil) {
        _showVC.playVC = nil;
    }
    
    [self showPushSettingView];
}

- (void)showPushSettingView {
    TCAnchorPrepareViewController *publish = [TCAnchorPrepareViewController new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:publish];
    [self presentViewController:nav animated:YES completion:nil];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)initLiveRoom {
    self.liveRoom = [MLVBLiveRoom sharedInstance];
    [TCRoomListMgr sharedMgr].liveRoom = self.liveRoom;
}

@end
