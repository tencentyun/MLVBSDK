//
//  NSDate+QCloudComapre.h
//  Pods
//
//  Created by Dong Zhao on 2017/4/5.
//
//

#import <Foundation/Foundation.h>

@interface NSDate (QCloudComapre)
-(BOOL) qcloud_isEarlierThan:(NSDate *)date;
/**
 *  Returns a YES if receiver is later than provided comparison date, otherwise returns NO
 *
 *  @param date NSDate - Provided date for comparison
 *
 *  @return BOOL representing comparison result
 */
-(BOOL)qcloud_isLaterThan:(NSDate *)date;
/**
 *  Returns a YES if receiver is earlier than or equal to the provided comparison date, otherwise returns NO
 *
 *  @param date NSDate - Provided date for comparison
 *
 *  @return BOOL representing comparison result
 */
-(BOOL)qcloud_isEarlierThanOrEqualTo:(NSDate *)date;
@end
