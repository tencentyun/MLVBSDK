//
//  QCloudSDKModuleManager.h
//  Pods
//
//  Created by Dong Zhao on 2017/5/26.
//
//

#import <Foundation/Foundation.h>


@interface QCloudSDKModule : NSObject
@property (nonatomic, strong) NSString* version;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* crashID;
@end

@interface QCloudSDKModuleManager : NSObject
@property (nonatomic, strong, readonly) NSArray* allModules;
+ (QCloudSDKModuleManager*) shareInstance;
- (void) registerModule:(QCloudSDKModule*)module;
- (void) registerModuleByJSON:(NSDictionary*)json;
@end
