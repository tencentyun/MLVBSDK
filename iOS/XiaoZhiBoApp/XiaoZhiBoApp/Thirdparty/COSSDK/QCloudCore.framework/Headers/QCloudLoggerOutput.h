//
//  QCloudLoggerOutput.h
//  QCloudCore
//
//  Created by Dong Zhao on 2018/5/29.
//

#import <Foundation/Foundation.h>
@class QCloudLogModel;
@interface QCloudLoggerOutput : NSObject
- (void) appendLog:(QCloudLogModel*(^)(void))logCreate;
@end
