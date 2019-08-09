/**
 * Module: TCRoomListCell
 *
 * Function: 直播/点播列表的Cell类，主要展示封面、标题、昵称、在线数、点赞数、定位位置
 */

#import "TCRoomListCell.h"
#import <UIImageView+WebCache.h>
#import "UIImage+Additions.h"
#import "TCRoomListModel.h"
#import "UIView+Additions.h"
#import <sys/types.h>
#import <sys/sysctl.h>
#import <Masonry/Masonry.h>
#import "TCUtil.h"
#import "ColorMacro.h"

@interface TCRoomListCell()
{
//    UIImageView *_avatarView;
    UILabel     *_titleLabel;
    UILabel     *_nameLabel;
    UILabel     *_visitorCountLabel;
    UILabel     *_likeCountLabel;
    UILabel     *_locationLabel;
    UIImageView *_bigPicView;

    UIImageView *_flagView;
    UILabel     *_flagTitleLabel;
    
    UIImageView *_timeView;
    UILabel     *_timeLable;
    UIImageView *_locationImageView;
    /// 用户信息容器
    UIView      *_userMsgView;
    UIView      *_lineView;
    UIImageView *_visitorView;
    UIImageView *_likeView;
    UIImageView *_locationView;
    UIImage     *_defaultImage;
    CGRect      _titleRect;
    UIImageView  *_bottomGradient;
}

@end

@implementation TCRoomListCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initUIForLiveAndVOD];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    {
//        [self layoutForLiveAndVOD];
    }
}

- (void)initUIForLiveAndVOD {
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)@[(__bridge id)[UIColor clearColor].CGColor, (__bridge id)[UIColor colorWithWhite:0 alpha:0.5].CGColor], (CGFloat[]){0.0, 1.0});
    UIGraphicsBeginImageContext(CGSizeMake(1, 39));
    CGContextRef cxt = UIGraphicsGetCurrentContext();
    CGContextDrawLinearGradient(cxt, gradient, CGPointZero, CGPointMake(0, 39), kCGGradientDrawsAfterEndLocation);
    _bottomGradient = [[UIImageView alloc] initWithImage:UIGraphicsGetImageFromCurrentImageContext()];
    UIGraphicsEndImageContext();
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
//    self.contentView.backgroundColor = UIColorFromRGB(0x181d27);
    //背景图
    _bigPicView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _bigPicView.layer.cornerRadius = 10;
    _bigPicView.contentMode = UIViewContentModeScaleAspectFill;
    _bigPicView.clipsToBounds = YES;
    [self.contentView addSubview:_bigPicView];
    
    [self.contentView addSubview:_bottomGradient];
    [_bottomGradient mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView);
        make.width.equalTo(self.contentView);
        make.height.equalTo(@39);
    }];
    
    //用户信息
    _userMsgView = [[UIView alloc] initWithFrame:CGRectZero];
    _userMsgView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_userMsgView];
    
