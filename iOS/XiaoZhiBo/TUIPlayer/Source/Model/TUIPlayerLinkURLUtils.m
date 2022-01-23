//
//  TUIPlayerLinkURLUtils.m
//  TUIPlayer
//
//  Created by gg on 2021/9/14.
//

#import "TUIPlayerLinkURLUtils.h"
#import <ImSDK_Plus/ImSDK_Plus.h>
#import <TUICore/TUILogin.h>
#import "TUIPlayerHeader.h"

static NSString *const TRTC        = @"trtc://";
static NSString *const TRTC_DOMAIN = @"cloud.tencent.com";

@implementation TUIPlayerLinkURLUtils

+ (NSString *)getStreamIdByPushUrl:(NSString *)urlStr {
    NSURL *url = [NSURL URLWithString:urlStr];
    if (!url) {
        return @"";
    }
    NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    NSString *path = urlComponents.path;
    if (!path) {
        return @"";
    }
    NSArray *arr = [path componentsSeparatedByString:@"/"];
    if (arr.count > 0) {
        return arr.lastObject;
    }
    return @"";
}

+ (NSString *)generatePushUrl:(NSString *)streamId {
    if (V2TIM_STATUS_LOGINED != [[V2TIMManager sharedInstance] getLoginStatus]) {
        LOGE("【Player】not login");
        return @"";
    }
    NSString *userId = [TUILogin getUserID];
    NSString *userSig = [TUILogin getUserSig];
    int sdkAppId = [TUILogin getSdkAppID];
    
    if (streamId == nil) {
        LOGE("【Player】stream id error");
        return @"";
    }
    return [NSString stringWithFormat:@"%@%@/push/%@?sdkappid=%d&userid=%@&usersig=%@", TRTC, TRTC_DOMAIN, streamId, sdkAppId, userId, userSig];
}

+ (NSString *)generatePlayUrl:(NSString *)streamId {
    NSString *userId = [TUILogin getUserID];
    NSString *userSig = [TUILogin getUserSig];
    int sdkAppId = [TUILogin getSdkAppID];
    if (sdkAppId == 0 || userId == nil || userSig == nil) {
        LOGE("【Player】not login");
        return @"";
    }
    if (streamId == nil) {
        LOGE("【Player】stream id error");
        return @"";
    }
    return [NSString stringWithFormat:@"trtc://cloud.tencent.com/play/%@?sdkappid=%d&userid=%@&usersig=%@", streamId, sdkAppId, userId, userSig];
}
@end
