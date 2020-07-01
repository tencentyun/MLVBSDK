//
//  QCloudLogger.h
//  Pods
//
//  Created by Dong Zhao on 2017/3/14.
//
//

#import <Foundation/Foundation.h>
#import "QCloudLogModel.h"
#import "QCloudLoggerOutput.h"

#define QCloudLog(level, frmt, ...) \
[[QCloudLogger sharedLogger] logMessageWithLevel:level  cmd:__PRETTY_FUNCTION__ line:__LINE__ file:__FILE__ format:(frmt), ##__VA_ARGS__]

#define QCloudLogError(frmt, ...) \
QCloudLog(QCloudLogLevelError, (frmt), ##__VA_ARGS__)

#define QCloudLogWarning(frmt, ...) \
QCloudLog(QCloudLogLevelWarning, (frmt), ##__VA_ARGS__)

#define QCloudLogInfo(frmt, ...) \
QCloudLog(QCloudLogLevelInfo, (frmt), ##__VA_ARGS__)

#define QCloudLogDebug( frmt, ...) \
QCloudLog(QCloudLogLevelDebug, (frmt), ##__VA_ARGS__)


#define QCloudLogVerbose(frmt, ...) \
QCloudLog(QCloudLogLevelInfo, (frmt), ##__VA_ARGS__)

#define QCloudLogException(exception) \
QCloudLogError( @"Caught \"%@\" with reason \"%@\"%@", \
exception.name, exception, \
[exception callStackSymbols] ? [NSString stringWithFormat:@":\n%@.", [exception callStackSymbols]] : @"")

#define QCloudLogTrance()\
QCloudLog(QCloudLogLevelDebug,@"%@",[NSThread callStackSymbols])


@interface QCloudLogger : NSObject

@property (nonatomic, assign) QCloudLogLevel logLevel;

@property (nonatomic, strong, readonly) NSString* logDirctoryPath;

@property (nonatomic, assign) uint64_t maxStoarageSize;

@property (nonatomic, assign) float keepDays;



///--------------------------------------
#pragma mark - Shared Logger
///--------------------------------------

/**
 A shared instance of `QCloudLogger` that should be used for all logging.
 
 @return An shared singleton instance of `QCloudLogger`.
 */
+ (instancetype)sharedLogger; 

///--------------------------------------
#pragma mark - Logging Messages
///--------------------------------------


- (void)logMessageWithLevel:(QCloudLogLevel)level
                        cmd:(const char*)commandInfo
                       line:(int)line
                       file:(const char*)file
                     format:(NSString *)format, ...;



/**
 增加一个输出源

 @param output 输出源
 */
- (void) addLogger:(QCloudLoggerOutput*)output;


/**
 删除一个输出源

 @param output 删除一个输出源
 */
- (void) removeLogger:(QCloudLoggerOutput*)output;
@end
