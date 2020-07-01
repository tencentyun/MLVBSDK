//
//  QCloudNetProfile.h
//  Pods
//
//  Created by Dong Zhao on 2017/3/22.
//
//

#import <Foundation/Foundation.h>
#define kQCloudNetProfileUploadSpeedUpdate @"kQCloudNetProfileUploadSpeedUpdate"
@interface QCloudNetProfile : NSObject
+ (QCloudNetProfile*) shareProfile;
- (void)checkSpeed;
- (void) pointDownload:(int64_t)bytes;
- (void) pointUpload:(int64_t)bytes;
@end


@interface QCloudNetProfileLevel : NSObject
{
    NSMutableArray* _downloadPoints;
    NSMutableArray* _uploadPoints;
}
@property (atomic, assign, readonly) int64_t downloadSpeed;
@property (atomic, assign, readonly) int64_t uploadSpped;
@property (atomic, assign) NSTimeInterval interval;
@end
