//
//  ShowLiveAudienceViewController.swift
//  XiaoZhiBoApp
//
//  Created by adams on 2021/9/29.
//

import UIKit

typealias ShowLiveRoomLinkStateChangedBlock = (_ isLinking: Bool) -> Void
class ShowLiveAudienceViewController: UIViewController {
    
    // 滑动直播间列表索引
    var pageIndex: Int = 0
    // 连麦状态回调
    var linkStateChanged: ShowLiveRoomLinkStateChangedBlock? = nil
    let viewModel: ShowLiveAudienceViewModel
    /// 默认构造观众直播视图控制器
    /// - Parameters:
    ///   - viewModel: ShowLiveAudienceViewModel
    ///   - pageIndex: 滑动播放场景，列表索引
    init(viewModel: ShowLiveAudienceViewModel, pageIndex: Int = 0) {
        self.viewModel = viewModel
        self.pageIndex = pageIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        TRTCLog.out("deinit \(type(of: self))")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    public override func loadView() {
        let rootView = ShowLiveAudienceRootView.init(viewModel: viewModel)
        viewModel.viewNavigator = self
        view = rootView
    }
    
    /// 取消
    @objc func cancel() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - ShowLiveAudienceViewNavigator
extension ShowLiveAudienceViewController: ShowLiveAudienceViewNavigator {
    
    func currentViewController() -> UIViewController {
        return self
    }
    
    func push(viewController: UIViewController, animated: Bool) {
        navigationController?.pushViewController(viewController, animated: animated)
    }
    
    func pop(animated: Bool) {
        navigationController?.popViewController(animated: animated)
    }
    
    func present(viewController: UIViewController) {
        present(viewController, animated: true, completion: nil)
    }
    
    func openMoreLiveRoom(viewController: UIViewController) {
        self.addChild(viewController)
        viewController.didMove(toParent: self)
        viewController.view.frame = CGRect(origin: CGPoint(x: ScreenWidth, y: 0), size: UIScreen.main.bounds.size)
        viewController.view.backgroundColor = .clear
        self.view.addSubview(viewController.view)
        UIView.animate(withDuration: 0.25) {
            viewController.view.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: UIScreen.main.bounds.size)
            viewController.view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        }
    }
}

// MARK: - ShowLiveScrollViewResponder 滑动直播间
extension ShowLiveAudienceViewController: ShowLiveScrollViewResponder {
    
    func listIndex() -> Int {
        return pageIndex
    }
    
    func isLinking() -> Bool {
        return viewModel.isLinking
    }
    
    func startPlay() {
        guard viewModel.isPlaying == false else {
            resumeVideo()
            return
        }
        guard let playerView = (view as? ShowLiveAudienceRootView)?.playerView else {
            return
        }
        let playURL = URLUtils.generatePlayUrl(viewModel.roomInfo.ownerId, type: .WEBRTC)
        playerView.startPlay(playURL)
    }
    
    func stopPlay() {
        guard let playerView = (view as? ShowLiveAudienceRootView)?.playerView else {
            return
        }
        playerView.stopPlay()
    }
    
    func pauseAudio() {
        guard let playerView = (view as? ShowLiveAudienceRootView)?.playerView else {
            return
        }
        playerView.pauseAudio()
    }
    
    func resumeAudio() {
        guard let playerView = (view as? ShowLiveAudienceRootView)?.playerView else {
            return
        }
        playerView.resumeAudio()
    }
    
    func pauseVideo() {
        guard let playerView = (view as? ShowLiveAudienceRootView)?.playerView else {
            return
        }
        playerView.pauseVideo()
    }
    
    func resumeVideo() {
        guard let playerView = (view as? ShowLiveAudienceRootView)?.playerView else {
            return
        }
        playerView.resumeVideo()
    }
    
    func enterIMGroup() {
        viewModel.joinRoom { [weak self] in
            guard let self = self else { return }
            guard let rootView = self.view as? ShowLiveAudienceRootView else { return }
            rootView.playerView.setGroupId(self.viewModel.groupId)
        } failed: { [weak self] (code, msg) in
            guard let rootView = self?.view as? ShowLiveAudienceRootView else { return }
            rootView.showToast(message: msg)
        }
    }
    
    func leaveIMGroup() {
        viewModel.leaveRoom()
    }
}
