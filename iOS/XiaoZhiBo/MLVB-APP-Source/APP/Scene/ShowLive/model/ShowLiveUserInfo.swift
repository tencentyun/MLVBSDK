//
//  ShowLiveUserInfo.swift
//  XiaoZhiBoApp
//
//  Created by jack on 2021/12/14.
//

import UIKit

public class ShowLiveUserInfo: NSObject {

    var userId: String = ""
    
    var name: String = ""
    
    var avatar: String = ""
    
    convenience init(userId: String, name: String, avatar: String) {
        self.init()
        self.userId = userId
        self.name = name
        self.avatar = avatar
    }
    
}
