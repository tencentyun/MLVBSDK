//
//  HttpJsonModel.swift
//  TRTCAPP_AppStore
//
//  Created by WesleyLei on 2021/8/2.
//

import Foundation
// 拦截错误码model定义
public class HttpJsonModel: NSObject {
    var errorCode: Int32 = -1
    var errorMessage: String = ""
    var data: Any?

    public static func json(_ json: [String: Any]) -> HttpJsonModel? {
        guard let errorCode = json["errorCode"] as? Int32 else {
            return nil
        }
        guard let errorMessage = json["errorMessage"] as? String else {
            return nil
        }
        let info = HttpJsonModel()
        info.errorCode = errorCode
        info.errorMessage = errorMessage
        info.data = json["data"] as Any
        return info
    }

    // 懒加载---业务解析层处理
    // 全局调度
    lazy var captchaWebAppid: NSInteger? = {
        guard let result = data as? [String: Any] else { return nil }
        return result["captcha_web_appid"] as? NSInteger
    }()

    // 获取验证码业务
    lazy var sessionID: String? = {
        guard let result = data as? [String: Any] else { return nil }
        return result["sessionId"] as? String
    }()

    // 获取登录返回的sdkAppId
    lazy var sdkAppId: Int32? = {
        guard let result = data as? [String: Any] else { return nil }
        return result["sdkAppId"] as? Int32
    }()

    // 获取UserModel
    lazy var currentUserModel: UserModel? = {
        guard let result = data as? [String: Any] else { return nil }
        return getUserModel(result)
    }()

    // 获取UserModel
    lazy var searchUserModel: UserModel? = {
        guard let result = data as? [String: Any] else { return nil }
        return getSearchUserModel(result)
    }()
    private func getSearchUserModel(_ result: [String: Any]) -> UserModel? {
        guard let name = result["name"] as? String else { return nil }
        guard let avatar = result["avatar"] as? String else { return nil }
        guard let userId = result["userId"] as? String else { return nil }
        let phone = (result["phone"] as? String) ?? ""
        let userSig = (result["userSig"] as? String) ?? ""
        let token = (result["token"] as? String) ?? ""
        let apaasAppId = (result["apaasAppId"] as? String) ?? ""
        let apaasUserId = (result["apaasUserId"] as? String) ?? ""
        let sdkUserSig = (result["sdkUserSig"] as? String) ?? ""
        return UserModel(token: token, phone: phone, name: name, avatar: avatar, userId: userId, userSig: userSig, apaasAppId: apaasAppId, apaasUserId: apaasUserId, sdkUserSig: sdkUserSig)
    }
    
    private func getUserModel(_ result: [String: Any]) -> UserModel? {
        guard let userId = result["userId"] as? String else { return nil }
        guard let userSig = result["userSig"] as? String else { return nil }
        guard let token = result["token"] as? String else { return nil }
        
        let phone = (result["phone"] as? String) ?? ""
        let email = (result["email"] as? String) ?? ""
        let name = (result["name"] as? String) ?? ""
        let avatar = (result["avatar"] as? String) ?? defaultAvatar()

        let apaasAppId = (result["apaasAppId"] as? String) ?? ""
        let apaasUserId = (result["apaasUserId"] as? String) ?? ""
        let sdkUserSig = (result["sdkUserSig"] as? String) ?? ""
        return UserModel(token: token, phone: phone, name: name, avatar: avatar, userId: userId, userSig: userSig, apaasAppId: apaasAppId, apaasUserId: apaasUserId, sdkUserSig: sdkUserSig)
    }

    // 获取房间列表
    lazy var roomIDs: [String] = {
        var roomIDs: [String] = []
        guard let result = data as? [[String: Any]] else { return roomIDs }
        for roomInfo in result {
            if let roomId = roomInfo["roomId"] as? String {
                roomIDs.append(roomId)
            }
        }
        return roomIDs
    }()
    
    lazy var roomInfos: [ShowLiveRoomInfo] = {
        guard let result = data as? [[String: Any]] else { return [] }
        var infos: [ShowLiveRoomInfo] = []
        for info in result {
            var roomId = ""
            if let ID = info["roomId"] as? String {
                roomId = ID
            }
            var ownerId = ""
            if let ID = info["ownBy"] as? String {
                ownerId = ID
            }
            let roomInfo = ShowLiveRoomInfo(roomID: roomId, ownerId: roomId, memberCount: 1)
            if let roomName = info["title"] as? String {
                roomInfo.roomName = roomName
            }
            if let coverUrl = info["cover"] as? String, coverUrl.count > 0 {
                roomInfo.coverUrl = coverUrl
            }
            else {
                roomInfo.coverUrl = defaultAvatar()
            }
            roomInfo.ownerName = String(ownerId)
            if let totalJoined = info["totalJoined"] as? Int {
                roomInfo.totalJoined = totalJoined
            }
            infos.append(roomInfo)
        }
        return infos
    }()

    // 获取用户列表
    lazy var users: [UserModel] = {
        var usersResult: [UserModel] = []
        guard let result = data as? [[String: Any]] else { return usersResult }
        for dict in result {
            if let userModel = getUserModel(dict) {
                usersResult.append(userModel)
            }
        }
        return usersResult
    }()
    
    /// 获取Cos信息
    lazy var cosInfo: ShowLiveCosInfo? = {
        guard let result = data as? [String: Any] else { return nil }
        guard let bucket = result["bucket"] as? String else { return nil }
        guard let region = result["region"] as? String else { return nil }
        guard let fileName = result["filename"] as? String else { return nil }
        guard let preview = result["preview"] as? String else { return nil }
        let cosInfo = ShowLiveCosInfo(bucket: bucket, region: region, fileName: fileName, preview: preview)
        if let credential = result["credential"] as? [String: Any] {
            cosInfo.startTime = (credential["startTime"] as? Int) ?? 0
            cosInfo.expiredTime = (credential["expiredTime"] as? Int) ?? 0
            if let credentials = credential["credentials"] as? [String: Any] {
                cosInfo.sessionToken = (credentials["sessionToken"] as? String) ?? ""
                cosInfo.tmpSecretId = (credentials["tmpSecretId"] as? String) ?? ""
                cosInfo.tmpSecretKey = (credentials["tmpSecretKey"] as? String) ?? ""
            }
        }
        return cosInfo
    }()
    
    private func defaultAvatar() -> String {
        return "https://liteav-test-1252463788.cos.ap-guangzhou.myqcloud.com/voice_room/voice_room_cover1.png"
    }
}
