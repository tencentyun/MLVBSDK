//
//  RoomManager.swift
//  trtcScenesDemo
//
//  Created by 刘智民 on 2020/3/2.
//  Copyright © 2020 xcoderliu. All rights reserved.
//
import Alamofire
import UIKit

private let roomBaseUrl = SERVERLESSURL
/// 进入房间，房主观众均需要调用
private let enterRoomUrl = "base/v1/rooms/enter_room"
/// 更新房间信息，房主调用
private let updateRoomUrl = "base/v1/rooms/update_room"
/// 获取房间列表
private let queryRoomUrl = "base/v1/rooms/query_room"
/// 获取Cos头像上传地址
private let cosRoomUrl = "base/v1/cos/config"
/// 离开房间、观众调用
private let leaveRoomUrl = "base/v1/rooms/leave_room"
/// 销毁房间，只能房主调用
private let destroyRoomUrl = "base/v1/rooms/destroy_room"

public enum RoomType: String {
    case showLive = "mlvb-show-live"
    case shoppingLive = "mlvb-shopping-live"
    case other = "other"
}
/// 房间列表排序规则
public enum RoomOrderType: String {
    /// 按时间倒序
    case createUtc = "createUtc"
    /// 按房间人数倒序
    case totalJoined = "totalJoined"
}

/// Cos上传类型
public enum RoomCosType: String {
    /// 头像
    case avatar = "avatar"
}

@objcMembers
class RoomCommonModel: NSObject, Codable {
    var errorCode: Int32 = -1
    var errorMessage: String = ""
}

@objcMembers
class RoomInfoModel: NSObject, Codable {
    var appId: String = ""
    var type: String = ""
    var roomId: String = ""
    var id: UInt32 = 0
    var createTime: String = ""
}

@objcMembers
class RoomInfoResultModel: NSObject, Codable {
    var errorCode: Int32 = -1
    var errorMessage: String = ""
    var data: [RoomInfoModel]? = []
}

@objcMembers
public class RoomService: NSObject {
    public static let shared = RoomService()
    override private init() {}
    public func createRoom(sdkAppID: Int32,
                           roomID: String,
                           roomName: String,
                           coverUrl: String,
                           roomType: RoomType,
                           success: @escaping () -> Void,
                           failed: @escaping (_ code: Int32, _ error: String) -> Void) {
        IMRoomManager.sharedManager().createRoom(roomId: roomID, roomName: roomName) { (code, msg) in
            if code == 0 {
                let params = ["category": roomType.rawValue,
                              "role": "anchor",
                              "roomId": roomID] as [String: Any]
                HttpBaseRequest.trtcRequest(roomBaseUrl + enterRoomUrl, method: .post, parameters: params, completionHandler: { (model: HttpJsonModel) in
                    if model.errorCode == 0 {
                        let param = ["roomId": roomID,
                                     "title": roomName,
                                     "cover": coverUrl
                        ] as [String : Any]
                        HttpBaseRequest.trtcRequest(roomBaseUrl + updateRoomUrl, method: .post, parameters: param) { model in
                            if model.errorCode == 0 {
                                success()
                            }
                            else {
                                failed(model.errorCode, model.errorMessage)
                            }
                        }
                    }
                    else {
                        failed(model.errorCode, model.errorMessage)
                    }
                })
            }
            else {
                failed(code, msg ?? "")
            }
        }
    }

    public func destroyRoom(sdkAppID: Int32,
                            roomID: String,
                            roomType: RoomType,
                            success: @escaping () -> Void,
                            failed: @escaping (_ code: Int32, _ error: String) -> Void) {
        HttpBaseRequest.trtcRequest(roomBaseUrl + destroyRoomUrl, method: .post, parameters: ["roomId": roomID], completionHandler: { (model: HttpJsonModel) in
            if model.errorCode == 0 {
                success()
            } else {
                failed(model.errorCode, model.errorMessage)
            }
        })
        
        IMRoomManager.sharedManager().destroyRoom(roomId: roomID) { code, msg in
            
        }
    }

    public func enterRoom(roomId: String,
                          roomType: RoomType,
                          success: @escaping () -> Void,
                          failed: @escaping (_ code: Int32, _ error: String) -> Void) {
        IMRoomManager.sharedManager().joinGroup(roomId: roomId) { code, msg in
            TRTCLog.out("enterRoom code: \(code), msg: \(msg ?? "")")
            if (code == 0) {
                let params = ["category": roomType.rawValue,
                              "role": "audience",
                              "roomId": roomId] as [String: Any]
                HttpBaseRequest.trtcRequest(roomBaseUrl + enterRoomUrl, method: .post, parameters: params, completionHandler: { (model: HttpJsonModel) in
                    if model.errorCode == 0 {
                        success()
                    } else {
                        failed(model.errorCode, model.errorMessage)
                    }
                })
            } else {
                failed(code, msg ?? "")
            }
        }
    }
    
    public func exitRoom(roomId: String,
                         success: @escaping () -> Void,
                         failed: @escaping (_ code: Int32, _ error: String) -> Void) {
        IMRoomManager.sharedManager().quitGroup(roomId: roomId) { code, msg in
            TRTCLog.out("exitRoom code: \(code), msg: \(msg ?? "")")
            if (code == 0) {
                success()
            } else {
                failed(code, msg ?? "")
            }
        }
        HttpBaseRequest.trtcRequest(roomBaseUrl + leaveRoomUrl, method: .post, parameters: ["roomId": roomId], completionHandler: { _ in
            
        })
    }
    
