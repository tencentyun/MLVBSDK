//
//  QCloudHTTPRequestOperation.h
//  Pods
//
//  Created by Dong Zhao on 2017/4/14.
//
//

#import "QCloudRequestOperation.h"
@class QCloudHTTPSessionManager;
@interface QCloudHTTPRequestOperation : QCloudRequestOperation
@property (nonatomic, weak) QCloudHTTPSessionManager* sessionManager;
@end
