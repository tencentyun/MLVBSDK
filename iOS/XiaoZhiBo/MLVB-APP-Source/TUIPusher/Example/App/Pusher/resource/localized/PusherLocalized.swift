//
//  CallingLocalized.swift
//  TRTCScene
//
//  Created by adams on 2021/5/20.
//

import Foundation

//MARK: Calling
let CallingLocalizeTableName = "CallingLocalized"
func TRTCCallingLocalize(_ key: String) -> String {
    return localizeFromTable(key: key, table: CallingLocalizeTableName)
}
