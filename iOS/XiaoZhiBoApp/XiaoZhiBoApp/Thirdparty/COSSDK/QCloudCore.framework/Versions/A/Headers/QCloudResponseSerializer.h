//
//  QCloudResponseSerializer.h
//  QCloudNetworking
//
//  Created by tencent on 15/9/25.
//  Copyright © 2015年 QCloudTernimalLab. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef id (^QCloudResponseSerializerBlock)(NSHTTPURLResponse* response,  id inputData, NSError* __autoreleasing* error);




@interface QCloudResponseSerializer : NSObject
@property (nonatomic, assign) BOOL waitForBodyData;
@property (nonatomic, strong) NSArray<QCloudResponseSerializerBlock>* serializerBlocks;
- (id) decodeWithWithResponse:(NSHTTPURLResponse*)response data:(NSData*)data error:(NSError*__autoreleasing*)error;
@end


FOUNDATION_EXTERN QCloudResponseSerializerBlock QCloudAcceptRespnseCodeBlock(NSSet* acceptCode , Class errorModel);
FOUNDATION_EXTERN QCloudResponseSerializerBlock QCloudResponseXMLSerializerBlock;
FOUNDATION_EXTERN QCloudResponseSerializerBlock QCloudResponseJSONSerilizerBlock;
FOUNDATION_EXTERN QCloudResponseSerializerBlock QCloudResponseAppendHeadersSerializerBlock;
