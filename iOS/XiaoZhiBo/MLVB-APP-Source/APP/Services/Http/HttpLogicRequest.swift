//
//  HttpLogicRequest.swift
//  TRTCAPP_AppStore
//
//  Created by WesleyLei on 2021/8/3.
//

import Alamofire
import Foundation
import ImSDK_Plus
import TUICore

private let httpBaseUrl = SERVERLESSURL
private let appLoginBaseUrl = httpBaseUrl + "base/v1/"
private let appKaraokeBaseUrl = httpBaseUrl + "base/v1/music/"

private let SDK_APP_ID_KEY = "sdk_app_id_key"

public typealias HttpLogicRequestSuccessCallBack = (_ data: HttpJsonModel) -> Void
public typealias HttpLogicRequestFailedCallBack = (_ errorCode: Int32, _ errorMessage: String?) -> Void
public typealias HttpUserLoginRequestSuccessCallBack = (_ data: UserModel?) -> Void

public class HttpLogicRequest {
    // set get 方法
    private static var _sdkAppId: Int32 = 0
    private(set) static var sdkAppId: Int32 {
        set {
            _sdkAppId = newValue
        }
        get {
            if _sdkAppId > 0 {
                return _sdkAppId
            }
            if let appid = UserDefaults.standard.object(forKey: SDK_APP_ID_KEY) as? String {
                _sdkAppId = Int32(appid) ?? 0
            }
            return _sdkAppId
        }
    }

    /// 全局调度
    /// - Parameters:
    public static func gslb(success: HttpLogicRequestSuccessCallBack?, failed: HttpLogicRequestFailedCallBack?) {
        let baseUrl = appLoginBaseUrl + "gslb"
        logicRequest(baseUrl: baseUrl, params: nil, success: success, failed: failed)
    }

    /// 心跳和保活
    /// - Parameters:
    public static func user_keepalive(success: HttpLogicRequestSuccessCallBack?, failed: HttpLogicRequestFailedCallBack?) {
        let baseUrl = appLoginBaseUrl + "auth_users/user_keepalive"
        logicRequest(baseUrl: baseUrl, params: [:], success: success, failed: failed)
    }

    /// Token登录
    /// - Parameters:
    ///   - userId: 用户id
    ///   - token: token
    ///   - success: 成功回调
    ///   - failed: 失败回调
    public static func userLoginToken(userId: String, token: String, success: HttpUserLoginRequestSuccessCallBack?, failed: HttpLogicRequestFailedCallBack?) {
        let baseUrl = appLoginBaseUrl + "auth_users/user_login_token"
        let params = ["userId": userId, "token": token]
        logicRequest(baseUrl: baseUrl, params: params, success: { model in
            IMLogicRequest.imUserLogin(currentUserModel: model.currentUserModel, success: success, failed: failed)
        }, failed: failed)
    }
    
    /// 用户签名注册
    /// - Parameters:
    ///   - userName: 用户名
    ///   - salt: 使用password生成salt，例如：md5(username-password)
    ///   - success: 成功回调
    ///   - failed: 失败回调
    public static func userNameRegister(userName: String, salt: String, success: HttpUserLoginRequestSuccessCallBack?, failed: HttpLogicRequestFailedCallBack?) {
        let baseUrl = appLoginBaseUrl + "oauth/register"
        let params = ["username": userName, "salt": salt]
        logicRequest(baseUrl: baseUrl, params: params, success: { model in
            success?(nil)
        }, failed: failed)
    }
    
