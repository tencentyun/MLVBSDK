//
//  NSString+RegularExpressionCategory.h
//  QCloudCOSXML
//
//  Created by erichmzhang(张恒铭) on 29/06/2018.
//

#import <Foundation/Foundation.h>

@interface NSString (RegularExpressionCategory)
- (BOOL) matchesRegularExpression:(NSString *)regularExpression;
@end
