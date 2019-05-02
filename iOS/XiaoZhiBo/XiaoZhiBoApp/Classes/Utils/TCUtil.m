//
//  TCUtil.m
//  TCLVBIMDemo
//
//  Created by felixlin on 16/8/2.
//  Copyright © 2016年 tencent. All rights reserved.
//
#define ENABLE_SHARE 1

#import "TCUtil.h"
#import "TCConstants.h"
#import "NSData+Common.h"
#import "NSString+Common.h"
#import <mach/mach.h>
#import <Accelerate/Accelerate.h>
#import <mach/mach.h>
#import <sys/types.h>
#import <sys/sysctl.h>
#import "TCUserInfoModel.h"
#import "TCLoginParam.h"
#import "TCLiveListModel.h"

#if ENABLE_SHARE
#import <UShareUI/UMSocialUIManager.h>
#import <UMSocialCore/UMSocialCore.h>
#endif

@implementation TCUtil

+ (NSData *)dictionary2JsonData:(NSDictionary *)dict
{
    // 转成Json数据
    if ([NSJSONSerialization isValidJSONObject:dict])
    {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
        if(error)
        {
            DebugLog(@"[%@] Post Json Error", [self class]);
        }
        return data;
    }
    else
    {
        DebugLog(@"[%@] Post Json is not valid", [self class]);
    }
    return nil;
}

+ (NSDictionary *)jsonData2Dictionary:(NSString *)jsonData
{
    if (jsonData == nil) {
        return nil;
    }
    NSData *data = [jsonData dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (err || ![dic isKindOfClass:[NSDictionary class]]) {
        DebugLog(@"Json parse failed: %@", jsonData);
        return nil;
    }
    return dic;
}

+ (NSString *)getFileCachePath:(NSString *)fileName
{
    if (nil == fileName)
    {
        return nil;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDirectory = [paths objectAtIndex:0];
    
    NSString *fileFullPath = [cacheDirectory stringByAppendingPathComponent:fileName];
    return fileFullPath;
}


//通过分别计算中文和其他字符来计算长度
+ (NSUInteger)getContentLength:(NSString*)content
{
    size_t length = 0;
    for (int i = 0; i < [content length]; i++)
    {
        unichar ch = [content characterAtIndex:i];
        if (0x4e00 < ch  && ch < 0x9fff)
        {
            length += 2;
        }
        else
        {
            length++;
        }
    }
    
    return length;
}

+ (void)asyncSendHttpRequest:(NSString*)command token:(NSString*)token params:(NSDictionary*)params handler:(void (^)(int resultCode, NSString* message, NSDictionary* resultDict))handler
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData* data = [TCUtil dictionary2JsonData:params];
        if (data == nil)
        {
            DebugLog(@"sendHttpRequest failed，参数转成json格式失败");
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(kError_ConvertJsonFailed, @"参数错误", nil);
            });
            return;
        }
        
        NSString* urlString = [kHttpServerAddr stringByAppendingPathComponent:command];
        NSMutableString *strUrl = [[NSMutableString alloc] initWithString:urlString];
        
        NSURL *URL = [NSURL URLWithString:strUrl];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
        
        if (data)
        {
            [request setValue:[NSString stringWithFormat:@"%ld",(long)[data length]] forHTTPHeaderField:@"Content-Length"];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
            [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
            if (token.length > 0) {
                NSString* sig = [[NSString stringWithFormat:@"%@%@", token, [data md5Hash]] md5];
                [request setValue:sig forHTTPHeaderField:@"Liteav-Sig"];
            }
            [request setHTTPBody:data];
        }
        
        [request setTimeoutInterval:kHttpTimeout];
        
        
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error != nil)
            {
                DebugLog(@"internalSendRequest failed，NSURLSessionDataTask return error code:%d, des:%@", [error code], [error description]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(kError_HttpError, @"服务请求失败", nil);
                });
            }
            else
            {
                NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSDictionary* resultDict = [TCUtil jsonData2Dictionary:responseString];
                int errCode = -1;
                NSString* message = @"";
                NSDictionary* dataDict = nil;
                if (resultDict)
                {
                    if (resultDict[@"code"]) {
                        errCode = [resultDict[@"code"] intValue];
                    }
                    
                    if (resultDict[@"message"]) {
                        message = resultDict[@"message"];
                    }
                    
                    if (200 == errCode && resultDict[@"data"])
                    {
                        dataDict = resultDict[@"data"];
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(errCode, message, dataDict);
                });
            }
        }];
        
        [task resume];
    });
}

