//
//  TCBeautyModel.m
//  TUIBeauty
//
//  Created by gg on 2021/9/22.
//

#import "TCBeautyModel.h"
#import "BeautyLocalized.h"
#import "TUIBeautyHeader.h"
#import "SSZipArchive.h"

#define SuppressPerformSelectorLeakWarning(Stuff) \
            _Pragma("clang diagnostic push") \
            _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
            Stuff; \
            _Pragma("clang diagnostic pop") \


@implementation TCBeautyBaseItem

- (instancetype)initWithTitle:(NSString *)title normalIcon:(UIImage *)normalIcon selIcon:(UIImage *)selIcon package:(TCBeautyBasePackage *)package isClear:(BOOL)isClear {
    if (self = [super init]) {
        self.title = title;
        self.normalIcon = normalIcon;
        self.selectIcon = selIcon;
        self.package = package;
        self.isClear = isClear;
    }
    return self;
}

- (void)setValue:(float)current min:(float)min max:(float)max {
    self.defaultValue = current;
    self.currentValue = current;
    self.minValue = min;
    self.maxValue = max;
}

- (void)addTarget:(id)target action:(SEL)action {
    self.target = target;
    self.action = action;
}

- (TCBeautyType)type {
    return self.package.type;
}

- (void)sendAction:(NSArray *)args {
    if (self.target == nil && self.action == nil) {
        return;
    }
    if (![self.target respondsToSelector:self.action]) {
        return;
    }
    
    if (args.count == 0) {
        SuppressPerformSelectorLeakWarning([self.target performSelector:self.action withObject:nil])
    }
    else if (args.count == 1) {
        SuppressPerformSelectorLeakWarning([self.target performSelector:self.action withObject:args.firstObject])
    }
    else if (args.count == 2) {
        SuppressPerformSelectorLeakWarning([self.target performSelector:self.action withObject:args.firstObject withObject:args[1]])
    }
    else {
        SuppressPerformSelectorLeakWarning([self.target performSelector:self.action withObject:args])
    }
}

@end

@implementation TCBeautyBasePackage

- (instancetype)initWithType:(TCBeautyType)type title:(NSString *)title enableClearBtn:(BOOL)enableClearBtn enableSlider:(BOOL)enableSlider {
    if (self = [super init]) {
        self.title = title;
        self.enableClearBtn = enableClearBtn;
        self.enableSlider = enableSlider;
        self.type = type;
    }
    return self;
}

- (NSMutableArray<TCBeautyBaseItem *> *)items {
    if (!_items) {
        _items = [NSMutableArray array];
    }
    return _items;
}

- (TCBeautyBaseItem *)clearItem {
    if (self.enableClearBtn) {
        TCBeautyBaseItem *clearItem = [[TCBeautyBaseItem alloc] initWithTitle:BeautyLocalize(@"TC.Common.Clear") normalIcon:[UIImage imageNamed:@"clear_nor" inBundle:BeautyBundle() compatibleWithTraitCollection:nil] selIcon:[UIImage imageNamed:@"clear_nor" inBundle:BeautyBundle() compatibleWithTraitCollection:nil] package:self isClear:YES];
        return clearItem;
    }
    return nil;
}

- (NSString *)typeStr {
    switch (self.type) {
        case TCBeautyTypeBeauty:
            return @"beauty";
        case TCBeautyTypeFilter:
            return @"filter";
        case TCBeautyTypeMotion:
            return @"motion";
        case TCBeautyTypeKoubei:
            return @"koubei";
        case TCBeautyTypeCosmetic:
            return @"cosmetic";
        case TCBeautyTypeGesture:
            return @"gesture";
        case TCBeautyTypeGreen:
            return @"green";
        default:
            return @"none";
    }
}

@end

@implementation TCBeautyBeautyItem

- (instancetype)initWithTitle:(NSString *)title normalIcon:(UIImage *)normalIcon package:(TCBeautyBasePackage *)package target:(id)target action:(SEL)action currentValue:(float)currentValue minValue:(float)minValue maxValue:(float)maxValue {
    if (self = [super initWithTitle:title normalIcon:normalIcon selIcon:nil package:package isClear:NO]) {
        [self addTarget:target action:action];
        [self setValue:currentValue min:minValue max:maxValue];
    }
    return self;
}

