//
//  CustomProcessFilter.m
//  DeviceManageIOSApp
//
//  Created by annidyfeng on 2017/3/21.
//  Copyright © 2017年 tencent. All rights reserved.
//

#import "CustomProcessFilter.h"
#import <GPUImage/GPUImageFilter.h>

NSString *const kCustomProcessInvertVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 varying vec2 textureCoordinate;
 
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
 }
 );

NSString *const kCustomProcessInvertFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     
     gl_FragColor = vec4((1.0 - textureColor.rgb), textureColor.w);
 }
 );

@interface CustomProcessFilter()
@property CGSize size;
@property GLuint texture;
@property GPUTextureOptions textureOptions;
@end

@implementation CustomProcessFilter
{
    GLuint framebuffer;
    CVPixelBufferRef renderTarget;
    CVOpenGLESTextureRef renderTexture;
    GLProgram *filterProgram;
    GLint filterPositionAttribute, filterTextureCoordinateAttribute;
    GLint filterInputTextureUniform;
}


- (id)init {
    self = [super init];
    if (self) {
        filterProgram = [[GLProgram alloc] initWithVertexShaderString:kCustomProcessInvertVertexShaderString fragmentShaderString:kCustomProcessInvertFragmentShaderString];
        if (!filterProgram.initialized)
        {
            [self initializeAttributes];
            
            if (![filterProgram link])
            {
                NSString *progLog = [filterProgram programLog];
                NSLog(@"Program link log: %@", progLog);
                NSString *fragLog = [filterProgram fragmentShaderLog];
                NSLog(@"Fragment shader compile log: %@", fragLog);
                NSString *vertLog = [filterProgram vertexShaderLog];
                NSLog(@"Vertex shader compile log: %@", vertLog);
                filterProgram = nil;
                NSAssert(NO, @"Filter shader link failed");
            }
        }
        
        filterPositionAttribute = [filterProgram attributeIndex:@"position"];
        filterTextureCoordinateAttribute = [filterProgram attributeIndex:@"inputTextureCoordinate"];
        filterInputTextureUniform = [filterProgram uniformIndex:@"inputImageTexture"]; // This does assume a name of "inputImageTexture" for the fragment shader
        
        [filterProgram use];
        
        glEnableVertexAttribArray(filterPositionAttribute);
        glEnableVertexAttribArray(filterTextureCoordinateAttribute);
        
        GPUTextureOptions defaultTextureOptions;
        defaultTextureOptions.minFilter = GL_LINEAR;
        defaultTextureOptions.magFilter = GL_LINEAR;
        defaultTextureOptions.wrapS = GL_CLAMP_TO_EDGE;
        defaultTextureOptions.wrapT = GL_CLAMP_TO_EDGE;
        defaultTextureOptions.internalFormat = GL_RGBA;
        defaultTextureOptions.format = GL_BGRA;
        defaultTextureOptions.type = GL_UNSIGNED_BYTE;
        self.textureOptions = defaultTextureOptions;
    }
    return self;
}

- (void)initializeAttributes;
{
    [filterProgram addAttribute:@"position"];
    [filterProgram addAttribute:@"inputTextureCoordinate"];
    
    // Override this, calling back to this super method, in order to add new attributes to your vertex shader
}

- (void)generateTexture;
{
    glActiveTexture(GL_TEXTURE1);
    glGenTextures(1, &_texture);
    glBindTexture(GL_TEXTURE_2D, _texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, _textureOptions.minFilter);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, _textureOptions.magFilter);
    // This is necessary for non-power-of-two textures
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, _textureOptions.wrapS);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, _textureOptions.wrapT);
    
    // TODO: Handle mipmaps
}

- (void)createDataFBO;
{
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    
    {
        [self generateTexture];
        
        glBindTexture(GL_TEXTURE_2D, _texture);
        
        glTexImage2D(GL_TEXTURE_2D, 0, _textureOptions.internalFormat, (int)_size.width, (int)_size.height, 0, _textureOptions.format, _textureOptions.type, 0);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _texture, 0);
        
    }
    
#ifndef NS_BLOCK_ASSERTIONS
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    NSAssert(status == GL_FRAMEBUFFER_COMPLETE, @"Incomplete filter FBO: %d", status);
#endif
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
}


- (void)setFilterFBO:(CGSize)size;
{
    _size = size;
    if (!framebuffer)
    {
        [self createDataFBO];
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    
    glViewport(0, 0, (int)_size.width, (int)_size.height);
}

- (void)destroyFramebuffer;
{
    if (framebuffer)
    {
        glDeleteFramebuffers(1, &framebuffer);
        framebuffer = 0;
    }
    
    {
        glDeleteTextures(1, &_texture);
    }
}

- (GLuint)renderToTextureWithSize:(CGSize)fboSize sourceTexture:(GLuint)sourceTexture;
{
    
    [filterProgram use];
    [self setFilterFBO:fboSize];
    
    //    [self setUniformsForProgramAtIndex:0];
    
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, sourceTexture);
    
    glUniform1i(filterInputTextureUniform, 2);
    
    static const GLfloat imageVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    static const GLfloat noRotationTextureCoordinates[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
    };
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, imageVertices);
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, noRotationTextureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    return _texture;
    
}

@end

