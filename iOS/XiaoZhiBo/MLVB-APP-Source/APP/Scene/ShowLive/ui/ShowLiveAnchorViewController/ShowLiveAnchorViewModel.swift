//
//  ShowLiveAnchorViewModel.swift
//  XiaoZhiBoApp
//
//  Created by adams on 2021/9/28.
//

import UIKit
import TUICore
import SwiftUI
import CommonCrypto

public protocol ShowLiveAnchorViewNavigator: NSObject {
    func pop()
    func present(viewController: UIViewController)
}

public protocol ShowLiveAnchorViewResponder: NSObject {
    func switchCamera(isFront: Bool)
    func showToast(message: String)
    // 刷新在线用户视图
    func refreshOnlineUsersView()
}

enum ShowLiveAudioQuality {
    case normal
    case music
}

class ShowLiveAnchorViewModel: NSObject {
    weak var viewNavigator: ShowLiveAnchorViewNavigator?
    weak var viewResponder: ShowLiveAnchorViewResponder?
    var roomInfo: ShowLiveRoomInfo
    var audioQuality: ShowLiveAudioQuality = .music
    // 在线用户
    var onlineUsers: [ShowLiveUserInfo] = [ShowLiveUserInfo]()
    // 在线用户数量
    var onlineUsersCount: Int {
        return onlineUsers.count
    }
    
    var groupId: String {
        return roomInfo.roomID
    }
    // 房间头像上传cos信息
    var cosInfo: ShowLiveCosInfo? = nil
    
    public var cameraIsFrontMonitor: Bool = false {
        willSet {
            UserDefaults.standard.set(cameraIsFrontMonitor, forKey: "kShowLiveSwitchCamera")
            if let viewResponder = viewResponder {
                viewResponder.switchCamera(isFront: cameraIsFrontMonitor)
            }
        }
    }
    
    init(roomInfo: ShowLiveRoomInfo) {
        self.roomInfo = roomInfo
        super.init()
        self.roomInfo.roomID = getRoomId()
        self.roomInfo.ownerId = TUILogin.getUserID() ?? ""
        self.roomInfo.coverUrl = ProfileManager.sharedManager().currentUserModel?.avatar ?? randomBgImageLink()
        self.roomInfo.ownerName = TUILogin.getNickName() ?? ""
        //
        registerNotification()
    }
    
    func stopPush() {
        RoomService.shared.destroyRoom(sdkAppID: HttpLogicRequest.sdkAppId, roomID: roomInfo.roomID, roomType: .showLive) {
            
        } failed: { code, msg in
            
        }
        if let viewNavigator = viewNavigator {
            viewNavigator.pop()
        }
    }
    
    func showAlert(viewController: UIViewController) {
        if let viewNavigator = viewNavigator {
            viewNavigator.present(viewController: viewController)
        }
    }

    private func randomBgImageLink() -> String {
        let random = arc4random() % 12 + 1
        return "https://liteav-test-1252463788.cos.ap-guangzhou.myqcloud.com/voice_room/voice_room_cover\(random).png"
    }
    
    private func getRoomId() -> String {
        if let userId = TUILogin.getUserID() {
            TRTCLog.out("room id:\(userId), userId: \(userId)")
            return userId
        }
        return ""
    }
    
    public func createRoom(callback: ((_ code: Int32, _ msg: String) -> Void)?) {
        
        if roomInfo.roomName == "" {
            roomInfo.roomName = "\(roomInfo.ownerName)的直播间"
        }
        RoomService.shared.createRoom(sdkAppID: HttpLogicRequest.sdkAppId,
                                        roomID: roomInfo.roomID,
                                      roomName: roomInfo.roomName,
                                      coverUrl: roomInfo.coverUrl,
                                      roomType: .showLive) { [weak self] in
            callback?(0, "create Room Success.")
            guard let `self` = self else { return }
            // 获取群成员列表
            IMRoomManager.sharedManager().getGroupMemberList(roomID: self.roomInfo.roomID) { [weak self] (code, message, memberList) in
                if code == 0, let userList = memberList {
                    self?.onlineUsers = userList
                    self?.viewResponder?.refreshOnlineUsersView()
                }
            }
        } failed: { code, msg in
            if let callBack = callback {
                callBack(code, msg)
            }
        }
    }
    
    public func getRoomList(callBack: @escaping ([ShowLiveRoomInfo]) -> Void) {
        RoomService.shared.getRoomList(sdkAppID: HttpLogicRequest.sdkAppId, roomType: .showLive) { showLiveRoomInfos in
            callBack(showLiveRoomInfos)
        } failed: { code, msg in
            callBack([])
        }
    }
    
    /// 获取房间Cos上传信息
    public func getRoomAvatarCosInfo(callBack: @escaping (ShowLiveCosInfo?) -> Void) {
        RoomService.shared.getRoomCosInfo(cosType: .avatar) { cosInfo in
            callBack(cosInfo)
        } failed: { _, _ in
            callBack(nil)
        }
    }
    
