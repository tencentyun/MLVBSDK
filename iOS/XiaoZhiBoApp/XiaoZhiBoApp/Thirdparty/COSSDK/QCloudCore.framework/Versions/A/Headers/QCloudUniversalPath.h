//
//  QCloudUniversalPath.h
//  QCloudCore
//
//  Created by erichmzhang(张恒铭) on 2018/7/20.
//

#import <Foundation/Foundation.h>
#import "QCloudUniversalPathConstants.h"
NS_ASSUME_NONNULL_BEGIN



@interface QCloudUniversalPath : NSObject

@property (nonatomic, strong) NSString *originURL;
@property (nonatomic, assign) QCloudUniversalPathType type;
- (NSURL *)fileURL;
- (instancetype)initWithStrippedURL:(NSString * )strippedURL;

@end

NS_ASSUME_NONNULL_END
