/**
 * Module:   PushLogView
 *
 * Function: 用来显示App层的关键日志
 */

#import "PushLogView.h"
#import "TXLiveSDKTypeDef.h"
#import "AppLocalized.h"

@interface PushLogView() {
    int _step;
    NSMutableArray *_stepImgViews;
    UILabel *_encBitrateLabel;
    UILabel *_upBitrateLabel;
    UILabel *_fpsLabel;
    UILabel *_gopLabel;
}
@end

@implementation PushLogView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _step = 0;
        int height = 20;
        
        int statusOffsetX = 40, statusOffsetY = 10, statusIntervalY = 40;
        [self addLabel:LivePlayerLocalize(@"LivePusherDemo.PushLogView.coderate") withFrame:CGRectMake(statusOffsetX, statusOffsetY, 100, height)];
        [self addLabel:@"FPS：" withFrame:CGRectMake(statusOffsetX, statusOffsetY + statusIntervalY * 2, 50, height)];
        
        _encBitrateLabel = [self addLabel:@"0kbps" withFrame:CGRectMake(statusOffsetX + 100, statusOffsetY, 100, height)];
        _fpsLabel = [self addLabel:@"0" withFrame:CGRectMake(statusOffsetX + 50, statusOffsetY + statusIntervalY * 2, 20, height)];
    }
    return self;
}

- (UILabel *)addLabel:(NSString *)text withFrame:(CGRect)frame {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = text;
    label.adjustsFontSizeToFitWidth = true;
    [self addSubview:label];
    return label;
}

- (UIImageView *)addImageView:(NSString *)imageName withFrame:(CGRect)frame {
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    imgView.frame = frame;
    [self addSubview:imgView];
    return imgView;
}

- (void)setStep:(int)step {
    _step = step;
    UIImageView *imgView = _stepImgViews[_step-1];
    [imgView setImage:[UIImage imageNamed:@"ic_green"]];
}

- (void)setPushUrlValid:(BOOL)valid {
    if (valid) {
        [self setStep:1];
    }
}

- (void)setPushEvent:(int)evtID withParam:(NSDictionary *)param {
    switch (evtID) {
        case EVT_RTMP_PUSH_CONNECT_SUCC:
            [self setStep:2];
            break;
        case EVT_CAMERA_START_SUCC:
            [self setStep:3];
            break;
        case EVT_START_VIDEO_ENCODER:
            [self setStep:4];
            break;
        case EVT_RTMP_PUSH_BEGIN:
            [self setStep:5];
            break;
        default:
            break;
    }
}

- (void)setNetStatus:(NSDictionary *)param {
    int netspeed = [(NSNumber *) [param valueForKey:NET_STATUS_NET_SPEED] intValue];
    int videoEncBitrate = [(NSNumber *) [param valueForKey:NET_STATUS_VIDEO_BITRATE] intValue];
    int fps = [(NSNumber *) [param valueForKey:NET_STATUS_VIDEO_FPS] intValue];
    int gop = [(NSNumber *) [param valueForKey:NET_STATUS_VIDEO_GOP] intValue];
    
    _encBitrateLabel.text = [NSString stringWithFormat:@"%dkbps", videoEncBitrate];
    _upBitrateLabel.text = [NSString stringWithFormat:@"%dkbps", netspeed];
    _fpsLabel.text = [NSString stringWithFormat:@"%d", fps];
    _gopLabel.text = [NSString stringWithFormat:@"%ds", gop];
}

- (void)clear {
    _step = 0;
    
    _encBitrateLabel.text = @"0kbps";
    _upBitrateLabel.text = @"0kbps";
    _fpsLabel.text = @"0";
    _gopLabel.text = @"0s";
    
    for (UIImageView *imgView in _stepImgViews) {
        [imgView setImage:[UIImage imageNamed:@"ic_red"]];
    }
}

@end
