/**
 * Module:   PushSettingViewController
 *
 * Function: 推流相关的主要设置项
 */

#import "PushSettingViewController.h"
#import "UIView+Additions.h"
#import "ColorMacro.h"

/* 列表项 */
#define SECTION_QUALITY             0
#define SECTION_REVERB              1
#define SECTION_VOICE_CHANGER       2
#define SECTION_BANDWIDTH_ADJUST    3
#define SECTION_HW                  4
#define SECTION_AUDIO_PREVIEW       5

/* 编号，请不要修改，写配置文件依赖这个 */
#define TAG_QUALITY                 1000
#define TAG_REVERB                  1001
#define TAG_VOICE_CHANGER           1002
#define TAG_BANDWIDTH_ADJUST        1003
#define TAG_HW                      1004
#define TAG_AUDIO_PREVIEW           1005

@interface PushSettingQuality : NSObject
@property (copy, nonatomic) NSString *title;
@property (assign, nonatomic) TX_Enum_Type_VideoQuality value;
@end

@implementation PushSettingQuality
@end

@interface PushSettingViewController () <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
    UISwitch *_bandwidthSwitch;
    UISwitch *_hwSwitch;
    UISwitch *_audioPreviewSwitch;
    
    UIActionSheet *_actionSheet;

    NSArray<PushSettingQuality *> *_qualities;
}
@property (strong, nonatomic) UITableView *mainTableView;

@end

@implementation PushSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";

    NSArray<NSString *> * titleArray = @[@"蓝光", @"超清", @"高清", @"标清",
                                         @"连麦大主播", @"连麦小主播", @"实时音视频"];
    TX_Enum_Type_VideoQuality qualityArray[] = {
        VIDEO_QUALITY_ULTRA_DEFINITION,
        VIDEO_QUALITY_SUPER_DEFINITION,
        VIDEO_QUALITY_HIGH_DEFINITION,
        VIDEO_QUALITY_STANDARD_DEFINITION,
        VIDEO_QUALITY_LINKMIC_MAIN_PUBLISHER,
        VIDEO_QUALITY_LINKMIC_SUB_PUBLISHER,
        VIDEO_QUALITY_REALTIME_VIDEOCHAT
    };
    NSMutableArray *qualities = [[NSMutableArray alloc] initWithCapacity:titleArray.count];
    for (int i = 0; i < titleArray.count; ++i) {
        PushSettingQuality *quality = [[PushSettingQuality alloc] init];
        quality.title = titleArray[i];
        quality.value = qualityArray[i];
        [qualities addObject:quality];
    }
    _qualities = qualities;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(onClickedCancel:)];
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(onClickedOK:)];
    
    _bandwidthSwitch = [self createUISwitch:TAG_BANDWIDTH_ADJUST on:[PushSettingViewController getBandWidthAdjust]];
    _hwSwitch = [self createUISwitch:TAG_HW on:[PushSettingViewController getEnableHWAcceleration]];
    _audioPreviewSwitch = [self createUISwitch:TAG_AUDIO_PREVIEW on:[PushSettingViewController getEnableAudioPreview]];
    
    _mainTableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    _mainTableView.separatorColor = [UIColor darkGrayColor];
    [self.view addSubview:_mainTableView];
    [_mainTableView setContentInset:UIEdgeInsetsMake(0, 0, 34, 0)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationBar.translucent = YES;
}

- (void)onClickedCancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onClickedOK:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UISwitch *)createUISwitch:(NSInteger)tag on:(BOOL)on {
    UISwitch *sw = [[UISwitch alloc] initWithFrame:CGRectZero];
    sw.tag = tag;
    sw.on = on;
    [sw addTarget:self action:@selector(onSwitchTap:) forControlEvents:UIControlEventTouchUpInside];
    return sw;
}

