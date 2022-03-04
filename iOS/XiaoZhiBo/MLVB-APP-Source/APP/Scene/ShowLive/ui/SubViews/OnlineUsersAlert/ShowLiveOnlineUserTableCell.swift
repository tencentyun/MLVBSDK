//
//  ShowLiveOnlineUserTableCell.swift
//  XiaoZhiBoApp
//
//  Created by jack on 2021/12/13.
//  在线用户列表弹框 用户Cell

import UIKit

class ShowLiveOnlineUserTableCell: UITableViewCell {

    lazy var orderLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = UIColor(hex: "#999999")
        label.font = UIFont(name: "PingFangSC-Regular", size: 16)
        label.text = "0"
        return label
    }()
    
    lazy var avatarImageView:UIImageView = {
        let view = UIImageView(frame: .zero)
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 24
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = UIColor(hex: "#333333")
        label.font = UIFont(name: "PingFangSC-Regular", size: 16)
        return label
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .white
        constructViewHierarchy()
        activateConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.kf.cancelDownloadTask()
    }
    
    private func constructViewHierarchy() {
        contentView.addSubview(orderLabel)
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
    }
    
    private func activateConstraints() {
        orderLabel.snp.makeConstraints { make in
            make.leading.equalTo(20)
            make.centerY.equalToSuperview()
        }
        avatarImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(48)
            make.leading.equalTo(orderLabel.snp.trailing).offset(20)
        }
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(16)
            make.trailing.lessThanOrEqualTo(-20)
            make.centerY.equalTo(avatarImageView)
        }
    }
    

}

// MARK: - Public
extension ShowLiveOnlineUserTableCell {
    
    func updateUI(order: Int, userInfo: ShowLiveUserInfo) {
        if order == 1 {
            orderLabel.textColor = UIColor(hex: "#FF465D")
        } else if order == 2 {
            orderLabel.textColor = UIColor(hex: "#FF8607")
        } else if order == 3 {
            orderLabel.textColor = UIColor(hex: "#FCAF41")
        } else {
            orderLabel.textColor = UIColor(hex: "#999999")
        }
        orderLabel.text = order.description
        var userAvatar = userInfo.avatar
        if userAvatar.isEmpty {
            userAvatar = "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar1.png"
        }
        let imageURL = URL(string: userAvatar)
        avatarImageView.kf.setImage(with: imageURL, placeholder: nil)
        nameLabel.text = userInfo.name
    }
    
}
