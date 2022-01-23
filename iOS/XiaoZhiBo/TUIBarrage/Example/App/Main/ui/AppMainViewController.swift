//
//  AppMainViewController.swift
//  DemoApp
//
//  Created by wesley on 2021/7/20.
//

import UIKit
import ImSDK_Plus


class AppMainViewController: UIViewController {
    
    let rootView = AppMainRootView.init(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = .naviTitleText
        navigationController?.navigationBar.barTintColor = .white
        setupViewHierarchy()
        initNavigationItemTitleView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

}

extension AppMainViewController {
    private func setupViewHierarchy() {
        rootView.frame = view.bounds
        rootView.backgroundColor = .white
        rootView.delegate = self
        view = rootView
    }
    
    private func initNavigationItemTitleView() {
        let titleView = UILabel()
        titleView.text = .videoInteractionText
        titleView.textColor = .black
        titleView.textAlignment = .center
        titleView.font = UIFont.boldSystemFont(ofSize: 17)
        titleView.adjustsFontSizeToFitWidth = true
        let width = titleView.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
        titleView.frame = CGRect(origin:CGPoint.zero, size:CGSize(width: width, height: 500))
        self.navigationItem.titleView = titleView
        
        let isCdnMode = ((UserDefaults.standard.object(forKey: "liveRoomConfig_useCDNFirst") as? Bool) ?? false)
        let rightCDN = UIBarButtonItem()
        if isCdnMode {
            rightCDN.title = "CDN模式"
        } else {
            rightCDN.title = ""
        }
        
        let helpBtn = UIButton(type: .custom)
        helpBtn.setImage(UIImage.init(named: "help_small"), for: .normal)
        helpBtn.addTarget(self, action: #selector(connectWeb), for: .touchUpInside)
        helpBtn.sizeToFit()
        let rightItem = UIBarButtonItem(customView: helpBtn)
        rightItem.tintColor = .black
        navigationItem.rightBarButtonItems = [rightItem, rightCDN]
        
        let backBtn = UIButton(type: .custom)
        backBtn.setImage(UIImage.init(named: "liveroom_back"), for: .normal)
        backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        backBtn.sizeToFit()
        let backItem = UIBarButtonItem(customView: backBtn)
        backItem.tintColor = .black
        navigationItem.leftBarButtonItem = backItem
    }
    
}

extension AppMainViewController {
    @objc func backBtnClick() {
        let alertVC = UIAlertController.init(title: TRTCKaraokeLocalize("App.PortalViewController.areyousureloginout"), message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction.init(title: TRTCKaraokeLocalize("App.PortalViewController.cancel"), style: .cancel, handler: nil)
        let sureAction = UIAlertAction.init(title: TRTCKaraokeLocalize("App.PortalViewController.determine"), style: .default) { (action) in
            ProfileManager.shared.removeLoginCache()
            V2TIMManager.sharedInstance()?.logout({
                AppUtils.shared.appDelegate.showLoginViewController()
            }, fail: { (errCode, errMsg) in
                debugPrint("errCode = \(errCode), errMsg = \(errMsg ?? "")")
            })
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(sureAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    @objc func connectWeb() {
        if let url = URL(string: "https://cloud.tencent.com/document/product/647/59402") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension AppMainViewController: AppMainRootViewDelegate {
    func enterRoom(roomId: String) {
    
        V2TIMManager.sharedInstance().joinGroup(roomId, msg: "" ,succ:{
            self.pushGiftController(roomId: roomId)
        },fail: { code, message in
            debugPrint("code = \(code), message = \(message ?? "")")
        })
    }
    
    func createRoom() {
        guard let curUserID = ProfileManager.shared.curUserID() else {
            debugPrint("not login")
            return
        }
        let groupID = "\(Int(curUserID) ?? 0 & 0x7FFFFFFF)"
        V2TIMManager.sharedInstance().createGroup("AVChatRoom", groupID: groupID, groupName: "gift_app") { [weak self] groupID in
            guard let `self` = self else { return }
            self.pushGiftController(roomId: groupID!)
        } fail: { [weak self] code, message in
            guard let `self` = self else { return }
            if (code == 10025 || code == 10021) {
                // 表明群主是自己，认为创建成功
                // 群ID已被他人使用，走进房的逻辑
                self.enterRoom(roomId: groupID)
            }
            debugPrint("code = \(code), message = \(message ?? "")")
        }
    }
    
    private func alert(roomId: String, handle: @escaping () -> Void) {
        let alertVC = UIAlertController.init(title: .promptText, message: .roomNumberisText + roomId, preferredStyle: .alert)
        let alertAction = UIAlertAction.init(title: .okText, style: .default) { _ in
            handle()
        }
        alertVC.addAction(alertAction)
        if let keyWindow = SceneDelegate.getCurrentWindow() {
            keyWindow.rootViewController?.present(alertVC, animated: true, completion: nil)
        }
    }
    
    private func pushGiftController(roomId: String) {
        let vc = AppTUIBarrageShowViewController.init()
        vc.roomId = roomId
        navigationController?.pushViewController(vc, animated: true)
    }
}


extension String {
    static let naviTitleText = TRTCKaraokeLocalize("Demo.TRTC.Karaoke.voicechatroom")
    static let videoInteractionText = TRTCKaraokeLocalize("Demo.TRTC.Karaoke.voicechatroom")
    static let promptText = TRTCKaraokeLocalize("Demo.TRTC.LiveRoom.prompt")
    static let okText = TRTCKaraokeLocalize("Demo.TRTC.LiveRoom.ok")
    static let roomNumberisText = TRTCKaraokeLocalize("Demo.TRTC.LiveRoom.roomNumberis:")
    static let roomdoesnotexistText = TRTCKaraokeLocalize("Demo.TRTC.LiveRoom.roomdoesnotexist")
}
