//
//  MLVBConfigManager.swift
//  XiaoZhiBoApp
//
//  Created by jack on 2022/1/17.
//

import Foundation

/// 隐私合规配置信息
let MLVB_Privacy_Info: NSDictionary = {
    guard let privacyPath = Bundle.main.path(forResource: "Privacy", ofType: "plist") else {
        return NSDictionary()
    }
    guard let privacyInfo = NSDictionary(contentsOfFile: privacyPath) else {
        return NSDictionary()
    }
    return privacyInfo
}()

/// 用户协议
let WEBURL_Agreement: String = {
    return (MLVB_Privacy_Info["userProtocolURL"] as? String) ?? ""
}()

/// 隐私协议
let WEBURL_Privacy: String = {
    return (MLVB_Privacy_Info["privacyURL"] as? String) ?? ""
}()

class MLVBConfigManager {
    
    static let shared: MLVBConfigManager = MLVBConfigManager()
    /// 本地配置文件信息
    var configInfo: [String: Any] = [:]
    
    init() {
        loadConfig()
    }
    
}

// MARK: - Public 便利获取Config配置信息
extension MLVBConfigManager {
    /// 是否支持直播间广告外链
    public class func enableLiveRoomAdLink() -> Bool {
        return (shared.configInfo["enableLiveRoomAdLink"] as? NSNumber)?.boolValue ?? false
    }
}

// MARK: - Private
extension MLVBConfigManager {
    
    /// 加载本地Config文件
    private func loadConfig() {
        let plistName: String = "Config"
        guard let plistPath: String = Bundle.main.path(forResource: plistName, ofType: "plist") else {
            return
        }
        guard let plistData = FileManager.default.contents(atPath: plistPath) else {
            return
        }
        var propertyListFormat = PropertyListSerialization.PropertyListFormat.xml
        guard let config = try? PropertyListSerialization.propertyList(from: plistData, options: .mutableContainersAndLeaves, format: &propertyListFormat) as? [String: Any] else {
            return
        }
        configInfo = config
    }
    
}