+ (void)asyncSendHttpRequest:(NSString*)command params:(NSDictionary*)params handler:(void (^)(int resultCode, NSString* message, NSDictionary* resultDict))handler
{
    [self asyncSendHttpRequest:command token:nil params:params handler:handler];
}


+ (void)asyncSendHttpRequest:(NSDictionary*)param handler:(void (^)(int result, NSDictionary* resultDict))handler
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData* data = [TCUtil dictionary2JsonData:param];
        if (data == nil)
        {
            DebugLog(@"sendHttpRequest failed，参数转成json格式失败");
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(kError_ConvertJsonFailed, nil);
            });
            return;
        }
        
        NSMutableString *strUrl = [[NSMutableString alloc] initWithString:kHttpServerAddr];
        
        NSURL *URL = [NSURL URLWithString:strUrl];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
        
        if (data)
        {
            [request setValue:[NSString stringWithFormat:@"%ld",(long)[data length]] forHTTPHeaderField:@"Content-Length"];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
            [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
            
            [request setHTTPBody:data];
        }
        
        [request setTimeoutInterval:kHttpTimeout];
        
        
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error != nil)
            {
                DebugLog(@"internalSendRequest failed，NSURLSessionDataTask return error code:%d, des:%@", [error code], [error description]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(kError_HttpError, nil);
                });
            }
            else
            {
                NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSDictionary* resultDict = [TCUtil jsonData2Dictionary:responseString];
                int errCode = -1;
                NSDictionary* dataDict = nil;
                if (resultDict)
                {
                    if (resultDict[@"returnValue"])
                        errCode = [resultDict[@"returnValue"] intValue];
                    
                    if (0 == errCode && resultDict[@"returnData"])
                    {
                        dataDict = resultDict[@"returnData"];
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(errCode, dataDict);
                });
            }
        }];
        
        [task resume];
    });
}


+ (NSString *)transImageURL2HttpsURL:(NSString *)httpURL
{
    if (httpURL.length == 0) {
        return nil;
    }
    if ([NSURL URLWithString:httpURL] == nil) {
        return nil;
    }
    NSString * httpsURL = httpURL;
    if ([httpURL hasPrefix:@"http:"]) {
        httpsURL = [httpURL stringByReplacingOccurrencesOfString:@"http:" withString:@"https:"];
    }else{
        httpsURL = [NSString stringWithFormat:@"https:%@",httpURL];
    }
    return httpsURL;
}

+(NSString*) getStreamIDByStreamUrl:(NSString*) strStreamUrl {
    if (strStreamUrl == nil || strStreamUrl.length == 0) {
        return nil;
    }
    
    strStreamUrl = [strStreamUrl lowercaseString];
    
    //推流地址格式：rtmp://8888.livepush.myqcloud.com/live/8888_test_12345_test?txSecret=aaaa&txTime=bbbb
    NSString * strLive = @"/live/";
    NSRange range = [strStreamUrl rangeOfString:strLive];
    if (range.location == NSNotFound) {
        return nil;
    }
    
    NSString * strSubString = [strStreamUrl substringFromIndex:range.location + range.length];
    NSArray * array = [strSubString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"?."]];
    if ([array count] > 0) {
        return [array objectAtIndex:0];
    }
    
    return nil;
}

