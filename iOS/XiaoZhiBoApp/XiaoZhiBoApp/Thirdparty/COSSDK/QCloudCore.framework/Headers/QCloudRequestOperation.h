//
//  QCloudRequestOperation.h
//  Pods
//
//  Created by Dong Zhao on 2017/3/10.
//
//

#import <Foundation/Foundation.h>

@class QCloudAbstractRequest;


@class QCloudRequestOperation;
@protocol QCloudRequestOperationDelegate <NSObject>
- (void) requestOperationFinish:(QCloudRequestOperation*)operation;
@end
@interface QCloudRequestOperation : NSObject
@property (nonatomic, weak) id<QCloudRequestOperationDelegate>delagte;
@property (nonatomic, strong ,readonly) QCloudAbstractRequest* request;
+ (instancetype) new NS_UNAVAILABLE;
- (instancetype) init NS_UNAVAILABLE;
- (instancetype) initWithRequest:(QCloudAbstractRequest*)request NS_DESIGNATED_INITIALIZER;
- (void) execute;
- (void) main;
@end
