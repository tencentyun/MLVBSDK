//
//  MainTabbarController.swift
//  TXLiteAVDemo
//
//  Created by gg on 2021/4/7.
//  Copyright © 2021 Tencent. All rights reserved.
//

import UIKit

class MainTabbarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let portalNav = MainNavigationController(rootViewController: portalVC)
        addChild(portalNav)
        
        let discoverNav = MainNavigationController(rootViewController: discoverVC)
        addChild(discoverNav)
        
        let mineNav = MainNavigationController(rootViewController: mineVC)
        addChild(mineNav)
        
        tabBar.isTranslucent = false
        hidesBottomBarWhenPushed = true
        ProfileManager.sharedManager().startKeepaliveTimer()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    lazy var mineVC: MineViewController = {
        let mineVC = MineViewController()
        let item = UITabBarItem(title: .mineTitleText, image: UIImage(named: "main_mine_nor")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "main_mine_sel")?.withRenderingMode(.alwaysOriginal))
        mineVC.tabBarItem = item
        return mineVC
    }()
    
    lazy var discoverVC: DiscoverViewController = {
        let mainVC = DiscoverViewController()
        let item = UITabBarItem(title: .discover, image: UIImage(named: "main_home_disc")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "main_home_disc_sele")?.withRenderingMode(.alwaysOriginal))
        mainVC.tabBarItem = item
        return mainVC
    }()
    
    lazy var portalVC: MainViewController = {
        let mainVc = MainViewController()
        let item = UITabBarItem(title: .homeTitleText, image: UIImage(named: "main_home_nor")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "main_home_sel")?.withRenderingMode(.alwaysOriginal))
        mainVc.tabBarItem = item
        return mainVc
    }()
}

class MainNavigationController: UINavigationController {
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    override public var prefersStatusBarHidden: Bool {
        return false
    }
}

// MARK: - internationalization string

fileprivate extension String {
    static let mineTitleText = MainLocalize("Demo.TRTC.Portal.Main.mine")
    static let homeTitleText = MainLocalize("Demo.TRTC.Portal.Main.home")
    static let discover = MainLocalize("Demo.TRTC.Portal.Main.discover")
}
