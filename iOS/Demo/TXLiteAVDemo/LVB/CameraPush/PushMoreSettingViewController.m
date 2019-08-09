/**
 * Module:   PushMoreSettingViewController
 *
 * Function: 推流相关的更多设置项
 */

#import "PushMoreSettingViewController.h"
#import "UIView+Additions.h"


/* 列表项 */
#define CELL_DISABLE_VIDEO          0
#define CELL_MUTE_AUDIO             1
#define CELL_HORIZONTAL_PUSH        2
#define CELL_DEBUG_LOG              3
#define CELL_WARTERMARK             4
#define CELL_MIRROR                 5
#define CELL_TORCH                  6
#define CELL_DELAY_CHECK            7
#define CELL_TOUCH_FOCUS            8
#define CELL_ZOOM                   9
#define CELL_SNAPSHOT               10


/* 编号，请不要修改，写配置文件依赖这个 */
#define TAG_DISABLE_VIDEO          1000
#define TAG_MUTE_AUDIO             1001
#define TAG_HORIZONTAL_PUSH        1002
#define TAG_DEBUG_LOG              1003
#define TAG_WARTERMARK             1004
#define TAG_MIRROR                 1005
#define TAG_TORCH                  1006
#define TAG_DELAY_CHECK            1007
#define TAG_TOUCH_FOCUS            1008
#define TAG_ZOOM                   1009

@interface PushMoreSettingViewController () {
    UISwitch *_disableVideoSwitch;
    UISwitch *_muteAudioSwitch;
    UISwitch *_mirrorSwitch;
    UISwitch *_torchSwitch;
    UISwitch *_delayCheckSwitch;
    UISwitch *_horizontalPushSwitch;
    UISwitch *_debugLogSwitch;
    UISwitch *_watermarkSwitch;
    UISwitch *_touchFocusSwitch;
    UISwitch *_zoomSwitch;
    UIButton *_snapShotButton;
    
    UIColor  *_tintColor;
}
@end

@implementation PushMoreSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.3];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _tintColor = [[UISegmentedControl alloc] init].tintColor;
    
    _disableVideoSwitch   = [self createUISwitch:TAG_DISABLE_VIDEO on:[PushMoreSettingViewController isDisableVideo]];
    _muteAudioSwitch      = [self createUISwitch:TAG_MUTE_AUDIO on:[PushMoreSettingViewController isMuteAudio]];
    _mirrorSwitch         = [self createUISwitch:TAG_MIRROR on:[PushMoreSettingViewController isMirrorVideo]];
    _torchSwitch          = [self createUISwitch:TAG_TORCH on:[PushMoreSettingViewController isOpenTorch]];
    _delayCheckSwitch     = [self createUISwitch:TAG_DELAY_CHECK on:[PushMoreSettingViewController isEnableDelayCheck]];
    _horizontalPushSwitch = [self createUISwitch:TAG_HORIZONTAL_PUSH on:[PushMoreSettingViewController isHorizontalPush]];
    _debugLogSwitch       = [self createUISwitch:TAG_DEBUG_LOG on:[PushMoreSettingViewController isShowDebugLog]];
    _watermarkSwitch      = [self createUISwitch:TAG_WARTERMARK on:[PushMoreSettingViewController isEnableWaterMark]];
    _touchFocusSwitch     = [self createUISwitch:TAG_TOUCH_FOCUS on:[PushMoreSettingViewController isEnableTouchFocus]];
    _zoomSwitch           = [self createUISwitch:TAG_ZOOM on:[PushMoreSettingViewController isEnableVideoZoom]];
    
    _snapShotButton       = [UIButton new];
    _snapShotButton.frame = CGRectMake(0, 0, 50, 30);
    _snapShotButton.layer.cornerRadius  = 5;
    _snapShotButton.layer.shadowOffset  =  CGSizeMake(1, 1);
    _snapShotButton.layer.shadowOpacity = 0.8;
    _snapShotButton.layer.shadowColor   =  [UIColor whiteColor].CGColor;
    _snapShotButton.backgroundColor     = [_tintColor colorWithAlphaComponent:0.6];
    _snapShotButton.titleLabel.font     = [UIFont systemFontOfSize:14];
    [_snapShotButton setTitle:@"截图" forState:UIControlStateNormal];
    [_snapShotButton addTarget:self action:@selector(onSnapShot:) forControlEvents:UIControlEventTouchUpInside];
}

