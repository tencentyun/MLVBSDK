//
//  RoomMsgMgr.h
//  TXLiteAVDemo
//
//  Created by lijie on 2017/11/1.
//  Copyright © 2017年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLVBLiveRoomDef.h"

@protocol IMMsgManagerDelegate <NSObject>

// 接收群文本消息
- (void)onRecvGroupTextMsg:(NSString *)groupID userID:(NSString *)userID textMsg:(NSString *)textMsg userName:(NSString *)userName userAvatar:(NSString *)userAvatar;

// 接收到群成员变更消息
- (void)onMemberChange:(NSString *)groupID;

// 接收到房间解散消息
- (void)onGroupDelete:(NSString *)groupID;

// 接收到房间成员加入信息
- (void)onGroupMemberEnter:(NSString *)group user:(MLVBAudienceInfo *)audienceInfo;

// 接收到房间成员离开信息
- (void)onGroupMemberLeave:(NSString *)group user:(MLVBAudienceInfo *)audienceInfo;


@optional

// 被踢掉线
- (void)onForceOffline;

// 接收到小主播的连麦请求
- (void)onRecvJoinAnchorRequest:(NSString *)roomID userID:(NSString *)userID userName:(NSString *)userName userAvatar:(NSString *)userAvatar reason:(NSString *)reason;

// 接收到大主播的连麦回应， result为YES表示同意连麦，为NO表示拒绝连麦
- (void)onRecvJoinAnchorResponse:(NSString *)roomID result:(BOOL)result message:(NSString *)message;

// 接收到被大主播的踢出连麦的消息
- (void)onRecvJoinAnchorKickout:(NSString *)roomID;

// 接收群自定义消息，cmd为自定义命令字，msg为自定义消息体(这里统一使用json字符串)
- (void)onRecvGroupCustomMsg:(NSString *)groupID userID:(NSString *)userID cmd:(NSString *)cmd msg:(NSString *)msg userName:(NSString *)userName userAvatar:(NSString *)userAvatar;

// 接收到PK请求
- (void)onRequestRoomPK:(NSString *)roomID userID:(NSString *)userID userName:(NSString *)userName userAvatar:(NSString *)userAvatar streamUrl:(NSString *)streamUrl;

// 接收到PK请求回应, result为YES表示同意PK，为NO表示拒绝PK，若同意，则streamUrl为对方的播放流地址
- (void)onRecvPKResponse:(NSString *)roomID userID:(NSString *)userID result:(BOOL)result message:(NSString *)message streamUrl:(NSString *)streamUrl;

// 接收PK结束消息
- (void)onRecvPKFinishRequest:(NSString *)roomID userID:(NSString *)userID;

@end


@interface IMMsgManager : NSObject

@property (nonatomic, weak) id<IMMsgManagerDelegate> delegate;
@property (nonatomic, assign) uint64_t loginServerTime;
@property (nonatomic, assign, readonly) uint64_t loginUptime;

- (instancetype)initWithConfig:(MLVBLoginInfo *)config;

- (void)setLoginServerTime:(uint64_t)loginServerTime;

// 登录
- (void)loginWithCompletion:(void (^)(int errCode, NSString *errMsg))completion;

// 登出
- (void)logout:(void (^)(int errCode, NSString *errMsg))completion;

// 创建群
- (void)createGroupWithID:(NSString *)groupID name:(NSString *)groupName completion:(void (^)(int errCode, NSString *errMsg))completion;

// 删除群
- (void)deleteGroupWithID:(NSString *)groupID completion:(void (^)(int errCode, NSString *errMsg))completion;

// 获取群成员
- (void)getGroupMemberList:(NSString *)groupID completion:(void(^)(int code, NSString *msg, NSArray <MLVBAudienceInfo *>* members))completion;

// 加入房间
- (void)enterRoom:(NSString *)groupID completion:(void (^)(int errCode, NSString *errMsg))completion;

// 退出房间
- (void)quitGroup:(NSString *)groupID completion:(void (^)(int errCode, NSString *errMsg))completion;

- (void)sendNotifyMessage;

// 发送群自定义消息
- (void)sendRoomCustomMsg:(NSString *)cmd msg:(NSString *)msg completion:(void (^)(int errCode, NSString *errMsg))completion;

// 发送群文本消息
- (void)sendGroupTextMsg:(NSString *)textMsg completion:(void (^)(int errCode, NSString *errMsg))completion;;

#pragma mark - 连麦

// 向userID发起连麦请求
- (void)sendJoinAnchorRequest:(NSString *)userID roomID:(NSString *)roomID;

// 向userID发起连麦响应, result为YES表示接收，为NO表示拒绝
- (void)sendJoinAnchorResponseWithUID:(NSString *)userID roomID:(NSString*)roomID result:(BOOL)result reason:(NSString *)reason;

// 群主向userID发出踢出连麦消息
- (void)sendJoinAnchorKickout:(NSString *)userID roomID:(NSString*)roomID;

// 向userID发起PK请求
- (void)sendPKRequest:(NSString *)userID roomID:(NSString *)roomID withAccelerateURL:(NSString *)accelerateURL;

// 请求结束PK
- (void)sendPKFinishRequest:(NSString *)userID roomID:(NSString *)roomID completion:(void(^)(int errCode, NSString *errMsg))completion;

// 接收PK
- (void)acceptPKRequest:(NSString *)userID roomID:(NSString *)roomID withAccelerateURL:(NSString *)accelerateURL;

// 拒绝PK
- (void)rejectPKRequest:(NSString *)userID roomID:(NSString *)roomID reason:(NSString *)reason;

#pragma mark - 个人信息
-(void)setSelfProfile:(NSString *)userName avatarURL:(NSString*)avatarURL completion:(void(^)(int code, NSString *msg))completion;
- (void)getProfile:(void(^)(int code, NSString *msg, NSString *nickname, NSString *avatar))completion;
@end
