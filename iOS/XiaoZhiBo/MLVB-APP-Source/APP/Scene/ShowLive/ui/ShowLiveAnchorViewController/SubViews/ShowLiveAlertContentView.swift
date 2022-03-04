//
//  ShowLiveAlertContentView.swift
//  XiaoZhiBo
//
//  Created by adams on 2021/9/29.
//  Copyright © 2021 Tencent. All rights reserved.
//

import UIKit
import TUICore

// MARK: - Base View
class ShowLiveAlertContentView: UIView {
    lazy var bgView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        view.alpha = 0.6
        return view
    }()
    lazy var contentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .black
        label.font = UIFont(name: "PingFangSC-Medium", size: 24)
        return label
    }()
    
    let viewModel: ShowLiveAnchorViewModel
    
    public var willDismiss: (()->())?
    public var didDismiss: (()->())?
    
    public init(frame: CGRect = .zero, viewModel: ShowLiveAnchorViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        contentView.transform = CGAffineTransform(translationX: 0, y: ScreenHeight)
        alpha = 0
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
    
    public func show() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
            self.contentView.transform = .identity
        }
    }
    
    public func dismiss() {
        if let action = willDismiss {
            action()
        }
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
            self.contentView.transform = CGAffineTransform(translationX: 0, y: ScreenHeight)
        } completion: { (finish) in
            if let action = self.didDismiss {
                action()
            }
            self.removeFromSuperview()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else {
            return
        }
        if !contentView.frame.contains(point) {
            dismiss()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        contentView.roundedRect(rect: contentView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 12, height: 12))
    }
    
    func constructViewHierarchy() {
        addSubview(bgView)
        addSubview(contentView)
        contentView.addSubview(titleLabel)
    }
    func activateConstraints() {
        bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(32)
        }
    }
    func bindInteraction() {
        
    }
}

// MARK: - PK View
class ShowLivePkAlert: ShowLiveAlertContentView {
    
    public var roomInfos: [ShowLiveRoomInfo] = []
    public var isLoading: Bool = false
    public var pkWithRoom: ((ShowLiveRoomInfo)->Void)? = nil
    
    public lazy var anchorTable: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.register(ShowLivePkAlertCell.classForCoder(), forCellReuseIdentifier: "ShowLivePkAlertCell")
        table.delegate = self
        table.dataSource = self
        table.separatorColor = UIColor.clear
        table.allowsSelection = true
        return table
    }()
    
    public override func didMoveToSuperview() {
        anchorTable.backgroundColor = .white
        self.addSubview(anchorTable)
        anchorTable.snp.remakeConstraints { (make) in
            make.leading.bottom.width.equalTo(self)
            make.height.equalTo(360)
        }
    }
    
    public func endLoading() {
        isLoading = false
        anchorTable.reloadData()
    }
    
    public func loadRoomsInfo() {
        anchorTable.reloadData()
        isLoading = true
        viewModel.getRoomList { [weak self] (showLiveRoomInfos) in
            guard let `self` = self else { return }
            if showLiveRoomInfos.count > 0 {
                DispatchQueue.main.async {
                    self.roomInfos = showLiveRoomInfos.filter { roomInfo in
                        roomInfo.ownerId != TUILogin.getUserID()
                    }
                    self.endLoading()
                }
            } else {
                self.endLoading()
            }
        }
    }
}
// MARK: - UITableViewDelegate, UITableViewDataSource
extension ShowLivePkAlert: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .clear
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = .white
        }
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if roomInfos.count > 0 {
            return " "
        }
        return isLoading ? .loadingText : .noAnchorText
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomInfos.count > 5 ? 5 : roomInfos.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShowLivePkAlertCell",for: indexPath)
        if let pkcell = cell as? ShowLivePkAlertCell {
            if indexPath.row < roomInfos.count {
                let room = roomInfos[indexPath.row]
                pkcell.config(model: room)
            } else {
                pkcell.config(model: ShowLiveRoomInfo.init(roomID: "", ownerId: "", memberCount: 0))
            }
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    //MARK: - delegate
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if indexPath.row < roomInfos.count {
            if let pk = pkWithRoom {
                let room = roomInfos[indexPath.row]
                pk(room)
                isHidden = true
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerLabel = UILabel()
        headerLabel.frame = CGRect(x: 0, y: 40, width: tableView.bounds.size.width, height: 50)
        headerLabel.textAlignment = NSTextAlignment.center
        headerLabel.text = .invitePKText
        headerLabel.textColor = .black
        headerLabel.backgroundColor = .white
        headerLabel.isUserInteractionEnabled = true
        return headerLabel
    }
}
class ShowLivePkAlertCell: UITableViewCell {
    public lazy var coverImg: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = 20
        img.layer.masksToBounds = true
        return img
    }()
    
    public lazy var inviteLabel: UILabel = {
        let label = UILabel()
        label.text = .pkInviteText
        label.textAlignment = NSTextAlignment.center
        label.isUserInteractionEnabled = true
        label.textColor = .white
        label.backgroundColor = UIColor("29CC85")
        label.clipsToBounds = true
        return label
    }()
    
    public lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 13)
        label.numberOfLines = 2
        return label
    }()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        inviteLabel.layer.cornerRadius = inviteLabel.frame.height*0.5
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
    }
    
    private func constructViewHierarchy() {
        contentView.addSubview(coverImg)
        contentView.addSubview(inviteLabel)
        contentView.addSubview(infoLabel)
    }
    
    private func activateConstraints() {
        coverImg.snp.makeConstraints { (make) in
            make.leading.equalTo(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(40)
        }
        inviteLabel.snp.makeConstraints { (make) in
            make.trailing.equalTo(-20)
            make.width.equalTo(75)
            make.height.equalTo(30)
            make.centerY.equalToSuperview()
        }
        infoLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(coverImg.snp.trailing).offset(10)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(inviteLabel.snp.leading).offset(-10)
        }
    }
    
    public func config(model: ShowLiveRoomInfo) {
        if let url = URL.init(string: model.coverUrl) {
            coverImg.kf.setImage(with: .network(url))
        }
        infoLabel.text = "\(model.ownerName)\n\(model.roomName)"
    }
}