- (UISwitch *)createUISwitch:(NSInteger)tag on:(BOOL)on {
    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectZero];
    sw.tag = tag;
    sw.on = on;
    sw.tintColor = _tintColor;
    sw.onTintColor = _tintColor;
    [sw addTarget:self action:@selector(onSwitchTap:) forControlEvents:UIControlEventTouchUpInside];
    return sw;
}

- (void)onSwitchTap:(UISwitch *)switchBtn {
    [PushMoreSettingViewController saveSetting:switchBtn.tag value:switchBtn.on];
    
    if (switchBtn.tag == TAG_DISABLE_VIDEO) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPushMoreSetting:disableVideo:)]) {
            [self.delegate onPushMoreSetting:self disableVideo:switchBtn.on];
        }
        
    }
    else if (switchBtn.tag == TAG_MUTE_AUDIO) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPushMoreSetting:muteAudio:)]) {
            [self.delegate onPushMoreSetting:self muteAudio:switchBtn.on];
        }
    }
    else if (switchBtn.tag == TAG_MIRROR) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPushMoreSetting:mirrorVideo:)]) {
            [self.delegate onPushMoreSetting:self mirrorVideo:switchBtn.on];
        }
        
    }
    else if (switchBtn.tag == TAG_TORCH) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPushMoreSetting:openTorch:)]) {
            [self.delegate onPushMoreSetting:self openTorch:switchBtn.on];
        }
    }
    else if (switchBtn.tag == TAG_HORIZONTAL_PUSH) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPushMoreSetting:horizontalPush:)]) {
            [self.delegate onPushMoreSetting:self horizontalPush:switchBtn.on];
        }
        
    }
    else if (switchBtn.tag == TAG_DEBUG_LOG) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPushMoreSetting:debugLog:)]) {
            [self.delegate onPushMoreSetting:self debugLog:switchBtn.on];
        }
    }
    else if (switchBtn.tag == TAG_WARTERMARK) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPushMoreSetting:waterMark:)]) {
            [self.delegate onPushMoreSetting:self waterMark:switchBtn.on];
        }
        
    }
    else if (switchBtn.tag == TAG_DELAY_CHECK) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPushMoreSetting:delayCheck:)]) {
            [self.delegate onPushMoreSetting:self delayCheck:switchBtn.on];
        }
        
    }
    else if (switchBtn.tag == TAG_TOUCH_FOCUS) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPushMoreSetting:touchFocus:)]) {
            [self.delegate onPushMoreSetting:self touchFocus:switchBtn.on];
        }
    }
    else if (switchBtn.tag == TAG_ZOOM) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPushMoreSetting:videoZoom:)]) {
            [self.delegate onPushMoreSetting:self videoZoom:switchBtn.on];
        }
        
    }
}

