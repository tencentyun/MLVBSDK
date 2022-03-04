//
//  ShowLiveRoomInfo.swift
//  XiaoZhiBoApp
//
//  Created by adams on 2021/9/27.
//

import UIKit

public class ShowLiveRoomInfo: NSObject {
    var roomID: String = ""
    var roomName: String = ""
    var coverUrl: String = ""
    var ownerId: String = ""
    var ownerName: String = ""
    var memberCount: UInt32 = 0
    var needRequest: Bool = false
    var totalJoined: Int = 0
    // isFollow 是否关注
    var isFollow: Bool = false
    
    init(roomID: String, ownerId: String, memberCount: UInt32) {
        self.roomID = roomID
        self.ownerId = ownerId
        self.memberCount = memberCount
    }
}
