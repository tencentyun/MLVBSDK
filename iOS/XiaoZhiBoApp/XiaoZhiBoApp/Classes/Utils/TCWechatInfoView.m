/**
 * Module: TCWechatInfoView
 *
 * Function: 小直播技术支持联系方式
 */

#import "TCWechatInfoView.h"

#define L(X) NSLocalizedString((X), nil)

@implementation TCWechatInfoView
{
    UILabel *wechatInfoLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        wechatInfoLabel = [[UILabel alloc] initWithFrame:self.bounds];
        wechatInfoLabel.numberOfLines = 0;
        wechatInfoLabel.textColor = [UIColor blackColor];
        wechatInfoLabel.text = [@[L(@"如何获取技术支持服务？"), L(@"关注公众号“腾讯云视频”"), L(@"给公众号发送“小直播”")] componentsJoinedByString:@"\n"];
        wechatInfoLabel.textAlignment = NSTextAlignmentCenter;
        [wechatInfoLabel sizeToFit];
        [self addSubview:wechatInfoLabel];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [wechatInfoLabel sizeThatFits:size];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    wechatInfoLabel.frame = self.bounds;
}

@end
