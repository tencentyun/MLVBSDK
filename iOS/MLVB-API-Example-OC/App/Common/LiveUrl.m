//
//  LiveUrl.m
//  MLVB-API-Example-OC
//
//  Created by bluedang on 2021/6/28.
//

/*
 * MLVB 移动直播地址生成
 *
 * 详情请参考：「https://cloud.tencent.com/document/product/454/7915」
 */

#import "LiveUrl.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation LiveUrl

+ (NSString*)getMd5WithString:(NSString *)string {
    const char* original_str=[string UTF8String];
    unsigned char digist[16];
    CC_MD5(original_str, (uint)strlen(original_str), digist);
    NSMutableString *outPutStr = [NSMutableString stringWithCapacity:10];
    for(int  i = 0; i < 16; i++){
        [outPutStr appendFormat:@"%02x", digist[i]];
    }
    return [outPutStr lowercaseString];
}

+ (NSString*)getSafeUrl:(NSString*)streamId {
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time= [date timeIntervalSince1970] + 60 * 60 * 24;

    NSString *hexTxTime = [[NSString alloc] initWithFormat:@"%X", (int)time];
    NSString *secret = [[URLKEY stringByAppendingString:streamId] stringByAppendingString:hexTxTime];
    NSString *txSecret = [LiveUrl getMd5WithString:secret];
    
    return [[NSString alloc] initWithFormat:@"txSecret=%@&txTime=%@", txSecret, hexTxTime];
}

+ (NSString*)generateRtmpPushUrl:(NSString*)streamId {
    NSString *url = [NSString stringWithFormat:@"rtmp://%d.livepush.myqcloud.com/live/%@?%@",
           BIZID, streamId, [LiveUrl getSafeUrl:streamId]];
    return url;
}
+ (NSString*)generateRtmpPlayUrl:(NSString*)streamId {
    NSString *url = [NSString stringWithFormat:@"rtmp://%d.liveplay.myqcloud.com/live/%@",
           BIZID, streamId];
    return url;
}

+ (NSString*)generateTRTCPushUrl:(NSString*)streamId {
    NSString *userId = [NSString generateRandomUserId];

    return [LiveUrl generateTRTCPushUrl:streamId userId:userId];
}

+ (NSString*)generateTRTCPlayUrl:(NSString*)streamId {
    NSString *userId = [NSString generateRandomUserId];

    return [LiveUrl generateTRTCPlayUrl:streamId userId:userId];
}

+ (NSString*)generateTRTCPushUrl:(NSString*)streamId userId:(NSString*)userId {
    NSString *url = [NSString stringWithFormat:@"trtc://cloud.tencent.com/push/%@?sdkappid=%d&userid=%@&usersig=%@&appscene=live",
                streamId, SDKAppID, userId, [GenerateTestUserSig genTestUserSig:userId]];
    return url;
}

+ (NSString*)generateTRTCPlayUrl:(NSString*)streamId userId:(NSString*)userId {
    NSString *url = [NSString stringWithFormat:@"trtc://cloud.tencent.com/play/%@?sdkappid=%d&userid=%@&usersig=%@&appscene=live",
                streamId, SDKAppID, userId, [GenerateTestUserSig genTestUserSig:userId]];
    return url;
}


+ (NSString*)generateLebPlayUrl:(NSString*)streamId {
    NSString *url = [NSString stringWithFormat:@"webrtc://%d.liveplay.myqcloud.com/live/%@",
           BIZID, streamId];

    return url;
}


@end
