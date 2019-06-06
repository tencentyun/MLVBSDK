/**
 * Module: TCPlayerItem
 *
 * Function: 播放器画面显示正在加载，日志等
 */

#import <Foundation/Foundation.h>
#import "TCStatusInfoView.h"
#import "SDKHeader.h"

@interface TCStatusInfoView()
{
    UIView*                 _loadingBackground;
    UITextView *            _loadingTextView;
    UIImageView *           _loadingImageView;
    
    UITextView*         	_statusView;
    UITextView*         	_eventView;
    NSString*       		_eventMsg;
}
@end


@implementation TCStatusInfoView
 
- (void)setVideoView:(UIView *)videoView {
    _videoView = videoView;
    [self initLoadingView:videoView];
}

- (void)setLogView:(UIView *)videoView {
    _logView = videoView;
    [self initLogView:_logView];
}

- (void)initLoadingView:(UIView *)view {
    CGRect rect = view.frame;
    
    if (_loadingBackground == nil) {
        _loadingBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(rect), CGRectGetHeight(rect))];
        _loadingBackground.hidden = YES;
        _loadingBackground.backgroundColor = [UIColor blackColor];
        _loadingBackground.alpha  = 0.5;
        [view addSubview:_loadingBackground];
        
        if (_loadingTextView == nil) {
            _loadingTextView = [[UITextView alloc]init];
            _loadingTextView.bounds = CGRectMake(0, 0, CGRectGetWidth(rect), 30);
            _loadingTextView.center = CGPointMake(CGRectGetWidth(rect) / 2, CGRectGetHeight(rect) / 2 - 30);
            _loadingTextView.textAlignment = NSTextAlignmentCenter;
            _loadingTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            _loadingTextView.textColor = [UIColor blackColor];
            _loadingTextView.text = @"连麦中···";
            _loadingTextView.hidden = YES;
            [_loadingBackground addSubview:_loadingTextView];
        }
    }
    
    if (_loadingImageView == nil) {
        float width = 50;
        float height = 50;
        NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:[UIImage imageNamed:@"loading_image0.png"],
                                 [UIImage imageNamed:@"loading_image1.png"],
                                 [UIImage imageNamed:@"loading_image2.png"],
                                 [UIImage imageNamed:@"loading_image3.png"],
                                 [UIImage imageNamed:@"loading_image4.png"],
                                 [UIImage imageNamed:@"loading_image5.png"],
                                 [UIImage imageNamed:@"loading_image6.png"],
                                 [UIImage imageNamed:@"loading_image7.png"],
                                 [UIImage imageNamed:@"loading_image8.png"],
                                 [UIImage imageNamed:@"loading_image9.png"],
                                 [UIImage imageNamed:@"loading_image10.png"],
                                 [UIImage imageNamed:@"loading_image11.png"],
                                 [UIImage imageNamed:@"loading_image12.png"],
                                 [UIImage imageNamed:@"loading_image13.png"],
                                 [UIImage imageNamed:@"loading_image14.png"],
                                 nil];
        _loadingImageView = [[UIImageView alloc] init];
        _loadingImageView.bounds = CGRectMake(0, 0, width, height);
        _loadingImageView.center = CGPointMake(CGRectGetWidth(rect) / 2, CGRectGetHeight(rect) / 2);;
        _loadingImageView.animationImages = array;
        _loadingImageView.animationDuration = 1;
        _loadingImageView.hidden = YES;
        [view addSubview:_loadingImageView];
    }
}

- (void)emptyPlayInfo {
    _pending = NO;
    _userID  = @"";
    _playUrl = @"";
    
    _eventMsg = nil;
    if (_statusView) {
        [_statusView setText:@""];
    }
    if (_eventView) {
        [_eventView setText:@""];
    }
}

- (void)startLoading {
    if (_loadingBackground) {
        _loadingBackground.hidden = NO;
    }
    
    if (_loadingImageView) {
        _loadingImageView.hidden = NO;
        [_loadingImageView startAnimating];
    }
}

- (void)stopLoading {
    if (_loadingBackground) {
        _loadingBackground.hidden = YES;
    }
    
    if (_loadingImageView) {
        _loadingImageView.hidden = YES;
        [_loadingImageView stopAnimating];
    }
}

- (void)startPlay:(NSString*)playUrl {
    if (_btnKickout) {
        _btnKickout.hidden = YES;
    }
}

