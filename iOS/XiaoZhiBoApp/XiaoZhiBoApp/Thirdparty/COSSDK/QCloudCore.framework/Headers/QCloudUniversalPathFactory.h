//
//  QCloudUniversalPathFactory.h
//  QCloudCore
//
//  Created by erichmzhang(张恒铭) on 2018/7/20.
//

#import <Foundation/Foundation.h>
#import "QCloudUniversalPath.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCloudUniversalPathFactory : NSObject

+ (QCloudUniversalPath *) universalPathWithURL:(NSURL *)url;

@end

NS_ASSUME_NONNULL_END
