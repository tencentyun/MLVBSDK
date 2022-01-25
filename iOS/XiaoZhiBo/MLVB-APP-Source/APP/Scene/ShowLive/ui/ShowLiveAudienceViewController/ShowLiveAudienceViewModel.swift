//
//  ShowLiveAudienceViewModel.swift
//  XiaoZhiBoApp
//
//  Created by adams on 2021/9/29.
//

import UIKit

public protocol ShowLiveAudienceViewNavigator: NSObject {
    func push(viewController: UIViewController, animated: Bool)
    func pop(animated: Bool)
    func present(viewController: UIViewController)
    /// 打开更多直播
    func openMoreLiveRoom(viewController: UIViewController)
    /// 获取当前控制器
    func currentViewController() -> UIViewController
}

public protocol ShowLiveAudienceViewResponder: NSObject {
    // 刷新在线用户视图
    func refreshOnlineUsersView()
}

class ShowLiveAudienceViewModel: NSObject {
    weak var viewNavigator: ShowLiveAudienceViewNavigator?
    weak var viewResponder: ShowLiveAudienceViewResponder?
    var roomInfo: ShowLiveRoomInfo
    // 是否连麦中
    var isLinking: Bool = false {
        didSet {
            if let viewController = viewNavigator as? ShowLiveAudienceViewController {
                viewController.linkStateChanged?(isLinking)
            }
        }
    }
    // 在线用户
    var onlineUsers: [ShowLiveUserInfo] = [ShowLiveUserInfo]()
    // 在线用户数量
    var onlineUsersCount: Int {
        return onlineUsers.count
    }
    // 是否拉流中
    var isPlaying: Bool = false
    
    var groupId: String {
        return roomInfo.roomID
    }
    
    init(roomInfo: ShowLiveRoomInfo) {
        self.roomInfo = roomInfo
        super.init()
        registerNotification()
    }
    /// 加入房间
    public func joinRoom(success: @escaping () -> Void,
                         failed: @escaping (_ code: Int32, _ error: String) -> Void) {
        let roomID = roomInfo.roomID
        RoomService.shared.enterRoom(roomId: roomID, roomType: .showLive) { [weak self] in
            success()
            guard let self = self else { return }
            // 获取群成员列表
            IMRoomManager.sharedManager().getGroupMemberList(roomID: self.roomInfo.roomID) { [weak self] (code, message, memberList) in
                guard let self = self else { return }
                if code == 0, let userList = memberList {
                    self.onlineUsers = userList
                    self.viewResponder?.refreshOnlineUsersView()
                }
            }
        } failed: { code, msg in
            failed(code, msg)
        }
    }
    /// 离开房间
    public func leaveRoom() {
        let roomID = roomInfo.roomID
        RoomService.shared.exitRoom(roomId: roomID) {
            debugPrint("leave room success \(roomID)")
        } failed: { code, msg in
            debugPrint("leave room error \(roomID) code: \(code) msg: \(msg)")
        }
    }
    /// 退出房间
    public func exitRoom(success: (() -> Void)?,
                         failed: ((_ code: Int32, _ error: String) -> Void)?) {
        let roomID = roomInfo.roomID
        RoomService.shared.exitRoom(roomId: roomID) {
            success?()
        } failed: { code, msg in
            failed?(code, msg)
        }
        if let viewNavigator = viewNavigator {
            viewNavigator.pop(animated: true)
        }
    }
    
    
    /// 获取关注状态
    public func getFollowState(success: ((_ isFollow: Bool) -> Void)? = nil,
                               failed: ((_ code: Int32, _ error: String) -> Void)? = nil) {
        let userId = roomInfo.ownerId
        RoomService.shared.getFollowState(userId: userId) { [weak self] isFollow in
            success?(isFollow)
            guard let self = self else { return }
            self.roomInfo.isFollow = isFollow
        } failed: { code, msg in
            failed?(code, msg)
        }
    }
    
    
    /// 请求关注
    /// - Parameters:
    ///   - isFollow: true 关注 false 取消关注
    public func requestFollow(isFollow: Bool,
                              success: (() -> Void)? = nil,
                              failed: ((_ code: Int32, _ error: String) -> Void)? = nil) {
        let userId = roomInfo.ownerId
        RoomService.shared.requestFollow(userId: userId, isFollow: isFollow) {
            success?()
        } failed: { code, msg in
            failed?(code, msg)
        }
    }
    
    public func showAlert(viewController: UIViewController) {
        if let viewNavigator = viewNavigator {
            viewNavigator.present(viewController: viewController)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - ShowLiveMoreDelegate 在线用户事件代理
extension ShowLiveAudienceViewModel: ShowLiveMoreDelegate {
    
    func showLiveMoreDidSelect(_ roomInfo: ShowLiveRoomInfo) {
        let currentRoomID = self.roomInfo.roomID
        // 判断房间号与当前房间是否一致
        guard roomInfo.roomID != currentRoomID else {
            return
        }
        // 退出当前直播间
        RoomService.shared.exitRoom(roomId: currentRoomID) {
            TRTCLog.out("exit room success: roomID: \(currentRoomID)")
        } failed: { (code, msg) in
            TRTCLog.out("exit room error: roomID: \(currentRoomID) msg: \(code)-\(msg)")
        }
        // 打开新的直播间
        let navigationController = viewNavigator?.currentViewController().navigationController
        viewNavigator?.pop(animated: false)
        let showLiveScrollViewController = ShowLiveScrollViewController(roomInfo: roomInfo)
        navigationController?.pushViewController(showLiveScrollViewController, animated: false)
    }
    
}

// MARK: - IMListenerNotification 用户进入、离开直播间监听
extension ShowLiveAudienceViewModel {
    
    private func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(onUserEnterLiveRoom(_:)), name: .IMGroupUserEnterLiveRoom, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUserLeaveLiveRoom(_:)), name: .IMGroupUserLeaveLiveRoom, object: nil)
    }
    
    @objc
    private func onUserEnterLiveRoom(_ notification: Notification) {
        guard let enterInfo = notification.userInfo as? [String: Any], let groupID = enterInfo["groupID"] as? String, groupID == self.groupId else {
            return
        }
        guard let enterUsers = enterInfo["memberList"] as? [ShowLiveUserInfo] else {
            return
        }
        for user in enterUsers {
            if onlineUsers.contains(where: {$0.userId == user.userId}) == false {
                onlineUsers.append(user)
            }
        }
        viewResponder?.refreshOnlineUsersView()
    }
    
    @objc
    private func onUserLeaveLiveRoom(_ notification: Notification) {
        guard let leaveInfo = notification.userInfo as? [String: Any], let groupID = leaveInfo["groupID"] as? String, groupID == self.groupId else {
            return
        }
        guard let leaveUser = leaveInfo["member"] as? ShowLiveUserInfo else {
            return
        }
        onlineUsers.removeAll(where: {$0.userId == leaveUser.userId})
        viewResponder?.refreshOnlineUsersView()
    }
}
