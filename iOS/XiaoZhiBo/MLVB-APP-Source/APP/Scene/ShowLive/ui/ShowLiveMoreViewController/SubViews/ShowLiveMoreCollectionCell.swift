//
//  ShowLiveMoreCollectionCell.swift
//  XiaoZhiBoApp
//
//  Created by jack on 2021/12/15.
//

import UIKit

class ShowLiveMoreCollectionCell: UICollectionViewCell {
    
    lazy var coverImageView: UIImageView = {
        let imageView = UIImageView.init(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 4
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var userAvatarImageView: UIImageView = {
        let imageView = UIImageView.init(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 12
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var roomNameLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.text = ""
        label.font = UIFont(name: "PingFangSC-Regular", size: 14)
        label.textColor = .white
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private var isViewReady: Bool = false
    // MARK: - 视图生命周期函数
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
        contentView.backgroundColor = .black
    }
    
    func constructViewHierarchy() {
        contentView.addSubview(coverImageView)
        contentView.addSubview(userAvatarImageView)
        contentView.addSubview(roomNameLabel)
    }
    
    func activateConstraints() {
        coverImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        userAvatarImageView.snp.makeConstraints { (make) in
            make.width.height.equalTo(24)
            make.leading.equalTo(10)
            make.bottom.equalTo(-10)
        }
        roomNameLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(userAvatarImageView.snp.trailing).offset(6)
            make.centerY.equalTo(userAvatarImageView)
            make.trailing.lessThanOrEqualToSuperview().offset(-10)
        }
    }
}

// MARK: - 更新数据
extension ShowLiveMoreCollectionCell {
    
    public func updateUI(data: ShowLiveRoomInfo) {
        let imageURL = URL.init(string: data.coverUrl)
        let placeholderImage = UIImage.init(named: "showLive_cover1")
        self.userAvatarImageView.kf.setImage(with: imageURL, placeholder: placeholderImage)
        /// - Note: 直播间没有房间预览图片，先使用用户头像替代
        self.coverImageView.kf.setImage(with: imageURL, placeholder: placeholderImage)
        roomNameLabel.text = data.roomName
    }
    
}