- (void)sendAction:(NSArray *)args {
    if (args.count > 0) {
        self.currentValue = [args.firstObject floatValue];
    }
    if (args.count == 5) {
        self.beautyStyle = [args[1] intValue];
        self.beautyLevel = [args[2] floatValue];
        self.whiteLevel  = [args[3] floatValue];
        self.ruddyLevel  = [args[4] floatValue];
    }
    if (self.index <= 4) {
        [self applyBeautySettings];
    }
    else if (args.count == 1) {
        if ([self.target respondsToSelector:self.action]) {
            SuppressPerformSelectorLeakWarning([self.target performSelector:self.action withObject:args.firstObject])
        }
    }
    else {
        [super sendAction:args];
    }
}

- (void)applyBeautySettings {
    if (self.target != nil) {
        if ([self.target respondsToSelector:@selector(setBeautyStyle:)]) {
            [self.target setBeautyStyle:self.beautyStyle];
        }
        if ([self.target respondsToSelector:@selector(setBeautyLevel:)]) {
            [self.target setBeautyLevel:self.beautyLevel];
        }
        if ([self.target respondsToSelector:@selector(setWhitenessLevel:)]) {
            [self.target setWhitenessLevel:self.whiteLevel];
        }
        if ([self.target respondsToSelector:@selector(setRuddyLevel:)]) {
            [self.target setRuddyLevel:self.ruddyLevel];
        }
    }
}

@end

@implementation TCBeautyBeautyPackage

- (void)decodeItems:(NSArray<NSDictionary *> *)array target:(id<TCBeautyPanelActionPerformer>)target {
    for (int i = 0; i < array.count; i++) {
        NSDictionary *dic = array[i];
        NSString *title = dic[@"title"];
        if (![title isKindOfClass:[NSString class]]) {
            continue;
        }
        NSString *normalIcon = dic[@"normalIcon"];
        if (![normalIcon isKindOfClass:[NSString class]]) {
            continue;
        }
        NSString *selIcon = @"";
        SEL action = nil;
        float minValue = 0;
        float maxValue = 10;
        float currentValue = 6;
        if ([dic.allKeys containsObject:@"selector"]) {
            NSString *selectorStr = dic[@"selector"];
            if ([selectorStr isKindOfClass:[NSString class]]) {
                action = NSSelectorFromString(selectorStr);
            }
        }
        if ([dic.allKeys containsObject:@"selIcon"]) {
            NSString *iconStr = dic[@"selIcon"];
            if ([iconStr isKindOfClass:[NSString class]]) {
                selIcon = iconStr;
            }
        }
        if ([dic.allKeys containsObject:@"minValue"]) {
            NSNumber *min = dic[@"minValue"];
            if ([min isKindOfClass:[NSNumber class]]) {
                minValue = [min floatValue];
            }
        }
        if ([dic.allKeys containsObject:@"maxValue"]) {
            NSNumber *max = dic[@"maxValue"];
            if ([max isKindOfClass:[NSNumber class]]) {
                maxValue = [max floatValue];
            }
        }
        if ([dic.allKeys containsObject:@"currentValue"]) {
            NSNumber *current = dic[@"currentValue"];
            if ([current isKindOfClass:[NSNumber class]]) {
                currentValue = [current floatValue];
            }
        }
        
        TCBeautyBeautyItem *item = [[TCBeautyBeautyItem alloc] initWithTitle:BeautyLocalize(title) normalIcon:[UIImage imageNamed:normalIcon inBundle:BeautyBundle() compatibleWithTraitCollection:nil] package:self target:target action:action currentValue:currentValue minValue:minValue maxValue:maxValue];
        if (selIcon.length > 0) {
            item.selectIcon = [UIImage imageNamed:selIcon inBundle:BeautyBundle() compatibleWithTraitCollection:nil];
        }
        item.index = i;
        [self.items addObject:item];
    }
}

@end

@implementation TCBeautyFilterItem

- (instancetype)initWithTitle:(NSString *)title normalIcon:(UIImage *)normalIcon package:(TCBeautyBasePackage *)package lookupImagePath:(NSString *)lookupImagePath target:(id<TCBeautyPanelActionPerformer>)target currentValue:(float)currentValue minValue:(float)minValue maxValue:(float)maxValue identifier:(NSString *)identifier {
    if (self = [super initWithTitle:title normalIcon:normalIcon selIcon:nil package:package isClear:NO]) {
        self.lookupImagePath = lookupImagePath;
        self.identifier = identifier;
        [self addTarget:target action:nil];
        [self setValue:currentValue min:minValue max:maxValue];
    }
    return self;
}

