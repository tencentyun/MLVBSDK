//
//  ShowLiveFloatingView.swift
//  XiaoZhiBoApp
//
//  Created by jack on 2021/12/21.
//

import UIKit
import TUIPlayer

fileprivate let TabBarHeight: CGFloat = kDeviceIsIphoneX ? (49.0 + 34.0):(49.0)
/// 悬浮框视图Size
fileprivate let FloatWindowSize = CGSize(width: 150.0, height: 200.0)
/// 悬浮框视图默认frame
fileprivate var WindowDefaultFrame: CGRect = CGRect(x: ScreenWidth - FloatWindowSize.width - 10, y: ScreenHeight - FloatWindowSize.height - TabBarHeight, width: FloatWindowSize.width, height: FloatWindowSize.height)

// MARK: - ShowLiveFloatingManager
class ShowLiveFloatingManager {
    /// 单例
    static let shared: ShowLiveFloatingManager = ShowLiveFloatingManager()
    /// 是否支持悬浮框，Default is true
    var enableFloating: Bool = true
    /// 是否显示悬浮框
    private(set) var isFloating: Bool = false
    /// 当前悬浮框聊天室ID
    var currentRoomId: String {
        return floatWindow?.roomInfo?.roomID ?? ""
    }
    /// 悬浮框视图
    private var floatWindow: ShowLiveFloatingWindow? = nil
    /// 原直播视图控制器
    private var sourceViewController: ShowLiveAudienceViewController? = nil
    
    /// 初始化默认数据
    private func initData() {
        sourceViewController = nil
        floatWindow = nil
        isFloating =  false
    }
}

// MARK: - 悬浮框视图控制
extension ShowLiveFloatingManager {
    
    /// 展示悬浮框-直播间挂起
    public func showFloating(from viewController: ShowLiveAudienceViewController) {
        if let oldSource = sourceViewController {
            if oldSource == viewController {
                // 防止多次点击
                return
            } else {
                // 清理原直播间数据
                closeWindowAndExitRoom()
            }
        }
        // 开始后台挂起 - 直播间截图
        guard let sourceSnapshot = viewController.view.snapshotView(afterScreenUpdates: false) else {
            return
        }
        // 获取播放PlayerView容器View
        guard let sourceRootView = viewController.view as? ShowLiveAudienceRootView else {
            return
        }
        // PlayerView处理 - 只展示播放视图
        sourceRootView.updatePlayerViewUIState(.TUIPLAYER_UISTATE_VIDEOONLY)
        
        sourceViewController = viewController
        // 构造直播间截图Window - 动画过渡，过渡完销毁
        var sourceWindow: UIWindow? = makeSnapshotWindow(snapshot: sourceSnapshot)
        sourceWindow?.frame.size = sourceSnapshot.frame.size
        sourceWindow?.frame.origin = .zero
        sourceWindow?.makeKeyAndVisible()
        // 构造悬浮框视图Window
        let targetWindow = ShowLiveFloatingWindow(frame: WindowDefaultFrame,
                                                  roomInfo: viewController.viewModel.roomInfo,
                                                  playerView: sourceRootView.playerView,
                                                  delegate: self)
        targetWindow.makeKeyAndVisible()
        floatWindow = targetWindow
        // 开始动画
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            sourceWindow?.frame = WindowDefaultFrame
            sourceWindow?.alpha = 0.0
        } completion: { _ in
            sourceWindow = nil
        }
        // 直播间控制器退出
        if let nav = viewController.navigationController {
            nav.popViewController(animated: false)
        } else {
            viewController.dismiss(animated: false, completion: nil)
        }
        isFloating = true
    }
    
    /// 关闭悬浮框-恢复直播间
    public func hiddenFloatingAndResume(from viewController: UIViewController) {
        // 获取悬浮框Window
        guard let sourceWindow = floatWindow else {
            closeWindowAndExitRoom()
            return
        }
        // 获取直播间视图控制View
        guard let targetRootView = sourceViewController?.view as? ShowLiveAudienceRootView else {
            return
        }
        // 恢复直播间视图
        targetRootView.updatePlayerViewUIState(.TUIPLAYER_UISTATE_DEFAULT)
        // 获取截图
        guard let targetSnapshot = targetRootView.snapshotView(afterScreenUpdates: true) else {
            return
        }
        // 构造直播间视图Window - 仅做动画过渡，动画结束销毁
        var targetWindow: UIWindow? = makeSnapshotWindow(snapshot: targetSnapshot)
        targetWindow?.frame = sourceWindow.frame
        targetWindow?.alpha = 1.0
        targetWindow?.makeKeyAndVisible()
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            targetWindow?.frame = UIScreen.main.bounds
        } completion: { [weak self] (finish) in
            guard let self = self else { return }
            guard let sourceVC = self.sourceViewController else {
                return
            }
            // 悬浮框视图需要提前销毁，不然页面会闪一下
            self.floatWindow = nil
            let scrollController = ShowLiveScrollViewController(viewController: sourceVC)
            if let fromVC = viewController as? UINavigationController {
                scrollController.hidesBottomBarWhenPushed = true
                fromVC.pushViewController(scrollController, animated: false)
            } else if let fromNav = viewController.navigationController {
                scrollController.hidesBottomBarWhenPushed = true
                fromNav.pushViewController(scrollController, animated: false)
            } else {
                viewController.present(scrollController, animated: false, completion: nil)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                guard let self = self else { return }
                // 清理数据
                targetWindow = nil
                self.initData()
            }
        }
    }
    
    /// 关闭悬浮框-退出直播间
    public func closeWindowAndExitRoom(completion: (() -> ())? = nil) {
        // 停止拉流
        floatWindow?.playerView?.stopPlay()
        if let viewModel = sourceViewController?.viewModel {
            // 退出房间
            viewModel.exitRoom {
                completion?()
            } failed: { code, error in
                completion?()
                debugPrint("exit room fail code: \(code), msg: \(error)")
            }
        } else {
            completion?()
        }
        // 初始化数据
        initData()
    }
    
}

