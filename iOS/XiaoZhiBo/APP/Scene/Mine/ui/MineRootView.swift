//
//  MineRootView.swift
//  TXLiteAVDemo
//
//  Created by gg on 2021/4/6.
//  Copyright © 2021 Tencent. All rights reserved.
//

import Foundation
import Kingfisher
import UIKit

class MineRootView: UIView {
    
    let viewModel: MineViewModel
    
    public weak var rootVC: MineViewController?
    
    init(viewModel: MineViewModel, frame: CGRect = .zero) {
        self.viewModel = viewModel
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var bgView: UIView = {
        let bgView = UIView(frame: .zero)
        bgView.backgroundColor = UIColor("338AFF")
        return bgView
    }()
    
    lazy var containerView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var contentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFangSC-Semibold", size: 18)
        label.textColor = .white
        label.text = .titleText
        return label
    }()
    
    lazy var userNameBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("USERID", for: .normal)
        btn.adjustsImageWhenHighlighted = false
        btn.setTitleColor(UIColor("333333"), for: .normal)
        btn.titleLabel?.font = UIFont(name: "PingFangSC-Semibold", size: 18)
        btn.setImage(UIImage(named: "main_mine_edit"), for: .normal)
        return btn
    }()
    
    lazy var userIdLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFangSC-Regular", size: 16)
        label.textColor = UIColor("999999")
        return label
    }()
    
    let headImageDiameter: CGFloat = 100
    
    lazy var headImageView: UIImageView = {
        let imageV = UIImageView(frame: .zero)
        imageV.contentMode = .scaleAspectFill
        imageV.layer.cornerRadius = headImageDiameter / 3
        imageV.clipsToBounds = true
        return imageV
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 48, right: 0)
        return tableView
    }()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        bgView.roundedRect(rect: bgView.bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: ScreenWidth, height: ScreenWidth))
        contentView.roundedRect(rect: contentView.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 10, height: 10))
    }
    
    var isViewReady = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        backgroundColor = UIColor("F4F5F9")
        isViewReady = true
        constructViewHierarchy() // 视图层级布局
        activateConstraints() // 生成约束（此时有可能拿不到父视图正确的frame）
        bindInteraction()
    }
    
    func constructViewHierarchy() {
        addSubview(bgView)
        addSubview(containerView)
        containerView.addSubview(contentView)
        contentView.addSubview(userNameBtn)
        contentView.addSubview(userIdLabel)
        contentView.addSubview(tableView)
        containerView.addSubview(headImageView)
        addSubview(titleLabel)
    }
    
    func activateConstraints() {
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(kDeviceSafeTopHeight+20)
        }
        bgView.snp.makeConstraints { (make) in
            make.top.centerX.equalToSuperview()
            make.width.equalTo(ScreenWidth * 1.2)
            make.height.equalTo(ScreenWidth * (273.0 / 375.0))
        }
        containerView.snp.makeConstraints { (make) in
            make.top.equalTo(bgView.snp.bottom).offset(-52-headImageDiameter * 0.5)
            make.leading.trailing.bottom.equalToSuperview();
        }
        contentView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(headImageDiameter * 0.5)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-40)
        }
        userNameBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(headImageDiameter * 0.5 + 8);
            make.centerX.equalToSuperview();
        }
        userIdLabel.snp.makeConstraints { (make) in
            make.top.equalTo(userNameBtn.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(userIdLabel.snp.bottom).offset(24)
            make.bottom.leading.trailing.equalToSuperview()
        }
        headImageView.snp.makeConstraints { (make) in
            make.top.centerX.equalToSuperview();
            make.size.equalTo(CGSize(width: headImageDiameter, height: headImageDiameter));
        }
    }
    
    func bindInteraction() {
        
        userNameBtn.addTarget(self, action: #selector(userIdBtnClick(btn:)), for: .touchUpInside)
        
        tableView.register(MineTableViewCell.self, forCellReuseIdentifier: "MineTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(headBtnClick))
        headImageView.addGestureRecognizer(tap)
        
        updateHeadImage()
        updateName()
        updateUserId()
    }
    
    func updateHeadImage() {
        if let user = viewModel.user, let url = URL.init(string: user.avatar) {
            headImageView.kf.setImage(with: .network(url))
        }
    }
    
    func updateUserId() {
        if let user = viewModel.user {
            userIdLabel.text = "ID:\(user.userId)"
        }
    }
    
    func updateName() {
        if let user = viewModel.user {
            // replace title and image, then add spacing
            userNameBtn.setTitle(user.name, for: .normal)
            userNameBtn.sizeToFit()
            let totalWidth = userNameBtn.frame.width
            let imageWidth = userNameBtn.imageView!.frame.width
            let titleWidth = totalWidth - imageWidth
            let spacing = CGFloat(4)
            userNameBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageWidth-spacing * 0.5, bottom: 0, right: imageWidth+spacing * 0.5)
            userNameBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: titleWidth+spacing * 0.5, bottom: 0, right: -titleWidth-spacing * 0.5)
            userNameBtn.snp.remakeConstraints { (make) in
                make.top.equalToSuperview().offset(headImageDiameter * 0.5);
                make.centerX.equalToSuperview();
                make.width.equalTo(totalWidth + spacing)
            }
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        guard let superview = headImageView.superview else {
            return super.hitTest(point, with: event)
        }
        let rect = superview.convert(headImageView.frame, to: self)
        if rect.contains(point) {
            return headImageView
        }
        return super.hitTest(point, with: event)
    }
    
    @objc func userIdBtnClick(btn: UIButton) {
        let alert = MineUserIdEditView(viewModel: viewModel)
        (AppUtils.getCurrentWindow() ?? self).addSubview(alert)
        alert.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        alert.layoutIfNeeded()
        alert.show()
        alert.didDismiss = { [weak self] in
            guard let `self` = self else { return }
            self.updateName()
        }
    }
    
    @objc func headBtnClick() {
        let model = TRTCAlertViewModel()
        let alert = TRTCAvatarListAlertView(viewModel: model)
        (AppUtils.getCurrentWindow() ?? self).addSubview(alert)
        alert.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        alert.layoutIfNeeded()
        alert.show()
        alert.didClickConfirmBtn = { [weak self] in
            guard let `self` = self else { return }
            if let url = URL.init(string: ProfileManager.sharedManager().currentUserModel?.avatar ?? "") {
                self.headImageView.kf.setImage(with: .network(url))
            }
        }
        alert.willDismiss = { [weak self] in
            guard let `self` = self else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.updateHeadImage()
            }
            
        }
    }
}