    /// 获取房间列表
    /// - Parameters:
    ///   - sdkAppID: 应用配置的sdkAppId
    ///   - roomType: 房间类型
    ///   - orderType: 房间列表排序规则 createUtc 按时间排序  totalJoined 按房间人数排序， 默认为createUtc。
    ///   - success: 成功房间列表回调
    ///   - failed: 失败回调
    public func getRoomList(sdkAppID: Int32,
                            roomType: RoomType,
                            orderType: RoomOrderType = .createUtc,
                            success: ((_ roomIDs: [ShowLiveRoomInfo]) -> Void)? = nil,
                            failed: ((_ code: Int32, _ error: String) -> Void)? = nil) {
        let params = ["category": roomType.rawValue, "orderBy": orderType.rawValue] as [String: Any]
        HttpBaseRequest.trtcRequest(roomBaseUrl + queryRoomUrl, method: .post, parameters: params, completionHandler: { (model: HttpJsonModel) in
            if model.errorCode == 0 {
                success?(model.roomInfos)
            } else {
                failed?(model.errorCode, model.errorMessage)
            }
        })
    }
    
    /// 获取头像上传Cos信息
    /// - Parameters:
    ///   - cosType: cos 上传类型
    ///   - success: 请求成功回调
    ///   - failed: 请求失败回调
    public func getRoomCosInfo(cosType: RoomCosType,
                           success: @escaping (_ cosInfo: ShowLiveCosInfo) -> Void,
                           failed: @escaping (_ code: Int32, _ error: String) -> Void) {
        let params = ["category": cosType.rawValue] as [String: Any]
        HttpBaseRequest.trtcRequest(roomBaseUrl + cosRoomUrl, method: .get, parameters: params) { (model: HttpJsonModel) in
            TRTCLog.out("get room cosInfo. code: \(model.errorCode), message:\(model.errorMessage)")
            if model.errorCode == 0, let cosInfo = model.cosInfo {
                success(cosInfo)
            } else {
                failed(model.errorCode, model.errorMessage)
            }
        }
    }
    
    /// 上传房间头像
    /// - Parameters:
    ///   - image: 需要上传的图片
    ///   - url: 上传的Cos地址
    ///   - fileName: 文件名
    ///   - headers: 请求Header
    ///   - parameters: 请求参数 parmas
    ///   - success: 上传成功回调
    ///   - failed: 上传失败回调
    public func uploadRoomAvatar(image: UIImage,
                                 url: String,
                                 fileName: String? = nil,
                                 headers: [String: String]? = nil,
                                 parameters: Parameters? = nil,
                                 success: @escaping () -> Void,
                                 failed: @escaping (_ code: Int32, _ error: String) -> Void) {
        // 图片处理
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            failed(-1, "upload error: file to data failed")
            return
        }
        // 拼接上传地址: - Alamofire upload 不支持参数设置，需要额外处理下请求地址
        var uploadURL = url
        if let paramsString = parameters?.map({ "\($0.key)=\($0.value)" }).joined(separator: "&") {
            uploadURL += "?\(paramsString)"
        }
        HttpBaseRequest.trtcUpload(uploadURL, data: imageData, mimeType: "image/jpeg", fileName: fileName, headers: headers) { model in
            TRTCLog.out("upload avatar. code: \(model.errorCode), message:\(model.errorMessage)")
            if model.errorCode == 0 {
                success()
            } else {
                failed(model.errorCode, model.errorMessage)
            }
        }
    }
}

// MARK: - 关注
extension RoomService {
    
    
    /// 获取房间关注状态
    /// - Parameters:
    ///   - userId: 房主UserId
    ///   - success: 成功回调
    ///   - failed: 失败回调
    public func getFollowState(userId: String,
                               success: @escaping (_ isFollow: Bool) -> Void,
                               failed: @escaping (_ code: Int32, _ error: String) -> Void) {
        IMRoomManager.sharedManager().getFollowState(userId: userId) { isFollow, code, message in
            if code == 0 {
                success(isFollow)
            } else {
                failed(code, message ?? "")
            }
        }
    }
    
    
    /// 请求关注
    /// - Parameters:
    ///   - userId: 用户ID
    ///   - isFollow: true 关注 false 取消关注
    ///   - success: 成功回调
    ///   - failed: 失败回调
    public func requestFollow(userId: String,
                              isFollow: Bool,
                              success: @escaping () -> Void,
                              failed: @escaping (_ code: Int32, _ error: String) -> Void) {
        IMRoomManager.sharedManager().requestFollow(userId: userId, isFollow: isFollow) { code, message in
            if code == 0 {
                success()
            } else {
                failed(code, message ?? "")
            }
        }
    }
    
    
    /// 获取关注数量
    /// - Parameters:
    ///   - success: 成功回调
    ///   - failed: 失败回调
    public func getFollowCount(success: @escaping (_ count: Int) -> Void,
                               failed: @escaping (_ code: Int32, _ error: String) -> Void) {
        IMRoomManager.sharedManager().getFollowCount { count, code, message in
            if code == 0 {
                success(count)
            } else {
                failed(code, message ?? "")
            }
        }
    }
    
}
