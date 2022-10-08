//
//  ThirdBeautyTencentEffectViewController.m
//  MLVB-API-Example-OC
//
//  Created by summer on 2022/5/11.
//  Copyright © 2022 Tencent. All rights reserved.
//

/*
 第三方美颜功能示例
 接入步骤：
 第一步：集成腾讯特效SDK并拷贝资源（可参考腾讯特效提供的接入文档：https://cloud.tencent.com/document/product/616/65887 ）
 第二步：腾讯特效SDK的鉴权与初始化,详见[self setupBeautySDK],License获取请参考 {https://cloud.tencent.com/document/product/616/65878}
 第三步：在MLVB中使用腾讯特效美颜，详见[self onProcessVideoFrame]中的[self processVideoFrameWithTextureId]方法
 - 开启自定义视频处理 API: [self.livePusher enableCustomVideoProcess:true pixelFormat:V2TXLivePixelFormatNV12 bufferType:V2TXLiveBufferTypePixelBuffer]
 - 在 [self.livePusher enableCustomVideoProcess] 回调方法中使用第三方美颜处理视频数据，详见API说明文档 {https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloudListener__android.html#a22afb08b2a1a18563c7be28c904b166a}
 
 注意：腾讯特效提供的 License 与 applicationId 一一对应的，测试过程中需要修改 applicationId 为 License对应的applicationId
 
 
 Access steps：
 First step：Integrate Tencent Effect SDK and copy resources（You can refer to the access document provided by Tencent Effects：https://cloud.tencent.com/document/product/616/65888）
 Second step：Authentication and initialization of Tencent Effect SDK,
 see details[self setupBeautySDK],to obtain the license, please refer to {https://cloud.tencent.com/document/product/616/65878}
 Third step：Using Tencent Effect in MLVB，see details[self onProcessVideoFrame]
 - Enable custom video processing: [self.livePusher enableCustomVideoProcess:true pixelFormat:V2TXLivePixelFormatNV12 bufferType:V2TXLiveBufferTypePixelBuffer]
 - For how to use third-party beauty filters to process video data in the [self.livePusher enableCustomVideoProcess] callback, see the API document {https://liteav.sdk.qcloud.com/doc/api/zh-cn/group__TRTCCloudListener__android.html#a22afb08b2a1a18563c7be28c904b166a}.
 Note：The applicationId and License provided by Tencent Effects are in one-to-one correspondence.
 During the test process, the applicationId needs to be modified to the applicationId corresponding to the License.
 */

#import "ThirdBeautyTencentEffectViewController.h"
//#import "XMagic.h"
//#import "TELicenseCheck.h"

@interface ThirdBeautyTencentEffectViewController () <V2TXLivePusherObserver>
@property (weak, nonatomic) IBOutlet UILabel *setBeautyLabel;
@property (weak, nonatomic) IBOutlet UILabel *beautyNumLabel;
@property (weak, nonatomic) IBOutlet UISlider *setBeautySlider;

@property (weak, nonatomic) IBOutlet UILabel *streamIdLabel;
@property (weak, nonatomic) IBOutlet UITextField *streamIdTextField;

@property (weak, nonatomic) IBOutlet UIButton *startPushStreamButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (strong, nonatomic) V2TXLivePusher *livePusher;
//@property (nonatomic, strong) XMagic *xMagicKit;

@property (nonatomic, assign) CGSize renderSize;

@end

@implementation ThirdBeautyTencentEffectViewController



- (V2TXLivePusher *)livePusher {
    if (!_livePusher) {
        _livePusher = [[V2TXLivePusher alloc] initWithLiveMode:V2TXLiveMode_RTC];
        [_livePusher setObserver:self];
    }
    return _livePusher;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDefaultUIConfig];
    [self addKeyboardObserver];
}

- (void)viewDidAppear:(BOOL)animated {
    [self setupBeautySDK];
}

- (void)setupDefaultUIConfig {
    self.streamIdTextField.text = [NSString generateRandomStreamId];
    
    self.streamIdLabel.text = localize(@"MLVB-API-Example.ThirdBeauty.streamIdInput");
    self.streamIdLabel.adjustsFontSizeToFitWidth = true;
    self.startPushStreamButton.backgroundColor = [UIColor themeBlueColor];
    [self.startPushStreamButton setTitle:localize(@"MLVB-API-Example.ThirdBeauty.startPush") forState:UIControlStateNormal];
    [self.startPushStreamButton setTitle:localize(@"MLVB-API-Example.ThirdBeauty.stopPush") forState:UIControlStateSelected];
    
    self.setBeautyLabel.text = localize(@"MLVB-API-Example.ThirdBeauty.beautyLevel");
    NSInteger value = self.setBeautySlider.value * 6;
    self.beautyNumLabel.text = [NSString stringWithFormat:@"%ld",value];
}

- (void)setupBeautySDK {
    //    _renderSize = CGSizeZero;
    //    [TELicenseCheck setTELicense:LicenseURL key:LicenseKey completion:^(NSInteger authresult, NSString * _Nonnull errorMsg) {
    //        if (authresult == TELicenseCheckOk) {
    //            [self buildBeautySDK];
    //        } else {
    //            NSLog(@"XMagic 授权失败");
    //        }
    //    }];
}

