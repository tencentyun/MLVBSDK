//
//  UIViewAdditions.h
//

#import <UIKit/UIKit.h>

#define kScaleX [UIScreen mainScreen].bounds.size.width / 375
#define kScaleY [UIScreen mainScreen].bounds.size.height / 667

@interface UIView (Additions)

- (id) initWithParent:(UIView *)parent;
+ (id) viewWithParent:(UIView *)parent;
-(void)removeAllSubViews;
- (void)setBackgroundImage:(UIImage*)image;
- (UIImage*)toImage;



// Position of the top-left corner in superview's coordinates
@property CGPoint position;
@property CGFloat x;
@property CGFloat y;
@property CGFloat top;
@property CGFloat bottom;
@property CGFloat left;
@property CGFloat right;


// makes hiding more logical
@property BOOL	visible;


// Setting size keeps the position (top-left corner) constant
@property CGSize size;
@property CGFloat width;
@property CGFloat height;

@end

@interface UIImageView (MFAdditions)

- (void) setImageWithName:(NSString *)name;

@end
