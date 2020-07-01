//
//  MCCameraDynamicView.m
//  PituMotionDemo
//
//  Created by ricocheng on 6/15/16.
//  Copyright © 2016 Pitu. All rights reserved.
//

#import "MCCameraDynamicView.h"
#import "UIColor+MCColor.h"
#import "UIImage+MCImage.h"
#import "UIImageView+WebCache.h"
#import "MaterialManager.h"
#import "UIView+Additions.h"

#define DEGREES_2_RADIANS(x) (0.0174532925 * (x))

@interface CircleProcessView : UIView {
    CAShapeLayer *arcLayer;
    CGFloat width;
    CGFloat height;
}
@property (nonatomic, retain) UIImageView *bgImage;
@property (nonatomic, assign) CGFloat value;
@property (nonatomic, strong) UIColor *progressTintColor;
@end
@implementation CircleProcessView
- (void)dealloc {
    arcLayer = nil;
    self.bgImage = nil;
}
- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        width = 60;
        height = 60;
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = YES;
    }
    
    return self;
}
- (void)drawRect:(CGRect)rect {
    
    [super drawRect:rect];
    
    CGPoint centerPoint = CGPointMake(width/2, height/2);
    CGFloat radius = 10;
    
    CGFloat pathWidth = 2.0;
    CGFloat innerRadius = radius-pathWidth;
//    CGFloat pathRadius = innerRadius+pathWidth/2;
    
    CGFloat radians = DEGREES_2_RADIANS((self.value*359.9)-90);
//    CGFloat xOffset = radius + pathRadius*cosf(radians);
//    CGFloat yOffset = radius + pathRadius*sinf(radians);
//    CGPoint endPoint = CGPointMake(xOffset, yOffset);
//    NSLog(@"%@",NSStringFromCGPoint(endPoint));

    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (self.value != 0) {
        [self.progressTintColor setFill];
        CGMutablePathRef progressPath = CGPathCreateMutable();
        CGPathMoveToPoint(progressPath, NULL, centerPoint.x, centerPoint.y);
        CGPathAddArc(progressPath, NULL, centerPoint.x, centerPoint.y, radius, DEGREES_2_RADIANS(270), radians, NO);
        CGPathCloseSubpath(progressPath);
        CGContextAddPath(context, progressPath);
        CGContextFillPath(context);
        CGPathRelease(progressPath);
    }
    
    CGContextSetBlendMode(context, kCGBlendModeClear);;
    CGPoint newCenterPoint = CGPointMake(centerPoint.x - innerRadius, centerPoint.y - innerRadius);
    CGContextAddEllipseInRect(context, CGRectMake(newCenterPoint.x, newCenterPoint.y, innerRadius*2, innerRadius*2));
    CGContextFillPath(context);
}
- (UIColor *)progressTintColor {
    if (!_progressTintColor) {
        _progressTintColor = [UIColor MCSelected];
    }
    return _progressTintColor;
}
- (void)setValue:(CGFloat)value {
    _value = value;
    [self setNeedsDisplay];
}
- (UIImageView *)bgImage {
    
    if (!_bgImage) {
        UIImage *image = [UIImage MCImageNamed:@"camera_downloadBG.png"];
        
        _bgImage = [[UIImageView alloc] initWithFrame:CGRectMake((width-image.size.width)/2, (height-image.size.height)/2, image.size.width, image.size.height)];
        _bgImage.image = image;
    }
    
    return _bgImage;
}
@end

@interface DynamicCell : UICollectionViewCell

@property (nonatomic, retain) NSString *materialID;
@property (nonatomic, retain) UIImageView *icon;
@property (nonatomic, retain) UIImageView *iconSelected;
@property (nonatomic, retain) UIImageView *iconDownload;
@property (nonatomic, retain) CircleProcessView *circleProcessView;
@property (nonatomic, retain) UIImageView *iconMusic;
@property (nonatomic, retain) UILabel *label;
@end

@implementation DynamicCell

