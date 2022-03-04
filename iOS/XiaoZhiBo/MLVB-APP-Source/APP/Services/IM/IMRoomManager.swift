//
//  IMRoomManager.swift
//  XiaoZhiBoApp
//
//  Created by adams on 2021/9/29.
//

import UIKit
import ImSDK_Plus

typealias IMRoomInfoListCallback = (_ code: Int32, _ message: String?, _ roomInfos: [ShowLiveRoomInfo]) -> Void
typealias IMCommonCallback = (_ code: Int32, _ message: String?) -> Void
typealias IMGroupMemberListCallback = (_ code: Int32, _ message: String?, _ memberList: [ShowLiveUserInfo]?) -> Void
typealias IMFollowStateCallBack = (_ isFollow: Bool, _ code: Int32, _ message: String?) -> Void
typealias IMFollowCountCallBack = (_ count: Int, _ code: Int32, _ message: String?) -> Void

// MARK: - IMListenerNotification
public extension Notification.Name {
    
    /// 监听IM群组用户加入房间
    /// - Note : userInfo: ["groupID":"群组id", "memberList":[ShowLiveUserInfo]]
    static let IMGroupUserEnterLiveRoom = Notification.Name("MLVB.IMGroup.UserEnterLiveRoomNotification")
    /// 监听IM群组用户离开房间
    /// - Note : userInfo: ["groupID":"群组id", "member":ShowLiveUserInfo]
    static let IMGroupUserLeaveLiveRoom = Notification.Name("MLVB.IMGroup.UserLeaveLiveRoomNotification")
}

// MARK: - IMRoomManager
class IMRoomManager: NSObject {
    private static let staticInstance: IMRoomManager = IMRoomManager.init()
    public static func sharedManager() -> IMRoomManager { staticInstance }
    private let imManager = V2TIMManager.sharedInstance()
    
    private override init(){
        super.init()
        imManager?.addGroupListener(listener: self)
    }
    
    deinit {
        // IMSDK 析构调用removeGroupListener会引发Crash
//        imManager?.removeGroupListener(listener: self)
    }
}

// MARK: - Public - Group相关
extension IMRoomManager {
    
    public func createRoom(roomId: String, roomName: String, callback: IMCommonCallback?) {
        TRTCLog.out("createRoom roomId: \(roomId)")
        imManager?.createGroup("AVChatRoom", groupID: roomId, groupName: roomName, succ: { [weak self] (succ) in
            guard let `self` = self else { return }
            TRTCLog.out("createGroup onSuccess succ: \(succ ?? "")")
            self.imManager?.addSimpleMsgListener(listener: self)
            if let callBack = callback {
                callBack(0, "create room success.")
            }
        }, fail: { (code, msg) in
            var msg = msg
            if code == 10036 {
                msg = "您当前使用的云通讯账号未开通音视频聊天室功能，创建聊天室数量超过限额，请前往腾讯云官网开通【IM音视频聊天室】，地址：https://cloud.tencent.com/document/product/269/11673"
            }
            
            if code == 10037 {
                msg = "单个用户可创建和加入的群组数量超过了限制，请购买相关套餐,价格地址：https://cloud.tencent.com/document/product/269/11673"
            }
            
            if code == 10038 {
                msg = "群成员数量超过限制，请参考，请购买相关套餐，价格地址：https://cloud.tencent.com/document/product/269/11673"
            }
            
            if code == 10025 {
                if let callBack = callback {
                    callBack(0, "success.")
                }
            } else {
                if let callBack = callback {
                    callBack(code, msg)
                }
            }
        })
    }
    
    public func destroyRoom(roomId: String, callback: IMCommonCallback?) {
        imManager?.dismissGroup(roomId, succ: { [weak self] in
            TRTCLog.out("destroyRoom remove onSuccess roomId: \(roomId)")
            guard let `self` = self else { return }
            self.imManager?.removeSimpleMsgListener(listener: self)
            TRTCLog.out("destroy room success.")
            if let callBack = callback {
                callBack(0, "destroy room success.")
            }
        }, fail: { code, msg in
            TRTCLog.out("destroy room fail, code: \(code), msg: \(msg ?? "")")
            if let callBack = callback {
                callBack(code, msg ?? "")
            }
        })
    }
    
