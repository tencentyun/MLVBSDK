//
//  TUIGiftModel.h
//  Pods
//
//  Created by WesleyLei on 2021/9/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIGiftModel : NSObject

@property (nonatomic, strong) NSString *giftId;
@property (nonatomic, strong) NSString *normalImageUrl;
@property (nonatomic, strong) NSString *selectedImageUrl;
@property (nonatomic, strong) NSString *animationURL;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *giveDesc;
@property (nonatomic, strong) NSDictionary *extInfo;

/**
* 默认创建
*
*/
+ (instancetype)defaultCreate;

@end

NS_ASSUME_NONNULL_END