    /// 用户签名登录
    /// - Parameters:
    ///   - userName: 用户名
    ///   - signature: 使用secret对这些参数签名
    ///   - tag: 签名的secret的标签
    ///   - timestamp: 签名时的时间戳
    ///   - nonce: 签名使用的随机字符串，也可是自定义hash
    ///   - hash: 签名使用的算法
    ///   - success: 成功回调
    ///   - failed: 失败回调
    public static func userNameLogin(userName: String,
                                     signature: String,
                                     tag:String,
                                     timestamp:String,
                                     nonce:String = "",
                                     hash:String,
                                     success: HttpUserLoginRequestSuccessCallBack?,
                                     failed: HttpLogicRequestFailedCallBack?) {
        let baseUrl = appLoginBaseUrl + "oauth/signature"
        let params = ["username": userName,
                      "signature": signature,
                      "tag": tag,
                      "ts": timestamp,
                      "nonce": nonce,
                      "hash": hash]
        logicRequest(baseUrl: baseUrl, params: params, success: { model in
            if let sdkAppId = model.sdkAppId, model.currentUserModel != nil{
                HttpLogicRequest.updateSdkAppId(sdkAppId: sdkAppId)
                IMLogicRequest.imUserLogin(currentUserModel: model.currentUserModel, success: success, failed: failed)
            } else {
                failed?(-1, LoginLocalize("Demo.TRTC.http.syserror"))
            }
        }, failed: failed)
    }

    /// 注销登录
    /// - Parameters:
    ///   - userId: 用户id
    ///   - token: token
    ///   - success: 成功回调
    ///   - failed: 失败回调
    public static func userLogout(userId: String, token: String, success: HttpUserLoginRequestSuccessCallBack?, failed: HttpLogicRequestFailedCallBack?) {
        let baseUrl = appLoginBaseUrl + "auth_users/user_logout"
        let params = ["userId": userId, "token": token]
        logicRequest(baseUrl: baseUrl, params: params, success: { _ in
            IMLogicRequest.imUserLogout(currentUserModel: nil, success: success, failed: failed)
        }, failed: failed)
    }

    /// 删除用户
    /// - Parameters:
    ///   - userId: 用户id
    ///   - token: token
    ///   - success: 成功回调
    ///   - failed: 失败回调
    public static func userDelete(userId: String, token: String, success: HttpUserLoginRequestSuccessCallBack?, failed: HttpLogicRequestFailedCallBack?) {
        let baseUrl = appLoginBaseUrl + "auth_users/user_delete"
        let params = ["userId": userId, "token": token]
        logicRequest(baseUrl: baseUrl, params: params, success: { _ in
            IMLogicRequest.imUserDelete(currentUserModel: nil, success: success, failed: failed)
        }, failed: failed)
    }

    /// 修改用户信息
    /// - Parameters:
    ///   - currentUserModel: UserModel
    ///   - name: 用户名，昵称。限制125个字符。可以是中文
    ///   - success: 成功回调
    ///   - failed: 失败回调
    public static func userUpdate(currentUserModel: UserModel, name: String, success: HttpUserLoginRequestSuccessCallBack?, failed: HttpLogicRequestFailedCallBack?) {
        let baseUrl = appLoginBaseUrl + "auth_users/user_update"
        let params = ["userId": currentUserModel.userId, "token": currentUserModel.token, "name": name]
        logicRequest(baseUrl: baseUrl, params: params, success: { _ in
            IMLogicRequest.synchronizUserInfo(currentUserModel: currentUserModel, name: name, success: success, failed: failed)
        }, failed: failed)
    }

    /// 获取用户信息
    /// - Parameters:
    ///   - searchUserId: 用户id
    ///   - success: 成功回调
    ///   - failed: 失败回调
    public static func userQuery(searchUserId: String, success: HttpLogicRequestSuccessCallBack?, failed: HttpLogicRequestFailedCallBack?) {
        let baseUrl = appLoginBaseUrl + "auth_users/user_query"
        let params = ["searchUserId": searchUserId]
        logicRequest(baseUrl: baseUrl, params: params, success: success, failed: failed)
    }

    /// 发起网络请求
    /// - Parameters:
    ///   - baseUrl: baseUrl
    ///   - params: params
    ///   - success: 成功回调
    ///   - failed: 失败回调
    private static func logicRequest(baseUrl: URLConvertible, params: Parameters? = nil, success: HttpLogicRequestSuccessCallBack?, failed: HttpLogicRequestFailedCallBack?) {
        HttpBaseRequest.trtcRequest(baseUrl, method: .post, parameters: params, encoding: JSONEncoding.default, completionHandler: { (model: HttpJsonModel) in
            if model.errorCode == 0 {
                success?(model)
            } else {
                failed?(model.errorCode, model.errorMessage)
            }
        })
    }
}

