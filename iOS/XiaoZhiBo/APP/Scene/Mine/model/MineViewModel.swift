//
//  MineViewModel.swift
//  TXLiteAVDemo
//
//  Created by gg on 2021/4/7.
//  Copyright © 2021 Tencent. All rights reserved.
//

import Foundation
import UIKit

enum MineListType {
    case privacy
    case agreement
    case disclaimer
    case about
}

class MineViewModel: NSObject {
    
    public var user: UserModel? {
        get {
            return ProfileManager.sharedManager().currentUserModel
        }
    }
    
    public lazy var tableDataSource: [MineTableViewCellModel] = {
        var res: [MineTableViewCellModel] = []
        tableTypeSource.forEach { (type) in
            switch type {
            case .privacy:
                let model = MineTableViewCellModel(title: .privacyTitleText, image: UIImage(named: "main_mine_privacy"), type: type)
                res.append(model)
            case .agreement:
                let model = MineTableViewCellModel(title: .protocolTitleText, image: UIImage(named: "userAgreement"), type: type)
                res.append(model)
            case .disclaimer:
                let model = MineTableViewCellModel(title: .disclaimerTitleText, image: UIImage(named: "main_mine_disclaimer"), type: type)
                res.append(model)
            case .about:
                let model = MineTableViewCellModel(title: .aboutTitleText, image: UIImage(named: "main_mine_about"), type: type)
                res.append(model)
            }
        }
        return res
    }()
    public lazy var tableTypeSource: [MineListType] = {
        return [.privacy, .agreement, .disclaimer, .about]
    }()
    
    public func validate(userName: String) -> Bool {
        let reg = "^[a-z0-9A-Z\\u4e00-\\u9fa5\\_]{2,20}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", reg)
        return predicate.evaluate(with: userName)
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let privacyTitleText = MineLocalize("Demo.TRTC.Portal.privacy")
    static let disclaimerTitleText = MineLocalize("Demo.TRTC.Portal.disclaimer")
    static let aboutTitleText = MineLocalize("Demo.TRTC.Portal.Mine.about")
    static let protocolTitleText = MineLocalize("Demo.TRTC.Portal.agreement")
}
