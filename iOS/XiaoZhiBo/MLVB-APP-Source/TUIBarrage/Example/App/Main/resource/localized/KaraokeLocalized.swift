//
//  KaraokeLocalized.swift
//  TRTCAPP_AppStore
//
//  Created by adams on 2021/6/4.
//

import Foundation

let KaraokeLocalizeTableName = "KaraokeLocalized"
func TRTCKaraokeLocalize(_ key: String) -> String {
    return localizeFromTable(key: key, table: KaraokeLocalizeTableName)
}