// MARK: - sdkAppId数据存储
extension HttpLogicRequest {
    static func updateSdkAppId(sdkAppId: Int32) {
        HttpLogicRequest.sdkAppId = sdkAppId
        UserDefaults.standard.setValue(String(sdkAppId), forKey: SDK_APP_ID_KEY)
        UserDefaults.standard.synchronize()
    }
}

// MARK: - Room请求数据相关方法扩展
extension HttpLogicRequest {
    /// 获取房间列表
    /// - Parameters:
    ///   - category: category
    ///   - success: 成功回调
    ///   - failed: 失败回调
    public static func queryRoom(category: RoomType, _ success: HttpLogicRequestSuccessCallBack?, _ failed: HttpLogicRequestFailedCallBack?) {
        let baseUrl = appLoginBaseUrl + "rooms/query_room"
        let params = ["category": category.rawValue]
        logicRequest(baseUrl: baseUrl, params: params, success: success, failed: failed)
    }

    /// 生成房间ID
    /// - Parameters:
    ///   - category: category
    ///   - success: 成功回调
    ///   - failed: 失败回调
    public static func generateRoomid(category: RoomType, _ success: HttpLogicRequestSuccessCallBack?, _ failed: HttpLogicRequestFailedCallBack?) {
        let baseUrl = appLoginBaseUrl + "rooms/generate_roomid"
        let params = ["category": category.rawValue]
        logicRequest(baseUrl: baseUrl, params: params, success: success, failed: failed)
    }

    /// 进入房间
    /// - Parameters:
    ///   - roomId: roomId
    ///   - category: category
    ///   - success: 成功回调
    ///   - failed: 失败回调
    public static func enterRoom(roomId: String, category: RoomType, _ success: HttpLogicRequestSuccessCallBack?, _ failed: HttpLogicRequestFailedCallBack?) {
        let baseUrl = appLoginBaseUrl + "rooms/enter_room"
        let params = ["roomId": roomId, "category": category.rawValue]
        logicRequest(baseUrl: baseUrl, params: params, success: success, failed: failed)
    }

    /// 获取用户列表
    /// - Parameters:
    ///   - roomId: roomId
    ///   - category: category
    ///   - success: 成功回调
    ///   - failed: 失败回调
    public static func listUsers(roomId: String, _ success: HttpLogicRequestSuccessCallBack?, _ failed: HttpLogicRequestFailedCallBack?) {
        let baseUrl = appLoginBaseUrl + "rooms/list_users"
        let params = ["roomId": roomId]
        logicRequest(baseUrl: baseUrl, params: params, success: success, failed: failed)
    }

    /// 退出房间
    /// - Parameters:
    ///   - roomId: roomId
    ///   - success: 成功回调
    ///   - failed: 失败回调
    public static func leaveRoom(roomId: String, _ success: HttpLogicRequestSuccessCallBack?, _ failed: HttpLogicRequestFailedCallBack?) {
        let baseUrl = appLoginBaseUrl + "rooms/leave_room"
        let params = ["roomId": roomId]
        logicRequest(baseUrl: baseUrl, params: params, success: success, failed: failed)
    }

    /// 销毁房间
    /// - Parameters:
    ///   - roomId: roomId
    ///   - success: 成功回调
    ///   - failed: 失败回调
    public static func destroyRoom(roomId: String, _ success: HttpLogicRequestSuccessCallBack?, _ failed: HttpLogicRequestFailedCallBack?) {
        let baseUrl = appLoginBaseUrl + "rooms/destroy_room"
        let params = ["roomId": roomId]
        logicRequest(baseUrl: baseUrl, params: params, success: success, failed: failed)
    }
}

