//
//  MCPackageDownloadTask.h
//  PituCameraSDK
//
//  Created by billwang on 16/7/13.
//  Copyright © 2016年 Pitu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MaterialManager.h"

@interface MCPackageDownloadTask : NSObject <MCPkgDownloadTaskProtocol>

@property (nonatomic, copy) NSString *packageID;
@property (nonatomic, strong) NSURL *packageURL;
@property (nonatomic, copy) NSString *unzipDir;
@property (nonatomic, strong) void (^successBlock)(id<MCPkgDownloadTaskProtocol>, NSString *, long long);
@property (nonatomic, strong) void (^failureBlock)(id<MCPkgDownloadTaskProtocol>, NSString *, NSError *);
@property (nonatomic, strong) void (^progressBlock)(id<MCPkgDownloadTaskProtocol>, NSString *, float);

@end



@interface MCPackageDownloadMgr : NSObject

@property (nonatomic, strong) NSOperationQueue *packageDownloadQueue;

+ (MCPackageDownloadMgr *)shareInstance;

@end
