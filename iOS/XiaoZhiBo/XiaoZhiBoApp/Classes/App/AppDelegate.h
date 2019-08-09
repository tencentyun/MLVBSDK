/**
 * Module: AppDelegate
 *
 * Function: App入口 & 初始化
 */

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder<UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (instancetype)sharedInstance;

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (UIViewController *)popViewController:(BOOL)animated;
- (void)presentViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)(void))completion;
- (void)dismissViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)(void))completion;

// 进入主界面
- (void)enterMainUI;

// 进入登录界面
- (void)enterLoginUI;

@end

