//
//  TCUtil.h
//  TCLVBIMDemo
//
//  Created by felixlin on 16/8/2.
//  Copyright © 2016年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCLog.h"
#import "TCConstants.h"
#import "SDKHeader.h"
#import "UIAlertView+BlocksKit.h"
#import "TCLiveListModel.h"

typedef void(^videoIsReadyBlock)(void);


//report
static NSString * const xiaozhibo_install  = @"install";
static NSString * const xiaozhibo_startup  = @"startup";
static NSString * const xiaozhibo_staytime = @"stay_time";
static NSString * const xiaozhibo_login    = @"login";
static NSString * const xiaozhibo_register = @"register";
static NSString * const xiaozhibo_vod_play = @"vod_play";
static NSString * const xiaozhibo_vod_play_duration = @"vod_play_duration";
static NSString * const xiaozhibo_live_play = @"live_play";
static NSString * const xiaozhibo_live_play_duration = @"live_play_duration";
static NSString * const xiaozhibo_camera_push = @"camera_push";
static NSString * const xiaozhibo_camera_push_duration = @"camera_push_duration";

typedef NS_ENUM(NSInteger, TCSocialPlatform) {
    TCSocialPlatformUnknown        = -2,
    TCSocialPlatformSina           = 0,
    TCSocialPlatformWechatSession  = 1,
    TCSocialPlatformWechatTimeline = 2,
    TCSocialPlatformQQ             = 4,
    TCSocialPlatformQZone          = 5
};


@interface TCUtil : NSObject

+ (NSData *)dictionary2JsonData:(NSDictionary *)dict;

+ (NSDictionary *)jsonData2Dictionary:(NSString *)jsonData;

+ (NSString *)getFileCachePath:(NSString *)fileName;

+ (NSUInteger)getContentLength:(NSString*)string;

+ (void)asyncSendHttpRequest:(NSDictionary*)param handler:(void (^)(int resultCode, NSDictionary* resultDict))handler;
+ (void)asyncSendHttpRequest:(NSString*)command params:(NSDictionary*)params handler:(void (^)(int resultCode, NSString* message, NSDictionary* resultDict))handler;
+ (void)asyncSendHttpRequest:(NSString*)command token:(NSString*)token params:(NSDictionary*)params handler:(void (^)(int resultCode, NSString* message, NSDictionary* resultDict))handler;


+ (NSString *)transImageURL2HttpsURL:(NSString *)httpURL;

+ (NSString*) getStreamIDByStreamUrl:(NSString*) strStreamUrl;

+ (UIImage *)gsImage:(UIImage *)image withGsNumber:(CGFloat)blur;

+ (UIImage*)scaleImage:(UIImage *)image scaleToSize:(CGSize)size;

+ (UIImage *)clipImage:(UIImage *)image inRect:(CGRect)rect;

+ (void)toastTip:(NSString*)toastInfo parentView:(UIView *)parentView;

+ (float)heightForString:(UITextView *)textView andWidth:(float)width;

+ (BOOL)isSuitableMachine:(int)targetPlatNum;


#pragma mark - 分享相关
+ (void)initializeShare;

+ (void)dismissShareDialog;

+ (void)shareDataWithPlatform:(TCSocialPlatform)platformType
                        title:(NSString *)title
                          url:(NSString *)url
                         text:(NSString*)text
                    thumbnail:(id)thumbnail
                        image:(id)image
        currentViewController:(UIViewController *)currentViewController;

+ (void)shareLive:(TCLiveInfo *)liveInfo currentViewController:(UIViewController *)currentViewController;

+ (void)shareDataWithPlatform:(TCSocialPlatform)platformType  liveInfo:(TCLiveInfo *)liveInfo currentViewController:(UIViewController *)currentViewController;

+ (void)report:(NSString *)type userName:(NSString *)userName code:(UInt64)code  msg:(NSString *)msg;

@end


// 频率控制类，如果频率没有超过 nCounts次/nSeconds秒，canTrigger将返回true
@interface TCFrequeControl : NSObject

- (instancetype)initWithCounts:(NSInteger)counts andSeconds:(NSTimeInterval)seconds;
- (BOOL)canTrigger;

@end


// 日志
#ifdef DEBUG

#ifndef DebugLog
//#define DebugLog(fmt, ...) NSLog((@"[%s Line %d]" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define DebugLog(fmt, ...) [[TCLog shareInstance] log:fmt, ##__VA_ARGS__]
#endif

#else

#ifndef DebugLog
#define DebugLog(fmt, ...)  [[TCLog shareInstance] log:fmt, ##__VA_ARGS__]
#endif
#endif

#ifndef TC_PROTECT_STR
#define TC_PROTECT_STR(x) (x == nil ? @"" : x)
#endif


// ITCLivePushListener
@protocol ITCLivePushListener <NSObject>
@optional
-(void)onLivePushEvent:(NSString*) pushUrl withEvtID:(int)evtID andParam:(NSDictionary*)param;

@optional
-(void)onLivePushNetStatus:(NSString*) pushUrl withParam: (NSDictionary*) param;
@end


// TXLivePushListenerImpl
@interface TCLivePushListenerImpl: NSObject<TXLivePushListener>
@property (nonatomic, strong) NSString*   pushUrl;
@property (nonatomic, weak) id<ITCLivePushListener> delegate;
@end



// ITCLivePlayListener
@protocol ITCLivePlayListener <NSObject>
@optional
-(void)onLivePlayEvent:(NSString*) playUrl withEvtID:(int)evtID andParam:(NSDictionary*)param;

@optional
-(void)onLivePlayNetStatus:(NSString*) playUrl withParam: (NSDictionary*) param;
@end



// TXLivePlayListenerImpl
@interface TCLivePlayListenerImpl: NSObject<TXLivePlayListener>
@property (nonatomic, strong) NSString*   playUrl;
@property (nonatomic, weak) id<ITCLivePlayListener> delegate;
@end