- (void)setFilter {
    if (self.target == nil || self.lookupImagePath == nil) {
        return;
    }
    UIImage *img = [UIImage imageWithContentsOfFile:self.lookupImagePath];
    if (img != nil) {
        if ([self.target respondsToSelector:@selector(setFilter:)]) {
            [self.target setFilter:img];
        }
    }
}

- (void)setSlider:(float)value {
    self.currentValue = value;
    if (self.target == nil) {
        return;
    }
    if ([self.target respondsToSelector:@selector(setFilterStrength:)]) {
        [self.target setFilterStrength:value / 10.0];
    }
    else if ([self.target respondsToSelector:@selector(setFilterConcentration:)]) {
        [self.target setFilterConcentration:value / 10.0];
    }
}

- (void)sendAction:(NSArray *)args {
    if (args.count > 0) {
        NSNumber *value = args.firstObject;
        if ([value isKindOfClass:[NSNumber class]]) {
            [self setSlider:[value floatValue]];
        }
    }
    else {
        [self setFilter];
    }
}

@end

@implementation TCBeautyFilterPackage

+ (NSArray *)defaultFilterValue {
    return @[@5, @5, @5, @8, @8, @7, @10, @8, @10, @5, @3, @3, @3, @3, @3, @3, @3, @3, @3];
}

@end


@interface TCBeautyMotionItem () <NSURLSessionDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic,  copy ) void (^progressBlock) (float progress);
@property (nonatomic,  copy ) void (^completeBlock) (BOOL success, NSString *message);
@end
@implementation TCBeautyMotionItem

- (BOOL)isDownloaded {
    if (self.isClear) {
        return YES;
    }
    NSMutableArray *files = [NSMutableArray arrayWithArray:[[NSFileManager defaultManager] subpathsAtPath:self.floderPath]];
    if ([files containsObject:@".DS_Store"]) {
        [files removeObject:@".DS_Store"];
    }
    return files.count > 0;
}

- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