- (void)onSnapShot:(UIButton *)btn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onPushMoreSettingSnapShot:)]) {
        [self.delegate onPushMoreSettingSnapShot:self];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 11;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, self.tableView.height / 10)];
    cell.backgroundColor = UIColor.clearColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = UIColor.whiteColor;
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    
    switch (indexPath.row) {
        case CELL_DISABLE_VIDEO: {
            cell.textLabel.text = @"开启隐私模式";
            cell.accessoryView = _disableVideoSwitch;
            
            break;
        }
            
        case CELL_MUTE_AUDIO: {
            cell.textLabel.text = @"开启静音模式";
            cell.accessoryView = _muteAudioSwitch;
            
            break;
        }
            
        case CELL_MIRROR: {
            cell.textLabel.text = @"开启观看端镜像";
            cell.accessoryView = _mirrorSwitch;
            
            break;
        }
            
        case CELL_TORCH: {
            cell.textLabel.text = @"开启后置闪光灯";
            cell.accessoryView = _torchSwitch;
            
            break;
        }
            
        case CELL_HORIZONTAL_PUSH: {
            cell.textLabel.text = @"开启横屏推流";
            cell.accessoryView = _horizontalPushSwitch;
            
            break;
        }
            
        case CELL_DEBUG_LOG: {
            cell.textLabel.text = @"开启调试日志";
            cell.accessoryView = _debugLogSwitch;
            
            break;
        }
            
        case CELL_WARTERMARK: {
            cell.textLabel.text = @"添加图像水印";
            cell.accessoryView = _watermarkSwitch;
            
            break;
        }
            
        case CELL_DELAY_CHECK: {
            cell.textLabel.text = @"延迟测定工具条";
            cell.accessoryView = _delayCheckSwitch;
            
            break;
        }
            
        case CELL_TOUCH_FOCUS: {
            cell.textLabel.text = @"手动点击曝光对焦";
            cell.accessoryView = _touchFocusSwitch;
            
            break;
        }
        case CELL_ZOOM: {
            cell.textLabel.text = @"手势放大预览画面";
            cell.accessoryView = _zoomSwitch;
            
            break;
        }
            
        case CELL_SNAPSHOT: {
            cell.textLabel.text = @"本地截图";
            cell.accessoryView = _snapShotButton;
            
            break;
        }
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark - 读写配置文件

+ (NSString *)getKey:(NSInteger)tag {
    return [NSString stringWithFormat:@"PUSH_MORE_SETTING_%ld", tag];
}

+ (void)saveSetting:(NSInteger)tag value:(NSInteger)value {
    NSString *key = [PushMoreSettingViewController getKey:tag];
    [[NSUserDefaults standardUserDefaults] setObject:@(value) forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isDisableVideo {
    NSString *key = [PushMoreSettingViewController getKey:TAG_DISABLE_VIDEO];
    NSNumber *d = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (d != nil) {
        return [d intValue];
    }
    return NO;
}

+ (BOOL)isMuteAudio {
    NSString *key = [PushMoreSettingViewController getKey:TAG_MUTE_AUDIO];
    NSNumber *d = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (d != nil) {
        return [d intValue];
    }
    return NO;
}

+ (BOOL)isMirrorVideo {
    NSString *key = [PushMoreSettingViewController getKey:TAG_MIRROR];
    NSNumber *d = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (d != nil) {
        return [d intValue];
    }
    return NO;
}

+ (BOOL)isOpenTorch {
    NSString *key = [PushMoreSettingViewController getKey:TAG_TORCH];
    NSNumber *d = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (d != nil) {
        return [d intValue];
    }
    return NO;
}

+ (BOOL)isHorizontalPush {
    NSString *key = [PushMoreSettingViewController getKey:TAG_HORIZONTAL_PUSH];
    NSNumber *d = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (d != nil) {
        return [d intValue];
    }
    return NO;
}

+ (BOOL)isShowDebugLog {
    NSString *key = [PushMoreSettingViewController getKey:TAG_DEBUG_LOG];
    NSNumber *d = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (d != nil) {
        return [d intValue];
    }
    return NO;
}

+ (BOOL)isEnableWaterMark {
    NSString *key = [PushMoreSettingViewController getKey:TAG_WARTERMARK];
    NSNumber *d = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (d != nil) {
        return [d intValue];
    }
    return NO;
}

+ (BOOL)isEnableDelayCheck {
    NSString *key = [PushMoreSettingViewController getKey:TAG_DELAY_CHECK];
    NSNumber *d = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (d != nil) {
        return [d intValue];
    }
    return NO;
}

+ (BOOL)isEnableTouchFocus {
    NSString *key = [PushMoreSettingViewController getKey:TAG_TOUCH_FOCUS];
    NSNumber *d = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (d != nil) {
        return [d intValue];
    }
    return YES;
}

+ (BOOL)isEnableVideoZoom {
    NSString *key = [PushMoreSettingViewController getKey:TAG_ZOOM];
    NSNumber *d = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (d != nil) {
        return [d intValue];
    }
    return NO;
}

+ (void)setDisableVideo:(BOOL)disable {
    [PushMoreSettingViewController saveSetting:TAG_DISABLE_VIDEO value:disable];
}

@end
