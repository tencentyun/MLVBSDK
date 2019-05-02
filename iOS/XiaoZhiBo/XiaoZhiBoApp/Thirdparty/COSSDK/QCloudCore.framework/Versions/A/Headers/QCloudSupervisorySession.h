//
//  QCloudSupervisorySession.h
//  Pods
//
//  Created by Dong Zhao on 2017/4/7.
//
//

#import <Foundation/Foundation.h>

@class QCloudSupervisoryRecord;
@interface QCloudSupervisorySession : NSObject
@property (nonatomic, strong) NSString* traceIdentifier;
@property (nonatomic, strong) NSString* deviceUUID;
@property (nonatomic, strong) NSDate* beginDate;
@property (nonatomic, strong) NSDate* endDate;
@property (nonatomic, strong) NSArray<QCloudSupervisoryRecord*>*records;
@property (nonatomic, strong) NSDictionary* ips;
+ (instancetype) new NS_UNAVAILABLE;
- (instancetype) init;
- (void) appendRecord:(QCloudSupervisoryRecord*)record;
- (void) markFinish;
@end
