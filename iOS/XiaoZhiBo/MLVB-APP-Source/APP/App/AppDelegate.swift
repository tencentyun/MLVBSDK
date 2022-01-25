//
//  AppDelegate.swift
//  TRTCScene
//
//  Created by abyyxwang on 2021/3/24.
//

import UIKit
import TUIPusher
import TUICore
import Toast_Swift

/// 用户协议
let WEBURL_Agreement:String = "https://web.sdk.qcloud.com/document/Tencent-MLVB-User-Agreement.html"
/// 隐私协议
let WEBURL_Privacy:String = "https://web.sdk.qcloud.com/document/Tencent-MLVB-Privacy-Protection-Guidelines.html"

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let kXiaoZhiBoAppId = "0"
    var window: UIWindow?
    
    func setLicence() {
        V2TXLivePremier.setLicence(LICENSEURL, key: LICENSEURLKEY)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        setLicence()
        window = UIWindow(frame: UIScreen.main.bounds)
        if let userModel = ProfileManager.sharedManager().currentUserModel {
            UserOverdueLogicManager.sharedManager().userOverdueState = .alreadyLogged
            let mainTabBarVC = MainTabbarController()
            mainTabBarVC.view.backgroundColor = .white
            window?.rootViewController = mainTabBarVC
            window?.makeKeyAndVisible()
            checkStoreVersion(appID: kXiaoZhiBoAppId)
            HttpLogicRequest.userLoginToken(userId: userModel.userId, token: userModel.token, success: nil, failed: { _, _ in
                UserOverdueLogicManager.sharedManager().userOverdueState = .loggedAndOverdue
            })
        } else {
            let loginViewController = TRTCLoginViewController()
            let naviVC = UINavigationController(rootViewController: loginViewController)
            naviVC.view.backgroundColor = .white
            window?.rootViewController = naviVC
        }
        setupNavigationBarAppearance()
        window?.makeKeyAndVisible()
        setToastDefaultPosition()
        return true
    }
    
    private func setToastDefaultPosition() {
        ToastManager.shared.position = .center
        TUICSToastManager.setDefaultPosition("TUICSToastPositionCenter")
    }
    
    func setupNavigationBarAppearance() {
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -1000, vertical: 0), for: .default)
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: UIColor.white]
        UINavigationBar.appearance().setBackgroundImage(UIImage(named: "transparent"), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        AppUtils.shared.deviceToken = deviceToken
    }
    
    @objc public func showMainViewController() {
        let mainTabBarVC = MainTabbarController()
        mainTabBarVC.view.backgroundColor = .white
        if let keyWindow = AppUtils.getCurrentWindow() {
            keyWindow.rootViewController = mainTabBarVC
            keyWindow.makeKeyAndVisible()
            checkStoreVersion(appID: kXiaoZhiBoAppId)
        } else {
            debugPrint("window error")
        }
    }
    
    @objc public func showLoginViewController() {
        let loginVC = TRTCLoginViewController()
        let nav = UINavigationController(rootViewController: loginVC)
        if let keyWindow = AppUtils.getCurrentWindow() {
            keyWindow.rootViewController = nav
            keyWindow.makeKeyAndVisible()
        } else {
            debugPrint("window error")
        }
    }
    
    func checkStoreVersion(appID: String) {
        let urlStr = "https://itunes.apple.com/cn/lookup?id=" + appID
        if let url = URL(string: urlStr) {
            let urlRequest = URLRequest(url: url)
            let dataTask = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, _, _ in
                guard let `self` = self else { return }
                guard let data = data else { return }
                guard let remoteDic = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: Any] else { return }
                guard let array = remoteDic["results"] as? [Any] else { return }
                guard let appInfo = array.first as? [String: Any] else { return }
                guard let appStoreVersion = appInfo["version"] as? String else { return }
                debugPrint("====== store version info: \(appStoreVersion) ======")
                let result = self.compareVersion(appStoreVersion: appStoreVersion)
                if result {
                    DispatchQueue.main.async {
                        self.showUpdateAlertController(appID: appID)
                    }
                }
            }
            dataTask.resume()
        }
    }
    
    func compareVersion(appStoreVersion: String) -> Bool {
        let currentVersion = AppUtils.appVersion
        print("====== current version is \(currentVersion) ======")
        return appStoreVersion.compare(currentVersion, options: .numeric, range: nil, locale: nil) == .orderedDescending
    }
    
    func showUpdateAlertController(appID: String) {
        let alertController = UIAlertController(title: LoginLocalize("Demo.TRTC.LiveRoom.prompt"), message: LoginLocalize("Demo.TRTC.Home.newversionpublic"), preferredStyle: .alert)
        let sureAction = UIAlertAction(title: LoginLocalize("Demo.TRTC.Home.updatenow"), style: .default) { [weak self] _ in
            guard let `self` = self else { return }
            self.openAppStore(appID: appID)
        }
        let cancelAction = UIAlertAction(title: LoginLocalize("Demo.TRTC.Home.later"), style: .cancel, handler: nil)
        alertController.addAction(sureAction)
        alertController.addAction(cancelAction)
        if let keyWindow = AppUtils.getCurrentWindow(), let rootViewController = keyWindow.rootViewController {
            rootViewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    func openAppStore(appID: String) {
        guard let url = URL(string: "https://itunes.apple.com/us/app/id\(appID)?ls=1&mt=8") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
