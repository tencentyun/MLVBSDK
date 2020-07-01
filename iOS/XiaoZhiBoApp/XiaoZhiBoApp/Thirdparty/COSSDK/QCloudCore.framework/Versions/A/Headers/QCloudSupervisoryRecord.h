//
//  QCloudSupervisoryRecord.h
//  Pods
//
//  Created by Dong Zhao on 2017/4/7.
//
//

#import <Foundation/Foundation.h>
#import "QCloudNetEnv.h"

typedef NS_ENUM(NSInteger, QCloudSupervisoryRecordType) {
    QCloudSupervisoryRecordTypeNetwork
};

@interface QCloudSupervisoryRecord : NSObject
@property (nonatomic, strong) NSDate* logDate;
@property (nonatomic, assign) QCloudSupervisoryRecordType type;
@end

@interface QCloudSupervisoryNetworkRecord : QCloudSupervisoryRecord
@property (nonatomic, assign) NSTimeInterval rtt;
@property (nonatomic, assign) NSTimeInterval connection;
@property (nonatomic, assign) NSTimeInterval securetyConnection;
@property (nonatomic, assign) NSTimeInterval upload;
@property (nonatomic, assign) NSTimeInterval request;
@property (nonatomic, assign) NSTimeInterval download;
@property (nonatomic, assign) NSTimeInterval response;
@property (nonatomic, assign) NSTimeInterval dns;
@property (nonatomic, assign) NSTimeInterval server;
@property (nonatomic, assign) int64_t uploadHeaderSize;
@property (nonatomic, assign) int64_t uploadBodySize;
@property (nonatomic, assign) int64_t downloadHeaderSize;
@property (nonatomic, assign) int64_t downloadBodySize;
@property (nonatomic, strong) NSString* service;
@property (nonatomic, strong) NSString* method;
@property (nonatomic, assign) int errorCode;
@property (nonatomic, strong) NSString* errorMessage;
@property (nonatomic, assign) QCloudNetworkStatus networkStatus;
@property (nonatomic, strong) NSString* userAgent;
@end
