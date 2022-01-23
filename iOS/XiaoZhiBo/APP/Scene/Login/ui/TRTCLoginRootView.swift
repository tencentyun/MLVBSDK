//
//  TRTCLoginOAuthView.swift
//  XiaoZhiBoApp
//
//  Created by jack on 2021/11/11.
//

import UIKit
import TUIPusher

/// OAuthView Delegate
protocol TRTCLoginOAuthViewDelegate: NSObjectProtocol{
    
    /// 发起用户名密码登陆
    func login(userName:String, password:String)
    /// 发起用户名密码注册
    func register(userName:String, password:String)
    /// 跳转用户名密码注册页面
    func openRegisterOAuthViewController()
    /// 打开web页面
    func openWebPage(url:URL, title:String)
}

// MARK: - 隐私协议选择按钮
class TRTCPrivacySelectButton: UIButton {
    /// 扩大点击区域
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if (bounds.size.width <= 16) && (bounds.size.height <= 16){
            let expandSize:CGFloat = 16.0;
            let buttonRect = CGRect(x: bounds.origin.x - expandSize, y: bounds.origin.y - expandSize, width: bounds.size.width + 2*expandSize, height: bounds.size.height + 2*expandSize);
            return buttonRect.contains(point)
        }else{
            return super.point(inside: point, with: event)
        }
    }
}

// MARK: - 隐私协议文本
class TRTCLoginAgreementTextView: UITextView {
    override var canBecomeFirstResponder: Bool {
        get {
            return false
        }
    }
}

class TRTCLoginOAuthView: UIView {
    
    public weak var delegate:TRTCLoginOAuthViewDelegate? = nil
    