//    //line
//    _lineView = [[UIView alloc] initWithFrame:CGRectZero];
//    [_lineView setBackgroundColor:UIColorFromRGB(0xD8D8D8)];
//    [_userMsgView addSubview:_lineView];
    
    //头像
    /*
    _avatarView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_userMsgView addSubview:_avatarView];
    */
    
    //标题名
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [_titleLabel setTextColor:[UIColor whiteColor]];
    [_userMsgView addSubview:_titleLabel];
    
    //用户名
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_nameLabel setFont:[UIFont systemFontOfSize:12]];
    [_nameLabel setTextColor:[UIColor whiteColor]];
    [_userMsgView addSubview:_nameLabel];
    
    //拜访者图标
    _visitorView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_visitorView setImage:[UIImage imageNamed:@"visitors"]];
    [_userMsgView addSubview:_visitorView];
    
    //拜访者人数
    _visitorCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_visitorCountLabel setFont:[UIFont systemFontOfSize:12]];
    [_visitorCountLabel setTextColor:[UIColor whiteColor]];
    [_userMsgView addSubview:_visitorCountLabel];
    
    //点赞图标
    _likeView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_likeView setImage:[UIImage imageNamed:@"like"]];
    [_userMsgView addSubview:_likeView];
    
    //点赞人数
    _likeCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_likeCountLabel setFont:[UIFont systemFontOfSize:12]];
    [_likeCountLabel setTextColor:[UIColor whiteColor]];
    [_userMsgView addSubview:_likeCountLabel];
    
    //位置图标
    _locationView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_locationView setImage:[UIImage imageNamed:@"position"]];
    [_userMsgView addSubview:_locationView];
    
    //位置详情
    _locationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_locationLabel setFont:[UIFont systemFontOfSize:12]];
    [_locationLabel setTextColor:[UIColor whiteColor]];
    [_userMsgView addSubview:_locationLabel];
    
    
    _flagTitleLabel = [[UILabel alloc] init];
    _flagTitleLabel.font = [UIFont systemFontOfSize:12];
    _flagTitleLabel.text = @"直播中";
    _flagTitleLabel.textColor = [UIColor colorWithWhite:1 alpha:1];
    _flagView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"live_tag_bg"]];
    [self.contentView addSubview:_flagView];
    [self.contentView addSubview:_flagTitleLabel];

    if (_defaultImage == nil) {
        _defaultImage = [self scaleClipImage:[UIImage imageNamed:@"bg.jpg"] clipW: [UIScreen mainScreen].bounds.size.width * 2 clipH:274 * 2 ];
    }
    //背景图
    [_bigPicView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    //用户信息
    [_userMsgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(5, 5, 5, 5));
    }];
    
    
    //LIVE标记
    [_flagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right);
        make.top.equalTo(self.contentView.mas_top);
    }];
    
    // "直播中"字
    [_flagTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_flagView);
    }];
    
    // 用户名 (左下角)
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_userMsgView);
        make.bottom.equalTo(_userMsgView);
    }];

    //标题名 (用户名上面)
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_userMsgView);
        make.bottom.equalTo(_nameLabel.mas_top);
    }];
    
    // 访问人数 右下角
    [_visitorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_visitorCountLabel.mas_left).offset(-2);
        make.centerY.equalTo(_visitorCountLabel);
    }];
    
    [_visitorCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_userMsgView);
        make.bottom.equalTo(_userMsgView);
    }];


    // 用户头像
    /*
    _avatarView.layer.cornerRadius  = _avatarView.height * 0.5;
    _avatarView.layer.masksToBounds = YES;
    _avatarView.layer.borderWidth   = 1;
    _avatarView.layer.borderColor   = [UIColor clearColor].CGColor;
    [_avatarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@24);
        make.height.equalTo(@24);
        make.left.equalTo(_userMsgView);
        make.top.equalTo(_userMsgView);
    }];
    */
    
    // 位置信息图标 左上，点赞以下
    [_locationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_userMsgView);
        make.top.equalTo(_userMsgView);

    }];
    // 位置信息字
    [_locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_locationView.mas_right);
        make.centerY.equalTo(_locationView);
    }];

    // 点赞数
    [_likeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_locationView.mas_bottom).offset(5);
        make.left.equalTo(_userMsgView);
    }];
    
    [_likeCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_likeView.mas_right).offset(2);
        make.centerY.equalTo(_likeView);
    }];
    
}

- (void)setIsLive:(BOOL)isLive {
    BOOL hide = !isLive;
    if (_flagView.hidden != hide) {
        _flagView.hidden = _flagTitleLabel.hidden = hide;
        _likeView.hidden = _likeCountLabel.hidden = hide;
    }
}

