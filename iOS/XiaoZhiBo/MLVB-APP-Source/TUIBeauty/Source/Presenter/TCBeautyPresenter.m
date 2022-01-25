//
//  TCBeautyPresenter.m
//  TUIBeauty
//
//  Created by gg on 2021/9/23.
//

#import "TCBeautyPresenter.h"
#import "TCBeautyPanelActionProxy.h"
#import "TCBeautyModel.h"
#import "BeautyLocalized.h"
#import "TCFilter.h"
#import "TUIBeautyHeader.h"

@interface TCBeautyPresenter ()

@property (nonatomic, strong) TCBeautyPanelActionProxy *actionPerformer;

@end

@implementation TCBeautyPresenter

- (instancetype)initWithBeautyManager:(id)beautyManager {
    if (self = [super init]) {
        self.actionPerformer = [TCBeautyPanelActionProxy proxyWithBeautyManager:beautyManager];
        self.beautyStyle = 2;
        self.beautyLevel = 6;
        self.whiteLevel = 0;
        self.ruddyLevel = 0;
        self.currentShowIndexPath = [NSIndexPath indexPathForItem:-1 inSection:0];
    }
    return self;
}

- (void)dealloc {
    [self reset];
}

- (void)applyDefaultSetting {
    [self reset];
}

- (void)reset {
    LOGD("【Beauty】reset to default");
    for (TCBeautyBasePackage *pkg in self.dataSource) {
        for (TCBeautyBaseItem *item in pkg.items) {
            item.currentValue = item.defaultValue;
            switch (item.type) {
                case TCBeautyTypeBeauty: {
                    if (item.index <= 4) {
                        self.beautyStyle = item.index < 3 ? item.index : 2;
                        [item sendAction:@[@(item.currentValue), @(self.beautyStyle), @(self.beautyLevel), @(self.whiteLevel), @(self.ruddyLevel)]];
                    }
                    else {
                        [item sendAction:@[@(0)]];
                    }
                } break;
                case TCBeautyTypeFilter: {
                    if (!item.isClear) {
                        TCBeautyFilterItem *filterItem = (TCBeautyFilterItem *)item;
                        if ([filterItem.identifier isEqualToString:@"baixi"]) {
                            [filterItem setFilter];
                            [filterItem setSlider:item.currentValue];
                        }
                    }
                } break;
                case TCBeautyTypeMotion:
                case TCBeautyTypeKoubei:
                case TCBeautyTypeCosmetic:
                case TCBeautyTypeGesture: {
                    if (item.isClear) {
                        [item sendAction:@[]];
                    }
                    else {
                        TCBeautyMotionItem *motionItem = (TCBeautyMotionItem *)item;
                        [motionItem stopTask];
                    }
                } break;
                case TCBeautyTypeGreen: {
                    if (item.isClear) {
                        [item sendAction:@[]];
                    }
                } break;
                default:
                    break;
            }
        }
    }
}

- (NSMutableArray<TCBeautyBasePackage *> *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
        
        TCBeautyBasePackage *beautyPkg = [self getBeautyPackage];
        [_dataSource addObject:beautyPkg];
        
        TCBeautyBasePackage *filterPkg = [self getFilterPackage];
        [_dataSource addObject:filterPkg];
        
        NSArray <TCBeautyBasePackage *>*motionPkgs = [self getMotionPackages];
        [_dataSource addObjectsFromArray:motionPkgs];
        
        TCBeautyBasePackage *greenPkg = [self getGreenPackage];
        [_dataSource addObject:greenPkg];
        
        self.currentShowIndexPath = [NSIndexPath indexPathForItem:2 inSection:0];
        
        if (_dataSource.count > 0) {
            TCBeautyBasePackage *first = _dataSource.firstObject;
            self.currentSelectItem = first.items.count > 3 ? first.items[2] : first.items.firstObject;
        }
    }
    return _dataSource;
}

