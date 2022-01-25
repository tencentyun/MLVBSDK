//
//  MineAboutViewController.swift
//  TXLiteAVDemo
//
//  Created by gg on 2021/4/8.
//  Copyright © 2021 Tencent. All rights reserved.
//

import UIKit
import TUIPusher

class MineAboutViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        self.title = .titleText;
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor : UIColor.black,
             NSAttributedString.Key.font : UIFont(name: "PingFangSC-Semibold", size: 18) ?? UIFont.systemFont(ofSize: 18)
            ]
//        navigationController?.navigationBar.barTintColor = .white
//        navigationController?.navigationBar.isTranslucent = false

        let backBtn = UIButton(type: .custom)
        backBtn.setImage(UIImage(named: "main_mine_about_back"), for: .normal)
        backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        backBtn.sizeToFit()
        let item = UIBarButtonItem(customView: backBtn)
        item.tintColor = .black
        navigationItem.leftBarButtonItem = item
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    @objc func backBtnClick() {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        tableView.register(MineAboutTableViewCell.self, forCellReuseIdentifier: "MineAboutTableViewCell")
        tableView.register(MineAboutDetailCell.self, forCellReuseIdentifier: "MineAboutDetailCell")
        return tableView
    }()
    
    lazy var dataSource: [MineAboutModel] = {
        var res : [MineAboutModel] = []
        
        if let sdkVersion = TRTCCloud.getSDKVersion() {
            let sdk = MineAboutModel(title: .sdkVersionText, value: sdkVersion)
            res.append(sdk)
        }
        let version = AppUtils.appVersionWithBuild
        let storeVersion = MineAboutModel(title: .storeVersionText, value: version)
        res.append(storeVersion)
        
        let resign = MineAboutModel(title: .resignText, type: .resign)
        res.append(resign)
        
        return res
    }()
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            if #available(iOS 13.0, *) {
                return .darkContent
            } else {
                return .default
            }
        }
    }
    
    public override var prefersStatusBarHidden: Bool {
        get {
            return false
        }
    }
}

extension MineAboutViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = dataSource[indexPath.row]
        switch model.type {
        case .normal:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MineAboutTableViewCell", for: indexPath)
            if let scell = cell as? MineAboutTableViewCell {
                scell.titleLabel.text = model.title
                scell.descLabel.text = model.value
            }
            return cell
        case .resign:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MineAboutDetailCell", for: indexPath)
            if let scell = cell as? MineAboutDetailCell {
                scell.titleLabel.text = model.title
            }
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
}
extension MineAboutViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataSource[indexPath.row]
        if model.type == .resign {
            let vc = MineAboutResignViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

enum MineAboutCellType {
    case normal
    case resign
}

class MineAboutModel: NSObject {
    let title: String
    let value: String
    let type: MineAboutCellType
    init(title: String, value: String = "", type: MineAboutCellType = .normal) {
        self.title = title
        self.value = value
        self.type = type
        super.init()
    }
}

class MineAboutDetailCell: UITableViewCell {
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFangSC-Regular", size: 16)
        label.textColor = UIColor("333333")
        return label
    }()
    lazy var lineView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor("EEEEEE")
        return view
    }()
    lazy var detailImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "main_mine_detail"))
        return imageView
    }()
    
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
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailImageView)
        contentView.addSubview(lineView)
    }
    func activateConstraints() {
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        detailImageView.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
        lineView.snp.makeConstraints { (make) in
            make.leading.equalTo(titleLabel)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    func bindInteraction() {
        
    }
}

class MineAboutTableViewCell: UITableViewCell {
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFangSC-Regular", size: 16)
        label.textColor = UIColor("333333")
        return label
    }()
    lazy var descLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFangSC-Regular", size: 16)
        label.textColor = UIColor("666666")
        return label
    }()
    lazy var lineView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor("EEEEEE")
        return view
    }()
    
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
    }
    
    func constructViewHierarchy() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(descLabel)
        contentView.addSubview(lineView)
    }
    func activateConstraints() {
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        descLabel.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
        lineView.snp.makeConstraints { (make) in
            make.leading.equalTo(titleLabel)
            make.trailing.equalTo(descLabel)
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
}

/// MARK: - internationalization string
fileprivate extension String {
    static let titleText = MineLocalize("Demo.TRTC.Portal.Mine.about")
    static let sdkVersionText = MineLocalize("Demo.TRTC.Portal.sdkversion")
    static let storeVersionText = MineLocalize("Demo.TRTC.Portal.appversion")
    static let resignText = MineLocalize("Demo.TRTC.Portal.resignaccount")
}
