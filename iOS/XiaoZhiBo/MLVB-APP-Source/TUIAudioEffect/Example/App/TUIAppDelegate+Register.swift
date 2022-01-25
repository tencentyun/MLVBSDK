//
//  TUIAppDelegate+Register.swift
//  TUIAudioEffectView_Example
//
//  Created by jack on 2021/11/15.
//  Copyright © 2021 jackyixue. All rights reserved.
//

import Foundation
import ImSDK_Plus

extension TUIAppDelegate {
    
    /**
     * - Note: 注册 SDK 的 License
     * - Parameters:
     *  - url License Url信息
     *  - key License Key信息
     */
    @objc func registerLicense() {
        TXLiveBase.setLicenceURL(LICENSEURL, key: LICENSEURLKEY)
    }
    
}