    public func joinGroup(roomId: String, callback: IMCommonCallback?) {
        imManager?.joinGroup(roomId, msg: "", succ: { [weak self] in
            guard let `self` = self else { return }
            TRTCLog.out("enter room success. roomId:  \(roomId)")
            self.imManager?.addSimpleMsgListener(listener: self)
            if let callBack = callback {
                callBack(0, "success")
            }
        }, fail: { code, msg in
            // 已经是群成员了，可以继续操作
            if (code == 10013) {
                if let callBack = callback {
                    callBack(0, "success")
                }
            } else {
                TRTCLog.out("enter room fail, code: \(code) msg: \(msg ?? "")");
                if let callBack = callback {
                    callBack(code, msg ?? "")
                }
            }
        })
    }
    
    public func quitGroup(roomId: String, callback: IMCommonCallback?) {
        imManager?.quitGroup(roomId, succ: { [weak self] in
            guard let `self` = self else { return }
            TRTCLog.out("exit room success.")
            self.imManager?.removeSimpleMsgListener(listener: self)
            if let callBack = callback {
                callBack(0, "exit room success.")
            }
        }, fail: { code, msg in
            TRTCLog.out("exit room fail, code: \(code) msg: \(msg ?? "")")
            if let callBack = callback {
                callBack(code, msg ?? "")
            }
        })
    }
    
    public func getIMRoomInfoList(roomIds:[String], callback: IMRoomInfoListCallback?) {
        imManager?.getGroupsInfo(roomIds, succ: { [weak self] groupResultList in
            guard let `self` = self else { return }
            if let groupResultList = groupResultList {
                var groupResults: [ShowLiveRoomInfo] = []
                var tempDic: [String : V2TIMGroupInfoResult] = [:]
                groupResultList.forEach { result in
                    if result.info.groupID != nil {
                        tempDic[result.info.groupID] = result
                    }
                }
                var userList: [String] = []
                var roomDic: [String : ShowLiveRoomInfo] = [:]
                roomIds.forEach { roomId in
                    if let groupInfo = tempDic[roomId] {
                        if groupInfo.resultCode == 0 {
                            let roomInfo = ShowLiveRoomInfo.init(roomID: groupInfo.info.groupID, ownerId: groupInfo.info.owner, memberCount: groupInfo.info.memberCount)
                            roomInfo.roomName = groupInfo.info.groupName ?? ""
                            roomInfo.coverUrl = groupInfo.info.faceURL ?? .defaultRoomAvatar
                            roomInfo.ownerName = groupInfo.info.introduction ?? ""
                            if groupInfo.info.owner != nil {
                                userList.append(groupInfo.info.owner)
                                roomDic.updateValue(roomInfo, forKey: groupInfo.info.owner)
                            }
                        }
                    }
                }
                if userList.count > 0 {
                    self.imManager?.getUsersInfo(userList, succ: { infos in
                        if let infos = infos {
                            for info in infos {
                                if let roomInfo = roomDic[info.userID] {
                                    roomInfo.ownerId = info.userID
                                    roomInfo.ownerName = info.nickName ?? ""
                                    roomInfo.coverUrl = info.faceURL ?? .defaultRoomAvatar
                                    groupResults.append(roomInfo)
                                }
                            }
                            if let callBack = callback {
                                callBack(0,"success",groupResults)
                            }
                        } else {
                            if let callBack = callback {
                                callBack(-1,"get group info failed.reslut is nil.",[])
                            }
                        }
                    }, fail: { code, msg in
                        if let callBack = callback {
                            callBack(-1,"get group info failed.reslut is nil.",[])
                        }
                    })
                } else {
                    if let callBack = callback {
                        callBack(-1,"get group info failed.reslut is nil.",[])
                    }
                }
            } else {
                if let callBack = callback {
                    callBack(-1,"get group info failed.reslut is nil.",[])
                }
            }
        }, fail: { code, message in
            if let callBack = callback {
                callBack(code,message,[])
            }
        })
    }
    
    public func getGroupMemberList(roomID: String, callback: IMGroupMemberListCallback?) {
        imManager?.getGroupMemberList(roomID, filter: .GROUP_MEMBER_FILTER_COMMON, nextSeq: 0, succ: { (_, memberDatas) in
            if let memberList = memberDatas {
                // 去重
                let results = memberList.enumerated().filter { (index, info) in
                    return memberList.firstIndex(where: {$0.userID == info.userID}) == index
                }.map { (_, info) in
                    info
                }
                var onlineUsers:[ShowLiveUserInfo] = [ShowLiveUserInfo]()
                for member in results {
                    let userInfo = ShowLiveUserInfo(member: member)
                    onlineUsers.append(userInfo)
                }
                callback?(0, "get audience list success.", onlineUsers)
            } else {
                callback?(-1, "get audience list fail, results is nil", nil)
            }
        }, fail: { (code, message) in
            callback?(code, message, nil)
        })
    }
    
}

