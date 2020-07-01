//
//  NSObject+HTTPHeadersContainer.h
//  QCloudCore
//
//  Created by Dong Zhao on 2017/11/28.
//

#import <Foundation/Foundation.h>

@interface NSObject (HTTPHeadersContainer)
@property (nonatomic, strong) NSHTTPURLResponse * __originHTTPURLResponse__;

@property (nonatomic, strong) NSData*             __originHTTPResponseData__;
@end
