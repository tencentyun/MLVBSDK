//
//  ShowLiveMoreViewController.swift
//  XiaoZhiBoApp
//
//  Created by jack on 2021/12/15.
//

import UIKit
import MJRefresh

// MARK: - 更多直播间Delegate
protocol ShowLiveMoreDelegate: AnyObject{
    
    /// 更多直播间房间点击事件
    /// - Parameters:
    ///    - roomInfo: 房间信息
    func showLiveMoreDidSelect(_ roomInfo: ShowLiveRoomInfo)
}

class ShowLiveMoreViewController: UIViewController {
    
    private lazy var contentView: UIView = {
        let view = UIView(frame: CGRect(x: 40, y: 0, width: ScreenWidth-40, height: ScreenHeight))
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .white
        label.font = UIFont(name: "PingFangSC-Medium", size: 24)
        label.text = .recommendTitle
        return label
    }()
    
    private lazy var collectionLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let width = floor((ScreenWidth - 40 - 10*3) / 2) - 1
        layout.itemSize = CGSize(width: width, height: 1.2 * width)
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
        view.backgroundColor = .black
        view.register(ShowLiveMoreCollectionCell.self, forCellWithReuseIdentifier: ShowLiveMoreCollectionCell.reuseIdentifier)
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.automaticallyAdjustsScrollIndicatorInsets = false
        view.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: kDeviceSafeBottomHeight, right: 10)
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    private var roomList: [ShowLiveRoomInfo] = []
    weak var delegate: ShowLiveMoreDelegate? = nil
    convenience init(delegate: ShowLiveMoreDelegate?) {
        self.init()
        self.delegate = delegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getRoomList()
    }
    
    @objc
    private func constructViewHierarchy() {
        view.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(collectionView)
    }
    
    @objc
    private func activateConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(20)
            make.top.equalTo(kDeviceSafeTopHeight)
        }
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview()
        }
    }
    
    @objc
    private func bindInteraction() {
        // 添加滑动手势
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panAction(gesture:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(panGesture)
        // 单击手势
        view.addTapGesture(target: self, action: #selector(tapDismiss), delegate: self)
        // 下拉
        collectionView.setupNormalRefreshHeader(target: self, action: #selector(getRoomList))
    }
    
    deinit {
        TRTCLog.out("deinit \(type(of: self))")
    }
}

// MARK: - getData
extension ShowLiveMoreViewController {
    
    /// 获取房间列表
    @objc
    private func getRoomList() {
        guard HttpLogicRequest.sdkAppId != 0 else {
            view.makeToast(.appidErrorText)
            collectionView.mj_header?.endRefreshing()
            return
        }
        RoomService.shared.getRoomList(sdkAppID: HttpLogicRequest.sdkAppId, roomType: .showLive) { [weak self] (roomInfos) in
            guard let self = self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.roomList = roomInfos
                self.collectionView.reloadData()
                self.collectionView.mj_header?.endRefreshing()
            }
        } failed: { [weak self] (code, message) in
            guard let self = self else { return }
            TRTCLog.out("error: get room list fail. code: \(code), message:\(message)")
            self.view.makeToast(.listFailedText)
            self.collectionView.mj_header?.endRefreshing()
        }
    }
}

// MARK: - Swipe Gesture 滑动手势
extension ShowLiveMoreViewController {
    
    ///  滑动手势响应
    @objc
    private func panAction(gesture: UIPanGestureRecognizer) {
        let translationPoint = gesture.translation(in: view)
        guard translationPoint.x >= 0 else {
            return
        }
        // 手势滑动比例
        let touchPer = translationPoint.x / view.bounds.size.width
        let per = min(1.0, touchPer)
        if gesture.state == .changed {
            updateInteractiveTransition(per: per)
        } else if gesture.state == .ended || gesture.state == .changed {
            if per >= 0.5 {
                finishInteractiveTransition()
            } else {
                cancelInteractiveTransition()
            }
        }
    }
    /// 更新手势滑动动画
    private func updateInteractiveTransition(per: CGFloat) {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2*(1-per))
        let translationX = per * view.bounds.size.width
        contentView.transform = CGAffineTransform(translationX: translationX, y: 0)
    }
    /// 取消手势滑动
    private func cancelInteractiveTransition() {
        updateInteractiveTransition(per: 0)
    }
    /// 完成动画
    private func finishInteractiveTransition(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.25) { [weak self] in
            guard let self = self else { return }
            self.updateInteractiveTransition(per: 1.0)
        } completion: { [weak self](_) in
            completion?()
            guard let self = self else { return }
            self.view.removeFromSuperview()
            self.willMove(toParent: nil)
            self.removeFromParent()
        }
    }
}

// MARK: - UIGestureRecognizerDelegate 单击手势处理
extension ShowLiveMoreViewController: UIGestureRecognizerDelegate{
    /// 点击dismiss视图
    @objc
    private func tapDismiss() {
        finishInteractiveTransition()
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let point = gestureRecognizer.location(in: contentView)
        return point.x <= 0
    }
}

// MARK: - UICollectionViewDataSource
extension ShowLiveMoreViewController: UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return roomList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseId = ShowLiveMoreCollectionCell.reuseIdentifier
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as! ShowLiveMoreCollectionCell
        cell.updateUI(data: roomList[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ShowLiveMoreViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < roomList.count else {
            return
        }
        let roomInfo = roomList[indexPath.item]
        finishInteractiveTransition { [weak self] in
            self?.delegate?.showLiveMoreDidSelect(roomInfo)
        }
    }
}

// MARK: - internationalization string
fileprivate extension String {
    static let appidErrorText = ShowLiveLocalize("Scene.ShowLive.List.invalidappid")
    static let nocontentText = ShowLiveLocalize("Scene.ShowLive.List.nocontentnow~")
    static let listFailedText = ShowLiveLocalize("Scene.ShowLive.List.getlistfailed")
    static let recommendTitle = ShowLiveLocalize("Scene.ShowLive.MoreLiveRoom.recommend")
}
