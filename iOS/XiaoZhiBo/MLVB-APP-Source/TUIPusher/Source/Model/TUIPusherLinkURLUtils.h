//
//  TUIPusherLinkURLUtils.h
//  TUIPusher
//
//  Created by gg on 2021/9/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIPusherLinkURLUtils : NSObject

+ (NSString *)generatePlayUrl:(NSString *)streamId;

@end

NS_ASSUME_NONNULL_END