// MARK: - ShowLiveFloatingWindowDelegate
extension ShowLiveFloatingManager: ShowLiveFloatingWindowDelegate {
    /// 悬浮框视图点击事件
    func showLiveFloatingDidClickView() {
        guard let currentController = currentViewController() else { return }
        hiddenFloatingAndResume(from: currentController)
    }
    /// 悬浮框视图Frame改变
    func showLiveFloatingDidChangedFrame() {
        guard let window = floatWindow else {
            return
        }
        WindowDefaultFrame = window.frame
    }
    /// 悬浮框视图关闭按钮点击
    func showLiveFloatingDidClickClose() {
        closeWindowAndExitRoom()
    }
}

// MARK: - Private
extension ShowLiveFloatingManager {
    /// 构造截图window
    private func makeSnapshotWindow(snapshot: UIView) -> UIWindow {
        let window = UIWindow(frame: .zero)
        window.backgroundColor = .clear
        window.clipsToBounds = true
        window.windowLevel = .statusBar - 1
        snapshot.frame.origin = .zero
        window.addSubview(snapshot)
        return window
    }
    /// 获取当前视图控制器
    private func currentViewController() -> UIViewController? {
        guard let rootViewController = (UIApplication.shared.delegate as? AppDelegate)?.window?.rootViewController else {
            return nil
        }
        if let nav = rootViewController as? UINavigationController {
            return nav.topViewController
        }
        if let tabBarViewController = rootViewController as? UITabBarController  {
            if let nav = tabBarViewController.selectedViewController as? UINavigationController {
                return nav.topViewController
            }
            return tabBarViewController.selectedViewController
        }
        return rootViewController
    }
}

