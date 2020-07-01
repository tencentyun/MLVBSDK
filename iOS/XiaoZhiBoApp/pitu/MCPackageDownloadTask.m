//
//  MCPackageDownloadTask.m
//  PituCameraSDK
//
//  Created by billwang on 16/7/13.
//  Copyright © 2016年 Pitu. All rights reserved.
//

#import "MCPackageDownloadTask.h"
#import "AFNetworking.h"
#import "ZipArchive.h"

@interface MCPackageDownloadTask()
@property NSURLSessionDownloadTask *operation;
@end

@implementation MCPackageDownloadTask

- (id)initWithPackageID:(NSString *)packageID
             packageURL:(NSURL *)packageURL
               unzipDir:(NSString *)unzipDir
                success:(void (^)(id<MCPkgDownloadTaskProtocol>, NSString *, long long))successBlock
                failure:(void (^)(id<MCPkgDownloadTaskProtocol>, NSString *, NSError *))failureBlock
               progress:(void (^)(id<MCPkgDownloadTaskProtocol>, NSString *, float))progressBlock {
    self = [super init];
    if (self) {
        self.packageID = packageID;
        self.packageURL = packageURL;
        self.unzipDir = unzipDir;
        self.successBlock = successBlock;
        self.failureBlock = failureBlock;
        self.progressBlock = progressBlock;
    }
    return self;
}

- (void)start {
    if (self.operation) {
        if (self.operation.state != NSURLSessionTaskStateRunning) {
            [self.operation resume];
        }
    }
    
    NSString *targetPath = [NSString stringWithFormat:@"%@/%@.zip", self.unzipDir, self.packageID];
    if ([[NSFileManager defaultManager] fileExistsAtPath:targetPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:targetPath error:nil];
    }
    
    __weak MCPackageDownloadTask *weakSelf = self;
    NSURLRequest *downloadReq = [NSURLRequest requestWithURL:self.packageURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30.f];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    self.operation = [manager downloadTaskWithRequest:downloadReq progress:^(NSProgress * _Nonnull downloadProgress) {
        if (weakSelf.progressBlock) {
            CGFloat progress = (float)downloadProgress.completedUnitCount / (float)downloadProgress.totalUnitCount;
            weakSelf.progressBlock(weakSelf, weakSelf.packageID, progress);
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath_, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:targetPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            if (weakSelf.failureBlock) {
                weakSelf.failureBlock(weakSelf, weakSelf.packageID, error);
            }
            return;
        }
        // 解压
        BOOL unzipSuccess = NO;
        ZipArchive *zipArchive = [[ZipArchive alloc] init];
        if ([zipArchive UnzipOpenFile:targetPath]) {
            unzipSuccess = [zipArchive UnzipFileTo:weakSelf.unzipDir overWrite:YES];
            [zipArchive UnzipCloseFile];
            
            // 删除zip文件
            [[NSFileManager defaultManager] removeItemAtPath:targetPath error:&error];
        }
        if (unzipSuccess) {
            if (weakSelf.successBlock) {
                long long totalBytes = weakSelf.operation.countOfBytesReceived;
                weakSelf.successBlock(weakSelf, weakSelf.packageID, totalBytes);
            }
        } else {
            if (weakSelf.failureBlock) {
                weakSelf.failureBlock(weakSelf, weakSelf.packageID, error);
            }
        }
    }];
    [self.operation resume];
#if 0
    self.operation = [[AFDownloadRequestOperation alloc] initWithRequest:downloadReq targetPath:targetPath shouldResume:YES];
    [self.operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // 解压
        BOOL unzipSuccess = NO;
        NSError *error = nil;
        ZipArchive *zipArchive = [[ZipArchive alloc] init];
        if ([zipArchive UnzipOpenFile:targetPath]) {
            unzipSuccess = [zipArchive UnzipFileTo:weakSelf.unzipDir overWrite:YES];
            [zipArchive UnzipCloseFile];
            
            // 删除zip文件
            [[NSFileManager defaultManager] removeItemAtPath:targetPath error:&error];
        }
        if (unzipSuccess) {
            if (weakSelf.successBlock) {
                long long totalBytes = 0;
                if ([operation isKindOfClass:[AFDownloadRequestOperation class]]) {
                    AFDownloadRequestOperation *downloadOp = (AFDownloadRequestOperation *)operation;
                    totalBytes = downloadOp.totalContentLength;
                }
                weakSelf.successBlock(weakSelf, weakSelf.packageID, totalBytes);
            }
        } else {
            if (weakSelf.failureBlock) {
                weakSelf.failureBlock(weakSelf, weakSelf.packageID, error);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (weakSelf.failureBlock) {
            weakSelf.failureBlock(weakSelf, weakSelf.packageID, error);
        }
    }];
    [self.operation setProgressiveDownloadProgressBlock:^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
        if (weakSelf.progressBlock) {
            CGFloat progress = (float)totalBytesReadForFile / (float)totalBytesExpectedToReadForFile;
            weakSelf.progressBlock(weakSelf, weakSelf.packageID, progress);
        }
    }];
#endif
//    [[MCPackageDownloadMgr shareInstance].packageDownloadQueue addOperation:self.operation];
}
- (void)cancel {
    [self.operation cancel];
}

@end



static MCPackageDownloadMgr *_instance = nil;

@implementation MCPackageDownloadMgr

+ (MCPackageDownloadMgr *)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[MCPackageDownloadMgr alloc] init];
    });
    
    return _instance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.packageDownloadQueue = [[NSOperationQueue alloc] init];
        self.packageDownloadQueue.maxConcurrentOperationCount = 4;
    }
    return self;
}

@end
