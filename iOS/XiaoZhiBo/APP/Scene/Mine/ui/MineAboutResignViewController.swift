//
//  MineAboutResignViewController.swift
//  TXLiteAVDemo
//
//  Created by gg on 2021/6/2.
//  Copyright © 2021 Tencent. All rights reserved.
//

import UIKit

class MineAboutResignViewController: UIViewController {
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "resign"))
        return imageView
    }()
    lazy var tipsLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFangSC-Regular", size: 16)
        label.textColor = .black
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.text = .tipsText
        return label
    }()
    lazy var numberLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFangSC-Regular", size: 16)
        label.textColor = UIColor("333333")
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    lazy var confirmBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle(.confirmResignText, for: .normal)
        btn.backgroundColor = UIColor("006EFF")
        btn.addTarget(self, action: #selector(resignBtnClick), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        self.title = .titleText;
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor : UIColor.black,
             NSAttributedString.Key.font : UIFont(name: "PingFangSC-Semibold", size: 18) ?? UIFont.systemFont(ofSize: 18)
            ]
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        
        let backBtn = UIButton(type: .custom)
        backBtn.setImage(UIImage(named: "main_mine_about_back"), for: .normal)
        backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        backBtn.sizeToFit()
        let item = UIBarButtonItem(customView: backBtn)
        item.tintColor = .black
        navigationItem.leftBarButtonItem = item
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(40)
        }
        
        view.addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(40)
            make.trailing.lessThanOrEqualToSuperview().offset(-40)
        }
        
        view.addSubview(numberLabel)
        numberLabel.snp.makeConstraints { (make) in
            make.top.equalTo(tipsLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(40)
            make.trailing.lessThanOrEqualToSuperview().offset(-40)
        }
        
        view.addSubview(confirmBtn)
        confirmBtn.snp.makeConstraints { (make) in
            make.top.equalTo(numberLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
            make.height.equalTo(56)
        }
        
        numberLabel.text = localizeReplaceOneCharacter(origin: .numberText, xxx_replace: ProfileManager.sharedManager().currentUserModel?.phone ?? "")
        
        view.addSubview(loading)
        loading.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.centerX.centerY.equalTo(view)
        }
    }
    
    lazy var loading: UIActivityIndicatorView  = {
        if #available(iOS 13.0, *) {
            let load = UIActivityIndicatorView.init(style: .large)
            return load
        } else {
            let load = UIActivityIndicatorView.init(style: .whiteLarge)
            return load
        }
    }()
    
    @objc func resignBtnClick() {
        let alert = UIAlertController(title: .resignAlertTitleText, message: "", preferredStyle: .alert)
        let cancel = UIAlertAction(title: .cancelBtnText, style: .cancel) { (action) in
            
        }
        let confirm = UIAlertAction(title: .confirmResignText, style: .default) { [weak self] (action) in
            guard let `self` = self else { return }
            self.resignPhoneNumber()
        }
        alert.addAction(cancel)
        alert.addAction(confirm)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func resignPhoneNumber() {
        // 悬浮框存在，关闭悬浮框
        if ShowLiveFloatingManager.shared.isFloating {
            ShowLiveFloatingManager.shared.closeWindowAndExitRoom()
        }
        loading.startAnimating()
        if let userModel = ProfileManager.sharedManager().currentUserModel{
            HttpLogicRequest.userDelete(userId: userModel.userId, token: userModel.token ,success: { (user) in
                AppUtils.shared.appDelegate.showLoginViewController()
                if let window = AppUtils.getCurrentWindow() {
                    window.makeToast(.resignSuccessText)
                }
            } ,failed: { (code, errorDes) in
                self.view.makeToast(errorDes)
            })
        }
        

//        ProfileManager.sharedManager().resign { [weak self] (success, message) in
//            guard let `self` = self else { return }
//            self.loading.stopAnimating()
//            if success {
//                AppUtils.shared.appDelegate.showLoginViewController()
//                if let window = AppUtils.getCurrentWindow() {
//                    window.makeToast(.resignSuccessText)
//                }
//            }
//            else {
//                self.view.makeToast(message)
//            }
//        }
    }
    
    @objc func backBtnClick() {
        navigationController?.popViewController(animated: true)
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let titleText = MineLocalize("Demo.TRTC.Portal.resignaccount")
    static let tipsText = MineLocalize("Demo.TRTC.Portal.resigntips")
    static let numberText = MineLocalize("Demo.TRTC.Portal.currentaccount")
    static let confirmResignText = MineLocalize("Demo.TRTC.Portal.confirmresign")
    static let resignAlertTitleText = MineLocalize("Demo.TRTC.Portal.alerttoresign")
    static let cancelBtnText = MineLocalize("App.PortalViewController.cancel")
    static let resignSuccessText = MineLocalize("Demo.TRTC.Portal.resignsuccess")
}
