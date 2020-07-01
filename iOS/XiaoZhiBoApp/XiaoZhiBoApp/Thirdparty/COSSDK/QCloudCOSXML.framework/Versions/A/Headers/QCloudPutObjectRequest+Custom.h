//
//  QCloudPutObjectRequest+Custom.h
//  Pods-QCloudCOSXMLDemo
//
//  Created by karisli(李雪) on 2018/8/14.
//

#import <Foundation/Foundation.h>
#import "QCloudPutObjectRequest.h"
@interface QCloudPutObjectRequest (Custom)
/**
 该选项设置为YES后，在上传完成后会比对COS上储存的文件MD5和本地文件的MD5，如果MD5有差异的话会返回-340013错误码。
 目前默认关闭。
 */
@property (nonatomic ,assign) BOOL enableMD5Verification;
-(void)setCOSServerSideEncyptionWithKMSCustomKey:(NSString *)customerKey jsonStr:(NSString *)jsonStr;
@end
