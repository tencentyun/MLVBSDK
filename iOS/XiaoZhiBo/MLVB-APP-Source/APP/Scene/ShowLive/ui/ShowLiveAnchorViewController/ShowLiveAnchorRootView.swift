//
//  ShowLiveAnchorRootView.swift
//  XiaoZhiBoApp
//
//  Created by adams on 2021/9/28.
//

import UIKit
import TUIPusher
import TUICore

class ShowLiveAnchorRootView: UIView {

    private let viewModel: ShowLiveAnchorViewModel
    
    private var pusherViewStartResult = true
    
    lazy var exitButton: UIButton = {
        let button = UIButton.init(frame: .zero)
        button.setBackgroundImage(UIImage.init(named: "exit_room"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()
    
    lazy var roomMsgView: ShowLiveAnchorRoomMsgView = {
        let view = ShowLiveAnchorRoomMsgView.init(viewModel: viewModel)
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var pusherView: TUIPusherView = {
        let view = TUIPusherView.init(frame: .zero)
        view.setDelegate(self)
        view.backgroundColor = .lightGray
        return view
    }()
    
    lazy var pkButton: UIButton = {
        let button = UIButton.init(frame: .zero)
        button.setBackgroundImage(UIImage.init(named: "live_pk_start"), for: .normal)
        button.setBackgroundImage(UIImage(named: "live_pk_end"), for: .selected)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()
    
    lazy var closeButton: UIButton = {
        let button = UIButton.init(frame: .zero)
        button.setBackgroundImage(UIImage.init(named: "live_exit"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()
    
    lazy var moreButton: UIButton = {
        let button = UIButton.init(frame: .zero)
        button.setBackgroundImage(UIImage.init(named: "live_more"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()
    
    lazy var roomInfoView: ShowLiveRoomInfoView = {
        let view = ShowLiveRoomInfoView(type: .anchor)
        view.isHidden = true
        return view
    }()
    
    /// 在线用户
    lazy var onlineUsersView: ShowLiveOnlineUsersView = {
        let view = ShowLiveOnlineUsersView(delegate: self)
        view.isHidden = true
        return view
    }()
    /// 人气榜
    lazy var hotRankingView: ShowLiveHotRankingView = {
        let view = ShowLiveHotRankingView(frame: .zero)
        view.isHidden = true
        return view
    }()
    
    /// 广告外链视图
    lazy var adImageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.contentMode = .scaleAspectFill
        view.image = UIImage(named: "ad_default")
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()
    
    var isInPK = false {
        didSet {
            self.pkButton.isSelected = isInPK
        }
    }
    var isInLinkMic = false
    
    var currentAlert: UIAlertController?
    
    init(viewModel: ShowLiveAnchorViewModel, frame: CGRect = .zero) {
        self.viewModel = viewModel
        super.init(frame: frame)
        backgroundColor = .white
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
        setBottomMenuBtn(true)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        roomMsgView.layer.cornerRadius = 8
    }
    
    private func constructViewHierarchy() {
        addSubview(pusherView)
        addSubview(roomMsgView)
        addSubview(exitButton)
        addSubview(roomInfoView)
        addSubview(onlineUsersView)
        addSubview(adImageView)
        addSubview(hotRankingView)
        pusherView.addSubview(pkButton)
        pusherView.addSubview(closeButton)
        pusherView.addSubview(moreButton)
    }
    
    private func activateConstraints() {
        
        exitButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(5)
        }
        
        pusherView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        roomMsgView.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(80)
        }
        
        let width = bounds.width
        
        pkButton.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.trailing).offset(-width * 0.5 * (5.0 / 6.0))
            make.width.height.equalTo(44)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
        
        closeButton.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.trailing).offset(-width * 0.5 * 0.5)
            make.width.height.equalTo(44)
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
        
        moreButton.snp.makeConstraints { make in
            make.centerX.equalTo(self.snp.trailing).offset(-width * 0.5 * (1.0 / 6.0))
            make.width.height.equalTo(44)
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
        adImageView.snp.makeConstraints { make in
            make.trailing.equalTo(-16)
            make.size.equalTo(CGSize(width: 150, height: 44))
            make.top.equalTo(roomInfoView.snp.bottom).offset(40)
        }
        hotRankingView.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.height.equalTo(22)
            make.top.equalTo(roomInfoView.snp.bottom).offset(10)
        }
    }
    
    private func bindInteraction() {
        viewModel.viewResponder = self
        let pushURL = URLUtils.generatePushUrl(TUILogin.getUserID(), type: .RTC)
        pusherViewStartResult = pusherView.start(pushURL)
        
        pkButton.addTarget(self, action: #selector(pkButtonClick(sender:)), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(closeButtonClick(sender:)), for: .touchUpInside)
        moreButton.addTarget(self, action: #selector(moreButtonClick(sender:)), for: .touchUpInside)
        exitButton.addTarget(self, action: #selector(closeButtonClick(sender:)), for: .touchUpInside)
        adImageView.addTapGesture(target: self, action: #selector(adImageViewClick))
        hotRankingView.addTapGesture(target: self, action: #selector(hotRankingClick))
    }
    
    func setBottomMenuBtn(_ isHidden: Bool) {
        pkButton.isHidden = isHidden
        closeButton.isHidden = isHidden
        moreButton.isHidden = isHidden
    }
    
    func showToast(message: String) {
        makeToast(message)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        roomMsgView.resignFirstResponder()
    }
    
    @objc
    func keyboardFrameChange(noti : Notification) {
//        guard let info = noti.userInfo else {
//            return
//        }
//        guard let value = info[UIResponder.keyboardFrameEndUserInfoKey], value is CGRect else {
//            return
//        }
//        let rect = value as! CGRect
//        transform = CGAffineTransform(translationX: 0, y: -ScreenHeight+rect.minY)
    }
}

//MARK: - UIButton Touch Event
extension ShowLiveAnchorRootView {
    
    @objc func pkButtonClick(sender: UIButton) {
        if sender.isSelected {
            if isInPK {
                let alert = UIAlertController.init(title: "退出PK吗？", message: "", preferredStyle: .alert)
                let confirm = UIAlertAction.init(title: "确认", style: .default) { [weak self] _ in
                    guard let `self` = self else { return }
                    self.pusherView.stopPK()
                    self.pkButton.isSelected = false
                }
                let cancel = UIAlertAction.init(title: "取消", style: .cancel) { [weak self] _ in
                    guard let `self` = self else { return }
                    self.pkButton.isSelected = true
                }
                alert.addAction(confirm)
                alert.addAction(cancel)
                viewModel.showAlert(viewController: alert)
            }
            else {
                self.pusherView.cancelPKRequest()
                self.pkButton.isSelected = false
            }
        }
        else {
            if isInLinkMic {
                showToast(message: "正在忙线中，无法发起PK")
            }
            else {
                let alert = ShowLivePkAlert(viewModel: viewModel)
                alert.pkWithRoom = { [weak self] room in
                    guard let `self` = self else { return }
                    self.pusherView.sendPKRequest(room.ownerId)
                    self.pkButton.isSelected = true
                }
                alert.loadRoomsInfo()
                addSubview(alert)
                alert.snp.makeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
                alert.layoutIfNeeded()
                alert.show()
            }
        }
    }
    
    @objc func closeButtonClick(sender: UIButton) {
        let closeAlertViewController = UIAlertController.init(title: .exitAlertTitle, message: "", preferredStyle: .alert)
        let closeAction = UIAlertAction.init(title: .exitAlertConfirmTitle, style: .default) { [weak self] _ in
            guard let `self` = self else { return }
            
            self.pusherView.stop()
            self.viewModel.stopPush()
        }
        let cancelAction = UIAlertAction.init(title: .exitAlertWaitTitle, style: .cancel, handler: nil)
        closeAlertViewController.addAction(closeAction)
        closeAlertViewController.addAction(cancelAction)
        viewModel.showAlert(viewController: closeAlertViewController)
    }
    
    @objc func moreButtonClick(sender: UIButton) {
        let alert = ShowLiveMoreAlert(viewModel: viewModel)
        addSubview(alert)
        alert.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        alert.layoutIfNeeded()
        alert.show()
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

// MARK: - ShowLiveOnlineUsersDelegate
extension ShowLiveAnchorRootView: ShowLiveOnlineUsersDelegate {
    
    func showLiveOnlineUsersDidClickMore() {
        let alert = ShowLiveOnlineUsersAlertController(roomId: viewModel.groupId, userDataSource: viewModel.onlineUsers, delegate: nil)
        let alertNav = UINavigationController(rootViewController: alert)
        alertNav.modalPresentationStyle = .custom
        viewModel.viewNavigator?.present(viewController: alertNav)
    }
    
}

// MARK: - ShowLiveAnchorViewResponder
extension ShowLiveAnchorRootView: ShowLiveAnchorViewResponder {
    
    func refreshOnlineUsersView() {
        onlineUsersView.updateUI(userDataSource: viewModel.onlineUsers, userCount: viewModel.onlineUsersCount)
    }
    
    func switchCamera(isFront: Bool) {
        pusherView.switchCamera(isFront)
    }
}

// MARK: - TUIPusherViewDelegate
extension ShowLiveAnchorRootView: TUIPusherViewDelegate {
    func onPushStarted(_ pusherView: TUIPusherView, url: String) {
        setBottomMenuBtn(false)
        roomInfoView.isHidden = false
        onlineUsersView.isHidden = false
        adImageView.isHidden = !MLVBConfigManager.enableLiveRoomAdLink()
        hotRankingView.isHidden = false
        roomInfoView.start()
    }
    
    func onPushStoped(_ pusherView: TUIPusherView, url: String) {
        setBottomMenuBtn(true)
        roomMsgView.isHidden = false
        exitButton.isHidden = false
        
    }
    
    func onClickStartPushButton(_ pusherView: TUIPusherView, url: String, responseCallback completion: @escaping Response) {
        if !pusherViewStartResult {
            self.roomMsgView.isHidden = false
            self.exitButton.isHidden = false
            showToast(message: .authorizationText)
            completion(false)
            return
        }
        viewModel.createRoom { [weak self] (code, msg) in
            guard let `self` = self else { return }
            if (code == 0) {
                self.roomMsgView.isHidden = true
                self.exitButton.isHidden = true
                self.pusherView.setGroupId(self.viewModel.groupId)
                self.roomInfoView.setRoomInfo(self.viewModel.roomInfo)
                completion(true)
            } else {
                self.roomMsgView.isHidden = false
                self.exitButton.isHidden = false
                self.showToast(message: msg)
                completion(false)
                
            }
        }
    }
    
    // MARK: - PK delegate
    func onReceivePKRequest(_ pusherView: TUIPusherView, userId: String, responseCallback completion: @escaping Response) {
        TRTCLog.out("onReceivePKRequest userId: \(userId)")
        let alert = UIAlertController.init(title: String(format: .receivePKRequestTitle, userId), message: "", preferredStyle: .alert)
        let closeAction = UIAlertAction.init(title: .acceptPKTitle, style: .default) { action in
            completion(true)
        }
        let cancelAction = UIAlertAction.init(title: .refusePKTitle, style: .cancel) { action in
            completion(false)
        }
        alert.addAction(closeAction)
        alert.addAction(cancelAction)
        currentAlert = alert
        viewModel.showAlert(viewController: alert)
    }
    func onRejectPKResponse(_ pusherView: TUIPusherView, reason: Int32) {
        switch reason {
        case 1:
            showToast(message: .rejectPKRequestTitle)
        case 2:
            showToast(message: .busyPKTitle)
        default:
            break
        }
        isInPK = false
    }
    func onCancelPKRequest(_ pusherView: TUIPusherView) {
        if let alert = currentAlert {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    func onStartPK(_ pusherView: TUIPusherView) {
        isInPK = true
    }
    func onStopPK(_ pusherView: TUIPusherView) {
        isInPK = false
    }
    func onPKTimeout(_ pusherView: TUIPusherView) {
        if let alert = currentAlert {
            alert.dismiss(animated: true, completion: nil)
        }
        else {
            isInPK = false
        }
    }
    
    // MARK: - JoinAnchor delegate
    func onReceiveJoinAnchorRequest(_ pusherView: TUIPusherView, userId: String, responseCallback completion: @escaping Response) {
        
        let alert = UIAlertController.init(title: String(format: .receiveLinkMicRequestTitle, userId), message: "", preferredStyle: .alert)
        let confirm = UIAlertAction.init(title: .acceptLinkMicTitle,
                                         style: .default) { _ in
            completion(true)
        }
        let cancel = UIAlertAction.init(title: .refuseLinkMicTitle,
                                        style: .cancel) { _ in
            completion(false)
        }
        alert.addAction(confirm)
        alert.addAction(cancel)
        currentAlert = alert
        viewModel.showAlert(viewController: alert)
    }
    func onCancelJoinAnchorRequest(_ pusherView: TUIPusherView) {
        if let alert = currentAlert {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    func onStartJoinAnchor(_ pusherView: TUIPusherView) {
        isInLinkMic = true
    }
    func onStopJoinAnchor(_ pusherView: TUIPusherView) {
        isInLinkMic = false
    }
    func onJoinAnchorTimeout(_ pusherView: TUIPusherView) {
        if let alert = currentAlert {
            alert.dismiss(animated: true, completion: nil)
        }
        else {
            isInLinkMic = false
        }
    }
}

// MARK: - internationalization string
fileprivate extension String {
    static let authorizationText = ShowLiveLocalize("Scene.ShowLive.Authorization")
    static let receiveLinkMicRequestTitle = ShowLiveLocalize("Scene.ShowLive.LinkMic.requestreceive")
    static let acceptLinkMicTitle = ShowLiveLocalize("Scene.ShowLive.LinkMic.requestaccept")
    static let refuseLinkMicTitle = ShowLiveLocalize("Scene.ShowLive.LinkMic.requestrefuse")
    
    static let receivePKRequestTitle = ShowLiveLocalize("Scene.ShowLive.PK.requestreceive")
    static let acceptPKTitle = ShowLiveLocalize("Scene.ShowLive.LinkMic.requestaccept")
    static let refusePKTitle = ShowLiveLocalize("Scene.ShowLive.LinkMic.requestrefuse")
    static let rejectPKRequestTitle =  ShowLiveLocalize("Scene.ShowLive.PK.requestreject")
    static let busyPKTitle = ShowLiveLocalize("Scene.ShowLive.PK.busy")
    
    static let exitAlertTitle = ShowLiveLocalize("Scene.ShowLive.Anchor.exit")
    static let exitAlertWaitTitle = ShowLiveLocalize("Scene.ShowLive.Anchor.exitwait")
    static let exitAlertConfirmTitle = ShowLiveLocalize("Scene.ShowLive.Anchor.exitconfirm")
}