- (void)buildBeautySDK {
    //    NSString *beautyConfigPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //    beautyConfigPath = [beautyConfigPath stringByAppendingPathComponent:@"your beauty json"];
    //    NSFileManager *localFileManager=[[NSFileManager alloc] init];
    //    BOOL isDir = YES;
    //    NSDictionary * beautyConfigJson = @{};
    //    if ([localFileManager fileExistsAtPath:beautyConfigPath isDirectory:&isDir] && !isDir) {
    //        NSString *beautyConfigJsonStr = [NSString stringWithContentsOfFile:beautyConfigPath encoding:NSUTF8StringEncoding error:nil];
    //        NSError *jsonError;
    //        NSData *objectData = [beautyConfigJsonStr dataUsingEncoding:NSUTF8StringEncoding];
    //        beautyConfigJson = [NSJSONSerialization JSONObjectWithData:objectData
    //                                                           options:NSJSONReadingMutableContainers
    //                                                             error:&jsonError];
    //    }
    //    NSDictionary *assetsDict = @{@"core_name":@"LightCore.bundle",
    //                                 @"root_path":[[NSBundle mainBundle] bundlePath],
    //                                 @"plugin_3d":@"Light3DPlugin.bundle",
    //                                 @"plugin_hand":@"LightHandPlugin.bundle",
    //                                 @"plugin_segment":@"LightSegmentPlugin.bundle",
    //
    //                                 @"beauty_config":beautyConfigJson
    //    };
    //    self.xMagicKit = [[XMagic alloc] initWithRenderSize:_renderSize assetsDict:assetsDict];
}

//- (int)processVideoFrameWithTextureId:(int)textureId textureWidth:(int)textureWidth textureHeight:(int)textureHeight {
//    if (textureWidth != _renderSize.width || textureHeight != _renderSize.height) {
//        _renderSize = CGSizeMake(textureWidth, textureHeight);
//        [self.xMagicKit setRenderSize:_renderSize];
//    }
//    YTProcessInput *input = [[YTProcessInput alloc] init];
//    input.textureData = [[YTTextureData alloc] init];
//    input.textureData.texture = textureId;
//    input.textureData.textureWidth = textureWidth;
//    input.textureData.textureHeight = textureHeight;
//    input.dataType = kYTTextureData;
//    YTProcessOutput *output = [self.xMagicKit process:input withOrigin:YtLightImageOriginTopLeft withOrientation:YtLightCameraRotation0];
//    return output.textureData.texture;
//}

- (void)startPush:(NSString*)streamId {
    self.title = streamId;
    [self.livePusher setRenderView:self.view];
    [self.livePusher startCamera:true];
    [self.livePusher startMicrophone];
    
    [self.livePusher enableCustomVideoProcess:true pixelFormat:V2TXLivePixelFormatTexture2D bufferType:V2TXLiveBufferTypeTexture];
    
    [self.livePusher startPush:[URLUtils generateTRTCPushUrl:streamId]];
}

- (void)stopPush {
    [self.livePusher stopCamera];
    [self.livePusher stopMicrophone];
    [self.livePusher stopPush];
}

#pragma mark - IBActions
- (IBAction)onPushStreamClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self startPush:self.streamIdTextField.text];
    } else {
        [self stopPush];
    }
}

#pragma mark - Slider ValueChange
- (IBAction)setBeautySliderValueChange:(UISlider *)sender {
    //    NSDictionary *extraInfo = [NSDictionary dictionary];
    //    [self.xMagicKit configPropertyWithType:@"beauty" withName:@"beauty.ruddy" withData:[NSString stringWithFormat:@"%f",sender.value] withExtraInfo:extraInfo];
    NSInteger value = sender.value * 6;
    self.beautyNumLabel.text = [NSString stringWithFormat:@"%ld",value];
}

#pragma mark - V2TXLivePusherObserver
- (void)onProcessVideoFrame:(V2TXLiveVideoFrame *)srcFrame dstFrame:(V2TXLiveVideoFrame *)dstFrame {
    //    dstFrame.textureId=[self processVideoFrameWithTextureId:srcFrame.textureId textureWidth:srcFrame.width textureHeight:srcFrame.height];
    dstFrame.textureId = srcFrame.textureId;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:true];
}

- (void)dealloc {
    //    if (_xMagicKit) {
    //        [_xMagicKit deinit];
    //        _xMagicKit = nil;
    //    }
    [self removeKeyboardObserver];
}

#pragma mark - Notification
- (void)addKeyboardObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeKeyboardObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (BOOL)keyboardWillShow:(NSNotification *)noti {
    CGFloat animationDuration = [[[noti userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyboardBounds = [[[noti userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:animationDuration animations:^{
        self.bottomConstraint.constant = keyboardBounds.size.height;
    }];
    return YES;
}

- (BOOL)keyboardWillHide:(NSNotification *)noti {
    CGFloat animationDuration = [[[noti userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:animationDuration animations:^{
        self.bottomConstraint.constant = 25;
    }];
    return YES;
}


@end
