//
//  TUIPusherStreamServiceDelegate.h
//  TXLiteAVDemo
//
//  Created by gg on 2020/9/7.
//

#ifndef TUIPusherStreamServiceDelegate_h
#define TUIPusherStreamServiceDelegate_h

#import "TUIPusherKit.h"

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TUIPusherStreamServiceDelegate <NSObject>

@optional
/// sdk内部发生了错误 | sdk error
/// - Parameters:
///   - code: 错误码
///   - msg: 错误消息
-(void)onStreamServiceError:(V2TXLiveCode)code msg:(NSString * _Nullable)msg
NS_SWIFT_NAME(onStreamServiceError(code:msg:));

@end

NS_ASSUME_NONNULL_END

#endif /* TRTCPusherDelegate_h */
