//
//  ShowLiveScrollViewController.swift
//  XiaoZhiBoApp
//
//  Created by jack on 2021/12/17.
//

import UIKit
import Toast_Swift

protocol ShowLiveScrollViewResponder: ShowLiveAudienceViewController {
    /// 直播列表索引
    func listIndex() -> Int
    /// 当前是否连麦, 连麦中不可滑动
    func isLinking() -> Bool
    /// 开始拉流
    func startPlay()
    /// 停止拉流
    func stopPlay()
    /// 暂停音频
    func pauseAudio()
    /// 恢复音频
    func resumeAudio()
    /// 暂停视频
    func pauseVideo()
    /// 恢复视频
    func resumeVideo()
    /// 加入IM群组
    func enterIMGroup()
    /// 退出IM群组
    func leaveIMGroup()
}

class ShowLiveScrollViewController: UIViewController {

    /// 当前PageViewController
    private lazy var currentPageViewController: UIPageViewController = {
        let controller = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .vertical, options: nil)
        controller.delegate = self
        controller.dataSource = self
        return controller
    }()
    
    // 最大缓存数量
    private var maxCachedCount: Int = 3;
    // 缓存直播间 避免重复创建
    private var cachedLiveRooms: [ShowLiveScrollViewResponder] = []
    // 数据源
    private var roomDataSource: [ShowLiveRoomInfo] = []
    // 当前直播间控制视图
    private var currentLiveRoom: ShowLiveScrollViewResponder? = nil {
        didSet {
            oldValue?.linkStateChanged = nil
            oldValue?.leaveIMGroup()
            currentLiveRoom?.linkStateChanged = { [weak self] (isLinking) in
                guard let self = self else { return }
                // 重置当前CurrentViewController, 优化交互体验
                self.resetPageViewController()
            }
            currentLiveRoom?.enterIMGroup()
        }
    }
    // 当前页面索引
    private var currentIndex: Int {
        return currentLiveRoom?.listIndex() ?? 0
    }
    /// 便利构造器 - roomInfo
    /// - Parameter roomInfo: 当前房间信息
    convenience init(roomInfo: ShowLiveRoomInfo) {
        self.init()
        self.roomDataSource.append(roomInfo)
    }
    
    /// 便利构造器 - ShowLiveAudienceViewController
    /// - Parameter viewController: 观众直播间视图控制器
    convenience init(viewController: ShowLiveAudienceViewController) {
        self.init()
        self.roomDataSource.append(viewController.viewModel.roomInfo)
        self.currentLiveRoom = viewController
        // 悬浮播放恢复，需要重置列表索引为0
        self.currentLiveRoom?.pageIndex = 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // 添加视图
        constructViewHierarchy()
        bindInteraction()
        view.backgroundColor = .black
        // 初始化默认视图
        setupPageViewController()
        // 请求房间列表
        requestRoomList()
    }
    
    private func constructViewHierarchy() {
        addChild(currentPageViewController)
        currentPageViewController.didMove(toParent: self)
        currentPageViewController.view.frame = UIScreen.main.bounds
        view.addSubview(currentPageViewController.view)
    }
    
    private func bindInteraction() {
        currentPageViewController.scrollView?.delegate = self
    }
    
    deinit {
        TRTCLog.out("deinit \(type(of: self))")
        if ShowLiveFloatingManager.shared.enableFloating {
            for liveRoom in cachedLiveRooms {
                if liveRoom.listIndex() != currentIndex {
                    liveRoom.stopPlay()
                }
            }
        } else {
            for liveRoom in cachedLiveRooms {
                liveRoom.stopPlay()
            }
            currentLiveRoom?.leaveIMGroup()
        }
        currentLiveRoom = nil
        currentPageViewController.view.removeFromSuperview()
        currentPageViewController.willMove(toParent: self)
        currentPageViewController.removeFromParent()
    }
}

// MARK: - 房间列表请求
extension ShowLiveScrollViewController {
    /// 获取房间列表
    func requestRoomList() {
        let sdkAppID = HttpLogicRequest.sdkAppId
        RoomService.shared.getRoomList(sdkAppID: sdkAppID, roomType: .showLive) { [weak self] (roomInfos) in
            guard let self = self else { return }
            // 是否需要重置PageViewController缓存池
            var needResetPageViewController = false
            for data in roomInfos {
                // 去重
                if !self.roomDataSource.contains(where: {$0.roomID == data.roomID}) {
                    self.roomDataSource.append(data)
                    // 检测到数据源更新，需要重置PageViewController缓存池
                    needResetPageViewController = true
                }
            }
            if needResetPageViewController {
                self.resetPageViewController()
            }
        } failed: { [weak self] (code, message) in
            guard let self = self else { return }
            TRTCLog.out("error: get room list fail. code: \(code), message:\(message)")
            self.view.makeToast(.listFailedText)
        }
    }
}


// MARK: - UIPageViewControllerDataSource
extension ShowLiveScrollViewController: UIPageViewControllerDataSource {
    // 获取前一个直播间
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        debugPrint("Scroll viewControllerBefore currentIndex: \(currentIndex)")
        if currentLiveRoom?.isLinking() == true {
            // 连麦中，不支持滑动
            return nil
        }
        guard let liveRoom = showLiveViewController(forIndex: currentIndex - 1) else {
            return nil
        }
        return liveRoom;
    }
    // 获取后一个直播间
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        debugPrint("Scroll viewControllerAfter currentIndex: \(currentIndex)")
        if currentLiveRoom?.isLinking() == true {
            // 连麦中，不支持滑动
            return nil
        }
        guard let liveRoom = showLiveViewController(forIndex: currentIndex + 1) else {
            view.makeToast(.noContentText)
            return nil
        }
        return liveRoom;
    }
}

