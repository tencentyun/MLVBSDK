//
//  TUIPusherViewController.swift
//  TUIPusherApp
//
//  Created by gg on 2021/9/8.
//

import Foundation
import TUIPusher
import SnapKit
import TUICore

class TUIPusherViewController: UIViewController {
    lazy var pusherView: TUIPusherView = {
        let view = TUIPusherView(frame: view.bounds)
        return view
    }()
    
    lazy var pkView: TUIPusherFunctionCollectionView = {
        let view = TUIPusherFunctionCollectionView(frame: .zero)
        return view
    }()
    
    lazy var joinAnchorView: TUIPusherFunctionCollectionView = {
        let view = TUIPusherFunctionCollectionView(frame: .zero)
        return view
    }()
    
    lazy var bottomView: TUIPusherFunctionCollectionView = {
        let view = TUIPusherFunctionCollectionView(frame: .zero)
        return view
    }()
    
    private var isFrontCamera = true
    private var isMirror = false
    
    private var alertController: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(pusherView)
        pusherView.setDelegate(self)
        pusherView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        let pushUrl = URLUtils.generatePushUrl(TUILogin.getUserID(), type: .RTC)
        debugPrint("___ push url: \(pushUrl)")
        pusherView.start(pushUrl)
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func setupUI() {
        view.addSubview(pkView)
        pkView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
        pkView.isHidden = true
        setPkViewAction()
        
        view.addSubview(joinAnchorView)
        joinAnchorView.snp.makeConstraints { make in
            make.top.equalTo(pkView.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
        setJoinAnchorViewAction()
        
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-40)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
        bottomView.isHidden = true
        setBottomViewAction()
    }
    
    private func setPkViewAction() {
        pkView.dataSource = ["RequestPK"]
        pkView.didClickItem = { [weak self] (functionView, index) in
            guard let `self` = self else { return }
            if functionView.dataSource.count == 1 {
                let title = functionView.dataSource.first!
                if title == "RequestPK" {
                    let users = ["369", "688"]
                    var user = ""
                    users.forEach { userId in
                        if userId != TUILogin.getUserID() {
                            user = userId
                        }
                    }
                    self.pusherView.sendPKRequest(user)
                    functionView.dataSource = ["Cancel"]
                }
                else if title == "Cancel" {
                    self.pusherView.cancelPKRequest()
                    functionView.dataSource = ["RequestPK"]
                }
                else if title == "Stop" {
                    self.pusherView.stopPK()
                }
            }
        }
    }
    
    private func setJoinAnchorViewAction() {
        joinAnchorView.dataSource = []
        joinAnchorView.didClickItem = { [weak self] (functionView, index) in
            guard let `self` = self else { return }
            if functionView.dataSource.count == 1 {
                let title = functionView.dataSource.first!
                if title == "Stop" {
                    self.pusherView.stopJoinAnchor()
                }
            }
        }
    }
    
    private func setBottomViewAction() {
        bottomView.dataSource = ["SwitchCamera", "Mirror", "Resolution360", "Resolution540", "Resolution720", "Resolution1080"]
        bottomView.didClickItem = { [weak self] (functionView, index) in
            guard let `self` = self else { return }
            switch index {
            case 0:
                self.isFrontCamera = !self.isFrontCamera
                self.pusherView.switchCamera(self.isFrontCamera)
            case 1:
                self.isMirror = !self.isMirror
                self.pusherView.setMirror(self.isMirror)
            default:
                let resolution = TUIPusherVideoResolution(UInt(index - 1))
                self.pusherView.setVideoResolution(resolution)
            }
        }
    }
}

extension TUIPusherViewController: TUIPusherViewDelegate {
    func onPushEvent(_ pusherView: TUIPusherView, event: TUIPusherEvent, message: String) {
        debugPrint("pusher event \(event), msg: \(message)")
    }
    func onPushStarted(_ pusherView: TUIPusherView, url: String) {
        debugPrint("pusher start push")
        pkView.isHidden = false
        bottomView.isHidden = false
    }
    func onPushStoped(_ pusherView: TUIPusherView, url: String) {
        debugPrint("pusher stop push")
    }
    
    func onClickStartPushButton(_ pusherView: TUIPusherView, url: String, responseCallback completion: @escaping Response) {
        completion(true)
    }
    
    /// MARK: PK
    func onReceivePKRequest(_ pusherView: TUIPusherView, userId: String, responseCallback completion: @escaping Response) {
        let alert = UIAlertController(title: "收到 PK 邀请，是否接受？", message: "", preferredStyle: .alert)
        alertController = alert
        let accept = UIAlertAction(title: "接受", style: .default) { [weak self] _ in
            guard let `self` = self else { return }
            completion(true)
            self.pkView.dataSource = ["Stop"]
        }
        let reject = UIAlertAction(title: "拒绝", style: .cancel) { [weak self] _ in
            guard let `self` = self else { return }
            completion(false)
            self.pkView.dataSource = ["RequestPK"]
        }
        alert.addAction(accept)
        alert.addAction(reject)
        present(alert, animated: true, completion: nil)
    }
    func onCancelPKRequest(_ pusherView: TUIPusherView) {
        alertController?.dismiss(animated: true, completion: nil)
    }
    func onStartPK(_ pusherView: TUIPusherView) {
        pkView.dataSource = ["Stop"]
    }
    func onStopPK(_ pusherView: TUIPusherView) {
        pkView.dataSource = ["RequestPK"]
    }
    
    /// MARK: Join Anchor
    func onReceiveJoinAnchorRequest(_ pusherView: TUIPusherView, userId: String, responseCallback completion: @escaping Response) {
        let alert = UIAlertController(title: "收到连麦邀请，是否接受？", message: "", preferredStyle: .alert)
        alertController = alert
        let accept = UIAlertAction(title: "接受", style: .default) { _ in
            completion(true)
        }
        let reject = UIAlertAction(title: "拒绝", style: .cancel) { _ in
            completion(false)
        }
        alert.addAction(accept)
        alert.addAction(reject)
        present(alert, animated: true, completion: nil)
    }
    func onCancelJoinAnchorRequest(_ pusherView: TUIPusherView) {
        alertController?.dismiss(animated: true, completion: nil)
    }
    func onStartJoinAnchor(_ pusherView: TUIPusherView) {
        joinAnchorView.dataSource = ["Stop"]
        pkView.isHidden = true
    }
    func onStopJoinAnchor(_ pusherView: TUIPusherView) {
        joinAnchorView.dataSource = []
        pkView.isHidden = false
    }
}
