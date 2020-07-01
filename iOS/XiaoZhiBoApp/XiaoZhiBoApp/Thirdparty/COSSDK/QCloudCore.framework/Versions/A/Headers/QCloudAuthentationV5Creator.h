//
//  QCloudAuthentationV5Creator.h
//  Pods
//
//  Created by Dong Zhao on 2017/8/31.
//
//

#import "QCloudAuthentationCreator.h"

/**
 COS V5 （XML）版本签名创建器。强烈不推荐在线上版本中使用。请使用服务器获取签名的模式来使用签名。如果您使用改类，请配合临时密钥CAM服务使用。
 
 @note 强烈不推荐在线上版本中使用。请使用服务器获取签名的模式来使用签名。如果您使用改类，请配合临时密钥CAM服务使用。
 */
@class QCloudHTTPRequest;
@interface QCloudAuthentationV5Creator : QCloudAuthentationCreator
- (QCloudSignature*) signatureForData:(NSMutableURLRequest*)signData;
@end