+ (NSString *)identifier {
    return @"DynamicCell";
}
+ (CGSize)getCellSize {
    UIImage *image = [UIImage imageNamed:@"icon_magicexpression_null"];// [UIImage MCImageNamed:@"non_normal"];
    return image.size;
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.icon = nil;
    self.iconSelected = nil;
    self.iconDownload = nil;
    self.circleProcessView = nil;
    self.label = nil;
}
- (id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkSelected:) name:[MCCameraDynamicView notificationKey] object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(progress:) name:kMC_NOTI_ONLINEMANAGER_PACKAGE_PROGRESS object:nil];
    }
    
    return self;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (![MaterialManager isOnlinePackage:_materialID]) {
        [self.icon sd_cancelCurrentImageLoad];
        self.icon.image = [UIImage MCImageNamed:[NSString stringWithFormat:@"Resource/%@/%@.png", _materialID, _materialID]];
        [self startAnimation:NO];
    } else {
        UIImage *img = [UIImage imageNamed:_materialID];
        if (img) {
            [self.icon sd_cancelCurrentImageLoad];
            self.icon.image = img;
            [self startAnimation:NO];
        } else {
            NSURL *iconURL = [NSURL URLWithString:[MaterialManager thumbUrl:_materialID]];
            [self.icon sd_setImageWithURL:iconURL placeholderImage:[UIImage MCImageNamed:@"camera_model_loading"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [self startAnimation:NO];
            }];
            if ([[SDWebImageManager sharedManager].imageCache diskImageExistsWithKey:[[SDWebImageManager sharedManager] cacheKeyForURL:iconURL]]) {
                [self startAnimation:NO];
            } else {
                [self startAnimation:YES];
            }
        }
    }
    
    [self addSubview:self.icon];
    
    if (self.label == nil) {
        self.label = [UILabel new];
        [self addSubview:self.label];
        self.label.font = [UIFont systemFontOfSize:13];
    }
    self.label.text = [MaterialManager getMotionName:_materialID];
    [self.label sizeToFit];
    self.label.center = CGPointMake(self.icon.center.x, self.icon.size.height+15);
    
    self.iconSelected.alpha = self.selected?1.f:0.f;
    self.iconSelected.center = self.icon.center;
    [self addSubview:self.iconSelected];
    
//    BOOL tmplHasAudio = [[MCOnlineManager shareInstance] hasAudio:tmplName];
//    self.iconMusic.hidden = !tmplHasAudio;
//    [self addSubview:self.iconMusic];
    
    CGFloat progress = [MaterialManager packageDownloaded:_materialID] ? 1.f : 0.f;
    self.iconDownload.hidden = progress==1.f ? YES : NO;
    [self addSubview:self.iconDownload];
    
    self.circleProcessView.bgImage.alpha = progress>0.f && progress<1.f;
    self.circleProcessView.alpha = self.circleProcessView.bgImage.alpha;
    self.circleProcessView.value = progress;
    [self addSubview:self.circleProcessView.bgImage];
    [self addSubview:self.circleProcessView];
}
- (void)checkSelected:(NSNotification *)notification {
    NSString *tmplName = [notification object];
    self.selected = [tmplName isEqualToString:_materialID] && tmplName.length>0;
    self.iconSelected.alpha = self.selected?1.f:0.f;
    self.iconSelected.center = self.icon.center;
}
- (void)setSelected:(BOOL)selected {
    if (selected) {
        BOOL isDownload = [MaterialManager packageDownloaded:_materialID];
        [super setSelected:isDownload];
    } else {
        [super setSelected:selected];
    }
}
- (void)progress:(NSNotification *)notification {
    if ([[notification object] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *progressDic = [notification object];
        if ([progressDic[kMC_USERINFO_ONLINEMANAGER_PACKAGE_MATERIALID] isEqualToString:_materialID]) {
            CGFloat progress = [progressDic[kMC_USERINFO_ONLINEMANAGER_PACKAGE_PROGRESS] floatValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (progress>0 && progress<1) {
                    self.iconDownload.hidden = 1;
                    self.circleProcessView.bgImage.alpha = 1;
                    self.circleProcessView.alpha = 1;
                    self.circleProcessView.value = progress;
                } else {
                    [self setNeedsLayout];
                }
            });
        }
        
    }
}
- (void)startAnimation:(BOOL)animation {
    if (animation) {
        CABasicAnimation *rotate = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        rotate.removedOnCompletion = NO;
        rotate.fromValue = [NSNumber numberWithFloat:0];
        rotate.toValue = [NSNumber numberWithFloat:M_PI * 2];
        rotate.duration = 2;
        rotate.repeatCount = HUGE_VALF;
        [self.icon.layer addAnimation:rotate forKey:@"loadingRotate"];
    } else {
        [self.icon.layer removeAllAnimations];
    }
}
- (UIImageView *)icon {
    if (!_icon) {
        UIImage *image = [UIImage imageNamed:@"icon_magicexpression_null"];
        
        _icon = [[UIImageView alloc] init];
        _icon.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        _icon.bounds = self.bounds;
        _icon.layer.cornerRadius = image.size.width * 0.5f;
        _icon.layer.masksToBounds = YES;
    }
    
    return _icon;
}
- (UIImageView *)iconSelected {
    if (!_iconSelected) {
        UIImage *image = [UIImage MCImageNamed:@"camera_selected"];
        _iconSelected = [[UIImageView alloc] init];
        _iconSelected.frame = CGRectMake(0, 0, image.size.width * 4 / 5, image.size.height * 4 / 5);
        _iconSelected.image = image;
        _iconSelected.alpha = 0.f;
        _iconSelected.layer.cornerRadius = image.size.width * 0.5f * 4 / 5;
        _iconSelected.layer.masksToBounds = YES;
    }
    
    return _iconSelected;
}
- (UIImageView *)iconDownload {

    if (!_iconDownload) {
        UIImage *image = [UIImage MCImageNamed:@"camera_downloadIcon"];
        _iconDownload = [[UIImageView alloc] initWithImage:image];
        _iconDownload.frame = CGRectMake(CGRectGetWidth(self.frame)-image.size.width+2, CGRectGetHeight(self.frame)-image.size.height-4, image.size.width, image.size.height);
    }
    
    return _iconDownload;
}
- (CircleProcessView *)circleProcessView {
    
    if (!_circleProcessView) {
        _circleProcessView = [[CircleProcessView alloc] initWithFrame:self.bounds];
        _circleProcessView.backgroundColor = [UIColor clearColor];
        [_circleProcessView setValue:0.5];
    }
    
    return _circleProcessView;
}
- (UIImageView *)iconMusic {
    
    if (!_iconMusic) {
        UIImage *image = [UIImage MCImageNamed:@"video_music"];
        _iconMusic = [[UIImageView alloc] initWithImage:image];
        _iconMusic.frame = CGRectMake(CGRectGetWidth(self.frame)-image.size.width+2, CGRectGetHeight(self.frame)-image.size.height-4, image.size.width, image.size.height);
    }
    
    return _iconMusic;
}
@end