extension MineRootView : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tableDataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MineTableViewCell", for: indexPath)
        if let scell = cell as? MineTableViewCell {
            let model = viewModel.tableDataSource[indexPath.row]
            scell.model = model
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
}
extension MineRootView : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = viewModel.tableDataSource[indexPath.row]
        switch model.type {
            
        case .about:
            let vc = MineAboutViewController()
            vc.hidesBottomBarWhenPushed = true
            rootVC?.navigationController?.pushViewController(vc, animated: true)
            
        case .privacy:
            guard let url = URL(string: WEBURL_Privacy) else {
                return
            }
            let vc = TRTCWebViewController(url: url, title: model.title)
            vc.hidesBottomBarWhenPushed = true
            rootVC?.navigationController?.pushViewController(vc, animated: true)
        case .agreement:
            guard let url = URL(string: WEBURL_Agreement) else {
                return
            }
            let vc = TRTCWebViewController(url: url, title: model.title)
            vc.hidesBottomBarWhenPushed = true
            rootVC?.navigationController?.pushViewController(vc, animated: true)
            
        case .disclaimer:
            let alert = UIAlertController(title: .disclaimerText, message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: .doneText, style: .default, handler: nil)
            alert.addAction(action)
            rootVC?.present(alert, animated: true, completion: nil)
        }
    }
}

class MineTableViewCellModel: NSObject {
    let title: String
    let image: UIImage?
    let type: MineListType
    init(title: String, image: UIImage?, type: MineListType) {
        self.title = title
        self.image = image
        self.type = type
        super.init()
    }
}

class MineTableViewCell: UITableViewCell {
    
    lazy var titleImageView: UIImageView = {
        let imageV = UIImageView(frame: .zero)
        return imageV
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFangSC-Regular", size: 16)
        label.textColor = UIColor("333333")
        return label
    }()
    
    lazy var detailImageView: UIImageView = {
        let imageV = UIImageView(image: UIImage(named: "main_mine_detail"))
        return imageV
    }()
    
    var model: MineTableViewCellModel? {
        didSet {
            guard let model = model else {
                return
            }
            titleImageView.image = model.image
            titleLabel.text = model.title
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isViewReady = false
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
    
    func constructViewHierarchy() {
        contentView.addSubview(titleImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailImageView)
    }
    func activateConstraints() {
        titleImageView.snp.makeConstraints { (make) in
            make.centerX.equalTo(contentView.snp.leading).offset(36)
            make.centerY.equalToSuperview()
        }
        detailImageView.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(titleImageView)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(titleImageView)
            make.leading.equalTo(titleImageView.snp.centerX).offset(28)
            make.trailing.lessThanOrEqualTo(detailImageView.snp.leading).offset(-10)
        }
    }
    func bindInteraction() {
        
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let titleText = MineLocalize("Demo.TRTC.Portal.Mine.personalcenter")
    static let disclaimerText = MineLocalize("Demo.TRTC.Portal.disclaimerdesc")
    static let doneText = MineLocalize("Demo.TRTC.Portal.confirm")
    static let privacyTitleText = MineLocalize("隐私条例")
    static let protocolTitleText = MineLocalize("用户协议")
}