- (void)onSwitchTap:(UISwitch *)switchBtn {
    [PushSettingViewController saveSetting:switchBtn.tag value:switchBtn.on];
    
    if (switchBtn.tag == TAG_BANDWIDTH_ADJUST) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPushSetting:enableBandwidthAdjust:)]) {
            [self.delegate onPushSetting:self enableBandwidthAdjust:switchBtn.on];
        }
        
    } else if (switchBtn.tag == TAG_HW) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPushSetting:enableHWAcceleration:)]) {
            [self.delegate onPushSetting:self enableHWAcceleration:switchBtn.on];
        }
        
    } else if (switchBtn.tag == TAG_AUDIO_PREVIEW) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPushSetting:enableAudioPreview:)]) {
            [self.delegate onPushSetting:self enableAudioPreview:switchBtn.on];
        }
        
    }
}

- (NSString *)getQualityStr {
    TX_Enum_Type_VideoQuality quality = [PushSettingViewController getVideoQuality];
    for (PushSettingQuality *q in _qualities) {
        if (q.value == quality) {
            return q.title;
        }
    }

    return _qualities.firstObject.title;
}

- (NSString *)getReverbStr {
    static NSArray *arr = nil;
    if (arr == nil) {
        arr = [NSArray arrayWithObjects:@"关闭混响", @"KTV", @"小房间", @"大会堂", @"低沉", @"洪亮", @"金属声", @"磁性", nil];
    }
    
    NSInteger index = [PushSettingViewController getReverbType];
    if (index < arr.count && index >= 0) {
        return arr[index];
    }
    
    return arr[0];
}

- (NSString *)getVoiceChangerStr {
    static NSArray *arr = nil;
    if (arr == nil) {
        arr = [NSArray arrayWithObjects:@"关闭变声", @"熊孩子", @"萝莉", @"大叔", @"重金属", @"感冒",
               @"外国人", @"困兽", @"死肥仔", @"强电流", @"重机械", @"空灵", nil];
    }
    
    NSInteger index = [PushSettingViewController getVoiceChangerType];
    if (index < arr.count && index >= 0) {
        return arr[index];
    }
    
    return arr[0];
}

+ (UIView *)buildAccessoryView {
    return [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow"]];
}

- (void)_showQualityActionSheet {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"画质"
                                                                        message:nil
                                                                 preferredStyle:UIAlertControllerStyleActionSheet];
    __weak __typeof(self) wself = self;
    for (PushSettingQuality *q in _qualities) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:q.title
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
            __strong __typeof(wself) self = wself; if (nil == self) return;
            [PushSettingViewController saveSetting:TAG_QUALITY value:q.value];
            id<PushSettingDelegate> delegate = self.delegate;
            if ([delegate respondsToSelector:@selector(onPushSetting:videoQuality:)]) {
                [delegate onPushSetting:self videoQuality:q.value];
            }
            [self.mainTableView reloadData];
        }];
        [controller addAction:action];
    }
    [controller addAction:[UIAlertAction actionWithTitle:@"取消"
                                                   style:UIAlertActionStyleCancel
                                                 handler:nil]];
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - UITableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 40)];

    if (indexPath.section == SECTION_QUALITY) {
        cell.textLabel.text = [self getQualityStr];
        cell.accessoryView = [PushSettingViewController buildAccessoryView];
    } else if (indexPath.section == SECTION_REVERB) {
        cell.textLabel.text = [self getReverbStr];
        cell.accessoryView = [PushSettingViewController buildAccessoryView];
    } else if (indexPath.section == SECTION_VOICE_CHANGER) {
        cell.textLabel.text = [self getVoiceChangerStr];
        cell.accessoryView = [PushSettingViewController buildAccessoryView];
    } else if (indexPath.section == SECTION_BANDWIDTH_ADJUST) {
        cell.textLabel.text = @"开启带宽适应";
        cell.accessoryView = _bandwidthSwitch;
    } else if (indexPath.section == SECTION_HW) {
        cell.textLabel.text = @"开启硬件加速";
        cell.accessoryView = _hwSwitch;
    } else if (indexPath.section == SECTION_AUDIO_PREVIEW) {
        cell.textLabel.text = @"开启耳返";
        cell.accessoryView = _audioPreviewSwitch;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == SECTION_QUALITY) {
        return @"画质偏好";
    }
    if (section == SECTION_REVERB) {
        return @"混响";
    }
    if (section == SECTION_VOICE_CHANGER) {
        return @"变声";
    }
    
    return @"";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == SECTION_QUALITY) {
        [self _showQualityActionSheet];
    } else if (indexPath.section == SECTION_REVERB) {
        _actionSheet = [[UIActionSheet alloc] initWithTitle:@"混响" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil
                                          otherButtonTitles:@"关闭混响", @"KTV", @"小房间", @"大会堂", @"低沉", @"洪亮", @"金属声", @"磁性", nil];
        _actionSheet.tag = TAG_REVERB;
        _actionSheet.actionSheetStyle = UIBarStyleDefault;
        [_actionSheet showInView:self.view];
        
    } else if (indexPath.section == SECTION_VOICE_CHANGER) {
        _actionSheet = [[UIActionSheet alloc] initWithTitle:@"变声" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil
                                          otherButtonTitles:@"关闭变声", @"熊孩子", @"萝莉", @"大叔", @"重金属", @"感冒",
                                                    @"外国人", @"困兽", @"死肥仔", @"强电流", @"重机械", @"空灵", nil];
        _actionSheet.tag = TAG_VOICE_CHANGER;
        _actionSheet.actionSheetStyle = UIBarStyleDefault;
        [_actionSheet showInView:self.view];
    }
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex < 0 || buttonIndex >= actionSheet.numberOfButtons - 1) {
        return;
    }
    
    if (actionSheet.tag == TAG_REVERB) {
        NSInteger reverbType = buttonIndex;
        [PushSettingViewController saveSetting:TAG_REVERB value:reverbType];
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPushSetting:reverbType:)]) {
            [self.delegate onPushSetting:self reverbType:reverbType];
        }
        
    } else if (actionSheet.tag == TAG_VOICE_CHANGER) {
        NSInteger voiceChangerType = buttonIndex;
        [PushSettingViewController saveSetting:TAG_VOICE_CHANGER value:voiceChangerType];
        if (self.delegate && [self.delegate respondsToSelector:@selector(onPushSetting:voiceChangerType:)]) {
            [self.delegate onPushSetting:self voiceChangerType:voiceChangerType];
        }
    }
    
    [_mainTableView reloadData];
}