// MARK: - More View
class ShowLiveMoreAlert: ShowLiveAlertContentView {
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 52, height: 76)
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    override init(frame: CGRect = .zero, viewModel: ShowLiveAnchorViewModel) {
        super.init(viewModel: viewModel)
        titleLabel.text = .toolText
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func constructViewHierarchy() {
        super.constructViewHierarchy()
        contentView.addSubview(collectionView)
    }
    
    override func activateConstraints() {
        super.activateConstraints()
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.height.equalTo(76)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-kDeviceSafeBottomHeight)
        }
    }
    
    override func bindInteraction() {
        super.bindInteraction()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ShowLiveMoreAlertCell.self, forCellWithReuseIdentifier: "ShowLiveMoreAlertCell")
    }
}

// MARK: - UICollectionViewDelegate
extension ShowLiveMoreAlert : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            guard let cell = collectionView.cellForItem(at: indexPath) else { return }
            if let cell = cell as? ShowLiveMoreAlertCell {
                viewModel.cameraIsFrontMonitor = !viewModel.cameraIsFrontMonitor
                cell.enable = viewModel.cameraIsFrontMonitor
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ShowLiveMoreAlert : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShowLiveMoreAlertCell", for: indexPath)
        if let cell = cell as? ShowLiveMoreAlertCell {
            cell.model = (UIImage(named: "switch_camera"), UIImage(named: "switch_camera"))
            cell.titleLabel.text = .earMonitorText
            cell.enable = viewModel.cameraIsFrontMonitor
        }
        return cell
    }
}

class ShowLiveMoreAlertCell: UICollectionViewCell {
    
    public var model : (normal : UIImage?, selected : UIImage?)?
    
    public var enable: Bool = false {
        willSet {
            if newValue {
                imageView.image = model?.selected
            }
            else {
                imageView.image = model?.normal
            }
        }
    }
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .black
        label.font = UIFont(name: "PingFangSC-Regular", size: 14)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textAlignment = .center
        return label
    }()
    
    private var isViewReady = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
    }
    private func constructViewHierarchy() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
    }
    private func activateConstraints() {
        imageView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalToSuperview()
            make.size.equalTo(CGSize(width: 52, height: 52))
        }
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview()
        }
    }
}

// MARK: - internationalization string
fileprivate extension String {
    static let earMonitorText = ShowLiveLocalize("Scene.ShowLive.Anchor.switchcamera")
    static let toolText = ShowLiveLocalize("Scene.ShowLive.Anchor.tools")
    static let pkText = ShowLiveLocalize("Scene.ShowLive.Anchor.pktitle")
    static let inviteText = ShowLiveLocalize("Scene.ShowLive.Anchor.invite")
    static let pkInviteText = ShowLiveLocalize("Scene.ShowLive.Anchor.pkInvite")
    static let invitePKText = ShowLiveLocalize("Scene.ShowLive.Anchor.invitepk")
    static let loadingText = ShowLiveLocalize("Scene.ShowLive.Anchor.loading")
    static let noAnchorText = ShowLiveLocalize("Scene.ShowLive.Anchor.noanchor")
    static let cancelText = ShowLiveLocalize("Scene.ShowLive.Anchor.cancel")
}