- (void)setModel:(TCRoomInfo *)model {
    _model = model;
    /*
    [_avatarView sd_setImageWithURL:[NSURL URLWithString:[TCUtil transImageURL2HttpsURL:_model.userinfo.headpic]]
                      placeholderImage:[UIImage imageNamed:@"face"]];
    */
    if (_titleLabel) _titleLabel.text = _model.title;
   
    
    NSMutableString* name = [[NSMutableString alloc] initWithString:@""];
    if (0 == _model.userinfo.nickname.length) {
        [name appendString:_model.userid];
    }
    else {
        [name appendString:_model.userinfo.nickname];
    }
    if (_nameLabel) _nameLabel.text = name;
    
    if (_visitorCountLabel) _visitorCountLabel.text = [NSString stringWithFormat:@"%d", _model.viewercount];
    if (_likeCountLabel) _likeCountLabel.text = [NSString stringWithFormat:@"%d", _model.likecount];
    if (_locationLabel) _locationLabel.text = _model.userinfo.location;
    
    //self.locationImageView.hidden = NO;
    if (_locationLabel && _locationLabel.text.length == 0) {
        _locationLabel.text = @"不显示地理位置";
    }
    
    __weak typeof(_bigPicView) weakPicView =  _bigPicView;
    [_bigPicView sd_setImageWithURL:[NSURL URLWithString:[TCUtil transImageURL2HttpsURL:model.userinfo.frontcover]] placeholderImage:_defaultImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        UIImage *newImage = [self scaleClipImage:image clipW:_bigPicView.width clipH:_bigPicView.height];
        if (image != nil) {
            weakPicView.image = image;
        }
    }];
    
    
    if (_timeLable) {
        [self setTimeLable:_model.timestamp];
    }
    
//    {
//        [self layoutForLiveAndVOD];
//    }
}

- (TCRoomInfo *)model {
    _model.userinfo.frontcoverImage = _bigPicView.image;
    return _model;
}

- (UIImage *)scaleClipImage:(UIImage *)image clipW:(CGFloat)clipW clipH:(CGFloat)clipH {
    UIImage *newImage = nil;
    if (image != nil) {
        if (image.size.width >=  clipW && image.size.height >= clipH) {
            newImage = [self clipImage:image inRect:CGRectMake((image.size.width - clipW)/2, (image.size.height - clipH)/2, clipW,clipH)];
        } else{
            CGFloat widthRatio = clipW / image.size.width;
            CGFloat heightRatio = clipH / image.size.height;
            CGFloat imageNewHeight = 0;
            CGFloat imageNewWidth = 0;
            UIImage *scaleImage = nil;
            if (widthRatio < heightRatio) {
                imageNewHeight = clipH;
                imageNewWidth = imageNewHeight * image.size.width / image.size.height;
                scaleImage = [self scaleImage:image scaleToSize:CGSizeMake(imageNewWidth, imageNewHeight)];
            }else{
                imageNewWidth = clipW;
                imageNewHeight = imageNewWidth * image.size.height / image.size.width;
                scaleImage = [self scaleImage:image scaleToSize:CGSizeMake(imageNewWidth, imageNewHeight)];
            }
            newImage = [self clipImage:image inRect:CGRectMake((scaleImage.size.width - clipW)/2, (scaleImage.size.height - clipH)/2, clipW,clipH)];
        }
    }
    return newImage;
}

/**
 *缩放图片
 */
- (UIImage*)scaleImage:(UIImage *)image scaleToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

/**
 *裁剪图片
 */
- (UIImage *)clipImage:(UIImage *)image inRect:(CGRect)rect {
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
    return newImage;
}

- (void)setTimeLable:(int)timestamp {
    NSString *timeStr = @"刚刚";
    int interval = [[NSDate date] timeIntervalSince1970] - timestamp;
    
    if (interval >= 60 && interval < 3600) {
        timeStr = [[NSString alloc] initWithFormat:@"%d分钟前", interval/60];
    } else if (interval >= 3600 && interval < 60*60*24) {
        timeStr = [[NSString alloc] initWithFormat:@"%d小时前", interval/3600];
    } else if (interval >= 60*60*24 && interval < 60*60*24*365) {
        timeStr = [[NSString alloc] initWithFormat:@"%d天前", interval/3600/24];
    } else if (interval >= 60*60*24*265) {
        timeStr = [[NSString alloc] initWithFormat:@"很久前"];
    }
    
    _timeLable.text = timeStr;
}

@end
