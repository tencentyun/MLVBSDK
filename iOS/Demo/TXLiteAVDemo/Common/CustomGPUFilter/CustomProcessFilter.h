//
//  CustomProcessFilter.h
//  DeviceManageIOSApp
//
//  Created by annidyfeng on 2017/3/21.
//  Copyright © 2017年 tencent. All rights reserved.
//
#import <UIKit/UIKit.h>
#include <OpenGLES/gltypes.h>

@interface CustomProcessFilter : NSObject

- (GLuint)renderToTextureWithSize:(CGSize)fboSize sourceTexture:(GLuint)sourceTexture;
- (void)destroyFramebuffer;

@end
