//
//  TXCAudioCustomRecorder.h
//  TXLiteAVDemo_Professional
//
//  Created by realingzhou on 2018/1/15.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#ifndef TXCAudioCustomRecorder_h
#define TXCAudioCustomRecorder_h

@protocol TXCAudioCustomRecorderDelegate

- (void)onRecordPcm:(NSData *)pcmData;

@end

#import <UIKit/UIKit.h>

@interface TXCAudioCustomRecorder : NSObject

@property(nonatomic, strong)id<TXCAudioCustomRecorderDelegate> delegate;

+ (instancetype) sharedInstance;

- (void)startRecord:(int)sampleRate nChannels:(int)channels nSampleLen:(int)sampleLen;

- (void)stopRecord;

- (void)setAudioSession;

- (void)sendPcmData:(unsigned char *)pcmData len:(int)pcmDataLen;

@end

#endif /* TXCAudioCustomRecorder_h */
