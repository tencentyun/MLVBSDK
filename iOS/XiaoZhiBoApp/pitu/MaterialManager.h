//
//  MaterialManager.h
//  PituMotionDemo
//
//  Created by billwang on 16/8/8.
//  Copyright © 2016年 Pitu. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kMC_NOTI_ONLINEMANAGER_PACKAGE_PROGRESS @"mc_noti_onlinemanager_packageprogress"

#define kMC_USERINFO_ONLINEMANAGER_PACKAGE_MATERIALID @"materialID"
#define kMC_USERINFO_ONLINEMANAGER_PACKAGE_PROGRESS @"Progress"

@interface MaterialManager : NSObject

@property (nonatomic, strong) NSMutableDictionary *packageDownloadTasks;

+ (NSArray *)motionArray;
+ (NSString *)getMotionName:(NSString *)motion;
+ (NSArray *)materialIDs;
+ (NSString *)thumbUrl:(NSString *)materialID;
+ (NSString *)packageUrl:(NSString *)materialID;
+ (NSString *)packageDownloadDir;
+ (NSString *)packageDownloadDir:(NSString *)materialID;
+ (BOOL)packageDownloaded:(NSString *)materialID;
+ (BOOL)isOnlinePackage:(NSString *)materialID;

+ (MaterialManager *)shareInstance;

- (BOOL)downloadPackage:(NSString *)materialID;

@end


@protocol MCPkgDownloadTaskProtocol <NSObject>

@required
- (id)initWithPackageID:(NSString *)packageID
             packageURL:(NSURL *)packageURL
               unzipDir:(NSString *)unzipDir
                success:(void (^)(id<MCPkgDownloadTaskProtocol> task, NSString *packageID, long long totalBytes))successBlock
                failure:(void (^)(id<MCPkgDownloadTaskProtocol> task, NSString *packageID, NSError *error))failureBlock
               progress:(void (^)(id<MCPkgDownloadTaskProtocol> task, NSString *packageID, float progress))progressBlock;

- (void)start;
- (void)cancel;

@end
