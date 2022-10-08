## 示例代码

## 画中画功能

### iOS 平台(需要iOS15及以上支持)

1. 首先需要开启后台模式:
 ![](https://qcloudimg.tencent-cloud.cn/raw/5f757cbcce02e4e555826b16e3eaa3b2.png)
 
2. 初始化SDK的`V2TXLivePlayer`实例对象并开启自定义渲染和后台解码能力。

``` objc
	/// 开启自定义渲染接口
	[_livePlayer enableObserveVideoFrame:YES pixelFormat:V2TXLivePixelFormatNV12 bufferType:V2TXLiveBufferTypePixelBuffer];
    /// 开启后台解码能力
	[_livePlayer setProperty:@"enableBackgroundDecoding" value:@(YES)];
```

3. 判断是否支持开启画中画功能，在支持的前提下，创建画中画内容源和画中画控制器。

``` objc
	 if (@available(iOS 15.0, *)) {
		if ([AVPictureInPictureController isPictureInPictureSupported]) {
			//开启画中画后台声音权限
			NSError *error = nil;
			[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
			[[AVAudioSession sharedInstance] setActive:YES error:nil];
			if (error) {
				NSLog(@"%@%@",Localize(@"MLVB-API-Example.Home.PermissionFailed"),error);
			}          
			/// 创建视频渲染层AVSampleBufferDisplayLayer
			[self setupSampleBufferDisplayLayer];
			[self.view.layer addSublayer:self.sampleBufferDisplayLayer];
			/// 初始化画中画内容源
			AVPictureInPictureControllerContentSource *contentSource = [[AVPictureInPictureControllerContentSource alloc] initWithSampleBufferDisplayLayer:self.sampleBufferDisplayLayer playbackDelegate:self];
			/// 初始化画中画控制器
			self.pipViewController = [[AVPictureInPictureController alloc] initWithContentSource:contentSource];
			self.pipViewController.delegate = self;
			self.pipViewController.canStartPictureInPictureAutomaticallyFromInline = YES;
		}
	}
```

4. 开始拉流后，在自定义渲染的SDK回调内处理视频帧，将视频帧（CVPixelBuffer）转为（CMSampleBuffer）送给AVSampleBufferDisplayLayer进行渲染。


``` objc 
- (void)onRenderVideoFrame:(id<V2TXLivePlayer>)player frame:(V2TXLiveVideoFrame *)videoFrame {
    /// 画中画功能需要拿到视频的pixelBuffer格式数据
    if (videoFrame.bufferType != V2TXLiveBufferTypeTexture && videoFrame.pixelFormat != V2TXLivePixelFormatTexture2D) {
        [self dispatchPixelBuffer:videoFrame.pixelBuffer];
    }
}

//把pixelBuffer包装成samplebuffer送给displayLayer
- (void)dispatchPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    if (!pixelBuffer) {
        return;
    }
    //不设置具体时间信息
    CMSampleTimingInfo timing = {kCMTimeInvalid, kCMTimeInvalid, kCMTimeInvalid};
    //获取视频信息
    CMVideoFormatDescriptionRef videoInfo = NULL;
    OSStatus result = CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuffer, &videoInfo);
    NSParameterAssert(result == 0 && videoInfo != NULL);
    
    CMSampleBufferRef sampleBuffer = NULL;
    result = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault,pixelBuffer, true, NULL, NULL, videoInfo, &timing, &sampleBuffer);
    NSParameterAssert(result == 0 && sampleBuffer != NULL);
    CFRelease(videoInfo);
    CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, YES);
    CFMutableDictionaryRef dict = (CFMutableDictionaryRef)CFArrayGetValueAtIndex(attachments, 0);
    CFDictionarySetValue(dict, kCMSampleAttachmentKey_DisplayImmediately, kCFBooleanTrue);
    [self enqueueSampleBuffer:sampleBuffer toLayer:self.sampleBufferDisplayLayer];
    CFRelease(sampleBuffer);
}
```

5. 开启/关闭画中画功能


``` objc
	//在点击画中画按钮的时候 开启画中画
	if (self.pipViewController.isPictureInPictureActive) {
		[self.pipViewController stopPictureInPicture];
	} else {
		[self.pipViewController startPictureInPicture];
	}
```
至此，即实现了iOS平台的画中画功能，具体的实例代码请参考API-Example 工程内的PictureInPictureViewController.m文件。