//
//  TCBeautyPresenter.h
//  TUIBeauty
//
//  Created by gg on 2021/9/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TCBeautyBaseItem, TCBeautyBasePackage;

@interface TCBeautyPresenter : NSObject

@property (nonatomic,  weak ) TCBeautyBaseItem *currentSelectItem;

@property (nonatomic, strong) NSIndexPath *currentShowIndexPath;

@property (nonatomic, strong) NSMutableArray <TCBeautyBasePackage *>*dataSource;

@property (nonatomic, assign) int beautyStyle;
@property (nonatomic, assign) float beautyLevel;
@property (nonatomic, assign) float whiteLevel;
@property (nonatomic, assign) float ruddyLevel;

- (instancetype)initWithBeautyManager:(id)beautyManager;

- (void)applyDefaultSetting;
@end

NS_ASSUME_NONNULL_END