#pragma mark - Green
- (TCBeautyBasePackage *)getGreenPackage {
    TCBeautyGreenPackage *pkg = [[TCBeautyGreenPackage alloc] initWithType:TCBeautyTypeGreen title:BeautyLocalize(@"TC.BeautyPanel.Menu.GreenScreen") enableClearBtn:YES enableSlider:NO];
    
    NSString *path = [BeautyBundle() pathForResource:@"goodluck" ofType:@"mp4"];
    if (path) {
        TCBeautyGreenItem *item = [[TCBeautyGreenItem alloc] initWithUrl:path title:BeautyLocalize(@"TC.BeautySettingPanel.GoodLuck") normalIcon:@"beautyPanelGoodLuckIcon" package:pkg target:self.actionPerformer];
        [pkg.items addObject:item];
    }
    
    TCBeautyBaseItem *clearItem = pkg.clearItem;
    if (clearItem != nil) {
        [clearItem addTarget:self.actionPerformer action:@selector(setGreenScreenFile:)];
        [pkg.items insertObject:clearItem atIndex:0];
    }
    
    return pkg;
}

#pragma mark - Motion
- (NSArray <TCBeautyBasePackage *>*)getMotionPackages {
    NSMutableArray <TCBeautyBasePackage *>*pkgs = [NSMutableArray array];
    
    NSDictionary *root = [self readMotionJson];
    
    if ([root.allKeys containsObject:@"motion"]) {
        NSArray *arr = root[@"motion"];
        if ([arr isKindOfClass:[NSArray class]]) {
            TCBeautyMotionPackage *pkg = [[TCBeautyMotionPackage alloc] initWithType:TCBeautyTypeMotion title:BeautyLocalize(@"TC.BeautyPanel.Menu.VideoEffect") enableClearBtn:YES enableSlider:NO];
            [pkg decodeItems:arr target:self.actionPerformer];
            
            TCBeautyBaseItem *clearItem = pkg.clearItem;
            if (clearItem) {
                [clearItem addTarget:self.actionPerformer action:@selector(setMotionTmpl:inDir:)];
                [pkg.items insertObject:clearItem atIndex:0];
            }
            
            [pkgs addObject:pkg];
        }
    }
    
    if ([root.allKeys containsObject:@"cosmetic"]) {
        NSArray *arr = root[@"cosmetic"];
        if ([arr isKindOfClass:[NSArray class]]) {
            TCBeautyMotionPackage *pkg = [[TCBeautyMotionPackage alloc] initWithType:TCBeautyTypeKoubei title:BeautyLocalize(@"TC.BeautyPanel.Menu.Cosmetic") enableClearBtn:YES enableSlider:NO];
            [pkg decodeItems:arr target:self.actionPerformer];
            
            TCBeautyBaseItem *clearItem = pkg.clearItem;
            if (clearItem) {
                [clearItem addTarget:self.actionPerformer action:@selector(setMotionTmpl:inDir:)];
                [pkg.items insertObject:clearItem atIndex:0];
            }
            
            [pkgs addObject:pkg];
        }
    }
    
    if ([root.allKeys containsObject:@"gesture"]) {
        NSArray *arr = root[@"gesture"];
        if ([arr isKindOfClass:[NSArray class]]) {
            TCBeautyMotionPackage *pkg = [[TCBeautyMotionPackage alloc] initWithType:TCBeautyTypeKoubei title:BeautyLocalize(@"TC.BeautyPanel.Menu.Gesture") enableClearBtn:YES enableSlider:NO];
            [pkg decodeItems:arr target:self.actionPerformer];
            
            TCBeautyBaseItem *clearItem = pkg.clearItem;
            if (clearItem) {
                [clearItem addTarget:self.actionPerformer action:@selector(setMotionTmpl:inDir:)];
                [pkg.items insertObject:clearItem atIndex:0];
            }
            
            [pkgs addObject:pkg];
        }
    }
    
    if ([root.allKeys containsObject:@"bgremove"]) {
        NSArray *arr = root[@"bgremove"];
        if ([arr isKindOfClass:[NSArray class]]) {
            TCBeautyMotionPackage *pkg = [[TCBeautyMotionPackage alloc] initWithType:TCBeautyTypeGesture title:BeautyLocalize(@"TC.BeautyPanel.Menu.BlendPic") enableClearBtn:YES enableSlider:NO];
            [pkg decodeItems:arr target:self.actionPerformer];
            
            TCBeautyBaseItem *clearItem = pkg.clearItem;
            if (clearItem) {
                [clearItem addTarget:self.actionPerformer action:@selector(setMotionTmpl:inDir:)];
                [pkg.items insertObject:clearItem atIndex:0];
            }
            
            [pkgs addObject:pkg];
        }
    }
    
    return pkgs;
}

