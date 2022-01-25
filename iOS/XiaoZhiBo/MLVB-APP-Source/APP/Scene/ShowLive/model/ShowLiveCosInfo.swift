//
//  ShowLiveCosInfo.swift
//  XiaoZhiBoApp
//
//  Created by jack on 2022/1/5.
//

import Foundation

/// Cos存储信息
public class ShowLiveCosInfo {
    /// 存储桶名字
    var bucket: String = ""
    /// COS 的可用地域
    var region: String = ""
    /// 文件名称
    var fileName: String = ""
    /// 预览地址
    var preview: String = ""
    /// 临时安全凭证
    var sessionToken: String = ""
    /// 临时SecretId
    var tmpSecretId: String = ""
    /// 临时SecretKey
    var tmpSecretKey: String = ""
    /// 开始时间
    var startTime: Int = 0
    /// 过期时间
    var expiredTime: Int = 0
    
    /// 默认构造CosInfo
    /// - Parameters:
    ///   - bucket: 存储桶名字
    ///   - region: COS 的可用地域
    ///   - fileName: 文件名称
    ///   - preview: 预览地址
    init(bucket: String, region: String, fileName: String, preview: String) {
        self.bucket = bucket
        self.region = region
        self.fileName = fileName
        self.preview = preview
    }
}

// MARK: - 请求扩展
extension ShowLiveCosInfo {
    /// 签名有效时间
    var keyTime: String {
        return "\(startTime);\(expiredTime)"
    }
    
}