+ (void)report:(NSString *)type userName:(NSString *)userName code:(UInt64)code  msg:(NSString *)msg;
{
    if(userName == nil){
        userName = [TCLoginParam shareInstance].identifier;
    }
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    // 过渡期间同时上报type和business保证报表数据可以连续展示
    [param setObject:@"xiaozhibo" forKey:@"type"];
    [param setObject:@"xiaozhibo" forKey:@"bussiness"];
    [param setObject:@"ios" forKey:@"platform"];
    [param setObject:userName == nil ? @"" : userName forKey:@"userName"];
    [param setObject:type == nil ? @"" : type forKey:@"action"];
    [param setObject:@(code) forKey:@"action_result_code"];
    [param setObject:msg == nil ? @"" : msg forKey:@"action_result_msg"];
    [param setObject:[[NSBundle mainBundle] bundleIdentifier] forKey:@"appidentifier"];
    [param setObject:[self getPackageName] forKey:@"appname"];
    [self report:param handler:^(int resultCode, NSString *message) {
        //to do
    }];
    
}

+ (NSString *)getPackageName {
    static NSString *packname = nil;
    if (packname)
        return packname;
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    packname = [infoDict objectForKey:@"CFBundleDisplayName"];
    if ([packname isEqual:@""]) {
        packname = [infoDict objectForKey:@"CFBundleIdentifier"];
    }
    return packname;
}

+ (void)report:(NSMutableDictionary *)param handler:(void (^)(int resultCode, NSString *message))handler;
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData* data = [self dictionary2JsonData:param];
        if (data == nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (handler) handler(kError_ConvertJsonFailed, nil);
            });
            return;
        }
        
        NSMutableString *strUrl = [[NSMutableString alloc] initWithString:DEFAULT_ELK_HOST];
        
        NSURL *URL = [NSURL URLWithString:strUrl];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
        
        if (data)
        {
            [request setValue:[NSString stringWithFormat:@"%ld",(long)[data length]] forHTTPHeaderField:@"Content-Length"];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
            [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
            
            [request setHTTPBody:data];
        }
        
        [request setTimeoutInterval:kHttpTimeout];
        
        
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error != nil)
            {
                NSLog(@"internalSendRequest failed，NSURLSessionDataTask return error code:%ld, des:%@", (long)[error code], [error description]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (handler) handler(kError_HttpError, nil);
                });
            }
            else
            {
                NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([responseString isEqualToString:@"ok"]) {
                        if (handler) handler(0, responseString);
                    }else{
                        if (handler) handler(-1, responseString);
                    }
                });
            }
        }];
        
        [task resume];
    });
}


//创建高斯模糊效果图片
+(UIImage *)gsImage:(UIImage *)image withGsNumber:(CGFloat)blur
{
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 40);
    boxSize = boxSize - (boxSize % 2) + 1;
    CGImageRef img = image.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    //从CGImage中获取数据
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    //设置从CGImage获取对象的属性
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate( outBuffer.data, outBuffer.width, outBuffer.height, 8, outBuffer.rowBytes, colorSpace, kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    free(pixelBuffer);
    CFRelease(inBitmapData);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    return returnImage;
}

/**
 *缩放图片
 */
+(UIImage*)scaleImage:(UIImage *)image scaleToSize:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

/**
 *裁剪图片
 */
+(UIImage *)clipImage:(UIImage *)image inRect:(CGRect)rect{
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
    return newImage;
}

+ (float) heightForString:(UITextView *)textView andWidth:(float)width{
    CGSize sizeToFit = [textView sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    return sizeToFit.height;
}

+ (void) toastTip:(NSString*)toastInfo parentView:(UIView *)parentView
{
    CGRect frameRC = [[UIScreen mainScreen] bounds];
    frameRC.origin.y = frameRC.size.height - 110;
    frameRC.size.height -= 110;
    __block UITextView * toastView = [[UITextView alloc] init];
    
    toastView.editable = NO;
    toastView.selectable = NO;
    
    frameRC.size.height = [self heightForString:toastView andWidth:frameRC.size.width];
    
    toastView.frame = frameRC;
    
    toastView.text = toastInfo;
    toastView.backgroundColor = [UIColor whiteColor];
    toastView.alpha = 0.5;
    
    [parentView addSubview:toastView];
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(){
        [toastView removeFromSuperview];
        toastView = nil;
    });
}

