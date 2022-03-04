//
//  AppMainViewController.swift
//  DemoApp
//
//  Created by wesley on 2021/7/20.
//

import UIKit
import ImSDK_Plus
import TUIBarrage
import TUICore

class AppTUIBarrageShowViewController: UIViewController {
    public var roomId = ""
    private var giftButton:UIButton?
    private var barrageSendView:UIView?
    private var barragePlayView:UIView?
    override func viewDidLoad() {
        super.viewDidLoad()
        title = .roomInfo;
        navigationController?.navigationBar.barTintColor = .white
        self.view.backgroundColor = UIColor.init(0xa1a3a6)
        setUI()
        if let view =  barragePlayView as? TUIBarrageDisplayBaseView {
            TUIBarrageExtension.setDisplayViewByGroupId(view, groupId: roomId)
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
        giftButton = TUIBarrageExtension.getEnterButton()
        barrageSendView = TUIBarrageSendPlugView.init(frame: self.view.frame, groupId: roomId)
        barragePlayView = TUIBarrageDisplayView.init(frame: self.view.frame, groupId: roomId)
        constructViewHierarchy()
        activateConstraints()
    }
    private func constructViewHierarchy() {
        self.view.addSubview(barragePlayView!)
        self.view.addSubview(barrageSendView!)
        self.view.addSubview(giftButton!)
    }
    
    private func activateConstraints() {
        barrageSendView?.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        barragePlayView?.snp.makeConstraints { make in
            make.width.equalTo(self.view.mm_w-40)
            make.height.equalTo(300)
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(self.view.mm_h-300-120)
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
        barrageSendView?.isHidden = false
    }
}

extension String {
    static let roomInfo = TRTCKaraokeLocalize("Demo.TRTC.Karaoke.roomInfo")
    static let roomNumber = TRTCKaraokeLocalize("Demo.TRTC.LiveRoom.roomNumber")
}
