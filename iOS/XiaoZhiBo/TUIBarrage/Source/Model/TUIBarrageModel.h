//
//  TUIBarrageModel.h
//  TUIBarrageService
//
//  Created by WesleyLei on 2021/9/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIBarrageModel : NSObject
@property(nonatomic, strong)NSString *message;
@property(nonatomic, strong)NSDictionary *extInfo;

/**
* 默认创建
*
*/
+ (instancetype)defaultCreate;
@end

NS_ASSUME_NONNULL_END