+(BOOL)isSuitableMachine:(int)targetPlatNum
{
    int mib[2] = {CTL_HW, HW_MACHINE};
    size_t len = 0;
    char* machine;
    
    sysctl(mib, 2, NULL, &len, NULL, 0);
    
    machine = (char*)malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString* platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    if ([platform length] > 6) {
        NSString * platNum = [NSString stringWithFormat:@"%C", [platform characterAtIndex: 6 ]];
        return ([platNum intValue] >= targetPlatNum);
    } else {
        return NO;
    }
}

#pragma mark - 分享

+ (void)initializeShare {
#if ENABLE_SHARE
    //打开调试日志
    [[UMSocialManager defaultManager] openLog:YES];
    
    //设置友盟appkey
    [[UMSocialManager defaultManager] setUmSocialAppkey:@"57f214fb67e58ecb11003aea"];
    
    // 获取友盟social版本号
    NSLog(@"UMeng social version: %@", [UMSocialGlobal umSocialSDKVersion]);
    
    //设置微信的appId和appKey
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:kWeiXin_Share_ID appSecret:kWeiXin_Share_Secrect redirectURL:@"http://mobile.umeng.com/social"];
    
    //设置分享到QQ互联的appId和appKey
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:kQQZone_Share_ID  appSecret:kQQZone_Share_Secrect redirectURL:@"http://mobile.umeng.com/social"];
    
    //设置新浪的appId和appKey
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:kSina_WeiBo_Share_ID  appSecret:kSina_WeiBo_Share_Secrect redirectURL:@"http://sns.whalecloud.com/sina2/callback"];
#endif
}

#if ENABLE_SHARE
+ (UMSocialPlatformType)toUMPlatform:(TCSocialPlatform)p {
    return (UMSocialPlatformType)p;
}
#endif

+ (void)dismissShareDialog {
    //    [UMSocialUIManager dismissShareMenuView];
}

+ (void)shareLive:(TCLiveInfo *)liveInfo currentViewController:(UIViewController *)currentViewController {
#if ENABLE_SHARE
    __weak typeof(self) weakSelf = self;
    //显示分享面板
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        [weakSelf shareDataWithPlatform:(TCSocialPlatform)platformType liveInfo:liveInfo currentViewController:currentViewController];
    }];
#endif
}

+ (void)shareDataWithPlatform:(TCSocialPlatform)platformType
                        title:(NSString *)title
                          url:(NSString *)url
                         text:(NSString*)text
                    thumbnail:(id)thumbnail
                        image:(id)image
        currentViewController:(UIViewController *)currentViewController
{
#if ENABLE_SHARE
    // 创建UMSocialMessageObject实例进行分享
    // 分享数据对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    
    // 以下分享类型，开发者可根据需求调用
    // 1、纯文本分享
    messageObject.text = @"开播啦，小伙伴火速围观～～～";
    
    // 2、 图片或图文分享
    // 图片分享参数可设置URL、NSData类型
    // 注意：由于iOS系统限制(iOS9+)，非HTTPS的URL图片可能会分享失败
    UMShareImageObject *shareObject = [UMShareImageObject shareObjectWithTitle:title descr:text thumImage:thumbnail];
    [shareObject setShareImage:image];
    
    UMShareWebpageObject *share2Object = [UMShareWebpageObject shareObjectWithTitle:title descr:text thumImage:thumbnail];
    share2Object.webpageUrl = url;
    
    //新浪微博有个bug，放在shareObject里面设置url，分享到网页版的微博不显示URL链接，这里在text后面也加上链接
    if (platformType == UMSocialPlatformType_Sina) {
        messageObject.text = [NSString stringWithFormat:@"%@  %@",messageObject.text,share2Object.webpageUrl];
    }else{
        messageObject.shareObject = share2Object;
    }
    [[UMSocialManager defaultManager] shareToPlatform:[self toUMPlatform:platformType]
                                        messageObject:messageObject
                                currentViewController:currentViewController
                                           completion:^(id data, NSError *error) {
                                               NSString *message = nil;
                                               if (!error) {
                                                   message = [NSString stringWithFormat:@"分享成功"];
                                               } else {
                                                   if (error.code == UMSocialPlatformErrorType_Cancel) {
                                                       message = [NSString stringWithFormat:@"分享取消"];
                                                   } else if (error.code == UMSocialPlatformErrorType_NotInstall) {
                                                       message = [NSString stringWithFormat:@"应用未安装"];
                                                   } else {
                                                       message = [NSString stringWithFormat:@"分享失败，失败原因(Code＝%d)\n",(int)error.code];
                                                   }
                                                   
                                               }
                                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                                                               message:message
                                                                                              delegate:nil
                                                                                     cancelButtonTitle:NSLocalizedString(@"确定", nil)
                                                                                     otherButtonTitles:nil];
                                               [alert show];
                                           }];
