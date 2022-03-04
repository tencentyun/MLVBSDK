//
//  ShowLiveLocalized.swift
//  XiaoZhiBoApp
//
//  Created by adams on 2021/5/10.
//

import Foundation

//MARK: ShowLive
let ShowLiveLocalizeTableName = "ShowLiveLocalized"
func ShowLiveLocalize(_ key: String) -> String {
    return localizeFromTable(key: key, table: ShowLiveLocalizeTableName)
}
