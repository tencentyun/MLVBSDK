//
//  PixelBufferRenderView.m
//  TRTC-API-Example-OC
//
//  Created by luoming on 2021/4/30.
//

#import "PixelBufferRenderView.h"

@interface PixelBufferRenderView ()

@property(strong, nonatomic) AVSampleBufferDisplayLayer *sampleBufferDisplayLayer;

@end

@implementation PixelBufferRenderView

- (AVSampleBufferDisplayLayer *)sampleBufferDisplayLayer {
    if (!_sampleBufferDisplayLayer) {
        _sampleBufferDisplayLayer = [AVSampleBufferDisplayLayer new];
    }
    return _sampleBufferDisplayLayer;
}
- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self setupSampleBufferDisplayLayer];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSampleBufferDisplayLayer];
    }
    return self;
}

- (void)setupSampleBufferDisplayLayer {
    [self.layer addSublayer:self.sampleBufferDisplayLayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.sampleBufferDisplayLayer.frame = self.layer.bounds;
}

- (void)renderPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    CMVideoFormatDescriptionRef videoInfo = NULL;
    OSStatus status = CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuffer, &videoInfo);
    if (status != 0) {
        NSLog(@"CMVideoFormatDescriptionCreateForImageBuffer fail %d", status);
        return;
    }

    CMSampleBufferRef sampleBuffer = NULL;
    CMSampleTimingInfo timing = kCMTimingInfoInvalid;
    status = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, true, NULL, NULL,
                                                videoInfo, &timing, &sampleBuffer);
    CFRelease(videoInfo);
    if (status != 0) {
        NSLog(@"CMSampleBufferCreateForImageBuffer fail %d", status);
        return;
    }
    CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, YES);
    CFMutableDictionaryRef d = (CFMutableDictionaryRef)CFArrayGetValueAtIndex(attachments, 0);
    CFDictionarySetValue(d, kCMSampleAttachmentKey_DisplayImmediately, kCFBooleanTrue);

    [self.sampleBufferDisplayLayer enqueueSampleBuffer:sampleBuffer];
    CFRelease(sampleBuffer);
}

@end
