//
//  LiveLinkAudienceViewController.h
//  MLVB-API-Example-OC
//
//  Created by bluedang on 2021/6/29.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "ViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface LiveLinkAudienceViewController : ViewController
- (instancetype)initWithStreamId:(NSString *)streamId userId:(NSString *)userId;
@end

NS_ASSUME_NONNULL_END
