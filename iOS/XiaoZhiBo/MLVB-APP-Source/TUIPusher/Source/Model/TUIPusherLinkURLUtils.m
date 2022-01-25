//
//  TUIPusherLinkURLUtils.m
//  TUIPusher
//
//  Created by gg on 2021/9/13.
//

#import "TUIPusherLinkURLUtils.h"
#import <TUICore/TUILogin.h>
#import "TUIPusherHeader.h"

@implementation TUIPusherLinkURLUtils

+ (NSString *)generatePlayUrl:(NSString *)streamId {
    NSString *userId = [TUILogin getUserID];
    NSString *userSig = [TUILogin getUserSig];
    int sdkAppId = [TUILogin getSdkAppID];
    if (sdkAppId == 0 || userId == nil || userSig == nil) {
        LOGE("【Pusher】not login");
        return @"";
    }
    if (streamId == nil) {
        LOGE("【Pusher】stream id error");
        return @"";
    }
    return [NSString stringWithFormat:@"trtc://cloud.tencent.com/play/%@?sdkappid=%d&userid=%@&usersig=%@", streamId, sdkAppId, userId, userSig];
}
@end