@interface NonCell : UICollectionViewCell

@property (nonatomic, retain) UIImageView *icon;
@property (nonatomic, retain) UIImageView *iconSelected;
@property (nonatomic, retain) UILabel *label;
@end

@implementation NonCell

+ (NSString *)identifier {
    return @"NonCell";
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.icon = nil;
    self.iconSelected = nil;
}
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkSelected:) name:[MCCameraDynamicView notificationKey] object:nil];
    }
    
    return self;
}
- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    UIImage *image = [UIImage imageNamed:@"icon_magicexpression_null"];
    self.icon.image = image;
    self.icon.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    [self addSubview:self.icon];
    
    if (self.label == nil) {
        self.label = [UILabel new];
        [self addSubview:self.label];
        self.label.font = [UIFont systemFontOfSize:13];
    }
//    self.label.text = @"无动效";
    self.label.text = @"";
    [self.label sizeToFit];
    self.label.center = CGPointMake(self.icon.center.x, self.icon.size.height+15);
    
    self.iconSelected.alpha = self.selected?1.f:0.f;
    self.iconSelected.center = self.icon.center;
    [self addSubview:self.iconSelected];
}
- (void)checkSelected:(NSNotification *)notification {
    NSString *tmplName = [notification object];
    self.selected = !tmplName;
    self.iconSelected.alpha = self.selected?1.f:0.f;
    self.iconSelected.center = self.icon.center;
}
- (UIImageView *)icon {
    if (!_icon) {
        UIImage *image = [UIImage MCImageNamed:@"camera_selected"];
        _icon = [[UIImageView alloc] init];
        _icon.layer.cornerRadius = image.size.width * 0.5f;
        _icon.layer.masksToBounds = YES;
    }
    
    return _icon;
}
- (UIImageView *)iconSelected {
    if (!_iconSelected) {
        UIImage *image = [UIImage MCImageNamed:@"camera_selected"];
        _iconSelected = [[UIImageView alloc] init];
        _iconSelected.frame = CGRectMake(0, 0, image.size.width * 4 / 5, image.size.height * 4 / 5);
        _iconSelected.image = image;
        _iconSelected.alpha = 0.f;
        _iconSelected.layer.cornerRadius = image.size.width * 0.5f * 4 / 5;
        _iconSelected.layer.masksToBounds = YES;
    }
    
    return _iconSelected;
}
@end

