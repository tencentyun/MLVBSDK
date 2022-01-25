//
//  LoginLocalized.swift
//  TRTCScene
//
//  Created by adams on 2021/5/10.
//

import Foundation

//MARK: Login
let LoginLocalizeTableName = "LoginLocalized"
func LoginLocalize(_ key: String) -> String {
    return localizeFromTable(key: key, table: LoginLocalizeTableName)
}