- (void)stopPlay {
    [self stopLoading];
    if (_btnKickout) {
        _btnKickout.hidden = YES;
    }
}

- (void)showLogView:(BOOL)hidden {
    if(_logView) {
        if (hidden == NO) {
            if (_userID && _userID.length > 0) {
                _logView.hidden = hidden;
            }
        }
        else {
            _logView.hidden = hidden;
        }
    }
}

- (void)freshStatusMsg:(NSDictionary*)param {
    int netspeed  = [(NSNumber*)[param valueForKey:NET_STATUS_NET_SPEED] intValue];
    int vbitrate  = [(NSNumber*)[param valueForKey:NET_STATUS_VIDEO_BITRATE] intValue];
    int abitrate  = [(NSNumber*)[param valueForKey:NET_STATUS_AUDIO_BITRATE] intValue];
    int cachesize = [(NSNumber*)[param valueForKey:NET_STATUS_VIDEO_CACHE] intValue];
    int dropsize  = [(NSNumber*)[param valueForKey:NET_STATUS_VIDEO_DROP] intValue];
    int jitter    = [(NSNumber*)[param valueForKey:NET_STATUS_NET_JITTER] intValue];
    int fps       = [(NSNumber*)[param valueForKey:NET_STATUS_VIDEO_FPS] intValue];
    int width     = [(NSNumber*)[param valueForKey:NET_STATUS_VIDEO_WIDTH] intValue];
    int height    = [(NSNumber*)[param valueForKey:NET_STATUS_VIDEO_HEIGHT] intValue];
    float cpu_usage = [(NSNumber*)[param valueForKey:NET_STATUS_CPU_USAGE] floatValue];
    NSString *serverIP = [param valueForKey:NET_STATUS_SERVER_IP];
    int codecCacheSize = [(NSNumber*)[param valueForKey:NET_STATUS_AUDIO_CACHE] intValue];
    int nCodecDropCnt = [(NSNumber*)[param valueForKey:NET_STATUS_AUDIO_DROP] intValue];
    
    NSString* statusMsg = [NSString stringWithFormat:@"CPU:%.1f%%\tRES:%d*%d\tSPD:%dkb/s\nJITT:%d\tFPS:%d\tARA:%dkb/s\nQUE:%d|%d\tDRP:%d|%d\tVRA:%dkb/s\nSVR:%@\t",
                           cpu_usage*100,
                           width,
                           height,
                           netspeed,
                           jitter,
                           fps,
                           abitrate,
                           codecCacheSize,
                           cachesize,
                           nCodecDropCnt,
                           dropsize,
                           vbitrate,
                           serverIP];
    
    [_statusView setText:statusMsg];
}

- (void)appendEventMsg:(int)event andParam:(NSDictionary*)param {
    long long time = [(NSNumber*)[param valueForKey:EVT_TIME] longLongValue];
    int mil = time % 1000;
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:time/1000];
    NSString* Msg = (NSString*)[param valueForKey:EVT_MSG];
    
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"hh:mm:ss";
    NSString* timeStr = [format stringFromDate:date];
    NSString* log = [NSString stringWithFormat:@"[%@.%-3.3d] %@", timeStr, mil, Msg];
    if (_eventMsg == nil) {
        _eventMsg = @"";
    }
    _eventMsg = [NSString stringWithFormat:@"%@\n%@", _eventMsg, log];
    [_eventView setText:_eventMsg];
}

- (void)initLogView:(UIView*)view {
    if (_logView != nil) {
        CGRect rect = _logView.frame;
        int logheadH = 65;
        
        _statusView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(rect),  logheadH)];
        _statusView.backgroundColor = [UIColor clearColor];
        _statusView.alpha = 1;
        _statusView.textColor = [UIColor blackColor];
        _statusView.editable = NO;
        _statusView.hidden = NO;
        [_logView addSubview:_statusView];
        
        _eventView = [[UITextView alloc] initWithFrame:CGRectMake(0, logheadH, CGRectGetWidth(rect), CGRectGetHeight(rect) - logheadH)];
        _eventView.backgroundColor = [UIColor clearColor];
        _eventView.alpha = 1;
        _eventView.textColor = [UIColor blackColor];
        _eventView.editable = NO;
        _eventView.hidden = NO;
        [_logView addSubview:_eventView];
    }
}

@end