// MARK: - IM请求相关方法
public class IMLogicRequest {
    /// IM 登录
    /// - Parameters:
    ///   - currentUserModel: UserModel
    ///   - success: 成功
    ///   - failed: 失败
    static func imUserLogin(currentUserModel: UserModel?, success: HttpUserLoginRequestSuccessCallBack?, failed: HttpLogicRequestFailedCallBack?) {
        guard let userModel = currentUserModel else {
            failed?(-1, LoginLocalize("LoginNetwork.ProfileManager.loginfailed"))
            return
        }
        TUILogin.initWithSdkAppID(HttpLogicRequest.sdkAppId)
        TUILogin.login(userModel.userId, userSig: userModel.userSig) {
            debugPrint("login success")
            V2TIMManager.sharedInstance()?.getUsersInfo([userModel.userId], succ: { infos in
                if let info = infos?.first {
                    userModel.avatar = info.faceURL ?? ""
                    userModel.name = info.nickName ?? ""
                    if info.userID != nil {
                        userModel.userId = info.userID!
                    }
                    ProfileManager.sharedManager().saveUserDefaults(userModel)
                    success?(userModel)
                    UserOverdueLogicManager.sharedManager().userOverdueState = .alreadyLogged
                } else {
                    failed?(-1, LoginLocalize("LoginNetwork.ProfileManager.loginfailed"))
                }
            }, fail: { code, errorDes in
                failed?(code, errorDes)
            })
        } fail: { code, errorDes in
            failed?(code, errorDes)
        }
    }

    /// IM 删除
    /// - Parameters:
    ///   - currentUserModel: UserModel
    ///   - success: 成功
    ///   - failed: 失败
    static func imUserDelete(currentUserModel: UserModel?, success: HttpUserLoginRequestSuccessCallBack?, failed: HttpLogicRequestFailedCallBack?) {
        let userInfo = V2TIMUserFullInfo()
        userInfo.nickName = ""
        userInfo.faceURL = ""
        V2TIMManager.sharedInstance()?.setSelfInfo(userInfo, succ: {
            debugPrint("set profile success")
            TUILogin.logout {
                success?(currentUserModel)
            } fail: { code, errorDes in
                failed?(code, errorDes)
            }
        }, fail: { code, errorDes in
            failed?(code, errorDes)
        })
    }

    /// IM 退出登录
    /// - Parameters:
    ///   - currentUserModel: UserModel
    ///   - success: 成功
    ///   - failed: 失败
    static func imUserLogout(currentUserModel: UserModel?, success: HttpUserLoginRequestSuccessCallBack?, failed: HttpLogicRequestFailedCallBack?) {
        TUILogin.logout {
            success?(currentUserModel)
        } fail: { code, errorDes in
            failed?(code, errorDes)
        }
    }

    /// IM 更新
    /// - Parameters:
    ///   - currentUserModel: UserModel
    ///   - name: 昵称
    ///   - success: 成功
    ///   - failed: 失败
    static func synchronizUserInfo(currentUserModel: UserModel, name: String, success: HttpUserLoginRequestSuccessCallBack?, failed: HttpLogicRequestFailedCallBack?) {
        let userInfo = V2TIMUserFullInfo()
        userInfo.nickName = name
        userInfo.faceURL = currentUserModel.avatar
        V2TIMManager.sharedInstance()?.setSelfInfo(userInfo, succ: {
            currentUserModel.name = name
            success?(currentUserModel)
            ProfileManager.sharedManager().saveUserDefaults(currentUserModel)
            debugPrint("set profile success")
        }, fail: { code, errorDes in
            failed?(code, errorDes)
        })
    }

    /// IM 更新
    /// - Parameters:
    ///   - currentUserModel: UserModel
    ///   - avatar: 头像
    ///   - success: 成功
    ///   - failed: 失败
    static func synchronizUserInfo(currentUserModel: UserModel, avatar: String, success: HttpUserLoginRequestSuccessCallBack?, failed: HttpLogicRequestFailedCallBack?) {
        let userInfo = V2TIMUserFullInfo()
        userInfo.nickName = currentUserModel.name
        userInfo.faceURL = avatar
        V2TIMManager.sharedInstance()?.setSelfInfo(userInfo, succ: {
            currentUserModel.avatar = avatar
            success?(currentUserModel)
            ProfileManager.sharedManager().saveUserDefaults(currentUserModel)
            debugPrint("set profile success")
        }, fail: { code, errorDes in
            failed?(code, errorDes)
        })
    }
}