// MARK: - UIScrollViewDelegate
extension ShowLiveScrollViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // 滑动到最后一个直播间，检查是否需要更新数据源
        if currentIndex == self.roomDataSource.count - 1 {
            requestRoomList()
        }
    }
}

// MARK: - UIPageViewControllerDelegate
extension ShowLiveScrollViewController: UIPageViewControllerDelegate {
    // 开始滚动回调
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        debugPrint("Scroll willTransitionTo currentIndex: \(currentIndex)")
        // 此处实现视频流的预加载
        // pendingViewControllers: 需要预加载的直播视图
        for pendingViewController in pendingViewControllers {
            if let liveRoom = pendingViewController as? ShowLiveScrollViewResponder {
                debugPrint("Scroll willTransitionTo pendingViewController index: \(liveRoom.listIndex())")
                liveRoom.startPlay()
                liveRoom.pauseAudio()
            }
        }
    }

    // 滚动结束回调
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        debugPrint("Scroll didFinishAnimating \(finished) transitionCompleted: \(completed) cacheRoomCount: \(cachedLiveRooms.count)")
        // 滚动结束事件处理
        if finished == true {
            // 停止滑动，当前直播间处理
            if completed == true, let liveRoom = (pageViewController.viewControllers?.first as? ShowLiveScrollViewResponder) {
                debugPrint("Scroll didFinishAnimating currentIndex: \(liveRoom.listIndex())")
                liveRoom.resumeVideo()
                liveRoom.resumeAudio()
                currentLiveRoom = liveRoom
            }
            // 暂停其它直播间视频流、退出IM群组
            for liveRoom in cachedLiveRooms {
                if liveRoom.listIndex() != currentIndex {
                    debugPrint("Scroll didFinishAnimating pauseIndex: \(liveRoom.listIndex())")
                    liveRoom.pauseAudio()
                    liveRoom.pauseVideo()
                    liveRoom.leaveIMGroup()
                }
            }
        }
    }
}

// MARL: - 获取构造直播视图控制器
extension ShowLiveScrollViewController {
    
    /// 设置初始视图
    func setupPageViewController() {
        if let liveRoom = currentLiveRoom {
            currentPageViewController.setViewControllers([liveRoom], direction: .reverse, animated: false, completion: nil)
            cachedLiveRooms.append(liveRoom)
            return
        }
        // 获取当前直播间
        guard let liveRoom = showLiveViewController(forIndex: 0) else {
            return
        }
        currentLiveRoom = liveRoom
        currentPageViewController.setViewControllers([liveRoom], direction: .reverse, animated: false) { [weak self] _ in
            guard let self = self else { return }
            self.currentLiveRoom?.startPlay()
        }
    }
    
    /// 重置默认视图
    /// - Note: 此操作会重置PageViewController缓存池
    func resetPageViewController() {
        if let liveRoom = currentLiveRoom {
            currentPageViewController.setViewControllers([liveRoom], direction: .reverse, animated: false, completion: nil)
        }
    }
    
    /// 根据索引获取直播间实例
    /// - Parameter index: 房间索引
    /// - Returns: 直播间视图控制器
    private func showLiveViewController(forIndex index:Int) -> ShowLiveScrollViewResponder? {
        debugPrint("Scroll get nextLiveRoom: \(index)")
        guard index >= 0, index < roomDataSource.count else {
            return nil
        }
        // 有缓存，则从缓存获取
        if let liveRoom = cachedLiveRooms.first( where: { $0.listIndex() == index} ) {
            return liveRoom
        }
        // 无缓存，创建新的直播间视图控制器。
        let roomModel = roomDataSource[index]
        let liveRoom = showLiveViewController(forRoomInfo: roomModel, pageIndex: index)
        
        var willCloseLiveRoom:ShowLiveScrollViewResponder? = nil
        if currentIndex < index {
            // 往上滑动：队尾插，队首删
            cachedLiveRooms.append(liveRoom)
            if cachedLiveRooms.count > maxCachedCount {
                willCloseLiveRoom = cachedLiveRooms.removeFirst()
            }
        } else {
            // 往下滑动：队首插，队尾删
            cachedLiveRooms.insert(liveRoom, at: 0)
            if cachedLiveRooms.count > maxCachedCount {
                willCloseLiveRoom = cachedLiveRooms.removeLast()
            }
        }
        // 关闭直播间
        willCloseLiveRoom?.stopPlay()
        return liveRoom
    }
    
    /// 根据 RoomInfo 实例化直播间视图控制器
    /// - Parameters:
    ///   - roomInfo: 房间信息
    ///   - pageIndex: 房间索引
    /// - Returns: 直播视图控制器
    private func showLiveViewController(forRoomInfo roomInfo: ShowLiveRoomInfo, pageIndex: Int) -> ShowLiveScrollViewResponder {
        let viewModel = ShowLiveAudienceViewModel.init(roomInfo: roomInfo)
        let showLiveController = ShowLiveAudienceViewController.init(viewModel: viewModel, pageIndex: pageIndex)
        return showLiveController
    }
}

// MARK: - UIPageViewController 滑动扩展
fileprivate extension UIPageViewController {
    /// 获取当前滚动的ScrollView
    var scrollView: UIScrollView? {
        for view in view.subviews {
            if let subView = view as? UIScrollView {
                return subView
            }
        }
        return nil
    }
}

// MARK: - internationalization string
fileprivate extension String {
    static let noContentText = ShowLiveLocalize("Scene.ShowLive.List.nocontentnow~")
    static let listFailedText = ShowLiveLocalize("Scene.ShowLive.List.getlistfailed")
}
