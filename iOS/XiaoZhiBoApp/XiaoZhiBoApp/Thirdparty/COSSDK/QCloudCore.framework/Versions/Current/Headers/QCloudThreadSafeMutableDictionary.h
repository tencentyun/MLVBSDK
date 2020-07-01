//
//  QCloudThreadSafeMutableDictionary.h
//  Pods
//
//  Created by Dong Zhao on 2017/3/31.
//
//

#import <Foundation/Foundation.h>

@interface QCloudThreadSafeMutableDictionary : NSObject
- (id)objectForKey:(id)aKey;
- (void)removeObjectForKey:(id)aKey;
- (void)removeObject:(id)object;
- (void)setObject:(id)anObject forKey:(id <NSCopying>)aKey;
- (NSArray *)allKeys;
@end