    /// 构造用户名登陆视图
    /// - Parameter pageStyle: login 登陆视图 register 注册视图
    convenience init(pageStyle: TRTCLoginOAuthViewController.PageStyle = .login, delegate:TRTCLoginOAuthViewDelegate?) {
        self.init(frame: UIScreen.main.bounds)
        self.pageStyle = pageStyle
        self.delegate = delegate
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChange(noti:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /// 背景视图
    private lazy var backgroundView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "login_bg"))
        return imageView
    }()
    /// 标题
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 32)
        label.textColor = UIColor("FFFFFF")
        label.text = .titleText
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    /// 内容视图
    private lazy var contentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        return view
    }()
    /// 用户名
    private lazy var userNameTextField: UITextField = {
        let textField = createTextField(.userNameText)
        textField.keyboardType = .default
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }()
    /// 密码
    private lazy var passwordTextField: UITextField = {
        let textField = createTextField(.passwordText)
        textField.keyboardType = .asciiCapable
        textField.isSecureTextEntry = true
        return textField
    }()
    /// 分割线
    private lazy var userNameBottomLine: UIView = {
        let view = createSpacingLine()
        return view
    }()
    /// 分割线
    private lazy var passwordBottomLine: UIView = {
        let view = createSpacingLine()
        return view
    }()
    /// 登陆按钮
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(.white, for: .normal)
        button.setTitle(.loginText, for: .normal)
        button.adjustsImageWhenHighlighted = false
        button.setBackgroundImage(UIColor("006EFF").trans2Image(), for: .normal)
        button.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 18)
        button.layer.shadowColor = UIColor("006EFF").cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 6)
        button.layer.shadowRadius = 16
        button.layer.shadowOpacity = 0.4
        button.layer.masksToBounds = true
        return button
    }()
    /// 注册提示按钮
    private lazy var registerTipButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(.link, for: .normal)
        button.setTitle(.registerTipText, for: .normal)
        button.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 14)
        return button
    }()
    /// 协议选择框
    private lazy var privacySelectButton: TRTCPrivacySelectButton = {
        let button = TRTCPrivacySelectButton(type: .custom)
        button.setImage(UIImage(named: "checkbox_nor"), for: .normal)
        button.setImage(UIImage(named: "checkbox_sel"), for: .selected)
        button.sizeToFit()
        return button
    }()
    /// 协议文本
    private lazy var privacyTextView: TRTCLoginAgreementTextView = {
        let textView = TRTCLoginAgreementTextView(frame: .zero, textContainer: nil)
        textView.delegate = self
        textView.backgroundColor = .white
        textView.isEditable = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.dataDetectorTypes = .link
        textView.textAlignment = .left
        let totalStr = localizeReplaceTwoCharacter(origin: .agreementText, xxx_replace: .privacyRegulationsText, yyy_replace: .userProtocolText)
        let privaStr = String.privacyRegulationsText
        let protoStr = String.userProtocolText
        
        let privaRange = (totalStr as NSString).range(of: privaStr)
        let protoRange = (totalStr as NSString).range(of: protoStr)
        
        let totalRange = NSRange(location: 0, length: totalStr.count)
        
        let attr = NSMutableAttributedString(string: totalStr)
        
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        attr.addAttribute(.paragraphStyle, value: style, range: totalRange)
        
        attr.addAttribute(.font, value: UIFont(name: "PingFangSC-Regular", size: 10) ?? UIFont.systemFont(ofSize: 10), range: totalRange)
        attr.addAttribute(.foregroundColor, value: UIColor.lightGray, range: totalRange)
        
        attr.addAttribute(.link, value: "privacy", range: privaRange)
        attr.addAttribute(.link, value: "protocol", range: protoRange)
        
        attr.addAttribute(.foregroundColor, value: UIColor.blue, range: privaRange)
        attr.addAttribute(.foregroundColor, value: UIColor.blue, range: protoRange)
        
        textView.attributedText = attr
        return textView
    }()
    /// 版本标签
    private let versionTipLabel: UILabel = {
        let tip = UILabel()
        tip.textAlignment = .center
        tip.font = UIFont.systemFont(ofSize: 14)
        tip.textColor = UIColor("BBBBBB").withAlphaComponent(0.8)
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "0.1.1"
        let sdkVersionStr = TRTCCloud.getSDKVersion() ?? "1.0.0"
        tip.text = "TRTC v\(sdkVersionStr)(\(version))"
        tip.adjustsFontSizeToFitWidth = true
        return tip
    }()
    /// 页面样式
    private var pageStyle:TRTCLoginOAuthViewController.PageStyle = .login
    /// 视图布局状态
    private var isViewReady = false
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        isViewReady = true
        // 视图层级布局
        constructViewHierarchy()
        // 生成约束（此时有可能拿不到父视图正确的frame）
        activateConstraints()
        // 绑定Action
        bindInteraction()
        
        registerTipButton.isHidden = pageStyle == .register
        loginButton.setTitle(pageStyle == .login ? .loginText:.registerText, for: .normal)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        contentView.roundedRect(rect: contentView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 40, height: 40))
        loginButton.layer.cornerRadius = loginButton.frame.height * 0.5
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

// MARK: - 视图布局初始化
extension TRTCLoginOAuthView {
    
    /// 构建视图层
    private func constructViewHierarchy() {
        addSubview(backgroundView)
        addSubview(titleLabel)
        addSubview(contentView)
        contentView.addSubview(userNameTextField)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(userNameBottomLine)
        contentView.addSubview(passwordBottomLine)
        contentView.addSubview(privacySelectButton)
        contentView.addSubview(privacyTextView)
        contentView.bringSubviewToFront(privacySelectButton)
        contentView.addSubview(registerTipButton)
        contentView.addSubview(loginButton)
        contentView.addSubview(versionTipLabel)

    }
    
