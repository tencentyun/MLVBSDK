//
//  QCloudCOSXMLUploadObjectRequest_Private.h
//  Pods
//
//  Created by Dong Zhao on 2017/5/26.
//
//

#import "QCloudCOSXMLUploadObjectRequest.h"

@class QCloudCOSTransferMangerService;
@interface QCloudCOSXMLUploadObjectRequest ()
@property (nonatomic, weak) QCloudCOSTransferMangerService* transferManager;
@end
