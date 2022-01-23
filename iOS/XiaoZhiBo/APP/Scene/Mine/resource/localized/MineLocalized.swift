//
//  MineLocalized.swift
//  TRTCScene
//
//  Created by adams on 2021/5/10.
//

import Foundation


//MARK: Login
let MineLocalizeTableName = "MineLocalized"
func MineLocalize(_ key: String) -> String {
    return localizeFromTable(key: key, table: MineLocalizeTableName)
}
