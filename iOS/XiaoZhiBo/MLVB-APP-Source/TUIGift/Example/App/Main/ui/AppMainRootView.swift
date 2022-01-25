//
//  AppMainRootView.swift
//  DemoApp
//
//  Created by wesley on 2021/7/20.
//

import UIKit
import SnapKit

protocol AppMainRootViewDelegate: NSObject {
    func enterRoom(roomId: String)
    func createRoom()
}

class AppMainRootView: UIView {

    lazy var createRoomBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle(.createRoomText, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemBlue
        btn.layer.cornerRadius = 24
        btn.layer.masksToBounds = true
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        btn.titleLabel?.adjustsFontSizeToFitWidth = true
        return btn
    }()
    
    lazy var roomInputTextField: TUITextField = {
        let textField = TUITextField.init(frame: .zero)
        textField.backgroundColor = .clear
        
        let leftLabel = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 120, height: 40))
        leftLabel.text = .roomNumberText
        leftLabel.font = UIFont.systemFont(ofSize: 15)
        leftLabel.textColor = .black
        textField.leftView = leftLabel
        textField.leftViewMode = .always
        
        let attributeString = NSMutableAttributedString.init(string: .enterRoomNumberText)
        attributeString.addAttributes([.foregroundColor : UIColor.gray, .font : UIFont.systemFont(ofSize: 15)], range: NSRange.init(location: 0, length: attributeString.length))
        textField.attributedPlaceholder = attributeString
        textField.addTarget(self, action: #selector(roomNumberTextFieldValueChange(sender:)), for: .editingChanged)
        textField.keyboardType = .numberPad
        textField.textColor = .black
        return textField
    }()
    
    lazy var textRoomContainerView: UIView = {
        let containerView = UIView.init(frame: .zero)
        containerView.backgroundColor = UIColor.init(0xF4F5F9)
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        return containerView
    }()
    
    lazy var enterRoomBtn: UIButton = {
        let btn = UIButton.init(frame: .zero)
        btn.setTitle(.enterRoomText, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.setBackgroundImage(UIColor.init(0xd8d8d8).trans2Image(), for: .normal)
        btn.setBackgroundImage(UIColor.systemBlue.trans2Image(), for: .selected)
        btn.layer.cornerRadius = 8
        btn.layer.masksToBounds = true
        return btn
    }()
    
    weak var delegate: AppMainRootViewDelegate? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewHierarchy()
        setupViewConstraints()
        bindInteraction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        roomInputTextField.resignFirstResponder()
    }
    
}

extension AppMainRootView {
    
    private func setupViewHierarchy() {
        addSubview(createRoomBtn)
        addSubview(textRoomContainerView)
        textRoomContainerView.addSubview(roomInputTextField)
        addSubview(enterRoomBtn)
    }
    
    private func setupViewConstraints() {
        createRoomBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-60)
            make.size.equalTo(CGSize.init(width: 163, height: 60))
        }
        
        textRoomContainerView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(10)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(54)
        }
        
        roomInputTextField.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        enterRoomBtn.snp.makeConstraints { make in
            make.left.equalTo(textRoomContainerView.snp.left)
            make.right.equalTo(textRoomContainerView.snp.right)
            make.height.equalTo(textRoomContainerView.snp.height)
            make.top.equalTo(textRoomContainerView.snp.bottom).offset(40)
        }
    }
    
    private func bindInteraction() {
        createRoomBtn.addTarget(self, action: #selector(createRoomBtnTouchEvent), for:.touchUpInside)
        enterRoomBtn.addTarget(self, action: #selector(enterRoomBtnTouchEvent), for: .touchUpInside)
    }
    
}

extension AppMainRootView {
    
    @objc private func createRoomBtnTouchEvent() {
        if let delegate = delegate {
            delegate.createRoom()
        }
    }
    
    @objc private func enterRoomBtnTouchEvent() {
        if let roomId = roomInputTextField.text, let delegate = delegate {
            delegate.enterRoom(roomId: roomId)
        }
    }
    
    @objc private func roomNumberTextFieldValueChange(sender: UITextField) {
        if let text = sender.text, text.count > 0 {
            enterRoomBtn.isSelected = true
            enterRoomBtn.isUserInteractionEnabled = true
        } else {
            enterRoomBtn.isSelected = false
            enterRoomBtn.isUserInteractionEnabled = false
        }
    }
    
}

class TUITextField: UITextField {
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.leftViewRect(forBounds: bounds)
        rect.origin.x += 10
        return rect
    }
}

private extension String {
    static let roomNumberText = TRTCKaraokeLocalize("Demo.TRTC.LiveRoom.roomNumber")
    static let enterRoomNumberText = TRTCKaraokeLocalize("Demo.TRTC.LiveRoom.enterRoomNumber")
    static let enterRoomText = TRTCKaraokeLocalize("Demo.TRTC.LiveRoom.enterRoom")
    static let createRoomText = TRTCKaraokeLocalize("Demo.TRTC.LiveRoom.createRoom")
}
