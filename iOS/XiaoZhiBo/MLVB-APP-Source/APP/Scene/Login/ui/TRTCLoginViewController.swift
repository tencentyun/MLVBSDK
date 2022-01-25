//
//  TRTCLoginOAuthViewController.swift
//  XiaoZhiBoApp
//
//  Created by jack on 2021/11/11.
//  OAuth Login/Register

import UIKit
import CryptoKit
import Toast_Swift

typealias TRTCLoginViewController = TRTCLoginOAuthViewController
class TRTCLoginOAuthViewController: UIViewController {

    // 页面样式
    enum PageStyle {
        // 登陆视图
        case login
        // 注册视图
        case register
    }
    
    /// OAuth视图构造器
    /// - Parameter pageStyle: login 登陆页面 register 注册页面
    convenience init(pageStyle: TRTCLoginOAuthViewController.PageStyle = .login) {
        self.init()
        self.pageStyle = pageStyle
    }

    // 视图样式
    private var pageStyle:PageStyle = .login
    // 指示器
    private lazy var loadingView:UIActivityIndicatorView = {
        return UIActivityIndicatorView.init(style: .large)
    }()
    
    override func loadView() {
        super.loadView()
        // 重载View
        view = TRTCLoginOAuthView(pageStyle: pageStyle, delegate: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ToastManager.shared.position = .center
        
        view.addSubview(loadingView)
        loadingView.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.centerX.centerY.equalTo(view)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 隐藏导航栏
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 隐私协议授权弹框检查
        if checkPrivacyAlertShouldShow() {
            showPrivacyAlert()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.bringSubviewToFront(loadingView)
    }

}

// MARK: - Private
extension TRTCLoginOAuthViewController {
    
    /// 登陆成功
    private func loginSuccess() {
        if ProfileManager.sharedManager().currentUserModel?.name.count == 0 {
            self.loadingView.stopAnimating()
            openRegisterOAuthViewController()
        } else {
            view.makeToast(LoginLocalize("V2.Live.LinkMicNew.loginsuccess"))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.loadingView.stopAnimating()
                AppUtils.shared.appDelegate.showMainViewController()
            }
        }
    }
    
    /// 注册成功
    private func registerSuccess() {
        self.loadingView.stopAnimating()
        self.view.makeToast(.registerSuccessText)
        // 注册成功 - 返回登陆页面
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    /// 检查是否展示隐私弹框
    private func checkPrivacyAlertShouldShow() -> Bool {
        let res = UserDefaults.standard.bool(forKey: "_kPrivacyHasShowedk_")
        return !res
    }
    
    /// 展示隐私弹框
    private func showPrivacyAlert() {
        let alert = TRTCPrivacyAlertView(superVC: self)
        view.addSubview(alert)
        alert.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        view.layoutIfNeeded()
        alert.didClickConfirmBtn = { [weak self] in
            (self?.view as? TRTCLoginOAuthView)?.updatePrivacyState(select: true)
        }
        alert.didDismiss = {
            UserDefaults.standard.setValue(true, forKey: "_kPrivacyHasShowedk_")
        }
    }
    
}


// MARK: - TRTCLoginOAuthViewDelegate
extension TRTCLoginOAuthViewController: TRTCLoginOAuthViewDelegate {
    
    func login(userName: String, password: String) {
        guard !userName.isEmpty, !password.isEmpty else {
            return
        }
        let salt = "\(userName)-\(password)".md5
        let tag = "xiaozhibo"
        let timestamp = String(format: "%.0f", Date().timeIntervalSince1970 * 1000)
        let nonce = ""
        let signature = "\(userName)-\(tag)-\(timestamp)-\(nonce)-\(salt)".md5
        loadingView.startAnimating()
        HttpLogicRequest.userNameLogin(userName: userName, signature: signature, tag: tag, timestamp: timestamp, nonce: nonce, hash: "md5"){ [weak self] (data) in
            guard let self = self else { return }
            guard let userModel = data else {
                self.loadingView.stopAnimating()
                self.view.makeToast(LoginLocalize("Demo.TRTC.http.syserror"))
                return
            }
            if userModel.name.isEmpty {
                userModel.name = userName
                // 更新UserName
                HttpLogicRequest.userUpdate(currentUserModel: userModel, name: userName, success: nil, failed: nil)
            }
            ProfileManager.sharedManager().updateUserModel(userModel)
            self.loginSuccess()
        } failed: { [weak self](errorCode, errorMessage) in
            guard let self = self else { return }
            self.loadingView.stopAnimating()
            self.view.makeToast(errorMessage)
        }
    }
    
    func register(userName: String, password: String) {
        guard !userName.isEmpty, !password.isEmpty else {
            return
        }
        let salt = "\(userName)-\(password)".md5
        loadingView.startAnimating()
        HttpLogicRequest.userNameRegister(userName: userName, salt: salt) { [weak self] (data) in
            guard let self = self else { return }
            self.registerSuccess()
        } failed: { [weak self](errorCode, errorMessage) in
            guard let self = self else { return }
            self.loadingView.stopAnimating()
            self.view.makeToast(errorMessage)
        }
    }
    
    func openRegisterOAuthViewController() {
        let controller = TRTCLoginOAuthViewController(pageStyle: .register)
        navigationController?.pushViewController(controller, animated: true)
    }

    func openWebPage(url: URL, title:String) {
        let vc = TRTCWebViewController(url: url, title: title)
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - md5
fileprivate extension String {
    var md5: String {
        guard let d = self.data(using: .utf8) else { return "" }
        let digest = Insecure.MD5.hash(data: d)
        let result = digest.reduce("") { (res: String, element) in
            return res + String(format: "%02x", element)
        }
        return result
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let registerSuccessText = LoginLocalize("Demo.TRTC.Login.registsuccess")
    static let firstLoginText = LoginLocalize("Demo.TRTC.LoginMock.adduserinformationforfirstlogin")
}

