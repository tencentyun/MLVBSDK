//
//  QCloudCredentailFenceQueue.h
//  Pods
//
//  Created by Dong Zhao on 2017/8/31.
//
//

#import <Foundation/Foundation.h>


@class QCloudAuthentationCreator;
@class QCloudCredentailFenceQueue;

typedef void(^QCloudCredentailFenceQueueContinue)(QCloudAuthentationCreator* creator, NSError* error);

@protocol QCloudCredentailFenceQueueDelegate <NSObject>

/**
 获取一个有效的密钥，该密钥可以为临时密钥（推荐），也可以是永久密钥（十分不推荐！！在终端存储是非常不安全的。）。并将获取结果传给调用方。

 @param queue 获取密钥的调用方
 @param continueBlock 用来通知获取结果的block
 */
- (void) fenceQueue:(QCloudCredentailFenceQueue*)queue requestCreatorWithContinue:(QCloudCredentailFenceQueueContinue)continueBlock;

@end


/**
 使用类似栅栏的机制，更新秘钥。可以是临时密钥，也可以是永久密钥。在没有合法密钥的时候，所有的请求会阻塞在队列里面。直到获取到一个合法密钥，或者获取出错。
 */
@interface QCloudCredentailFenceQueue : NSObject

/**
 执行委托
 */
@property (nonatomic, weak) id<QCloudCredentailFenceQueueDelegate> delegate;

/**
 获取新的密钥的超时时间。如果您在超时时间内没有返回任何结果数据，则将会将认为获取任务失败。失败后，将会通知所有需要签名的调用方：失败。
 @default  120s
 */
@property (nonatomic, assign) NSTimeInterval timeout;

/**
 当前获得的密钥
 */
@property (nonatomic, strong, readonly) QCloudAuthentationCreator* authentationCreator;


/**
 执行一个需要密钥的方法，如果密钥存在则直接传给Block。如果不存在，则会触发栅栏机制。该请求被缓存在队列中，同时触发请求密钥（如果可以）。直到请求到密钥或者请求密钥失败。

 @param action 一个需要密钥的方法
 */
- (void) performAction:(void(^)(QCloudAuthentationCreator* creator, NSError* error))action;
@end
