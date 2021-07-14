/**
 * Module:   PushLogView
 *
 * Function: 用来显示App层的关键日志
 */

#import "PushLogView.h"
#import "AppLocalized.h"

@interface PushLogView() {
    NSMutableArray *_stepImgViews;
    UILabel *_sysCpuLabel;
    UILabel *_appCpuLabel;
    UILabel *_videoBitrateLabel;
    UILabel *_audioBitrateLabel;
    UILabel *_fpsLabel;
    UILabel *_videoWidthLabel;
    UILabel *_videoHeightLabel;
}
@end

@implementation PushLogView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        int height = 20;
        int labelCount = 0;
        
        int statusOffsetX = 40, statusOffsetY = 10, statusIntervalY = 40;
        [self addLabel:@"sysCpu：" withFrame:CGRectMake(statusOffsetX, statusOffsetY + statusIntervalY * labelCount, 100, height)];
        _sysCpuLabel = [self addLabel:@"0" withFrame:CGRectMake(statusOffsetX + 100, statusOffsetY + statusIntervalY * labelCount, 50, height)];
        
        labelCount++;
        [self addLabel:@"appCpu：" withFrame:CGRectMake(statusOffsetX, statusOffsetY + statusIntervalY * labelCount, 100, height)];
        _appCpuLabel = [self addLabel:@"0" withFrame:CGRectMake(statusOffsetX + 100, statusOffsetY + statusIntervalY * labelCount, 50, height)];
        
        labelCount++;
        [self addLabel:@"FPS：" withFrame:CGRectMake(statusOffsetX, statusOffsetY + statusIntervalY * labelCount, 100, height)];
        _fpsLabel = [self addLabel:@"0" withFrame:CGRectMake(statusOffsetX + 100, statusOffsetY + statusIntervalY * labelCount, 50, height)];
        
        labelCount++;
        [self addLabel:@"video Width：" withFrame:CGRectMake(statusOffsetX, statusOffsetY + statusIntervalY * labelCount, 100, height)];
        _videoWidthLabel = [self addLabel:@"0" withFrame:CGRectMake(statusOffsetX + 100, statusOffsetY + statusIntervalY * labelCount, 50, height)];
        
        labelCount++;
        [self addLabel:@"video Height：" withFrame:CGRectMake(statusOffsetX, statusOffsetY + statusIntervalY * labelCount, 100, height)];
        _videoHeightLabel = [self addLabel:@"0" withFrame:CGRectMake(statusOffsetX + 100, statusOffsetY + statusIntervalY * labelCount, 50, height)];
        
        labelCount++;
        [self addLabel:LivePlayerLocalize(@"LivePusherDemo.PushLogView.videobitrate") withFrame:CGRectMake(statusOffsetX, statusOffsetY + statusIntervalY * labelCount, 100, height)];
        _videoBitrateLabel = [self addLabel:@"0kbps" withFrame:CGRectMake(statusOffsetX + 100, statusOffsetY + statusIntervalY * labelCount, 100, height)];
        
        labelCount++;
        [self addLabel:LivePlayerLocalize(@"LivePusherDemo.PushLogView.audiobitrate") withFrame:CGRectMake(statusOffsetX, statusOffsetY + statusIntervalY * labelCount, 100, height)];
        _audioBitrateLabel = [self addLabel:@"0kbps" withFrame:CGRectMake(statusOffsetX + 100, statusOffsetY + statusIntervalY * labelCount, 100, height)];
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

- (void)setPushUrlValid:(BOOL)valid {
    if (valid) {
    }
}

- (void)setNetStatus:(NSDictionary *)param {
    CGFloat sysCpu = [(NSNumber *) [param valueForKey:@"CPU_USAGE"] floatValue];
    CGFloat appCpu = [(NSNumber *) [param valueForKey:@"CPU_USAGE_DEVICE"] floatValue];
    NSInteger fps = [(NSNumber *) [param valueForKey:@"VIDEO_FPS"] intValue];
    NSInteger videoWidth = [(NSNumber *) [param valueForKey:@"VIDEO_WIDTH"] intValue];
    NSInteger videoHeight = [(NSNumber *) [param valueForKey:@"VIDEO_HEIGHT"] intValue];
    NSInteger videoBitrate = [(NSNumber *) [param valueForKey:@"VIDEO_BITRATE"] intValue];
    NSInteger audioBitrate = [(NSNumber *) [param valueForKey:@"AUDIO_BITRATE"] intValue];
    
    _sysCpuLabel.text = [NSString stringWithFormat:@"%.02f",sysCpu];
    _appCpuLabel.text =[NSString stringWithFormat:@"%.02f",appCpu];
    _fpsLabel.text = [NSString stringWithFormat:@"%ld", fps];
    _videoWidthLabel.text = [NSString stringWithFormat:@"%ld", videoWidth];
    _videoHeightLabel.text = [NSString stringWithFormat:@"%ld", videoHeight];
    _videoBitrateLabel.text = [NSString stringWithFormat:@"%ldkbps", videoBitrate];
    _audioBitrateLabel.text = [NSString stringWithFormat:@"%ldkbps", audioBitrate];
}

- (void)clear {
    _sysCpuLabel.text = @"0";
    _appCpuLabel.text = @"0";
    _fpsLabel.text = @"0";
    _videoWidthLabel.text = @"0";
    _videoHeightLabel.text = @"0";
    _videoBitrateLabel.text = @"0kbps";
    _audioBitrateLabel.text = @"0kbps";
}

@end
