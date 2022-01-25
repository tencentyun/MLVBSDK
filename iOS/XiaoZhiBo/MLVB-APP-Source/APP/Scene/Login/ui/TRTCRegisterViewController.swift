//
//  TRTCRegisterViewController.swift
//  TXLiteAVDemo
//
//  Created by gg on 2021/4/8.
//  Copyright © 2021 Tencent. All rights reserved.
//

import Foundation
import Toast_Swift

class TRTCRegisterViewController: UIViewController {
    
    let loading = UIActivityIndicatorView.init(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        navigationController?.navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.setHidesBackButton(true, animated: false)
        navigationController?.navigationBar.backItem?.setHidesBackButton(true, animated: false)
        
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor : UIColor.black,
             NSAttributedString.Key.font : UIFont(name: "PingFangSC-Semibold", size: 18) ?? UIFont.systemFont(ofSize: 18)
            ]
        
        ToastManager.shared.position = .center
        
        view.addSubview(loading)
        loading.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.centerX.centerY.equalTo(view)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.makeToast(.firstLoginText)
    }
    
    func regist(_ nickName: String) {
        loading.startAnimating()
        if let userModel = ProfileManager.sharedManager().currentUserModel{
            HttpLogicRequest.userUpdate(currentUserModel: userModel, name: nickName ,success:  { [weak self] (user) in
                guard let self = self else { return }
                self.registSuccess()
            } ,failed: { [weak self] (errocde,errorMessage) in
                guard let self = self else { return }
                self.loading.stopAnimating()
                self.view.makeToast(errorMessage)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }
//        ProfileManager.sharedManager().setNickName(name: nickName) { [weak self] in
//            guard let `self` = self else { return }
//            self.registSuccess()
//        } failed: { (err) in
//            self.loading.stopAnimating()
//            self.view.makeToast(err)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                self.navigationController?.popViewController(animated: true)
//            }
//        }
    }
    
    func registSuccess() {
        self.loading.stopAnimating()
        self.view.makeToast(.registSuccessText)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            AppUtils.shared.appDelegate.showMainViewController()
        }
    }
    
    override func loadView() {
        super.loadView()
        let rootView = TRTCRegisterRootView()
        rootView.rootVC = self
        view = rootView
    }
   
}

/// MARK: - internationalization string
fileprivate extension String {
    static let registSuccessText = LoginLocalize("Demo.TRTC.Login.registsuccess")
    static let firstLoginText = LoginLocalize("Demo.TRTC.LoginMock.adduserinformationforfirstlogin")
}

