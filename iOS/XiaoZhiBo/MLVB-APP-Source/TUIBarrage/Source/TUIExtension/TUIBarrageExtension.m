//
//  TUIBarrageExtension.m
//  TUIGiftView
//
//  Created by WesleyLei on 2021/9/28.
//

#import "TUIBarrageExtension.h"
#import "TUICore.h"
#import "TUIDefine.h"
#import "TUIBarrageLocalized.h"
#import "TUIBarrageSendPlugView.h"
#import "TUIBarrageDisplayView.h"
@interface TUIBarrageExtension () <TUIExtensionProtocol>
@property(nonatomic, strong) NSMapTable *extensions;
@end

@implementation TUIBarrageExtension

+ (void)load {
    [TUICore registerExtension:TUICore_TUIBarrageExtension_GetEnterBtn object:[TUIBarrageExtension shareInstance]];
    [TUICore registerExtension:TUICore_TUIBarrageExtension_GetTUIBarrageSendView object:[TUIBarrageExtension shareInstance]];
    [TUICore registerExtension:TUICore_TUIBarrageExtension_TUIBarrageDisplayView object:[TUIBarrageExtension shareInstance]];
}

+ (TUIBarrageExtension *)shareInstance {
    static dispatch_once_t onceToken;
    static TUIBarrageExtension * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[TUIBarrageExtension alloc] init];
    });
    return g_sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.extensions = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory capacity:2];
    }
    return self;
}

#pragma mark - TUIExtensionProtocol
- (NSDictionary *)getExtensionInfo:(NSString *)key param:(nullable NSDictionary *)param {
    if ([key isEqualToString:TUICore_TUIBarrageExtension_GetEnterBtn]) {
        return @{TUICore_TUIBarrageExtension_GetEnterBtn:[TUIBarrageExtension getEnterButton]};
    } else if ([key isEqualToString:TUICore_TUIBarrageExtension_GetTUIBarrageSendView]) {
        if ([param isKindOfClass:[NSDictionary class]]) {
            NSString *frameStr = param[@"frame"];
            NSString *groupId = param[@"groupId"];
            CGRect frame = CGRectZero;
            if ([frameStr isKindOfClass:[NSString class]]) {
                frame = CGRectFromString(frameStr);
            }
            if ([groupId isKindOfClass:[NSString class]]) {
                TUIBarrageSendPlugView *plugView = [[TUIBarrageSendPlugView alloc]initWithFrame:frame groupId:groupId];
                return @{TUICore_TUIBarrageExtension_GetTUIBarrageSendView:plugView};
            }
        }
        
    } else if ([key isEqualToString:TUICore_TUIBarrageExtension_TUIBarrageDisplayView]) {
        if ([param isKindOfClass:[NSDictionary class]]) {
            NSString *frameStr = param[@"frame"];
            NSString *groupId = param[@"groupId"];
            CGRect frame = CGRectZero;
            if ([frameStr isKindOfClass:[NSString class]]) {
                frame = CGRectFromString(frameStr);
            }
            if ([groupId isKindOfClass:[NSString class]]) {
                TUIBarrageDisplayView *displayView = [[TUIBarrageDisplayView alloc]initWithFrame:frame groupId:groupId];
                displayView.backgroundColor = [UIColor clearColor];
                [TUIBarrageExtension setDisplayViewByGroupId:displayView groupId:groupId];
                return @{TUICore_TUIBarrageExtension_TUIBarrageDisplayView:displayView};
            }
        }
    }
    return nil;
}

+ (TUIBarrageDisplayBaseView *)getDisplayViewByGroupId:(NSString *)groupId{
    return [[TUIBarrageExtension shareInstance].extensions objectForKey:groupId];
}

+ (void)setDisplayViewByGroupId:(TUIBarrageDisplayBaseView *)displayView groupId:(NSString *)groupId {
    if (displayView && groupId) {
        [[TUIBarrageExtension shareInstance].extensions setObject:displayView forKey:groupId];
    }
}

+ (UIButton *)getEnterButton {
    UIButton *enterButton = [[UIButton alloc] init];
    [enterButton setImage:[UIImage imageNamed:@"barrage_enter_icon" inBundle:TUIBarrageBundle() compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [enterButton sizeToFit];
    return enterButton;
}
@end
