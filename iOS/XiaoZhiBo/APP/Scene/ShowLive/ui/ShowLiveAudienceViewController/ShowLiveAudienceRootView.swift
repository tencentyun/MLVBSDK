//
//  ShowLiveAudienceRootView.swift
//  XiaoZhiBoApp
//
//  Created by adams on 2021/9/29.
//

import UIKit
import TUIPlayer

class ShowLiveAudienceRootView: UIView {

    private let viewModel: ShowLiveAudienceViewModel
    
    lazy var playerView: TUIPlayerView = {
        let view = TUIPlayerView.init(frame: .zero)
        view.setDelegate(self)
        return view
    }()
    
    lazy var exitButton: UIButton = {
        let button = UIButton.init(frame: .zero)
        button.setBackgroundImage(UIImage.init(named: "live_exit"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()
    
    lazy var roomInfoView: ShowLiveRoomInfoView = {
        let view = ShowLiveRoomInfoView(type: .audience)
        return view
    }()
    
    /// 在线用户
    lazy var onlineUsersView: ShowLiveOnlineUsersView = {
        let view = ShowLiveOnlineUsersView(delegate: self)
        return view
    }()
    
    /// 更多直播
    lazy var moreLiveView: ShowLiveMoreLiveView = {
        let view = ShowLiveMoreLiveView(frame: .zero)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        return view
    }()
    
    /// 广告外链视图
    lazy var adImageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.image = UIImage(named: "ad_default")
        view.isHidden = !MLVBConfigManager.enableLiveRoomAdLink()
        return view
    }()
    /// 滑动播放毛玻璃遮挡视图
    lazy var hitEffectView: ShowLiveScrollEffectView = {
        let view = ShowLiveScrollEffectView(frame: .zero)
        return view
    }()
    
    /// 人气榜
    lazy var hotRankingView: ShowLiveHotRankingView = {
        let view = ShowLiveHotRankingView(frame: .zero)
        return view
    }()
    
    init(viewModel: ShowLiveAudienceViewModel, frame: CGRect = .zero) {
        self.viewModel = viewModel
        super.init(frame: frame)
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var isViewReady = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
    }
    
    private func constructViewHierarchy() {
        addSubview(playerView)
        playerView.addSubview(hitEffectView)
        playerView.addSubview(exitButton)
        addSubview(roomInfoView)
        addSubview(onlineUsersView)
        addSubview(moreLiveView)
        addSubview(adImageView)
        addSubview(hotRankingView)
    }
    
    private func activateConstraints() {
        playerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        hitEffectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        exitButton.snp.makeConstraints { make in
            make.width.height.equalTo(44)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
        roomInfoView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(20)
            make.trailing.lessThanOrEqualTo(onlineUsersView.snp.leading).offset(-10)
            make.height.equalTo(36)
        }
        onlineUsersView.snp.makeConstraints { make in
            make.trailing.equalTo(-16)
            make.centerY.equalTo(roomInfoView)
        }
        moreLiveView.snp.makeConstraints { make in
            make.trailing.equalTo(0)
            make.height.equalTo(24)
            make.top.equalTo(roomInfoView.snp.bottom).offset(10)
        }
        adImageView.snp.makeConstraints { make in
            make.trailing.equalTo(-16)
            make.size.equalTo(CGSize(width: 150, height: 44))
            make.top.equalTo(moreLiveView.snp.bottom).offset(7)
        }
        hotRankingView.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.height.equalTo(22)
            make.top.equalTo(roomInfoView.snp.bottom).offset(10)
        }
    }
    
    private func bindInteraction() {
        viewModel.viewResponder = self
        exitButton.addTarget(self, action: #selector(exitButtonClick(sender:)), for: .touchUpInside)
        moreLiveView.addTapGesture(target: self, action: #selector(moreLiveRoomClick))
        adImageView.addTapGesture(target: self, action: #selector(adImageViewClick))
        // 设置预加载模糊背景图片
        hitEffectView.setImage(urlString: viewModel.roomInfo.coverUrl)
        roomInfoView.setRoomInfo(viewModel.roomInfo)
        
        // 请求关注状态
        viewModel.getFollowState { [weak self] isFollow in
            guard let self = self else { return }
            self.roomInfoView.updateFollowState(isFollow: isFollow)
        } failed: { code, error in
            debugPrint("getFollowState error code: \(code) msg: \(error)")
        }
        // 关注回调
        roomInfoView.followBlock = { [weak self] in
            guard let self = self else { return }
            self.followClick()
        }
        // roomInfo 点击事件
        roomInfoView.addTapGesture(target: self, action: #selector(roomInfoClick))
        hotRankingView.addTapGesture(target: self, action: #selector(hotRankingClick))
    }

    func showToast(message: String) {
        makeToast(message)
    }
    
    
    /// 设置当前PlayerView显示状态
    /// - Parameter state: TUIPLAYER_UISTATE_VIDEOONLY 只显示视频 TUIPLAYER_UISTATE_DEFAULT 默认展示全部元素
    func updatePlayerViewUIState(_ state: TUIPlayerUIState) {
        playerView.update(state)
        if state == .TUIPLAYER_UISTATE_VIDEOONLY {
            exitButton.isHidden = true
        }
        if state == .TUIPLAYER_UISTATE_DEFAULT {
            exitButton.isHidden = false
            guard playerView.superview != self else {
                return
            }
            playerView.removeFromSuperview()
            insertSubview(playerView, at: 0)
            playerView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            exitButton.snp.remakeConstraints { make in
                make.width.height.equalTo(44)
                make.trailing.equalToSuperview().offset(-20)
                make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-10)
            }
            hitEffectView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
            layoutIfNeeded()
        }
    }
}

//MARK: - UIButton Touch Event
extension ShowLiveAudienceRootView {
    
    @objc func exitButtonClick(sender: UIButton) {
        if viewModel.isPlaying {
            if viewModel.isLinking {
                // 连麦中，不展示悬浮框
                let alertController = UIAlertController(title: .exitAlertTitle, message: nil, preferredStyle: .alert)
                let closeAction = UIAlertAction.init(title: .exitAlertConfirmTitle, style: .default) { [weak self] _ in
                    guard let self = self else { return }
                    self.playerView.stopPlay()
                    self.viewModel.exitRoom(success: nil, failed: nil)
                }
                let cancelAction = UIAlertAction.init(title: .exitAlertWaitTitle, style: .cancel, handler: nil)
                alertController.addAction(closeAction)
                alertController.addAction(cancelAction)
                viewModel.viewNavigator?.present(viewController: alertController)
                return
            } else if ShowLiveFloatingManager.shared.enableFloating, let currentController = viewModel.viewNavigator?.currentViewController() as? ShowLiveAudienceViewController {
                // 正在拉流中，支持悬浮框，展示悬浮框
                ShowLiveFloatingManager.shared.showFloating(from: currentController)
                return
            }
        }
        self.playerView.stopPlay()
        self.viewModel.exitRoom(success: nil, failed: nil)
    }
    
    /// 更多直播
    @objc
    private func moreLiveRoomClick() {
        let moreController = ShowLiveMoreViewController(delegate: viewModel)
        viewModel.viewNavigator?.openMoreLiveRoom(viewController: moreController)
    }
    
    /// 关注点击事件
    private func followClick() {
        let willFollow = !viewModel.roomInfo.isFollow
        viewModel.requestFollow(isFollow: willFollow) { [weak self] in
            guard let self = self else { return }
            if willFollow {
                self.showToast(message: .followedText)
            } else {
                self.showToast(message: .unFollowedText)
            }
            self.viewModel.roomInfo.isFollow = willFollow
            self.roomInfoView.updateFollowState(isFollow: willFollow)
        } failed: { [weak self] (code, error) in
            guard let self = self else { return }
            self.showToast(message: error)
        }
    }
    
    /// roomInfoView 点击事件
    @objc
    private func roomInfoClick() {
        let alert = ShowLiveRoomInfoAlert(roomInfo: viewModel.roomInfo)
        alert.followBlock = { [weak self] (isFollow) in
            guard let self = self else { return }
            self.viewModel.roomInfo.isFollow = isFollow
            self.roomInfoView.updateFollowState(isFollow: isFollow)
        }
        viewModel.viewNavigator?.present(viewController: alert)
    }
    
    /// 广告图片点击
    @objc
    private func adImageViewClick() {
        let discoverController = DiscoverViewController()
        let discoverNav = MainNavigationController(rootViewController: discoverController)
        // 修复iOS 15导航栏显示异常
        discoverNav.navigationBar.backgroundColor = .white
        discoverNav.modalPresentationStyle = .popover
        viewModel.viewNavigator?.present(viewController: discoverNav)
	}
	
    /// 点击人气榜
    @objc
    private func hotRankingClick() {
        let viewController = ShowLiveHotRankingAlert(roomInfo: viewModel.roomInfo)
        viewModel.viewNavigator?.present(viewController: viewController)
    }
}

// MARK: - TUIPlayerViewDelegate
extension ShowLiveAudienceRootView: TUIPlayerViewDelegate {
    func onPlayStarted(_ playerView: TUIPlayerView!, url: String!) {
        viewModel.isPlaying = true
        hitEffectView.isHidden = true
        // 监听到直播结束回调，收起键盘，防止键盘遮挡
        endEditing(true)
    }
    
    func onPlayStoped(_ playerView: TUIPlayerView!, url: String!) {
        debugPrint("recv player stop")
        viewModel.isPlaying = false
        // 房主结束直播文本提示
        hitEffectView.setTipText(text: .anchorExitRoom)
        hitEffectView.isHidden = false
        playerView.update(.TUIPLAYER_UISTATE_VIDEOONLY)
        if ShowLiveFloatingManager.shared.isFloating, ShowLiveFloatingManager.shared.currentRoomId == viewModel.roomInfo.roomID {
            // 存在悬浮框，关闭悬浮框
            ShowLiveFloatingManager.shared.closeWindowAndExitRoom()
        } else {
            // 退出IM房间
            viewModel.leaveRoom()
        }
    }
    
    func onPlayEvent(_ playerView: TUIPlayerView!, event: TUIPlayerEvent, message: String!) {
        debugPrint("recv player event: \(event.rawValue)")
        if event == .TUIPLAYER_EVENT_LINKMIC_START {
            viewModel.isLinking = true
        }
        if event == .TUIPLAYER_EVENT_LINKMIC_STOP {
            viewModel.isLinking = false
        }
    }
    
    func onRejectJoinAnchorResponse(_ playerView: TUIPlayerView!, reason: Int32) {
        viewModel.isLinking = false
        switch reason {
        case 1:
            showToast(message: .rejectLinkMicTitle)
        case 2:
            showToast(message: .busyLinkMicTitle)
        default:
            break
        }
    }
}

// MARK: - ShowLiveAnchorViewResponder
extension ShowLiveAudienceRootView: ShowLiveAudienceViewResponder {
    
    func refreshOnlineUsersView() {
        onlineUsersView.updateUI(userDataSource: viewModel.onlineUsers, userCount: viewModel.onlineUsersCount)
    }
    
}

// MARK: - ShowLiveOnlineUsersDelegate
extension ShowLiveAudienceRootView: ShowLiveOnlineUsersDelegate {
    
    func showLiveOnlineUsersDidClickMore() {
        let alert = ShowLiveOnlineUsersAlertController(roomId: viewModel.groupId, userDataSource: viewModel.onlineUsers, delegate: nil)
        let alertNav = UINavigationController(rootViewController: alert)
        alertNav.modalPresentationStyle = .custom
        viewModel.viewNavigator?.present(viewController: alertNav)
    }
    
}

// MARK: - internationalization string
fileprivate extension String {
    static let followText = ShowLiveLocalize("Scene.ShowLive.Audience.follow")
    static let followedText = ShowLiveLocalize("Scene.ShowLive.Audience.followed")
    static let unFollowedText = ShowLiveLocalize("Scene.ShowLive.Audience.unfollowed")
    static let anchorExitRoom = ShowLiveLocalize("Scene.ShowLive.Audience.anchorexit")
    
    static let rejectLinkMicTitle =  ShowLiveLocalize("Scene.ShowLive.LinkMic.requestreject")
    static let busyLinkMicTitle = ShowLiveLocalize("Scene.ShowLive.LinkMic.busy")
    
    static let exitAlertTitle = ShowLiveLocalize("Scene.ShowLive.LinkMic.exit")
    static let exitAlertWaitTitle = ShowLiveLocalize("Scene.ShowLive.Anchor.exitwait")
    static let exitAlertConfirmTitle = ShowLiveLocalize("Scene.ShowLive.Anchor.exitconfirm")
}