- (NSDictionary *)readMotionJson {
    NSString *path = [BeautyBundle() pathForResource:@"TCPituMotion" ofType:@"json"];
    if (path == nil) {
        return @{};
    }
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) {
        return @{};
    }
    
    NSError *error;
    NSDictionary *root = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        return @{};
    }
    if (![root isKindOfClass:[NSDictionary class]]) {
        return @{};
    }
    if (![root.allKeys containsObject:@"bundle"] || ![root.allKeys containsObject:@"package"]) {
        return @{};
    }
    
    NSString *bundle = root[@"bundle"];
    if (![bundle isKindOfClass:[NSString class]]) {
        return @{};
    }
    if (![bundle isEqualToString:@"pitu"]) {
        return @{};
    }
    
    NSDictionary *packages = root[@"package"];
    if (![packages isKindOfClass:[NSDictionary class]]) {
        return @{};
    }
    
    return packages;
}

#pragma mark - Filter
- (TCBeautyBasePackage *)getFilterPackage {
    TCBeautyFilterPackage *pkg = [[TCBeautyFilterPackage alloc] initWithType:TCBeautyTypeFilter title:BeautyLocalize(@"TC.BeautyPanel.Menu.Filter") enableClearBtn:YES enableSlider:YES];
    
    NSArray *defaultValue = TCBeautyFilterPackage.defaultFilterValue;
    
    NSArray *allFilters = [TCFilterManager defaultManager].allFilters;
    
    for (int i = 0; i < allFilters.count; i++) {
        TCFilter *filter = allFilters[i];
        NSString *identifier = [NSString stringWithFormat:@"TC.Common.Filter_%@", filter.identifier];
        NSString *imgName = filter.identifier;
        if ([imgName isEqualToString:@"white"]) {
            imgName = @"fwhite";
        }
        
        TCBeautyFilterItem *item = [[TCBeautyFilterItem alloc] initWithTitle:BeautyLocalize(identifier) normalIcon:[UIImage imageNamed:imgName inBundle:BeautyBundle() compatibleWithTraitCollection:nil] package:pkg lookupImagePath:filter.lookupImagePath target:self.actionPerformer currentValue:[defaultValue[i] floatValue] minValue:0 maxValue:9 identifier:filter.identifier];
        item.index = i;
        [pkg.items addObject:item];
    }
    
    TCBeautyBaseItem *clearItem = pkg.clearItem;
    if (clearItem != nil) {
        [clearItem addTarget:self action:@selector(setFilter:)];
        [pkg.items insertObject:clearItem atIndex:0];
    }
    
    return pkg;
}

#pragma mark - Beauty
- (TCBeautyBasePackage *)getBeautyPackage {
    TCBeautyBeautyPackage *pkg = [[TCBeautyBeautyPackage alloc] initWithType:TCBeautyTypeBeauty title:BeautyLocalize(@"TC.BeautyPanel.Menu.Beauty") enableClearBtn:NO enableSlider:YES];
    
    NSString *path = [BeautyBundle() pathForResource:@"TCBeauty" ofType:@"json"];
    if (!path) {
        return pkg;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) {
        return pkg;
    }
    
    NSError *error;
    NSDictionary *root = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (error || ![root isKindOfClass:[NSDictionary class]]) {
        return pkg;
    }
    
    if (![root.allKeys containsObject:@"package"]) {
        return pkg;
    }
    
    NSArray *arr = root[@"item"];
    if (![arr isKindOfClass:[NSArray class]]) {
        return pkg;
    }
    
    [pkg decodeItems:arr target:self.actionPerformer];
    
    if (pkg.items.count > 3) {
        pkg.items[2].isSelected = YES;
    }
    
    TCBeautyBaseItem *clearItem = pkg.clearItem;
    if (clearItem != nil) {
        [pkg.items insertObject:clearItem atIndex:0];
    }
    
    return pkg;
}
@end
