//
//  BeautyLocalized.swift
//  TRTCScene
//
//  Created by gg on 2021/9/22.
//

import Foundation

//MARK: Beauty
let BeautyLocalizeTableName = "BeautyLocalized"
func TRTCBeautyLocalize(_ key: String) -> String {
    return localizeFromTable(key: key, table: BeautyLocalizeTableName)
}
