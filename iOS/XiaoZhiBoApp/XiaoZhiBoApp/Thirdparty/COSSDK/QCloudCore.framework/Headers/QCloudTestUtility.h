//
//  QCloudTestUtility.h
//  Pods-QCloudNewCOSV4Demo
//
//  Created by erichmzhang(张恒铭) on 02/11/2017.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger,QCloudTestFileUnit) {
    QCLOUD_TEST_FILE_UNIT_BYTES = 1,
    QCLOUD_TEST_FILE_UNIT_KB = 1024,
    QCLOUD_TEST_FILE_UNIT_MB = 1024*1024,
    QCLOUD_TEST_FILE_UNIT_GB = 1024*1024*1024
};


@interface QCloudTestUtility : NSObject

/**
 从硬盘中截取一段生成临时文件

 @param size 文件大小
 @param unit 文件单位，bytes, kb, 等
 @return 文件地址
 */
+ (NSString* )tempFileWithSize:(NSInteger)size unit:(QCloudTestFileUnit)unit;


+ (void)removeFileAtPath:(NSString*)path;


@end