    /// 布局Layout
    private func activateConstraints() {
        backgroundView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(backgroundView.snp.width)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(convertPixel(h: 86) + kDeviceSafeTopHeight)
            make.leading.equalToSuperview().offset(convertPixel(w: 40))
            make.trailing.lessThanOrEqualToSuperview().offset(-convertPixel(w: 40))
        }
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(backgroundView.snp.bottom).offset(-convertPixel(h: 64))
            make.leading.trailing.bottom.equalToSuperview()
        }
        userNameTextField.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(convertPixel(h: 40))
            make.leading.equalToSuperview().offset(convertPixel(w: 40))
            make.trailing.equalToSuperview().offset(-convertPixel(w: 40))
            make.height.equalTo(convertPixel(h: 57))
        }
        passwordTextField.snp.makeConstraints { (make) in
            make.leading.height.trailing.equalTo(userNameTextField)
            make.top.equalTo(userNameTextField.snp.bottom).offset(convertPixel(h: 20))
        }
        userNameBottomLine.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.equalTo(userNameTextField)
            make.height.equalTo(convertPixel(h: 1))
        }
        passwordBottomLine.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.equalTo(passwordTextField)
            make.height.equalTo(convertPixel(h: 1))
        }
        privacySelectButton.snp.makeConstraints { (make) in
            make.top.equalTo(passwordBottomLine.snp.bottom).offset(6)
            make.leading.equalTo(passwordTextField)
            make.size.equalTo(CGSize(width: 16, height: 16))
        }
        privacyTextView.snp.makeConstraints { (make) in
            make.leading.equalTo(privacySelectButton.snp.trailing)
            make.top.equalTo(privacySelectButton)
            make.trailing.equalTo(passwordTextField)
            make.height.equalTo(40)
        }
        registerTipButton.snp.makeConstraints { (make) in
            make.top.equalTo(passwordBottomLine.snp.bottom).offset(convertPixel(h: 30))
            make.trailing.equalTo(passwordBottomLine)
            make.height.equalTo(convertPixel(h: 30))
        }
        loginButton.snp.makeConstraints { (make) in
            make.top.equalTo(passwordBottomLine.snp.bottom).offset(convertPixel(h: 70))
            make.leading.equalToSuperview().offset(convertPixel(w: 20))
            make.trailing.equalToSuperview().offset(-convertPixel(w: 20))
            make.height.equalTo(convertPixel(h: 52))
        }
        versionTipLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(-12)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(30)
        }
    }
    
    /// 绑定Action
    private func bindInteraction() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenKeyboard))
        isUserInteractionEnabled = true
        addGestureRecognizer(tap)
        
        loginButton.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
        registerTipButton.addTarget(self, action: #selector(registerAction), for: .touchUpInside)
        privacySelectButton.addTarget(self, action: #selector(privacySelectAction), for: .touchUpInside)
    }
}

// MARK: - Public
extension TRTCLoginOAuthView {
    
    /// 更新隐私选择框选择状态
    /// - Parameter select: true 选中 false 未选中
    func updatePrivacyState(select:Bool) {
        privacySelectButton.isSelected = select
    }
    
}

// MARK: - KeyboardFrameChanged Notofication
extension TRTCLoginOAuthView {
    
    /// 键盘Frame监听
    @objc func keyboardFrameChange(noti : Notification) {
        guard userNameTextField.isFirstResponder || passwordTextField.isFirstResponder else {
            return
        }
        guard let info = noti.userInfo else {
            return
        }
        guard let value = info[UIResponder.keyboardFrameEndUserInfoKey], value is CGRect else {
            return
        }
        guard let superview = loginButton.superview else {
            return
        }
        let rect = value as! CGRect
        if rect.minY == UIScreen.main.bounds.height {
            // 键盘收起
            transform = .identity
            layoutIfNeeded()
        }else{
            // 键盘弹出
            let converted = superview.convert(loginButton.frame, to: self)
            if rect.intersects(converted) {
                let distance = -converted.maxY+rect.minY
                if transform.ty != distance {
                    transform = CGAffineTransform(translationX: 0, y: -converted.maxY+rect.minY)
                    layoutIfNeeded()
                }
            }
        }
    }
    
}

