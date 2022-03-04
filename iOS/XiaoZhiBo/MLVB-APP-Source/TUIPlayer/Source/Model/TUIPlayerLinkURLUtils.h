//
//  TUIPlayerLinkURLUtils.h
//  TUIPlayer
//
//  Created by gg on 2021/9/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIPlayerLinkURLUtils : NSObject

+ (NSString *)generatePushUrl:(NSString *)streamId;

+ (NSString *)generatePlayUrl:(NSString *)streamId;

+ (NSString *)getStreamIdByPushUrl:(NSString *)urlStr;
@end

NS_ASSUME_NONNULL_END
