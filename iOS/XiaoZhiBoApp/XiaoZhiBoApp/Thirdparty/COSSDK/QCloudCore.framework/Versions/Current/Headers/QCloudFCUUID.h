//
//  QCloudFCUUID.h
//
//  Created by Fabio Caccamo on 26/06/14.
//  Copyright © 2016 Fabio Caccamo. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString *const QCloudFCUUIDsOfUserDevicesDidChangeNotification;

@interface QCloudFCUUID : NSObject
{
    NSMutableDictionary *_uuidForKey;
    NSString *_uuidForSession;
    NSString *_uuidForInstallation;
    NSString *_uuidForVendor;
    NSString *_uuidForDevice;
    NSString *_uuidsOfUserDevices;
    BOOL _uuidsOfUserDevices_iCloudAvailable;
}
/**
 每次运行应用都会变
 */
+(NSString *)uuid;
/**
 changes each time (no persistent), but allows to keep in memory more temporary uuids
 */
+(NSString *)uuidForKey:(id<NSCopying>)key;
/**
 每次运行应用都会变
 */
+(NSString *)uuidForSession;
/**
 重新安装的时候会变
 */
+(NSString *)uuidForInstallation;
/**
 卸载后重装会变
 */
+(NSString *)uuidForVendor;
/**
 抹掉iPhone的时候才会变，适合做唯一标识
 */
+(NSString *)uuidForDevice;
+(NSString *)uuidForDeviceMigratingValue:(NSString *)value commitMigration:(BOOL)commitMigration;
+(NSString *)uuidForDeviceMigratingValueForKey:(NSString *)key commitMigration:(BOOL)commitMigration;
+(NSString *)uuidForDeviceMigratingValueForKey:(NSString *)key service:(NSString *)service commitMigration:(BOOL)commitMigration;
+(NSString *)uuidForDeviceMigratingValueForKey:(NSString *)key service:(NSString *)service accessGroup:(NSString *)accessGroup commitMigration:(BOOL)commitMigration;
+(NSArray *)uuidsOfUserDevices;
+(NSArray *)uuidsOfUserDevicesExcludingCurrentDevice;

+(BOOL)uuidValueIsValid:(NSString *)uuidValue;

@end