#pragma mark - 读写配置文件

+ (NSString *)getKey:(NSInteger)tag {
    return [NSString stringWithFormat:@"PUSH_SETTING_%ld", tag];
}

+ (void)saveSetting:(NSInteger)tag value:(NSInteger)value {
    NSString *key = [PushSettingViewController getKey:tag];
    [[NSUserDefaults standardUserDefaults] setObject:@(value) forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)getBandWidthAdjust {
    NSString *key = [PushSettingViewController getKey:TAG_BANDWIDTH_ADJUST];
    NSNumber *d = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (d != nil) {
        return [d intValue];
    }
    return NO;
}

+ (BOOL)getEnableHWAcceleration {
    NSString *key = [PushSettingViewController getKey:TAG_HW];
    NSNumber *d = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (d != nil) {
        return [d intValue];
    }
    return YES;
}

+ (BOOL)getEnableAudioPreview {
    NSString *key = [PushSettingViewController getKey:TAG_AUDIO_PREVIEW];
    NSNumber *d = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (d != nil) {
        return [d intValue];
    }
    return NO;
}

+ (TX_Enum_Type_VideoQuality)getVideoQuality {
    NSString *key = [PushSettingViewController getKey:TAG_QUALITY];
    NSNumber *d = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (d != nil) {
        return [d intValue];
    }
    return VIDEO_QUALITY_SUPER_DEFINITION;
}

+ (TXReverbType)getReverbType {
    NSString *key = [PushSettingViewController getKey:TAG_REVERB];
    NSNumber *d = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (d != nil) {
        return [d intValue];
    }
    return REVERB_TYPE_0;
}

+ (TXVoiceChangerType)getVoiceChangerType {
    NSString *key = [PushSettingViewController getKey:TAG_VOICE_CHANGER];
    NSNumber *d = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (d != nil) {
        return [d intValue];
    }
    return VOICECHANGER_TYPE_0;
}

@end
