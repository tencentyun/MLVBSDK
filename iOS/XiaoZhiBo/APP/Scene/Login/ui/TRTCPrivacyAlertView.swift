//
//  TRTCPrivacyAlertView.swift
//  TRTCAPP_AppStore
//
//  Created by gg on 2021/6/10.
//

import UIKit

class TRTCPrivacyAlertView: UIView {
    lazy var containerView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        view.layer.cornerRadius = 6
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.lightGray.cgColor
        return view
    }()
    lazy var bgView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        view.alpha = 0.1
        return view
    }()
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFangSC-Medium", size: 18)
        label.textColor = .black
        label.text = .titleText
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.textAlignment = .center
        return label
    }()
    lazy var descTextView: TRTCLoginAgreementTextView = {
        let textView = TRTCLoginAgreementTextView(frame: .zero)
        textView.backgroundColor = .clear
        textView.delegate = self
        
        let totalStr = localizeReplaceTwoCharacter(origin: .agreementText, xxx_replace: .privacyRegulationsText, yyy_replace: .userProtocolText)
        let privaStr = String.privacyRegulationsText
        let protoStr = String.userProtocolText
        
        guard let privaR = totalStr.range(of: privaStr), let protoR = totalStr.range(of: protoStr) else {
            return textView
        }
        
        let totalRange = NSRange(location: 0, length: totalStr.count)
        let privaRange = totalStr.nsrange(fromRange: privaR)
        let protoRange = totalStr.nsrange(fromRange: protoR)
        
        let attr = NSMutableAttributedString(string: totalStr)
        
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        attr.addAttribute(.paragraphStyle, value: style, range: totalRange)
        
        attr.addAttribute(.font, value: UIFont(name: "PingFangSC-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14), range: totalRange)
        attr.addAttribute(.foregroundColor, value: UIColor.darkGray, range: totalRange)
        
        attr.addAttribute(.link, value: "privacy", range: privaRange)
        attr.addAttribute(.link, value: "protocol", range: protoRange)
        
        attr.addAttribute(.foregroundColor, value: UIColor.blue, range: privaRange)
        attr.addAttribute(.foregroundColor, value: UIColor.blue, range: protoRange)
        
        textView.attributedText = attr
        
        return textView
    }()
    lazy var confirmBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle(.confirmText, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .blue
        return btn
    }()
    lazy var cancelBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle(.cancelText, for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .clear
        return btn
    }()
    lazy var lineView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .lightGray
        return view
    }()
    
    var didClickCancelBtn: (()->())?
    var didClickConfirmBtn: (()->())?
    var didDismiss: (()->())?
    
    let superVC: UIViewController
    
    init(superVC: UIViewController, frame: CGRect = .zero) {
        self.superVC = superVC
        super.init(frame: frame)
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
        constructViewHierarchy() // 视图层级布局
        activateConstraints() // 生成约束（此时有可能拿不到父视图正确的frame）
        bindInteraction()
    }
    
    func constructViewHierarchy() {
        addSubview(bgView)
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descTextView)
        containerView.addSubview(lineView)
        containerView.addSubview(cancelBtn)
        containerView.addSubview(confirmBtn)
    }
    func activateConstraints() {
        bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        containerView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
            make.centerY.equalToSuperview()
            make.height.equalTo(containerView.snp.width).multipliedBy(0.8)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16)
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.centerX.equalToSuperview()
        }
        cancelBtn.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalTo(40)
        }
        confirmBtn.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalTo(40)
        }
        lineView.snp.makeConstraints { (make) in
            make.bottom.equalTo(cancelBtn.snp.top)
            make.height.equalTo(0.5)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview()
        }
        descTextView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.bottom.equalTo(cancelBtn.snp.top)
            make.leading.trailing.equalToSuperview()
        }
    }
    func bindInteraction() {
        cancelBtn.addTarget(self, action: #selector(cancelBtnClick), for: .touchUpInside)
        confirmBtn.addTarget(self, action: #selector(confirmBtnClick), for: .touchUpInside)
    }
    
    @objc func cancelBtnClick() {
        if let action = didClickCancelBtn {
            action()
        }
        dismiss()
    }
    
    @objc func confirmBtnClick() {
        if let action = didClickConfirmBtn {
            action()
        }
        dismiss()
    }
    
    func dismiss() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        } completion: { (finish) in
            if let action = self.didDismiss {
                action()
            }
            self.removeFromSuperview()
        }
    }
}

extension TRTCPrivacyAlertView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if URL.absoluteString == "privacy" {
            showPrivacy()
        }
        else if URL.absoluteString == "protocol" {
            showProtocol()
        }
        return true
    }
    func showPrivacy() {
        guard let url = URL(string: WEBURL_Privacy) else {
            return
        }
        let vc = TRTCWebViewController(url: url, title: .privacyTitleText)
        superVC.navigationController?.pushViewController(vc, animated: true)
    }
    func showProtocol() {
        guard let url = URL(string: WEBURL_Agreement) else {
            return
        }
        let vc = TRTCWebViewController(url: url, title: .protocolTitleText)
        superVC.navigationController?.pushViewController(vc, animated: true)
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let titleText = LoginLocalize("Demo.TRTC.Login.welcome")
    
    static let confirmText = LoginLocalize("V2.Live.LinkMicNew.agree")
    static let cancelText = LoginLocalize("V2.Live.LinkMicNew.disagree")
    
    static let agreementText = LoginLocalize("Demo.TRTC.Portal.privatealertdescription")
    static let privacyRegulationsText = LoginLocalize("Demo.TRTC.Portal.<private>")
    static let userProtocolText = LoginLocalize("Demo.TRTC.Portal.<agreement>")
    static let noagreeAlertText = LoginLocalize("Demo.TRTC.Portal.agreeprivatefirst")
    static let privacyTitleText = LoginLocalize("Demo.TRTC.Portal.private")
    static let protocolTitleText = LoginLocalize("Demo.TRTC.Portal.agreement")
}