// MARK: - Public 好友关系
extension IMRoomManager {
    
    /// 获取好友关注状态
    /// - Parameters:
    ///   - userId: 需要查询的用户ID
    ///   - callback: 结果回调
    /// - Warning: 此方案通过IM单向好友实现，强烈建议接入方自己通过service实现
    public func getFollowState(userId: String, callback:@escaping IMFollowStateCallBack) {
        imManager?.getFriendsInfo([userId], succ: { friendInfoResults in
            if let result = friendInfoResults?.first, result.relation == .FRIEND_RELATION_TYPE_IN_MY_FRIEND_LIST {
                callback(true, 0, "get info success")
            } else {
                callback(false, 0, "get info success")
            }
        }, fail: { code, msg in
            callback(false, code, msg)
        })
    }
    
    
    /// 请求关注
    /// - Parameters:
    ///   - userId: 需要操作的用户ID
    ///   - isFollow: true 关注 false 取消关注
    ///   - callback: 结果回调
    /// - Warning: 此方案通过IM单向好友实现，强烈建议接入方自己通过service实现
    public func requestFollow(userId: String, isFollow: Bool, callback:@escaping IMCommonCallback) {
        if isFollow {
            let application = V2TIMFriendAddApplication()
            application.userID = userId
            application.addType = .FRIEND_TYPE_SINGLE
            imManager?.addFriend(application, succ: { result in
                if let resultInfo = result {
                    if resultInfo.resultCode == 30001 {
                        // 已关注
                        callback(0, resultInfo.resultInfo)
                    } else {
                        callback(Int32(resultInfo.resultCode), resultInfo.resultInfo)
                    }
                } else {
                    callback(-1, "follow error")
                }
            }, fail: { code, msg in
                callback(code, msg)
            })
        } else {
            imManager?.delete(fromFriendList: [userId], delete: .FRIEND_TYPE_SINGLE, succ: { _ in
                callback(0, "unfollow success")
            }, fail: { code, msg in
                callback(code, msg)
            })
        }
    }
    
    
    /// 获取关注数量
    /// - Parameter callback: 结果回调
    /// - Warning: 此方案通过IM单向好友实现，强烈建议接入方自己通过service实现
    public func getFollowCount(callback:@escaping IMFollowCountCallBack) {
        imManager?.getFriendList({ resultDatas in
            callback(resultDatas?.count ?? 0, 0, "getFriendList success")
        }, fail: { code, msg in
            callback(0, code, msg)
        })
    }
    
}

// MARK: - V2TIMSimpleMsgListener
extension IMRoomManager: V2TIMSimpleMsgListener {
    
}

// MARK: - V2TIMGroupListener
extension IMRoomManager: V2TIMGroupListener {
    
    func onMemberEnter(_ groupID: String?, memberList: [V2TIMGroupMemberInfo]?) {
        guard let roomId = groupID else { return }
        guard let memberDatas = memberList else { return }
        var users:[ShowLiveUserInfo] = [ShowLiveUserInfo]()
        for member in memberDatas {
            let userInfo = ShowLiveUserInfo(member: member)
            users.append(userInfo)
        }
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .IMGroupUserEnterLiveRoom, object: nil, userInfo: ["groupID" : roomId, "memberList": users])
        }
    }
    
    func onMemberLeave(_ groupID: String?, member: V2TIMGroupMemberInfo?) {
        guard let roomId = groupID else { return }
        guard let memberInfo = member else { return }
        let userInfo = ShowLiveUserInfo(member: memberInfo)
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .IMGroupUserLeaveLiveRoom, object: nil, userInfo: ["groupID" : roomId, "member": userInfo])
        }
    }
}

// MARK: - 便利转换 V2TIMGroupMemberInfo -> ShowLiveUserInfo
extension ShowLiveUserInfo {
    
    /// 便利转换 V2TIMGroupMemberInfo -> ShowLiveUserInfo
    convenience init(member: V2TIMGroupMemberInfo) {
        let userId = member.userID ?? ""
        let name = member.nickName ?? "yk"
        let avatar = member.faceURL ?? .defaultUserAvatar
        self.init(userId: userId, name: name, avatar: avatar)
    }
    
}

// MARK: - internationalization string
fileprivate extension String {
    
    static let defaultRoomAvatar = "https://liteav-test-1252463788.cos.ap-guangzhou.myqcloud.com/voice_room/voice_room_cover1.png"
    
    static let defaultUserAvatar = "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar2.png"
    
}
