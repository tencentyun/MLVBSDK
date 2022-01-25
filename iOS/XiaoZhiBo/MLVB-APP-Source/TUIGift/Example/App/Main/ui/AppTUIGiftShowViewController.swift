//
//  AppMainViewController.swift
//  DemoApp
//
//  Created by wesley on 2021/7/20.
//

import UIKit
import ImSDK_Plus
import TUIGift
import TUICore

class AppTUIGiftShowViewController: UIViewController {
    public var roomId = ""
    private var giftButton:UIButton?
    private var giftView:UIView?
    private var giftPlayView:UIView?
    override func viewDidLoad() {
        super.viewDidLoad()
        title = .roomInfo;
        navigationController?.navigationBar.barTintColor = .white
        self.view.backgroundColor = .white
        setUI()
        if let view =  giftPlayView as? TUIGiftPlayBaseView {
            TUIGiftExtension.setPlayViewByGroupId(view, groupId: roomId)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func setUI() {
        let roomIdLabel = UILabel.init(frame: CGRect.init(x: 20, y: 100, width: self.view.mm_w-40, height: 54))
        roomIdLabel.text = "   " + .roomNumber+roomId
        roomIdLabel.font = UIFont.systemFont(ofSize: 15)
        roomIdLabel.textColor = .black
        roomIdLabel.backgroundColor = UIColor.init(0xF4F5F9)
        roomIdLabel.layer.cornerRadius = 8
        roomIdLabel.layer.masksToBounds = true
        self.view.addSubview(roomIdLabel)
        giftButton = TUIGiftExtension.getEnterButton()
        giftView = TUIGiftListPanelPlugView.init(frame: self.view.frame, groupId: roomId)
        giftPlayView = TUIGiftPlayView.init(frame: self.view.frame, groupId: roomId)
        constructViewHierarchy()
        activateConstraints()
    }
    private func constructViewHierarchy() {
        self.view.addSubview(giftButton!)
        self.view.addSubview(giftView!)
        self.view.addSubview(giftPlayView!)
    }
    
    private func activateConstraints() {
        giftView?.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        giftPlayView?.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        giftButton?.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-50)
        }
        bindInteraction()
    }
    private func bindInteraction() {
        giftButton?.addTarget(self, action: #selector(exitButtonClick(sender:)), for: .touchUpInside)
    }
    @objc func exitButtonClick(sender: UIButton) {
        giftView?.isHidden = false
    }
}

extension String {
    static let roomInfo = TRTCKaraokeLocalize("Demo.TRTC.Karaoke.roomInfo")
    static let roomNumber = TRTCKaraokeLocalize("Demo.TRTC.LiveRoom.roomNumber")
}