#endif
}

+ (void)shareDataWithPlatform:(TCSocialPlatform)platformType  liveInfo:(TCLiveInfo *)liveInfo currentViewController:(UIViewController *)currentViewController;
{
#if ENABLE_SHARE
    NSString *title = liveInfo.title;
    
    NSString *url = [NSString stringWithFormat:@"%@?userid=%@&type=%@&fileid=%@&ts=%@&sdkappid=%@&acctype=%@",
                     kLivePlayShareAddr,
                     TC_PROTECT_STR([liveInfo.userid stringByUrlEncoding]),
                     [NSString stringWithFormat:@"%d", liveInfo.type],
                     TC_PROTECT_STR([liveInfo.fileid stringByUrlEncoding]),
                     [NSString stringWithFormat:@"%d", liveInfo.timestamp],
                     [[TCUserInfoModel sharedInstance] getUserProfile].appid,
                     [[TCUserInfoModel sharedInstance] getUserProfile].accountType];
    NSString *text = [NSString stringWithFormat:@"%@ 正在直播",liveInfo.userinfo.nickname ? liveInfo.userinfo.nickname : liveInfo.userid];
    id image = liveInfo.userinfo.frontcoverImage;
    id thumb = liveInfo.userinfo.frontcoverImage;
    
    [self shareDataWithPlatform:platformType
                          title:title
                            url:url
                           text:text
                      thumbnail:thumb
                          image:image
          currentViewController:currentViewController];
#endif
}

@end


@implementation TCFrequeControl
{
    NSInteger                _countsLimit;
    NSInteger                _curCounts;
    NSTimeInterval           _secondsLimit;
    NSTimeInterval           _preTime;
}

- (instancetype)initWithCounts:(NSInteger)counts andSeconds:(NSTimeInterval)seconds {
    if (self = [super init]) {
        _countsLimit = counts;
        _secondsLimit = seconds;
        _curCounts = 0;
        _preTime = 0;
    }
    return self;
}

- (BOOL)canTrigger {
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    if (_preTime == 0 || time - _preTime > _secondsLimit) {
        _preTime = time;
        _curCounts = 0;
    }
    if (_curCounts >= _countsLimit) {
        return NO;
    }
    _curCounts += 1;
    
    return YES;
}

@end



@implementation TCLivePushListenerImpl
-(void) onPushEvent:(int)evtID withParam:(NSDictionary*)param {
    if (self.delegate) {
        [self.delegate onLivePushEvent:self.pushUrl withEvtID:evtID andParam:param];
    }
}

-(void) onNetStatus:(NSDictionary*) param {
    if (self.delegate) {
        [self.delegate onLivePushNetStatus:self.pushUrl withParam:param];
    }
}
@end


@implementation TCLivePlayListenerImpl
-(void) onPlayEvent:(int)evtID withParam:(NSDictionary*)param {
    if (self.delegate) {
        [self.delegate onLivePlayEvent:self.playUrl withEvtID:evtID andParam:param];
    }
}

-(void) onNetStatus:(NSDictionary*) param {
    if (self.delegate) {
        [self.delegate onLivePlayNetStatus:self.playUrl withParam:param];
    }
}
@end

