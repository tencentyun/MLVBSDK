//
//  TCBeautyModel.h
//  TUIBeauty
//
//  Created by gg on 2021/9/22.
//

#import <Foundation/Foundation.h>
#import "TCBeautyPanelActionPerformer.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TCBeautyType) {
    TCBeautyTypeNone,
    TCBeautyTypeBeauty,
    TCBeautyTypeFilter,
    TCBeautyTypeMotion,
    TCBeautyTypeKoubei,
    TCBeautyTypeCosmetic,
    TCBeautyTypeGesture,
    TCBeautyTypeGreen
};

#pragma mark - Base
@class TCBeautyBaseItem;

@interface TCBeautyBasePackage : NSObject

@property (nonatomic,  copy ) NSString *title;

@property (nonatomic, assign) BOOL enableClearBtn;
@property (nonatomic, assign) BOOL enableSlider;

@property (nonatomic, assign) TCBeautyType type;

@property (nonatomic, readonly) NSString *typeStr;

@property (nonatomic, strong) NSMutableArray <TCBeautyBaseItem *>*items;

@property (nonatomic, nullable, readonly) TCBeautyBaseItem *clearItem;

- (instancetype)initWithType:(TCBeautyType)type title:(NSString *)title enableClearBtn:(BOOL)enableClearBtn enableSlider:(BOOL)enableSlider;
@end

@interface TCBeautyBaseItem : NSObject

@property (nonatomic,  weak ) TCBeautyBasePackage *package;

@property (nonatomic, assign) BOOL isSelected;

@property (nonatomic, assign) BOOL isClear;

@property (nonatomic, assign, readonly) TCBeautyType type;

@property (nonatomic,  copy ) NSString *title;

@property (nonatomic, strong) UIImage *normalIcon;
@property (nonatomic, strong) UIImage *selectIcon;

@property (nonatomic, assign) float defaultValue;
@property (nonatomic, assign) float currentValue;
@property (nonatomic, assign) float minValue;
@property (nonatomic, assign) float maxValue;

@property (nonatomic, strong) id <TCBeautyPanelActionPerformer> target;
@property (nonatomic, assign) SEL action;

@property (nonatomic, assign) int index;

- (instancetype)initWithTitle:(NSString *)title normalIcon:(UIImage *)normalIcon selIcon:(UIImage * _Nullable)selIcon package:(TCBeautyBasePackage *)package isClear:(BOOL)isClear;

- (void)setValue:(float)current min:(float)min max:(float)max;

- (void)addTarget:(id)target action:(SEL _Nullable)action;

- (void)sendAction:(NSArray *)args;
@end

#pragma mark - Beauty
@interface TCBeautyBeautyItem : TCBeautyBaseItem

@property (nonatomic, assign) int beautyStyle;
@property (nonatomic, assign) float beautyLevel;
@property (nonatomic, assign) float whiteLevel;
@property (nonatomic, assign) float ruddyLevel;

- (instancetype)initWithTitle:(NSString *)title normalIcon:(UIImage *)normalIcon package:(TCBeautyBasePackage *)package target:(id)target action:(SEL)action currentValue:(float)currentValue minValue:(float)minValue maxValue:(float)maxValue;

- (void)applyBeautySettings;
@end

@interface TCBeautyBeautyPackage : TCBeautyBasePackage

- (void)decodeItems:(NSArray <NSDictionary *>*)array target:(id <TCBeautyPanelActionPerformer>)target;

@end

#pragma mark - Filter
@interface TCBeautyFilterItem : TCBeautyBaseItem

@property (nonatomic, copy) NSString *lookupImagePath;
@property (nonatomic, copy) NSString *identifier;

- (instancetype)initWithTitle:(NSString *)title normalIcon:(UIImage *)normalIcon package:(TCBeautyBasePackage *)package lookupImagePath:(NSString *)lookupImagePath target:(id <TCBeautyPanelActionPerformer>)target currentValue:(float)currentValue minValue:(float)minValue maxValue:(float)maxValue identifier:(NSString *)identifier;

- (void)setFilter;
- (void)setSlider:(float)value;
@end

@interface TCBeautyFilterPackage : TCBeautyBasePackage

@property (nonatomic, class, readonly) NSArray *defaultFilterValue;

@end

#pragma mark - Motion
@interface TCBeautyMotionItem : TCBeautyBaseItem

@property (nonatomic,   copy  ) NSString *identifier;
@property (nonatomic,   copy  ) NSString *url;
@property (nonatomic,  assign ) BOOL isDownloading;
@property (nonatomic, readonly) BOOL isDownloaded;

- (instancetype)initWithTitle:(NSString *)title identifier:(NSString *)identifier url:(NSString *)url package:(TCBeautyBasePackage *)package target:(id <TCBeautyPanelActionPerformer>)target;

- (void)stopTask;
- (void)apply;

- (void)download:(void (^) (float prog))progress complete:(void (^) (BOOL success, NSString *message))complete;
@end

@interface TCBeautyMotionPackage : TCBeautyBasePackage

- (void)decodeItems:(NSArray <NSDictionary *>*)array target:(id <TCBeautyPanelActionPerformer>)target;

@end

#pragma mark - Green
@interface TCBeautyGreenItem : TCBeautyBaseItem

@property (nonatomic, copy) NSString *url;

- (instancetype)initWithUrl:(NSString *)url title:(NSString *)title normalIcon:(NSString *)normalIcon package:(TCBeautyBasePackage *)package target:(id <TCBeautyPanelActionPerformer>)target;

@end

@interface TCBeautyGreenPackage : TCBeautyBasePackage

@end

NS_ASSUME_NONNULL_END