// MARK: - ShowLiveFloatingWindowDelegate 悬浮框视图事件代理
protocol ShowLiveFloatingWindowDelegate: AnyObject {
    /// 悬浮框点击关闭
    func showLiveFloatingDidClickClose()
    /// 悬浮框视图Frame改变
    func showLiveFloatingDidChangedFrame()
    /// 悬浮框点击
    func showLiveFloatingDidClickView()
}

// MARK: - 悬浮框视图
class ShowLiveFloatingWindow: UIWindow {
    /// 当前的房间信息
    public var roomInfo: ShowLiveRoomInfo? = nil
    /// 播放视图
    public weak var playerView: TUIPlayerView? = nil
    
    /// 便利构造器 ShowLiveFloatingWindow
    /// - Parameters:
    ///   - frame: 悬浮框视图Frame
    ///   - roomInfo: 房间信息
    ///   - playerView: TUIPlayerView
    ///   - delegate: 悬浮框事件回调
    convenience init(frame: CGRect,
                     roomInfo: ShowLiveRoomInfo,
                     playerView: TUIPlayerView,
                     delegate: ShowLiveFloatingWindowDelegate?) {
        self.init(frame: frame)
        self.windowLevel = .statusBar - 2
        self.backgroundColor = .clear
        self.delegate = delegate
        self.playerView = playerView
        self.roomInfo = roomInfo
        self.constructViewHierarchy()
        self.activateConstraints()
        self.bindInteraction()
    }
    
    private weak var delegate: ShowLiveFloatingWindowDelegate? = nil
    /// 关闭按钮
    private lazy var closeBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "exit_room"), for: .normal)
        return button
    }()
    /// 手势开始触摸点
    private var beganPoint: CGPoint?
    
    private func constructViewHierarchy() {
        if let playerView = self.playerView {
            if playerView.superview != nil {
                playerView.removeFromSuperview()
            }
            addSubview(playerView)
        }
        addSubview(closeBtn)
    }
    
    private func activateConstraints() {
        playerView?.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        closeBtn.snp.makeConstraints { make in
            make.width.height.equalTo(32)
            make.trailing.equalTo(-10)
            make.top.equalTo(10)
        }
    }
    
    private func bindInteraction() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewDidClick))
        addGestureRecognizer(tap)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(viewDidDrag(pan:)))
        addGestureRecognizer(pan)
        tap.require(toFail: pan)
        
        closeBtn.addTarget(self, action: #selector(closeDidClick), for: .touchUpInside)
    }
    
    deinit {
        TRTCLog.out("deinit \(type(of: self))")
    }
}

// MARK: - UITouch Event
extension ShowLiveFloatingWindow {
    /// 悬浮框点击事件
    @objc
    private func viewDidClick() {
        delegate?.showLiveFloatingDidClickView()
    }
    /// 关闭按钮点击事件
    @objc
    private func closeDidClick() {
        delegate?.showLiveFloatingDidClickClose()
    }
    /// 悬浮框视图滑动事件
    @objc
    private func viewDidDrag(pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .began:
            beganPoint = pan.location(in: self)
        case .changed:
            guard let beganPoint = beganPoint else {
                return
            }
            let point = pan.location(in: self)
            let offsetX = point.x - beganPoint.x
            let offsetY = point.y - beganPoint.y
            let coefficient: CGFloat = 1.01
            let origin = self.frame.origin
            self.frame.origin = CGPoint(x: origin.x + offsetX * coefficient, y: origin.y + offsetY * coefficient)
        case .cancelled, .ended:
            let currentCenterX = self.frame.origin.x + self.frame.width/2.0
            let finalOriginX = (currentCenterX <= ScreenWidth/2.0) ? 10 : (ScreenWidth - 10 - self.frame.width)
            UIView.animate(withDuration: 0.2) { [weak self] in
                guard let self = self else { return }
                self.frame.origin.x = finalOriginX
            } completion: { [weak self] (_) in
                guard let self = self else { return }
                self.delegate?.showLiveFloatingDidChangedFrame()
            }
        default:
            break
        }
    }
}
