//
//  MainLocalized.swift
//  TRTCScene
//
//  Created by adams on 2021/5/10.
//

import Foundation

//MARK: Main
let MainLocalizeTableName = "MainLocalized"
func MainLocalize(_ key: String) -> String {
    return localizeFromTable(key: key, table: MainLocalizeTableName)
}