// MARK: - UITextFieldDelegate
extension TRTCLoginOAuthView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == userNameTextField, let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), password.isEmpty {
            passwordTextField.becomeFirstResponder()
        }
        return true
    }
    
}


// MARK: - UITextViewDelegate
extension TRTCLoginOAuthView: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if URL.absoluteString == "privacy" {
            showPrivacy()
        } else if URL.absoluteString == "protocol" {
            showProtocol()
        }
        return true
    }
    
}

// MARK: - Action
extension TRTCLoginOAuthView {

    // 登陆
    @objc private func loginAction() {
        guard let userName = userNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !userName.isEmpty else {
            userNameTextField.becomeFirstResponder()
            return
        }
        guard let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !password.isEmpty else {
            passwordTextField.becomeFirstResponder()
            return
        }
        endEditing(true)
        guard privacySelectButton.isSelected else {
            makeToast(.noagreeAlertText)
            return
        }
        if pageStyle == .login {
            // 发起登陆请求
            delegate?.login(userName: userName, password: password)
        } else {
            // 发起注册请求
            delegate?.register(userName: userName, password: password)
        }
    }
    
    /// 注册
    @objc private func registerAction() {
        endEditing(true)
        // 打开注册页面
        delegate?.openRegisterOAuthViewController()
    }
    
    /// 隐藏键盘
    @objc private func hiddenKeyboard() {
        endEditing(true)
    }
    
    /// 隐私开关
    @objc private func privacySelectAction() {
        privacySelectButton.isSelected = !privacySelectButton.isSelected
    }
    
}

// MARK: - Private
extension TRTCLoginOAuthView {
    
    /// 构造TextField
    /// - Parameter placeholder: 占位符
    /// - Returns: TextField Object
    private func createTextField(_ placeholder: String) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.backgroundColor = .white
        textField.font = UIFont(name: "PingFangSC-Regular", size: 16)
        textField.textColor = UIColor("333333")
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.font : UIFont(name: "PingFangSC-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor : UIColor("BBBBBB")])
        textField.delegate = self
        return textField
    }
    
    /// 构造分割线
    private func createSpacingLine() -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor("EEEEEE")
        return view
    }
    
    /// 展示隐私协议
    private func showPrivacy() {
        guard let url = URL(string: "https://web.sdk.qcloud.com/document/Tencent-RTC-Privacy-Protection-Guidelines.html") else {
            return
        }
        hiddenKeyboard()
        delegate?.openWebPage(url: url, title: .privacyTitleText)
    }
    
    /// 展示用户协议
    private func showProtocol() {
        guard let url = URL(string: "https://web.sdk.qcloud.com/document/Tencent-RTC-User-Agreement.html") else {
            return
        }
        hiddenKeyboard()
        delegate?.openWebPage(url: url, title: .protocolTitleText)
    }
    
}

extension String {
    func nsrange(fromRange range : Range<String.Index>) -> NSRange {
        return NSRange(range, in: self)
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    
    static let titleText = LoginLocalize("Demo.TRTC.Login.welcome")
    static let loginText = LoginLocalize("V2.Live.LoginMock.login")
    static let registerText = LoginLocalize("Demo.TRTC.Login.regist")
    static let registerTipText = LoginLocalize("V2.Live.loginMock.registertip")
    static let userNameText = LoginLocalize("V2.Live.LoginMock.username")
    static let passwordText = LoginLocalize("V2.Live.LoginMock.password")
    
    static let agreementText = LoginLocalize("Demo.TRTC.Portal.privateandagreement")
    static let privacyRegulationsText = LoginLocalize("Demo.TRTC.Portal.<private>")
    static let userProtocolText = LoginLocalize("Demo.TRTC.Portal.<agreement>")
    static let noagreeAlertText = LoginLocalize("Demo.TRTC.Portal.agreeprivatefirst")
    static let privacyTitleText = LoginLocalize("Demo.TRTC.Portal.private")
    static let protocolTitleText = LoginLocalize("Demo.TRTC.Portal.agreement")
    
}
