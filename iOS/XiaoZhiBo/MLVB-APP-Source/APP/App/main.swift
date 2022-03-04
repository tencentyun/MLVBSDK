import Foundation
import UIKit

let userDefault = UserDefaults.standard
userDefault.removeObject(forKey: "AppleLanguages")
let langCultureCode: [String] = ["en-CN"]
let currentLanguage = userDefault.stringArray(forKey: "AppleLanguages")?.first ?? ""
if (!currentLanguage.contains("zh-")) {
    userDefault.set(langCultureCode, forKey: "AppleLanguages")
}
UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, NSStringFromClass(AppDelegate.self))
