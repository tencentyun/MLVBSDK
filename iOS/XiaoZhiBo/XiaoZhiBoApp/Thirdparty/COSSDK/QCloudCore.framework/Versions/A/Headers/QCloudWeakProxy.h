//
//  QCloudWeakProxy.h
//  Pods
//
//  Created by QCloudTernimalLab on 2016/11/16.
//
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface QCloudWeakProxy : NSProxy
/**
 The proxy target.
 */
@property (nullable, nonatomic, weak, readonly) id target;

/**
 Creates a new weak proxy for target.
 
 @param target Target object.
 
 @return A new proxy object.
 */
- (instancetype)initWithTarget:(id)target;

/**
 Creates a new weak proxy for target.
 
 @param target Target object.
 
 @return A new proxy object.
 */
+ (instancetype)proxyWithTarget:(id)target;
@end
NS_ASSUME_NONNULL_END
