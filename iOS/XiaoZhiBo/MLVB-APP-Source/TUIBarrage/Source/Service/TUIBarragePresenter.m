//
//  TUIBarragePresenter.m
//  TUIBarrageService
//
//  Created by WesleyLei on 2021/9/26.
//

#import "TUIBarragePresenter.h"
#import "TUIBarrageIMService.h"
#import "TUIBarrageModel.h"
@interface TUIBarragePresenter ()<TUIBarrageIMServiceDelegate>{
    NSString *_groupId;
}
@property (nonatomic, weak, nullable) id <TUIBarragePresenterDelegate> delegate;
@property (nonatomic, strong) TUIBarrageIMService *msgService;
@property (nonatomic, strong) NSCache <NSString*,TUIBarrageModel*> *cacheSendModel;
@end
@implementation TUIBarragePresenter

+ (instancetype)defaultCreate:(id <TUIBarragePresenterDelegate>)delegate {//初始化
    TUIBarragePresenter *presenter = [[TUIBarragePresenter alloc] init];
    presenter.delegate = delegate;
    return presenter;
}

#pragma mark set/get
- (void)setGroupId:(NSString *)groupId {
    if (![_groupId isEqualToString:groupId]) {
        _groupId = groupId;
        [self resetIM];
    }
}

- (NSCache *)cacheSendModel {
    if (_cacheSendModel == nil) {
        _cacheSendModel = [[NSCache alloc] init];
    }
    return _cacheSendModel;
}

- (void)resetIM {
    self.msgService = [TUIBarrageIMService defaultCreate:_groupId delegate:self];
}

- (void)sendBarrage:(TUIBarrageModel*)barrage {
    NSDictionary *param = @{@"message":barrage.message?:@"",
                            @"extInfo":barrage.extInfo?:@{}};
    BOOL isSuccess = [self.msgService onSendMsg:param];
    if (!isSuccess) {
        NSLog(@"groupId is wrong.please check it");
    } else {
        NSString *key = ([NSString stringWithFormat:@"%ld",(long)((NSInteger)param)]);
        [self.cacheSendModel setObject:barrage forKey:key];
    }
}

#pragma mark TUIBarrageIMServiceDelegate
/// 消息发送完成回调
- (void)didSend:(NSDictionary<NSString *,id> *)param isSuccess:(BOOL)success message:(NSString *)message {
    NSString *key = ([NSString stringWithFormat:@"%ld",(long)((NSInteger)param)]);
    TUIBarrageModel *barrageMessage = [self.cacheSendModel objectForKey:key];
    if ([self.delegate respondsToSelector:@selector(onBarrageDidSend:isSuccess:message:)] && barrageMessage) {
        [self.delegate onBarrageDidSend:barrageMessage isSuccess:success message:message];
    }
    [self.cacheSendModel removeObjectForKey:key];
}

/// 收到消息回调
- (void)onReceive:(NSDictionary *)param {
    if (![param isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSString *msg = param[@"message"];
    NSDictionary *extInfo = param[@"extInfo"];
    
    if (![msg isKindOfClass:[NSString class]] || !msg.length) {
        return;
    }
    if (![extInfo isKindOfClass:[NSDictionary class]]) {
        return;
    }
    TUIBarrageModel *message = [[TUIBarrageModel alloc]init];
    message.message = msg;
    message.extInfo = extInfo;
    if ([self.delegate respondsToSelector:@selector(onReceiveBarrage:)]) {
        [self.delegate onReceiveBarrage:message];
    }
}

- (void)dealloc {
    [self.msgService releaseResources];
}

@end
