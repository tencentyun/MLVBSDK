//
//  QCloudSupervisory.h
//  Pods
//
//  Created by Dong Zhao on 2017/4/7.
//
//

#import <Foundation/Foundation.h>
@class QCloudHTTPRequest;
@interface QCloudSupervisory : NSObject
+ (QCloudSupervisory*) supervisory;

- (void) recordRequest:(QCloudHTTPRequest *)request error:(NSError*)error;
@end