    /// 上传房间头像
    public func uploadAvatar(image: UIImage, callBack: @escaping (_ imageURL: String?, _ msg: String) -> Void) {
        guard let cosInfo = cosInfo else {
            callBack(nil, "upload error: get cos failed")
            return
        }
        // 构造Cos上传地址
        let uploadURL = "https://\(cosInfo.bucket).cos.\(cosInfo.region).myqcloud.com"
        // 构造头像地址
        let avatarURL = (uploadURL as NSString).appendingPathComponent("\(cosInfo.fileName).jpg")
        // 请求参数
        let parmas = getCosParams()
        // 上传头像
        RoomService.shared.uploadRoomAvatar(image: image, url: uploadURL, parameters: parmas) { [weak self] in
            guard let self = self else {
                callBack(nil, "upload error: sync IM error")
                return
            }
            // IM同步
            if let userModel = ProfileManager.sharedManager().currentUserModel {
                IMLogicRequest.synchronizUserInfo(currentUserModel: userModel,
                                                  avatar: avatarURL,
                                                  success: { [weak self] _ in
                    debugPrint("set IM avatar success")
                    // 更新本地信息
                    if let self = self {
                        // 更新头像
                        self.roomInfo.coverUrl = avatarURL
                    }
                    callBack(avatarURL, "upload success")
                } ,failed: { (code, message) in
                    debugPrint("set IM avatar errorStr: \(message ?? ""), errorCode: \(code)")
                    callBack(nil, message ?? "upload error: sync IM error")
                })
            } else {
                callBack(nil, "upload error: sync IM error")
            }
        } failed: { code, error in
            callBack(nil, error)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - IMListenerNotification 用户进入、离开直播间监听
extension ShowLiveAnchorViewModel {
    
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

// MARK: - Private: Cos 签名加密、策略
extension ShowLiveAnchorViewModel {
    
    /// 获取Cos请求Params
    private func getCosParams() -> [String:Any]? {
        guard let cosInfo = cosInfo else {
            return nil
        }
        var headers: [String:Any] = [:]
        headers["x-cos-security-token"] = cosInfo.sessionToken
        headers["q-sign-algorithm"] = "sha1"
        headers["q-ak"] = cosInfo.tmpSecretId
        headers["q-key-time"] = cosInfo.keyTime
        headers["key"] = cosInfo.fileName + ".jpg"
        headers["success_action_status"] = 200
        // 构造策略
        let date = Date(timeIntervalSince1970: TimeInterval(cosInfo.expiredTime))
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let expirationDate = formatter.string(from: date)
        let policy = getCosPolicy(expirationDate: expirationDate, secretId: cosInfo.tmpSecretId, keyTime: cosInfo.keyTime)
        headers["policy"] = policy.base64
        // 获取签名
        headers["q-signature"] = getCosSignature(keyTime: cosInfo.keyTime, secretKey: cosInfo.tmpSecretKey, policy: policy.origin)
        return headers
    }
    
    /// 获取cos上传策略
    /// - Parameters:
    ///   - expirationDate: 该策略的过期时间，ISO8601 格式字符串
    ///   - secretId: Cos SecretId
    ///   - keyTime: 当前时间戳StartTimestamp和期望的签名到期时间戳 EndTimestamp。格式为StartTimestamp;EndTimestamp，即为 KeyTime
    /// - Returns: (“策略”Policy, Base64 编码的“策略”Policy)
    private func getCosPolicy(expirationDate: String, secretId: String, keyTime: String) -> (origin: String, base64: String) {
        var cosPolicy = """
        {
          "expiration": "ExpirationDate",
          "conditions": [
              { "q-sign-algorithm": "sha1" },
              { "q-ak": "SecretId" },
              { "q-sign-time": "KeyTime" }
          ]
        }
        """
        cosPolicy = cosPolicy.replacingOccurrences(of: "ExpirationDate", with: expirationDate)
        cosPolicy = cosPolicy.replacingOccurrences(of: "SecretId", with: secretId)
        cosPolicy = cosPolicy.replacingOccurrences(of: "KeyTime", with: keyTime)
        guard let policyData = cosPolicy.data(using: .utf8) else {
            return (cosPolicy, cosPolicy)
        }
        return (cosPolicy, policyData.base64EncodedString())
    }
    
    
    /// 获取Cos上传签名
    /// - Parameters:
    ///   - keyTime: 当前时间戳StartTimestamp和期望的签名到期时间戳 EndTimestamp。格式为StartTimestamp;EndTimestamp，即为 KeyTime
    ///   - secretKey: Cos-SecretKey
    ///   - policy: “策略”（Policy）内容
    /// - Returns: HMAC-SHA1消息摘要 - Cos签名
    private func getCosSignature(keyTime: String, secretKey: String, policy: String) -> String {
        // 1. 生成 SignKey
        let signKey = keyTime.hmacSha1(key: secretKey)
        // 2. 生成 StringToSign
        let stringToSign = policy.sha1()
        // 3. 生成 Signature
        let signature = stringToSign.hmacSha1(key: signKey)
        return signature
    }
    
}

// MARK: - Cos hash 摘要
fileprivate extension String {
    
    /// SHA-1加密
    func sha1() -> String {
        guard let data = data(using: .utf8) as NSData? else {
            return self
        }
        let length = Int(CC_SHA1_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)
        CC_SHA1(data.bytes, CC_LONG(data.count), &digest)
        return digest.map{ String(format: "%02x", $0) }.reduce("", +)
    }
    
    /// HMAC-SHA1加密方法
    /// - Parameters:
    ///   - key: 加密的key
    func hmacSha1(key: String) -> String {
        let keyChars = key.cString(using: .utf8) ?? []
        let keyLength = Int(key.lengthOfBytes(using: .utf8))
        
        let contentChars = self.cString(using: .utf8) ?? []
        let contentLength = Int(self.lengthOfBytes(using: .utf8))

        let digestLength = Int(CC_SHA1_DIGEST_LENGTH)
        var result = [CUnsignedChar].init(repeating: 0, count: Int(digestLength))
        let pointer = result.withUnsafeMutableBufferPointer { (unsafeBufferPointer) in
            return unsafeBufferPointer
        }
        let algorithm = CCHmacAlgorithm(kCCHmacAlgSHA1)
        CCHmac(algorithm, keyChars, keyLength, contentChars, contentLength, pointer.baseAddress)
        return result.map{ String(format: "%02x", $0) }.reduce("", +)
    }
}
