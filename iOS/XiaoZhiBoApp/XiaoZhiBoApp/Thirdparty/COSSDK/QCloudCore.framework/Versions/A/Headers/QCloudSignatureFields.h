//
//  QCloudSignatureFields.h
//  Pods
//
//  Created by Dong Zhao on 2017/4/21.
//
//

#import <Foundation/Foundation.h>

@interface QCloudSignatureFields : NSObject
@property (nonatomic, strong) NSString* appID;
@property (nonatomic, strong) NSString* bucket;
@property (nonatomic, strong, readonly) NSString* filed;
@property (nonatomic, strong) NSString* directory;
@property (nonatomic, strong) NSString* fileName;

/**
 是否需要一次性签名，默认为No
 */
@property (nonatomic, assign) BOOL once;
@end