- (NSString *)floderPath {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    if (self.package == nil) {
        return path;
    }
    NSFileManager *manager = [NSFileManager defaultManager];
    path = [path stringByAppendingPathComponent:@"packages"];
    [manager createDirectoryAtURL:[NSURL fileURLWithPath:path] withIntermediateDirectories:YES attributes:nil error:nil];
    path = [path stringByAppendingPathComponent:self.package.typeStr];
    [manager createDirectoryAtURL:[NSURL fileURLWithPath:path] withIntermediateDirectories:YES attributes:nil error:nil];
    path = [path stringByAppendingPathComponent:self.identifier];
    [manager createDirectoryAtURL:[NSURL fileURLWithPath:path] withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}

- (NSString *)packagePath {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    if (self.package == nil) {
        return path;
    }
    NSFileManager *manager = [NSFileManager defaultManager];
    path = [path stringByAppendingPathComponent:@"packages"];
    [manager createDirectoryAtURL:[NSURL fileURLWithPath:path] withIntermediateDirectories:YES attributes:nil error:nil];
    path = [path stringByAppendingPathComponent:self.package.typeStr];
    [manager createDirectoryAtURL:[NSURL fileURLWithPath:path] withIntermediateDirectories:YES attributes:nil error:nil];
    return path;
}

- (instancetype)initWithTitle:(NSString *)title identifier:(NSString *)identifier url:(NSString *)url package:(TCBeautyBasePackage *)package target:(id<TCBeautyPanelActionPerformer>)target {
    if (self = [super initWithTitle:title normalIcon:[UIImage imageNamed:identifier inBundle:BeautyBundle() compatibleWithTraitCollection:nil] selIcon:nil package:package isClear:NO]) {
        self.identifier = identifier;
        self.url = url;
        [self addTarget:target action:nil];
    }
    return self;
}

- (void)dealloc {
    [self stopTask];
    [self flushRefrence];
}

- (void)stopTask {
    if (self.isDownloading) {
        [self.session invalidateAndCancel];
        self.isDownloading = NO;
    }
}

- (void)flushRefrence {
    self.completeBlock = nil;
    self.progressBlock = nil;
}

- (void)sendAction:(NSArray *)args {
    if (self.isDownloaded) {
        [self apply];
    }
    else {
        @weakify(self)
        [self download:nil complete:^(BOOL success, NSString * _Nonnull message) {
            @strongify(self)
            if (!self) {
                return;
            }
            if (self.isSelected && success) {
                [self apply];
            }
            else if (!success) {
                LOGE("download error: %@", message);
            }
        }];
    }
}

- (void)apply {
    if (self.target == nil) {
        return;
    }
    if ([self.target respondsToSelector:@selector(setMotionTmpl:inDir:)]) {
        if (self.isClear) {
            [self.target setMotionTmpl:nil inDir:self.packagePath];
        }
        else {
            [self.target setMotionTmpl:self.identifier inDir:self.packagePath];
        }
    }
}

- (void)download:(void (^)(float))progress complete:(void (^)(BOOL, NSString * _Nonnull))complete {
    if (self.isDownloading) {
        return;
    }
    NSURL *url = [NSURL URLWithString:self.url];
    if (url == nil) {
        complete(NO, @"Url error");
        return;
    }
    self.isDownloading = YES;
    self.progressBlock = progress;
    self.completeBlock = complete;
    if (progress != nil) {
        progress(0);
    }
    NSString *downloadPath = [self.floderPath stringByAppendingFormat:@"/%@_download.zip", self.identifier];
    if ([[NSFileManager defaultManager] fileExistsAtPath:downloadPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:downloadPath error:nil];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
    NSURLSessionDownloadTask *task = [self.session downloadTaskWithRequest:request];
    [task resume];
}

#pragma mark - NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    if (error != nil) {
        if (error.code == -999) {
            return;
        }
        if (self.completeBlock != nil) {
            self.completeBlock(NO, error.localizedDescription);
        }
        [self flushRefrence];
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    if (self.progressBlock == nil) {
        return;
    }
    float prog = totalBytesWritten * 1.0 / totalBytesExpectedToWrite;
    self.progressBlock(prog);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    BOOL res = [SSZipArchive unzipFileAtPath:location.path toDestination:self.packagePath];
    
    self.isDownloading = NO;
    
    if (self.isDownloaded && res) {
        if (self.completeBlock != nil) {
            self.completeBlock(YES, @"");
        }
    }
    else {
        if (self.completeBlock != nil) {
            self.completeBlock(NO, @"Unzip failed");
        }
    }
    
    [self flushRefrence];
}
@end

@implementation TCBeautyMotionPackage

- (void)decodeItems:(NSArray<NSDictionary *> *)array target:(id<TCBeautyPanelActionPerformer>)target {
    for (int i = 0; i < array.count; i++) {
        NSDictionary *dic = array[i];
        NSString *title = dic[@"title"];
        if (![title isKindOfClass:[NSString class]]) {
            continue;
        }
        NSString *identifier = dic[@"id"];
        if (![identifier isKindOfClass:[NSString class]]) {
            continue;
        }
        NSString *url = dic[@"url"];
        if (![url isKindOfClass:[NSString class]]) {
            continue;
        }
        TCBeautyMotionItem *item = [[TCBeautyMotionItem alloc] initWithTitle:BeautyLocalize(title) identifier:identifier url:url package:self target:target];
        item.index = i;
        [self.items addObject:item];
    }
}

@end


@implementation TCBeautyGreenItem

- (instancetype)initWithUrl:(NSString *)url title:(NSString *)title normalIcon:(NSString *)normalIcon package:(TCBeautyBasePackage *)package target:(id<TCBeautyPanelActionPerformer>)target {
    if (self = [super initWithTitle:title normalIcon:[UIImage imageNamed:normalIcon inBundle:BeautyBundle() compatibleWithTraitCollection:nil] selIcon:nil package:package isClear:NO]) {
        self.url = url;
        [self addTarget:target action:nil];
    }
    return self;
}

- (void)sendAction:(NSArray *)args {
    if (self.target == nil) {
        return;
    }
    if ([self.target respondsToSelector:@selector(setGreenScreenFile:)]) {
        [self.target setGreenScreenFile:self.url];
    }
}

@end

@implementation TCBeautyGreenPackage



@end
