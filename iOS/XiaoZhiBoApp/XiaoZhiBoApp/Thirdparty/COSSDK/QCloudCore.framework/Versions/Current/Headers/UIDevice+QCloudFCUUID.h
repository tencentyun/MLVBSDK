//
//  UIDevice+QCloudFCUUID.h
//
//  Created by Fabio Caccamo on 19/11/15.
//  Copyright © 2015 Fabio Caccamo. All rights reserved.
//

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#import "QCloudFCUUID.h"

@interface UIDevice (QCloudFCUUID)

-(NSString *)qcloud_uuid;

@end
#endif

