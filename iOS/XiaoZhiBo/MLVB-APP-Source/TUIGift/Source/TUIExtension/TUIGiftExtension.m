//
//  TUIGiftExtension.m
//  TUIGiftView
//
//  Created by WesleyLei on 2021/9/28.
//

#import "TUIGiftExtension.h"
#import "TUICore.h"
#import "TUIDefine.h"
#import "TUIGiftLocalized.h"
#import "TUIGiftListPanelPlugView.h"
#import "TUIGiftPlayView.h"

@interface TUIGiftExtension () <TUIExtensionProtocol, TUIServiceProtocol>

@property(nonatomic, strong) NSMapTable *extensions;

@end

@implementation TUIGiftExtension

+ (void)load {
    [TUICore registerExtension:TUICore_TUIGiftExtension_GetEnterBtn object:[TUIGiftExtension shareInstance]];
    [TUICore registerExtension:TUICore_TUIGiftExtension_GetLikeBtn object:[TUIGiftExtension shareInstance]];
    [TUICore registerExtension:TUICore_TUIGiftExtension_GetTUIGiftListPanel object:[TUIGiftExtension shareInstance]];
    [TUICore registerExtension:TUICore_TUIGiftExtension_GetTUIGiftPlayView object:[TUIGiftExtension shareInstance]];
    
    // service注册
    [TUICore registerService:TUICore_TUIGiftService object:[TUIGiftExtension shareInstance]];
}

+ (TUIGiftExtension *)shareInstance {
    static dispatch_once_t onceToken;
    static TUIGiftExtension * g_sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        g_sharedInstance = [[TUIGiftExtension alloc] init];
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

#pragma mark - TUIServiceProtocol
- (id)onCall:(NSString *)method param:(NSDictionary *)param {
    if ([method isEqualToString:TUICore_TUIGiftService_SendLikeMethod]) {
        NSString *groupId = param[@"groupId"];
        if (groupId && [groupId isKindOfClass:[NSString class]] && groupId.length > 0) {
            TUIGiftListPanelPlugView *plugView = [TUIGiftExtension getPlugViewByGroupId:groupId];
            if (plugView) {
                [plugView sendLike];
            }
        }
    }
    return nil;
}

#pragma mark - TUIExtensionProtocol
- (NSDictionary *)getExtensionInfo:(NSString *)key param:(nullable NSDictionary *)param {
    if ([key isEqualToString:TUICore_TUIGiftExtension_GetEnterBtn]) {
        return @{TUICore_TUIGiftExtension_GetEnterBtn:[TUIGiftExtension getEnterButton]};
    } else if ([key isEqualToString:TUICore_TUIGiftExtension_GetTUIGiftListPanel]) {
        if ([param isKindOfClass:[NSDictionary class]]) {
            NSString *frameStr = param[@"frame"];
            NSString *groupId = param[@"groupId"];
            CGRect frame = CGRectZero;
            if ([frameStr isKindOfClass:[NSString class]]) {
                frame = CGRectFromString(frameStr);
            }
            if([groupId isKindOfClass:[NSString class]]){
                TUIGiftListPanelPlugView *plugView = [[TUIGiftListPanelPlugView alloc]initWithFrame:frame groupId:groupId];
                [TUIGiftExtension setPlugViewByGroupId:plugView groupId:groupId];
                return @{TUICore_TUIGiftExtension_GetTUIGiftListPanel:plugView};
            }
        }
    } else if ([key isEqualToString:TUICore_TUIGiftExtension_GetTUIGiftPlayView]) {
        if ([param isKindOfClass:[NSDictionary class]]) {
            NSString *frameStr = param[@"frame"];
            NSString *groupId = param[@"groupId"];
            CGRect frame = CGRectZero;
            if ([frameStr isKindOfClass:[NSString class]]) {
                frame = CGRectFromString(frameStr);
            }
            if([groupId isKindOfClass:[NSString class]]){
                TUIGiftPlayView *playView = [[TUIGiftPlayView alloc]initWithFrame:frame groupId:groupId];
                [TUIGiftExtension setPlayViewByGroupId:playView groupId:groupId];
                return @{TUICore_TUIGiftExtension_GetTUIGiftPlayView:playView};
            }
        }
    } else if ([key isEqualToString:TUICore_TUIGiftExtension_GetLikeBtn]) {
        return @{TUICore_TUIGiftExtension_GetLikeBtn:[TUIGiftExtension getLikeButton]};
    }
    return nil;
}

+ (TUIGiftPlayBaseView *)getPlayViewByGroupId:(NSString *)groupId {
    NSString *playKey = [NSString stringWithFormat:@"%@_play", groupId];
    return [[TUIGiftExtension shareInstance].extensions objectForKey:playKey];
}

+ (void)setPlayViewByGroupId:(TUIGiftPlayBaseView *)playView groupId:(NSString *)groupId{
    if (playView && groupId) {
        NSString *playKey = [NSString stringWithFormat:@"%@_play", groupId];
        [[TUIGiftExtension shareInstance].extensions setObject:playView forKey:playKey];
    }
}

+ (TUIGiftListPanelPlugView *)getPlugViewByGroupId:(NSString *)groupId {
    NSString *plugKey = [NSString stringWithFormat:@"%@_plug", groupId];
    return [[TUIGiftExtension shareInstance].extensions objectForKey:plugKey];
}

+ (void)setPlugViewByGroupId:(TUIGiftListPanelPlugView *)plugView groupId:(NSString *)groupId{
    if (plugView && groupId) {
        NSString *plugKey = [NSString stringWithFormat:@"%@_plug", groupId];
        [[TUIGiftExtension shareInstance].extensions setObject:plugView forKey:plugKey];
    }
}

+ (UIButton *)getEnterButton {
    UIButton *enterButton = [[UIButton alloc] init];
    [enterButton setImage:[UIImage imageNamed:@"gift_enter_icon" inBundle:TUIGiftBundle() compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [enterButton sizeToFit];
    return enterButton;
}

+ (UIButton *)getLikeButton {
    UIButton *enterButton = [[UIButton alloc] init];
    [enterButton setImage:[UIImage imageNamed:@"like_enter_icon" inBundle:TUIGiftBundle() compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    [enterButton sizeToFit];
    return enterButton;
}
@end
