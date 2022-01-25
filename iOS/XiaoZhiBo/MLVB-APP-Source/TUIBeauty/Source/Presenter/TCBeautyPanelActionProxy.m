//
//  TCBeautyPanelActionProxy.m
//  TCBeautyPanel
//
//  Created by cui on 2019/12/23.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TCBeautyPanelActionProxy.h"

@implementation TCBeautyPanelActionProxy

+ (instancetype)proxyWithBeautyManager:(id)beautyManager {
    return [[TCBeautyPanelActionProxy alloc] initWithBeautyManager:beautyManager];
}

- (instancetype)initWithBeautyManager:(id)beaubyManager {
    if (![beaubyManager isKindOfClass:NSClassFromString(@"TXBeautyManager")]) {
        NSLog(@"%s failed, type mismatch of object.getBeautyManager(%@)", __PRETTY_FUNCTION__, beaubyManager);
        return nil;
    }
    _beautyManager = beaubyManager;
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    if ([_beautyManager respondsToSelector:sel]) {
        return [_beautyManager methodSignatureForSelector:sel];
    }
    return [super methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    SEL selector = invocation.selector;
    if ([_beautyManager respondsToSelector: selector]) {
        [invocation invokeWithTarget:_beautyManager];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([_beautyManager respondsToSelector:aSelector]) {
        return YES;
    }
    return NO;
}

@end
