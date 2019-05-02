//
//  QCloudHTTPMultiDataStream.h
//  QCloudNetworking
//
//  Created by tencent on 16/2/18.
//  Copyright © 2016年 QCloudTernimalLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@class QCloudHTTPBodyPart;
@interface QCloudHTTPMultiDataStream : NSInputStream
@property (nonatomic, assign) NSStringEncoding stringEncoding;
@property (nonatomic, assign, readonly) BOOL hasData;
@property (nonatomic, assign, readonly) unsigned long long contentLength;
@property (nonatomic, strong) NSString* boundary;
- (instancetype) initWithStringEncoding:(NSStringEncoding)encoding;
- (void)setInitialAndFinalBoundaries;
- (void) appendBodyPart:(QCloudHTTPBodyPart*)bodyPart;
- (void) insertBodyPart:(QCloudHTTPBodyPart*)bodyPart;
@end
  
