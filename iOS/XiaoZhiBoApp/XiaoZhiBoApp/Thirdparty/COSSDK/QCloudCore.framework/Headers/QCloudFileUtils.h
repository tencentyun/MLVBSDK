//
//  QCloudFileUtils.h
//  Pods
//
//  Created by stonedong on 16/3/6.
//
//

#import <Foundation/Foundation.h>
#import "QCloudSHAPart.h"
#ifndef __QCloudFileUtils
#define __QCloudFileUtils
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"

#define NSShareFileManager [NSFileManager defaultManager]
FOUNDATION_EXTERN void QCloudEnsurePathExist(NSString* path);
FOUNDATION_EXTERN NSString* QCloudDocumentsPath();
FOUNDATION_EXTERN NSString* QCloudDocumentsSubPath(NSString* name);
FOUNDATION_EXTERN NSString* QCloudSettingsFilePath();
FOUNDATION_EXTERN NSString* QCloudAppendPath();
FOUNDATION_EXTERN NSString* QCloudMKTempDirectory();
FOUNDATION_EXTERN NSString* QCloudPathJoin(NSString* a, NSString* b);
FOUNDATION_EXTERN NSString* QCloudTempDir();
FOUNDATION_EXTERN NSString* QCloudTempFilePathWithExtension(NSString* extension);
FOUNDATION_EXTERN void QCloudRemoveFileByPath(NSString* path);
FOUNDATION_EXTERN NSString* QCloudFileInSubPath(NSString* subPath, NSString* fileName);
FOUNDATION_EXTERN BOOL QCloudFileExist(NSString* path);
FOUNDATION_EXTERN BOOL QCloudMoveFile(NSString* originPath, NSString* aimPath, NSError* __autoreleasing* error) ;
FOUNDATION_EXTERN int64_t QCloudDirectorySize(NSString * path, NSFileManager * fileManager);
FOUNDATION_EXTERN   NSString* QCloudDocumentsTempFilePathWithExcentsion(NSString* extension);
FOUNDATION_EXTERN  NSString * QCloudApplicationDocumentsPath();
FOUNDATION_EXTERN  NSString * QCloudApplicationLibaryPath();
FOUNDATION_EXTERN  NSString * QCloudApplicationTempPath();
FOUNDATION_EXTERN  NSString * QCloudApplicationDirectory();
FOUNDATION_EXTERN  NSString * QCloudFilteLocalPath(NSString * originPath);
FOUNDATION_EXTERN  NSString * QCloudGenerateLocalPath(NSString * pathCompents);
FOUNDATION_EXTERN  NSURL * QCloudMediaURL(NSString * path);
FOUNDATION_EXTERN  NSString* QCloudDocumentsTempPath();
FOUNDATION_EXTERN  NSString* QCloudDocumentsTempFile(NSString* fileName, NSString* extension);

FOUNDATION_EXTERN  uint64_t QCloudFileSize(NSString* path);
FOUNDATION_EXTERN NSArray<QCloudSHAPart*>*  QCloudIncreaseFileSHAData(NSString *path, uint64_t sliceSize);


#pragma clang diagnostic pop
#endif


