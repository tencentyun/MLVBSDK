//
//  ShowLiveAnchorRoomMsgView.swift
//  XiaoZhiBoApp
//
//  Created by adams on 2021/9/28.
//

import UIKit
import Photos
import CoreServices
import Toast_Swift
import Kingfisher

class ShowLiveAnchorRoomMsgView: UIView {
    
    let viewModel: ShowLiveAnchorViewModel
    
    private lazy var roomImageView: UIImageView = {
        let imageView = UIImageView.init(image: UIImage.init(named: "showLive_cover1"))
        if let url = URL.init(string: viewModel.roomInfo.coverUrl) {
            imageView.kf.setImage(with: .network(url))
        }
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private lazy var roomIdLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.textColor = .white
        label.textAlignment = .left
        label.text = viewModel.roomInfo.roomID
        return label
    }()
    
    private lazy var roomNameTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.font = UIFont(name: "PingFangSC-Regular", size: 16)
        textField.textColor = .white
        textField.attributedPlaceholder = NSAttributedString(string: "直播间的描述", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        textField.backgroundColor = .clear
        textField.delegate = self
        return textField
    }()
    
    init(frame: CGRect = .zero, viewModel: ShowLiveAnchorViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        backgroundColor = UIColor.gray.withAlphaComponent(0.5)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var isViewReady = false
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
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        roomImageView.layer.cornerRadius = roomImageView.frame.height * 0.5
    }
    
    private func constructViewHierarchy() {
        addSubview(roomImageView)
        addSubview(roomIdLabel)
        addSubview(roomNameTextField)
    }
    
    private func activateConstraints() {
        roomImageView.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.top.equalTo(15)
            make.size.equalTo(CGSize.init(width: 50, height: 50))
        }
        
        roomIdLabel.snp.makeConstraints { make in
            make.left.equalTo(roomImageView.snp.right).offset(10)
            make.top.equalTo(roomImageView.snp.top)
        }
        
        roomNameTextField.snp.makeConstraints { make in
            make.left.equalTo(roomImageView.snp.right).offset(10)
            make.bottom.equalTo(roomImageView.snp.bottom)
            make.height.equalTo(20)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-15)
        }
    }
    
    private func bindInteraction() {
        roomImageView.addTapGesture(target: self, action: #selector(roomImageClick))
    }
}

// MARK: - UIButton Touch Event
extension ShowLiveAnchorRoomMsgView {
    
    @objc
    private func roomImageClick() {
        makeToastActivity(.center)
        // 获取cos信息, 根据请求结果判断是否支持设置头像功能
        viewModel.getRoomAvatarCosInfo { [weak self] cosInfo in
            guard let self = self else { return }
            self.hideToastActivity()
            // 判断当前是否支持头像上传
            guard let info = cosInfo, !info.bucket.isEmpty else { return }
            self.viewModel.cosInfo = info
            // 弹出图片选择Alert
            self.presentAvatarPickerAlert()
        }
    }
}

// MARK: - 头像上传
extension ShowLiveAnchorRoomMsgView {
    /// 选取头像Alert
    private func presentAvatarPickerAlert() {
        let alert = UIAlertController(title: .selectPhotoText, message: nil, preferredStyle: .actionSheet)
        // 拍照选取
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: .cameraTitleText, style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.presentImagePicker(sourceType: .camera)
            }
            alert.addAction(cameraAction)
        }
        // 相册选取
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let photoLibraryAction = UIAlertAction(title: .photoLibraryText, style: .default) { [weak self] _ in
                guard let self = self else { return }
                self.presentImagePicker(sourceType: .photoLibrary)
            }
            alert.addAction(photoLibraryAction)
        }
        let cancelAction = UIAlertAction(title: .cancelText, style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        viewModel.viewNavigator?.present(viewController: alert)
    }

    /// 检测相关权限
    /// - Parameter sourceType: 需要检测的权限
    /// - Returns: true 已授权 false 未授权
    private func checkImagePickerAuth(sourceType: UIImagePickerController.SourceType) -> Bool {
        if sourceType == .camera {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            if status == .notDetermined {
                AVCaptureDevice.requestAccess(for: .video) { [weak self] status in
                    guard let self = self, status == true else { return }
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.presentImagePicker(sourceType: .camera)
                    }
                }
            } else if status == .denied || status == .restricted {
                makeToast(.cameraAuthText)
            }
            return status == .authorized
        }
        if sourceType == .photoLibrary {
            let status = PHPhotoLibrary.authorizationStatus()
            if status == .notDetermined {
                PHPhotoLibrary.requestAuthorization { [weak self] status in
                    guard let self = self, status == .authorized else { return }
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        self.presentImagePicker(sourceType: .photoLibrary)
                    }
                }
            } else if status == .denied || status == .restricted{
                makeToast(.photoLibraryAuthText)
            }
            return status == .authorized
        }
        return false
    }
    
    /// 打开ImagePicker
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        // 检测权限
        guard checkImagePickerAuth(sourceType: sourceType) else {
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = true
        if sourceType == .camera {
            imagePicker.cameraCaptureMode = .photo
        }
        viewModel.viewNavigator?.present(viewController: imagePicker)
    }
    
}

// MARK: - UIImagePickerControllerDelegate
extension ShowLiveAnchorRoomMsgView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let mediaType = info[.mediaType] as? String, mediaType == (kUTTypeImage as String) {
            if let editedImage = info[.editedImage] as? UIImage {
                makeToastActivity(.center)
                // 上传头像
                viewModel.uploadAvatar(image: editedImage) { [weak self] (imageURL, msg) in
                    guard let self = self else { return }
                    self.hideToastActivity()
                    if let coverUrl = imageURL, let url = URL.init(string: coverUrl) {
                        self.roomImageView.kf.setImage(with: .network(url), placeholder: editedImage)
                    } else {
                        self.makeToast(msg)
                    }
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ShowLiveAnchorRoomMsgView: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        viewModel.roomInfo.roomName = textField.text ?? ""
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        return roomNameTextField.resignFirstResponder()
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        return roomNameTextField.becomeFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        roomNameTextField.resignFirstResponder()
    }
}

// MARK: - internationalization string
fileprivate extension String {
    static let selectPhotoText = ShowLiveLocalize("Scene.ShowLive.Anchor.selectPhoto")
    static let cameraTitleText = ShowLiveLocalize("Scene.ShowLive.Anchor.camera")
    static let photoLibraryText = ShowLiveLocalize("Scene.ShowLive.Anchor.photolibrary")
    static let cameraAuthText = ShowLiveLocalize("Scene.ShowLive.Authorization.camera")
    static let photoLibraryAuthText = ShowLiveLocalize("Scene.ShowLive.Authorization.photolibrary")
    static let cancelText = ShowLiveLocalize("Scene.ShowLive.Anchor.cancel")
}
