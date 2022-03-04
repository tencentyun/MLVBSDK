//
//  ShowLiveListRootView.swift
//  XiaoZhiBoApp
//
//  Created by adams on 2021/9/27.
//

import UIKit
import MJRefresh

class ShowLiveListRootView: UIView {
    let viewModel: ShowLiveListViewModel
    var scrollviewBaseContentOffsetY:CGFloat = 0.0
    private var isViewReady = false
    
    init(frame: CGRect = .zero, viewModel: ShowLiveListViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        self.viewModel.viewResponder = self
        backgroundColor = UIColor("F4F5F9")
    }
    
    required init?(coder: NSCoder) {
        fatalError("can't init this viiew from coder")
    }
    
    lazy var loading: UIActivityIndicatorView = {
        let loading = UIActivityIndicatorView()
        if #available(iOS 13.0, *) {
            loading.style = .large
        }
        return loading
    }()
    
    let backgroundLayer: CALayer = {
        // fillCode
        let layer = CAGradientLayer()
        layer.colors = [UIColor.init(0x13294b).cgColor, UIColor.init(0x000000).cgColor]
        layer.locations = [0.2, 1.0]
        layer.startPoint = CGPoint(x: 0.4, y: 0)
        layer.endPoint = CGPoint(x: 0.6, y: 1.0)
        return layer
    }()
    
    let createButton: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 18)
        btn.titleLabel?.textColor = .white
        btn.setImage(UIImage.init(named: "add"), for: .normal)
        btn.setTitle(.createText, for: .normal)
        btn.adjustsImageWhenHighlighted = false
        btn.clipsToBounds = true
        btn.backgroundColor = UIColor("006EFF")
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: -4)
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        return btn
    }()
    
    let roomListCollection: UICollectionView = {
        let margin = 20
        let layout = UICollectionViewFlowLayout.init()
        let itemWidth = floor((ScreenWidth - CGFloat(3*margin)) * 0.5)
        layout.itemSize = CGSize.init(width: itemWidth, height: itemWidth * 180 / 158)
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets.init(top: 20, left: 0, bottom: 137+90, right: 0)
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ShowLiveListCell.self, forCellWithReuseIdentifier: "ShowLiveListCell")
        collectionView.backgroundColor = UIColor.clear
        collectionView.bounces = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
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
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        createButton.layer.cornerRadius = createButton.frame.height * 0.5
    }

    func constructViewHierarchy() {
        /// 此方法内只做add子视图操作
        addSubview(roomListCollection)
        addSubview(createButton)
        addSubview(loading)
    }

    func activateConstraints() {
        roomListCollection.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        createButton.sizeToFit()
        let createBtnWidth = createButton.frame.width
        createButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-90 - kDeviceSafeBottomHeight)
            make.centerX.equalToSuperview()
            make.width.equalTo(createBtnWidth+40)
            make.height.equalTo(52)
        }
        loading.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.width.equalTo(60)
        }
    }

    func bindInteraction() {
        createButton.addTarget(self, action: #selector(createButtonAction(_:)), for: .touchUpInside)
        roomListCollection.delegate = self
        roomListCollection.dataSource = self
        let header = MJRefreshStateHeader(refreshingTarget: self, refreshingAction: #selector(refreshListAction))
        header.setTitle(.pullrefreshText, for: .pulling)
        header.setTitle(.refreshingText, for: .refreshing)
        header.setTitle("", for: .idle)
        header.lastUpdatedTimeLabel?.isHidden = true
        roomListCollection.mj_header = header
    }
    
    @objc
    func createButtonAction(_ sender: UIButton) {
        viewModel.pushShowLiveAnchorRoom()
    }
    
    @objc
    func refreshListAction() {
        viewModel.getRoomList()
    }

}

// MARK: - UICollectionViewDelegate
extension ShowLiveListRootView: UICollectionViewDelegate {
    public func updateBaseCollectionOffsetY() -> Void {
        scrollviewBaseContentOffsetY = roomListCollection.contentOffset.y
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 检查是否是自己的房间
        viewModel.clickRoomItem(index: indexPath.row)
        collectionView.panGestureRecognizer.isEnabled = true
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if fabsf(Float(collectionView.contentOffset.y - scrollviewBaseContentOffsetY)) <= 0.001 &&
            !collectionView.isDragging &&
            !collectionView.isDecelerating {
            //bugfix 7P下拉刷新后，collectionCell无法选中
            collectionView.panGestureRecognizer.isEnabled = false
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1) {
                collectionView.panGestureRecognizer.isEnabled = true
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ShowLiveListRootView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.roomList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShowLiveListCell", for: indexPath)
        if let roomCell = cell as? ShowLiveListCell {
            let roomInfo = viewModel.roomList[indexPath.item]
            roomCell.setCell(model: roomInfo)
        }
        return cell
    }
    
}

// MARK: - ShowLiveListViewResponder
extension ShowLiveListRootView: ShowLiveListViewResponder {
    
    func showToast(message: String) {
        makeToast(message)
    }
    
    func refreshList() {
        roomListCollection.reloadData()
    }
    
    func stopListRefreshing() {
        roomListCollection.mj_header?.endRefreshing()
    }
    
    func showLoading(message: String) {
        loading.startAnimating()
    }
    
    func hideLoading() {
        loading.stopAnimating()
    }
    
}

// MARK: - internationalization string
fileprivate extension String {
    static let pullrefreshText = ShowLiveLocalize("Scene.ShowLive.List.pullrefresh")
    static let refreshingText = ShowLiveLocalize("Scene.ShowLive.List.refreshing")
    static let createText = ShowLiveLocalize("Scene.ShowLive.List.createroom")
}
