//
//  URLUtils.swift
//  TUIPusherApp
//
//  Created by gg on 2021/10/21.
//

import Foundation
import ImSDK_Plus
import TUICore

public class URLUtils: NSObject {
    
    static let WEBRTC     : String = "webrtc://"
    static let RTMP       : String = "rtmp://"
    static let HTTP       : String = "http://"
    static let TRTC       : String = "trtc://"
    static let TRTC_DOMAIN: String = "cloud.tencent.com"
    static let APP_NAME   : String = "live"
    
    enum AddressType: Int {
        case RTC = 0
        case RTMP = 1
        case WEBRTC = 2
    }
    
    static func generatePushUrl(_ streamId: String, type: AddressType) -> String {
        guard V2TIMManager.sharedInstance().getLoginStatus() == .STATUS_LOGINED else { return "" }
        guard let userId  = TUILogin.getUserID() else { return "" }
        guard let userSig = TUILogin.getUserSig() else { return "" }
        let sdkAppId      = TUILogin.getSdkAppID()
        switch type {
        case .RTC:
            return "\(TRTC)\(TRTC_DOMAIN)/push/\(streamId)?sdkappid=\(sdkAppId)&userid=\(userId)&usersig=\(userSig)"
        case .RTMP:
            return "\(RTMP)\(PUSH_DOMAIN)/\(APP_NAME)/\(streamId)\(GenerateTestUserSig.getSafeUrl(streamId))"
        case .WEBRTC:
            return ""
        }
    }
    
    static func generatePlayUrl(_ streamId: String, type: AddressType) -> String {
        guard V2TIMManager.sharedInstance().getLoginStatus() == .STATUS_LOGINED else { return "" }
        guard let userId  = TUILogin.getUserID() else { return "" }
        guard let userSig = TUILogin.getUserSig() else { return "" }
        let sdkAppId      = TUILogin.getSdkAppID()
        switch type {
        case .RTC:
            return "trtc://cloud.tencent.com/play/\(streamId)?sdkappid=\(sdkAppId)&userid=\(userId)&usersig=\(userSig)"
        case .RTMP:
            return "\(HTTP)\(PLAY_DOMAIN)/\(APP_NAME)/\(streamId).flv"
        case .WEBRTC:
            return "\(WEBRTC)\(PLAY_DOMAIN)/\(APP_NAME)/\(streamId)"
        }
    }
}