@interface MCCameraDynamicView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, retain) UICollectionView *dynamicCollectionView;
@property (nonatomic, retain) UICollectionViewFlowLayout *dynamicLayout;
@property (nonatomic, readonly) NSArray *materials;

@end

@implementation MCCameraDynamicView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //_materials = [MaterialManager materialIDs];
        _materials = [MaterialManager motionArray];
        [self addSubview:self.dynamicCollectionView];
    }
    return self;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.materials.count+1;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([collectionView isEqual:self.dynamicCollectionView]) {
        if (indexPath.item == 0) {
            NonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[NonCell identifier] forIndexPath:indexPath];
            cell.selected = !self.selectedMaterialID;
            [cell setNeedsLayout];
            
            return cell;
//        } else if (indexPath.item == 1) {
//            DynamicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[DynamicCell identifier] forIndexPath:indexPath];
//            cell.materialID = @"video_rabbit";
//            cell.selected = self.selectedMaterialID.length > 0 && [cell.materialID isEqualToString:self.selectedMaterialID];
//            [cell setNeedsLayout];
//            
//            return cell;
//        } else if (indexPath.item == 2) {
//            DynamicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[DynamicCell identifier] forIndexPath:indexPath];
//            cell.materialID = @"video_snow_white";
//            cell.selected = self.selectedMaterialID.length > 0 && [cell.materialID isEqualToString:self.selectedMaterialID];
//            [cell setNeedsLayout];
//            
//            return cell;
        } else {
            DynamicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[DynamicCell identifier] forIndexPath:indexPath];
            cell.materialID = [self.materials objectAtIndex:indexPath.item-1];
            cell.selected = self.selectedMaterialID.length > 0 && [cell.materialID isEqualToString:self.selectedMaterialID];
            [cell setNeedsLayout];
            
            return cell;
        }
        
    }
    
    return nil;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([collectionView isEqual:self.dynamicCollectionView]) {
        if (indexPath.item == 0) {
            self.selectedMaterialID = nil;
            [_delegate motionTmplSelected:nil];
//        } else if (indexPath.item == 1) {
//            NSString *materialID = @"video_rabbit";
//            self.selectedMaterialID = materialID;
//            [_delegate motionTmplSelected:materialID];
//        } else if (indexPath.item == 2) {
//            NSString *materialID = @"video_snow_white";
//            self.selectedMaterialID = materialID;
//            [_delegate motionTmplSelected:materialID];
        } else {
            NSString *materialID = [self.materials objectAtIndex:indexPath.item-1];
            if ([MaterialManager packageDownloaded:materialID]) {
                self.selectedMaterialID = materialID;
                [_delegate motionTmplSelected:materialID];
            } else {
                [[MaterialManager shareInstance] downloadPackage:materialID];
            }
        }
        [self.dynamicCollectionView reloadData];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([collectionView isEqual:self.dynamicCollectionView]) {
        return [DynamicCell getCellSize];
    }
    
    return CGSizeZero;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if ([collectionView isEqual:self.dynamicCollectionView]) {
        return UIEdgeInsetsMake(0, 10, 0, 10);
    }
    return UIEdgeInsetsZero;
}

#pragma mark - @property

- (UICollectionView *)dynamicCollectionView {
    
    if (!_dynamicCollectionView) {
        _dynamicCollectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.dynamicLayout];
        _dynamicCollectionView.delegate = self;
        _dynamicCollectionView.dataSource = self;
        _dynamicCollectionView.showsHorizontalScrollIndicator = NO;
        _dynamicCollectionView.showsVerticalScrollIndicator = NO;
        _dynamicCollectionView.backgroundColor = [UIColor clearColor];
        [_dynamicCollectionView registerClass:[DynamicCell class] forCellWithReuseIdentifier:[DynamicCell identifier]];
        [_dynamicCollectionView registerClass:[NonCell class] forCellWithReuseIdentifier:[NonCell identifier]];
    }
    
    return _dynamicCollectionView;
}
- (UICollectionViewFlowLayout *)dynamicLayout {
    
    if (!_dynamicLayout) {
        _dynamicLayout = [[UICollectionViewFlowLayout alloc] init];
        _dynamicLayout.minimumLineSpacing = 10;
        _dynamicLayout.minimumInteritemSpacing = 0;
        _dynamicLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    
    return _dynamicLayout;
}

@end
