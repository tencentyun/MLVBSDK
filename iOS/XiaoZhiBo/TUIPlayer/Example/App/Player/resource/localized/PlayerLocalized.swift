//
//  PlayerLocalized.swift
//  TUIPlayer
//
//  Created by gg on 2021/9/14.
//

import Foundation

//MARK: Player
let PlayerLocalizeTableName = "PlayerLocalized"
func TUIPlayerLocalize(_ key: String) -> String {
    return localizeFromTable(key: key, table: PlayerLocalizeTableName)
}
