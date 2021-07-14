//
//  MineAboutResignViewController.swift
//  TXLiteAVDemo
//
//  Created by gg on 2021/6/2.
//  Copyright © 2021 Tencent. All rights reserved.
//

import Foundation
import NVActivityIndicatorView

class MineAboutResignViewController: UIViewController {
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "resign"))
        return imageView
    }()
    lazy var tipsLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFangSC-Regular", size: 16)
        label.textColor = .white
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.text = .tipsText
        return label
    }()
    lazy var numberLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFangSC-Regular", size: 16)
        label.textColor = .white
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    lazy var confirmBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle(.confirmResignText, for: .normal)
        btn.backgroundColor = UIColor(hex: "006EFF")
        btn.addTarget(self, action: #selector(resignBtnClick), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let colors = [UIColor(red: 19.0 / 255.0, green: 41.0 / 255.0,
                              blue: 75.0 / 255.0, alpha: 1).cgColor,
                      UIColor(red: 5.0 / 255.0, green: 12.0 / 255.0,
                              blue: 23.0 / 255.0, alpha: 1).cgColor]
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.compactMap { $0 }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        self.title = .titleText;
        
        let backBtn = UIButton(type: .custom)
        backBtn.setImage(UIImage(named: "back"), for: .normal)
        backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        backBtn.sizeToFit()
        let item = UIBarButtonItem(customView: backBtn)
        navigationItem.leftBarButtonItem = item
        
        view.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.snp.top).offset(200)
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
        
        numberLabel.text = LocalizeReplaceXX(.numberText, ProfileManager.shared.curUserModel?.phone ?? "")
        
        view.addSubview(loading)
        loading.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.centerX.centerY.equalTo(view)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor : UIColor.white,
             NSAttributedString.Key.font : UIFont(name: "PingFangSC-Semibold", size: 18) ?? UIFont.systemFont(ofSize: 18)
            ]
        navigationController?.navigationBar.isTranslucent = true
    }
    
    let loading = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 60),
                                          type: .ballBeat,
                                          color: .appTint)
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
        loading.startAnimating()
        ProfileManager.shared.resign { [weak self] (success, message) in
            guard let `self` = self else { return }
            self.loading.stopAnimating()
            if success {
                AppUtils.shared.showLoginController()
                if let window = UIApplication.shared.windows.first {
                    window.makeToast(.resignSuccessText)
                }
            }
            else {
                self.view.makeToast(message)
            }
        }
    }
    
    @objc func backBtnClick() {
        navigationController?.popViewController(animated: true)
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let titleText = AppPortalLocalize("Demo.TRTC.Portal.resignaccount")
    static let tipsText = AppPortalLocalize("Demo.TRTC.Portal.resigntips")
    static let numberText = AppPortalLocalize("Demo.TRTC.Portal.currentaccount")
    static let confirmResignText = AppPortalLocalize("Demo.TRTC.Portal.confirmresign")
    static let resignAlertTitleText = AppPortalLocalize("Demo.TRTC.Portal.alerttoresign")
    static let cancelBtnText = AppPortalLocalize("App.PortalViewController.cancel")
    static let resignSuccessText = AppPortalLocalize("Demo.TRTC.Portal.resignsuccess")
}
