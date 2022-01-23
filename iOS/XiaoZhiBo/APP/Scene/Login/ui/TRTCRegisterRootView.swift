//
//  TRTCRegisterRootView.swift
//  TXLiteAVDemo
//
//  Created by gg on 2021/4/8.
//  Copyright © 2021 Tencent. All rights reserved.
//

import UIKit
import TUIPusher

class TRTCRegisterRootView: UIView {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 32)
        label.textColor = UIColor("FFFFFF") ?? .black
        label.text = .titleText
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var bgView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "login_bg"))
        return imageView
    }()
    
    lazy var contentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        return view
    }()
    
    lazy var headImageViewBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.layer.cornerRadius = 50
        btn.clipsToBounds = true
        btn.adjustsImageWhenHighlighted = false
        return btn
    }()
    
    lazy var textField: UITextField = {
        let textField = createTextField(.nicknamePlaceholderText)
        return textField
    }()
    
    lazy var textFieldSpacingLine: UIView = {
        let view = createSpacingLine()
        return view
    }()
    
    lazy var descLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFangSC-Regular", size: 16)
        label.textColor = .darkGray
        label.text = .descText
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var registBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle(.registText, for: .normal)
        btn.adjustsImageWhenHighlighted = false
        btn.setBackgroundImage(UIColor("DBDBDB").trans2Image(), for: .normal)
        btn.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 18)
        btn.layer.shadowColor = UIColor("006EFF").cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 6)
        btn.layer.shadowRadius = 16
        btn.layer.shadowOpacity = 0.4
        btn.layer.masksToBounds = true
        btn.isEnabled = false
        return btn
    }()
    
    let versionTipLabel: UILabel = {
        let tip = UILabel()
        tip.textAlignment = .center
        tip.font = UIFont.systemFont(ofSize: 14)
        tip.textColor = UIColor("BBBBBB").withAlphaComponent(0.8)
        let version = AppUtils.appVersionWithBuild
        let sdkVersionStr = TRTCCloud.getSDKVersion() ?? "1.0.0"
        tip.text = "TRTC v\(sdkVersionStr)(\(version))"
        tip.adjustsFontSizeToFitWidth = true
        return tip
    }()
    
    private func createTextField(_ placeholder: String) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.backgroundColor = .white
        textField.font = UIFont(name: "PingFangSC-Regular", size: 16)
        textField.textColor = UIColor("333333")
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.font : UIFont(name: "PingFangSC-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor : UIColor("BBBBBB")])
        textField.delegate = self
        return textField
    }
    
    private func createSpacingLine() -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor("EEEEEE")
        return view
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        contentView.roundedRect(rect: contentView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 40, height: 40))
        registBtn.layer.cornerRadius = registBtn.frame.height * 0.5
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        textField.resignFirstResponder()
        UIView.animate(withDuration: 0.3) {
            self.transform = .identity
        }
        checkRegistBtnState()
    }
    
    public weak var rootVC: TRTCRegisterViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChange(noti:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardFrameChange(noti : Notification) {
        guard let info = noti.userInfo else {
            return
        }
        guard let value = info[UIResponder.keyboardFrameEndUserInfoKey], value is CGRect else {
            return
        }
        guard let superview = textField.superview else {
            return
        }
        let rect = value as! CGRect
        let converted = superview.convert(textField.frame, to: self)
        if rect.intersects(converted) {
            transform = CGAffineTransform(translationX: 0, y: -converted.maxY+rect.minY)
        }
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
        
        if let url = URL.init(string: ProfileManager.sharedManager().currentUserModel?.avatar ?? "") {
            headImageViewBtn.kf.setImage(with: .network(url), for: .normal)
        }
        else {
            let model = TRTCAlertViewModel()
            let randomAvatar = model.avatarListDataSource[Int(arc4random())%model.avatarListDataSource.count]
            
            if  let userModel = ProfileManager.sharedManager().currentUserModel {
                IMLogicRequest.synchronizUserInfo(currentUserModel: userModel, avatar: randomAvatar.url,success: { (user) in
                    debugPrint("set IM avatar success")
                } ,failed: { (code, message) in
                    debugPrint("set IM avatar errorStr: \(message ?? ""), errorCode: \(code)")
                })
            }
            
            //            ProfileManager.sharedManager().setIMUser(avatar: randomAvatar.url) {
            //                debugPrint("set IM avatar success")
            //            } fail: { (code, message) in
            //                debugPrint("set IM avatar errorStr: \(message ?? ""), errorCode: \(code)")
            //            }
            
            if let url = URL.init(string: randomAvatar.url) {
                headImageViewBtn.kf.setImage(with: .network(url), for: .normal)
            }
        }
    }
    
    func constructViewHierarchy() {
        addSubview(bgView)
        addSubview(titleLabel)
        addSubview(contentView)
        addSubview(headImageViewBtn)
        contentView.addSubview(textField)
        contentView.addSubview(textFieldSpacingLine)
        contentView.addSubview(descLabel)
        contentView.addSubview(registBtn)
        contentView.addSubview(versionTipLabel)
    }
    func activateConstraints() {
        bgView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(bgView.snp.width)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(convertPixel(h: 86) + kDeviceSafeTopHeight)
            make.leading.equalToSuperview().offset(convertPixel(w: 40))
            make.trailing.lessThanOrEqualToSuperview().offset(-convertPixel(w: 40))
        }
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(bgView.snp.bottom).offset(-convertPixel(h: 64))
            make.leading.trailing.bottom.equalToSuperview()
        }
        headImageViewBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(contentView.snp.top).offset(-30)
            make.size.equalTo(CGSize(width: 100, height: 100))
        }
        textField.snp.makeConstraints { (make) in
            make.top.equalTo(bgView.snp.bottom).offset(convertPixel(h: 30))
            make.leading.equalToSuperview().offset(convertPixel(w: 40))
            make.trailing.equalToSuperview().offset(-convertPixel(w: 40))
            make.height.equalTo(convertPixel(h: 57))
        }
        textFieldSpacingLine.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.equalTo(textField)
            make.height.equalTo(1)
        }
        descLabel.snp.makeConstraints { (make) in
            make.top.equalTo(textField.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(convertPixel(w: 40))
            make.trailing.lessThanOrEqualToSuperview().offset(convertPixel(w: -40))
        }
        registBtn.snp.makeConstraints { (make) in
            make.top.equalTo(descLabel.snp.bottom).offset(convertPixel(h: 90))
            make.leading.equalToSuperview().offset(convertPixel(w: 20))
            make.trailing.equalToSuperview().offset(-convertPixel(w: 20))
            make.height.equalTo(convertPixel(h: 52))
        }
        versionTipLabel.snp.makeConstraints { (make) in
            make.bottomMargin.equalTo(contentView).offset(-12)
            make.leading.trailing.equalTo(contentView)
            make.height.equalTo(30)
        }
    }
    func bindInteraction() {
        registBtn.addTarget(self, action: #selector(registBtnClick), for: .touchUpInside)
        headImageViewBtn.addTarget(self, action: #selector(headBtnClick), for: .touchUpInside)
    }
    
    @objc func headBtnClick() {
        textField.resignFirstResponder()
        UIView.animate(withDuration: 0.3) {
            self.transform = .identity
        }
        
        let model = TRTCAlertViewModel()
        let alert = TRTCAvatarListAlertView(viewModel: model)
        addSubview(alert)
        alert.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        alert.layoutIfNeeded()
        alert.show()
        alert.didClickConfirmBtn = { [weak self] in
            guard let `self` = self else { return }
            if let url = URL.init(string: ProfileManager.sharedManager().currentUserModel?.avatar ?? "") {
                self.headImageViewBtn.kf.setImage(with: .network(url), for: .normal)
            }
        }
    }
    
    @objc func registBtnClick() {
        textField.resignFirstResponder()
        guard let name = textField.text else { return }
        if  let userModel = ProfileManager.sharedManager().currentUserModel {
            IMLogicRequest.synchronizUserInfo(currentUserModel: userModel, name: name,success: { (user) in
                debugPrint("set IM name success")
            } ,failed: { (code, message) in
                debugPrint("set IM avatar errorStr: \(message ?? ""), errorCode: \(code)")
            })
        }
        
        //        ProfileManager.sharedManager().setIMUser(name: name) {
        //            debugPrint("set IM name success")
        //        } fail: { (code, message) in
        //            debugPrint("set IM name errorStr: \(message ?? ""), errorCode: \(code)")
        //        }
        
        rootVC?.regist(name)
    }
    
    var canUse = false
    let enableColor = UIColor("BBBBBB")
    let disableColor = UIColor("FA585E")
    
    func checkRegistBtnState(_ count: Int = -1) {
        var ctt = textField.text?.count ?? 0
        if count > -1 {
            ctt = count
        }
        let isEnabled = canUse && ctt > 0
        registBtn.isEnabled = isEnabled
        let color = isEnabled ? UIColor("006EFF") : UIColor("DBDBDB")
        registBtn.setBackgroundImage(color.trans2Image(), for: .normal)
    }
}

extension TRTCRegisterRootView : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        UIView.animate(withDuration: 0.3) {
            self.transform = .identity
        }
        checkRegistBtnState()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        checkRegistBtnState()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxCount = 20
        guard let textFieldText = textField.text,
              let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                  return false
              }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        let res = count <= maxCount
        if res {
            let newText = (textFieldText as NSString).replacingCharacters(in: range, with: string)
            
            checkAlertTitleLState(newText)
            checkRegistBtnState(count)
        }
        return res
    }
    
    func checkAlertTitleLState(_ text: String = "") {
        if text == "" {
            if let str = textField.text {
                canUse = validate(userName: str)
                descLabel.textColor = canUse ? enableColor : disableColor
            }
            else {
                canUse = false
                descLabel.textColor = disableColor
            }
        }
        else {
            canUse = validate(userName: text)
            descLabel.textColor = canUse ? enableColor : disableColor
        }
    }
    
    func validate(userName: String) -> Bool {
        let reg = "^[a-z0-9A-Z\\u4e00-\\u9fa5\\_]{2,20}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", reg)
        return predicate.evaluate(with: userName)
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let titleText = LoginLocalize("Demo.TRTC.Login.regist.title")
    static let nicknamePlaceholderText = LoginLocalize("Demo.TRTC.Login.enterusername")
    static let descText = LoginLocalize("Demo.TRTC.Login.limit20count")
    static let registText = LoginLocalize("Demo.TRTC.Login.regist")
}
