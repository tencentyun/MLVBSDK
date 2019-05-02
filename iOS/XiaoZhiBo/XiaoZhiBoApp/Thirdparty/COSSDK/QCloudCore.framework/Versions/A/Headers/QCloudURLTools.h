//
//  QCloudURLTools.h
//  QCloudCore
//
//  Created by Dong Zhao on 2017/11/28.
//

#import <Foundation/Foundation.h>


FOUNDATION_EXTERN NSString* const QCloudHTTPScheme;
FOUNDATION_EXTERN NSString* const QCloudHTTPSScheme;

FOUNDATION_EXTERN NSString* QCloudFormattHTTPURL(NSString* originURL, BOOL useHTTPS);
