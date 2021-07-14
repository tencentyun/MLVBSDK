/**
 * Module:   PushMoreSettingViewController
 *
 * Function: 推流相关的更多设置项
 */

#import "PushMoreSettingViewController.h"
#import "UIView+Additions.h"
#import "AppLocalized.h"

/* 列表项 */
#define CELL_DISABLE_VIDEO          0
#define CELL_MUTE_AUDIO             1
#define CELL_DEBUG_LOG              2
#define CELL_WARTERMARK             3
#define CELL_MIRROR                 4
#define CELL_TORCH                  5
#define CELL_TOUCH_FOCUS            6
#define CELL_SNAPSHOT               7


/* 编号，请不要修改，写配置文件依赖这个 */
#define TAG_DISABLE_VIDEO          1000
#define TAG_MUTE_AUDIO             1001
#define TAG_DEBUG_LOG              1003
#define TAG_WARTERMARK             1004
#define TAG_MIRROR                 1005
#define TAG_TORCH                  1006
#define TAG_TOUCH_FOCUS            1008


@interface PushMoreSettingViewController ()<UITextFieldDelegate> {
    UISwitch *_disableVideoSwitch;
    UISwitch *_muteAudioSwitch;
    UISwitch *_mirrorSwitch;
    UISwitch *_torchSwitch;
    UISwitch *_debugLogSwitch;
    UISwitch *_watermarkSwitch;
    UISwitch *_touchFocusSwitch;
    UISwitch *_pureAudioSwitch;
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
    _debugLogSwitch       = [self createUISwitch:TAG_DEBUG_LOG on:[PushMoreSettingViewController isShowDebugLog]];
    _watermarkSwitch      = [self createUISwitch:TAG_WARTERMARK on:[PushMoreSettingViewController isEnableWaterMark]];
    _touchFocusSwitch     = [self createUISwitch:TAG_TOUCH_FOCUS on:[PushMoreSettingViewController isEnableTouchFocus]];
    
    _snapShotButton       = [self createButtonWithTitle:LivePlayerLocalize(@"LivePusherDemo.MoreSetting.screenshots") action:@selector(onSnapShot:)];
}

- (UIButton*)createButtonWithTitle:(NSString*)title action:(SEL)action
{
    UIButton* newBtn       = [UIButton new];
    newBtn.frame = CGRectMake(0, 0, 50, 30);
    newBtn.layer.cornerRadius  = 5;
    newBtn.layer.shadowOffset  =  CGSizeMake(1, 1);
    newBtn.layer.shadowOpacity = 0.8;
    newBtn.layer.shadowColor   =  [UIColor whiteColor].CGColor;
    newBtn.backgroundColor     = [_tintColor colorWithAlphaComponent:0.6];
    newBtn.titleLabel.font     = [UIFont systemFontOfSize:14];
    [newBtn setTitle:title forState:UIControlStateNormal];
    [newBtn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    return newBtn;
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
    else if (switchBtn.tag == TAG_TOUCH_FOCUS) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPushMoreSetting:touchFocus:)]) {
            [self.delegate onPushMoreSetting:self touchFocus:switchBtn.on];
        }
    }
}

- (void)onSnapShot:(UIButton *)btn {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onPushMoreSettingSnapShot:)]) {
        [self.delegate onPushMoreSettingSnapShot:self];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 13;
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
            cell.textLabel.text = LivePlayerLocalize(@"LivePusherDemo.MoreSetting.enableprivacymode");
            cell.accessoryView = _disableVideoSwitch;
            
            break;
        }
            
        case CELL_MUTE_AUDIO: {
            cell.textLabel.text = LivePlayerLocalize(@"LivePusherDemo.MoreSetting.turnonmutemode");
            cell.accessoryView = _muteAudioSwitch;
            
            break;
        }
            
        case CELL_MIRROR: {
            cell.textLabel.text = LivePlayerLocalize(@"LivePusherDemo.MoreSetting.turnonviewmirror");
            cell.accessoryView = _mirrorSwitch;
            
            break;
        }
            
        case CELL_TORCH: {
            cell.textLabel.text = LivePlayerLocalize(@"LivePusherDemo.MoreSetting.turnontherearflash");
            cell.accessoryView = _torchSwitch;
            
            break;
        }
        
        case CELL_DEBUG_LOG: {
            cell.textLabel.text = LivePlayerLocalize(@"LivePusherDemo.MoreSetting.openingdebuglog");
            cell.accessoryView = _debugLogSwitch;
            
            break;
        }
            
        case CELL_WARTERMARK: {
            cell.textLabel.text = LivePlayerLocalize(@"LivePusherDemo.MoreSetting.addwatermark");
            cell.accessoryView = _watermarkSwitch;
            
            break;
        }
                        
        case CELL_TOUCH_FOCUS: {
            cell.textLabel.text = LivePlayerLocalize(@"LivePusherDemo.MoreSetting.manuallyclickexposureandfocus");
            cell.accessoryView = _touchFocusSwitch;
            
            break;
        }
        case CELL_SNAPSHOT: {
            cell.textLabel.text = LivePlayerLocalize(@"LivePusherDemo.MoreSetting.localscreenshots");
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

+ (BOOL)isEnableTouchFocus {
    NSString *key = [PushMoreSettingViewController getKey:TAG_TOUCH_FOCUS];
    NSNumber *d = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (d != nil) {
        return [d intValue];
    }
    return YES;
}

+ (void)setDisableVideo:(BOOL)disable {
    [PushMoreSettingViewController saveSetting:TAG_DISABLE_VIDEO value:disable];
}

@end
