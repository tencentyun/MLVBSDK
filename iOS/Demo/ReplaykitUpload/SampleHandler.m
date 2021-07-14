//
//  SampleHandler.m
//  ReplayKit2Upload
//
//  Created by rushanting on 2018/3/26.
//  Copyright © 2018年 Tencent. All rights reserved.
//


#import "SampleHandler.h"
#import "ReplayKit2Define.h"
#import <UserNotifications/UserNotifications.h>
#import "ReplayKitLocalized.h"
#import <TXLiteAVSDK_ReplayKitExt/TXLiteAVSDK_ReplayKitExt.h>

//  To handle samples with a subclass of RPBroadcastSampleHandler set the following in the extension's Info.plist file:
//  - RPBroadcastProcessMode should be set to RPBroadcastProcessModeSampleBuffer

@interface SampleHandler()<TXReplayKitExtDelegate>
@end

@implementation SampleHandler {

}

- (void)dealloc {
}

- (void)sendLocalNotificationToHostAppWithTitle:(NSString*)title msg:(NSString*)msg userInfo:(NSDictionary*)userInfo
{
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString localizedUserNotificationStringForKey:title arguments:nil];
    content.body = [NSString localizedUserNotificationStringForKey:msg  arguments:nil];
    content.sound = [UNNotificationSound defaultSound];
    content.userInfo = userInfo;
    
    // 在 设定时间 后推送本地推送
    UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger
                                                  triggerWithTimeInterval:0.1f repeats:NO];
    
    UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:@"ReplayKit2Demo"
                                                                          content:content trigger:trigger];
    
    //添加推送成功后的处理！
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        
    }];
}

#pragma mark - RPBroadcastSampleHandler
- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    [self sendLocalNotificationToHostAppWithTitle:ReplayKitLocalize(@"ReplayKitUpload.SampleHandler.tencentcloudpushstream") msg:ReplayKitLocalize(@"ReplayKitUpload.SampleHandler.replaystart") userInfo:@{kReplayKit2UploadingKey: kReplayKit2Uploading}];
    [[TXReplayKitExt sharedInstance] setupWithAppGroup:kReplayKit2AppGroupId delegate:self];
}

- (void)broadcastPaused {
    // User has requested to pause the broadcast. Samples will stop being delivered.
    NSLog(@"broadcastPaused");
    [self sendLocalNotificationToHostAppWithTitle:ReplayKitLocalize(@"ReplayKitUpload.SampleHandler.tencentcloudpushstream") msg:ReplayKitLocalize(@"ReplayKitUpload.SampleHandler.replaystop") userInfo:nil];
}

- (void)broadcastResumed {
    // User has requested to resume the broadcast. Samples delivery will resume.
    NSLog(@"broadcastResumed");
    [self sendLocalNotificationToHostAppWithTitle:ReplayKitLocalize(@"ReplayKitUpload.SampleHandler.tencentcloudpushstream") msg:ReplayKitLocalize(@"ReplayKitUpload.SampleHandler.replayrestored") userInfo:nil];
}

- (void)broadcastFinished {
    // User has requested to finish the broadcast.
    NSLog(@"broadcastFinished");
    [self sendLocalNotificationToHostAppWithTitle:ReplayKitLocalize(@"ReplayKitUpload.SampleHandler.tencentcloudpushstream") msg:ReplayKitLocalize(@"ReplayKitUpload.SampleHandler.replayend") userInfo:@{kReplayKit2UploadingKey: kReplayKit2Stop}];
    [[TXReplayKitExt sharedInstance] broadcastFinished];
}


- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    if (sampleBufferType != RPSampleBufferTypeAudioMic) {
        /// 声音由主APP采集发送
        [[TXReplayKitExt sharedInstance] sendSampleBuffer:sampleBuffer withType:sampleBufferType];
    }
}

#pragma mark - TXReplayKitExtDelegate
- (void)broadcastFinished:(TXReplayKitExt *)broadcast reason:(TXReplayKitExtReason)reason
{
    NSString *tip = @"";
    switch (reason) {
        case TXReplayKitExtReasonRequestedByMain:
            tip = ReplayKitLocalize(@"ReplayKitUpload.SampleHandler.screenshareend");
            break;
        case TXReplayKitExtReasonDisconnected:
            tip = ReplayKitLocalize(@"ReplayKitUpload.SampleHandler.applicationtodisconnect");
            break;
        case TXReplayKitExtReasonVersionMismatch:
            tip = ReplayKitLocalize(@"ReplayKitUpload.SampleHandler.integrationerror"); 
            break;
    }

    NSError *error = [NSError errorWithDomain:NSStringFromClass(self.class)
                                         code:0
                                     userInfo:@{
                                         NSLocalizedFailureReasonErrorKey:tip
                                     }];
    [self finishBroadcastWithError:error];
}

@end
