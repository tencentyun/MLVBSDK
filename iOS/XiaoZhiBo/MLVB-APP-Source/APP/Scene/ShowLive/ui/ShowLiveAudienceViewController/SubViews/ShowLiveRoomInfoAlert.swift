//
//  ShowLiveRoomInfoAlert.swift
//  XiaoZhiBoApp
//
//  Created by jack on 2021/12/20.
//  房间关注弹框Alert

import UIKit

class ShowLiveRoomInfoAlert: ShowLiveAlertViewController {
    /// 用户头像
    private lazy var userAvatarView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 40
        return view
    }()
    /// 房间名称
    private lazy var roomNameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .black
        return label
    }()
    /// 粉丝数量
    private lazy var fansCountLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor(hex: "#999999")
        label.text = .fansText + " 678"
        return label
    }()
    /// 分割线
    private lazy var lineView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(hex: "#999999")
        return view
    }()
    /// 关注数量
    private lazy var followCountLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor(hex: "#999999")
        label.text = .followText + " \(followCount)"
        return label
    }()
    /// 关注按钮
    private lazy var followButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .lightGray
        button.setTitle(" \(String.followText)", for: .normal)
        button.setTitle(" \(String.followedText)", for: .selected)
        button.setImage(UIImage(named: "follow_add"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        button.layer.masksToBounds = true
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    /// follow 事件回调
    var followBlock: ((_ isFollow: Bool)->())? = nil
    /// 房间信息
    private var roomInfo: ShowLiveRoomInfo!
    /// 关注数量
    private var followCount: Int = 0
    /// 便利构造器
    convenience init(roomInfo: ShowLiveRoomInfo) {
        self.init()
        self.roomInfo = roomInfo
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 房间信息
        roomNameLabel.text = roomInfo.roomName
        if let url = URL(string: roomInfo.coverUrl.isEmpty ? .defaultUserAvatar : roomInfo.coverUrl) {
            userAvatarView.kf.setImage(with: .network(url))
        }
        // 更新关注状态
        updateFollowState(isFollow: roomInfo.isFollow)
        // 获取关注数量
        RoomService.shared.getFollowCount { [weak self] (count) in
            guard let self = self else { return }
            self.followCountLabel.text = .followText + " \(count)"
        } failed: { (_, _) in
            
        }
    }
    
    override func constructViewHierarchy() {
        super.constructViewHierarchy()
        view.addSubview(userAvatarView)
        contentView.addSubview(roomNameLabel)
        contentView.addSubview(fansCountLabel)
        contentView.addSubview(lineView)
        contentView.addSubview(followCountLabel)
        contentView.addSubview(followButton)
    }

    override func activateConstraints() {
        super.activateConstraints()
        userAvatarView.snp.makeConstraints { make in
            make.width.height.equalTo(80)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(contentView.snp.top).offset(40)
        }
        roomNameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualToSuperview().inset(10)
            make.top.equalTo(60)
        }
        lineView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalTo(12)
            make.top.equalTo(roomNameLabel.snp.bottom).offset(14)
        }
        fansCountLabel.snp.makeConstraints { make in
            make.trailing.equalTo(lineView.snp.leading).offset(-10)
            make.centerY.equalTo(lineView)
        }
        followCountLabel.snp.makeConstraints { make in
            make.leading.equalTo(lineView.snp.trailing).offset(10)
            make.centerY.equalTo(lineView)
        }
        followButton.snp.makeConstraints { make in
            make.height.equalTo(52)
            make.leading.trailing.equalToSuperview().inset(20)
            make.top.equalTo(lineView.snp.bottom).offset(30)
            make.bottom.equalTo(-20 - kDeviceSafeBottomHeight)
        }
    }
    
    override func bindInteraction() {
        super.bindInteraction()
        followButton.addTarget(self, action: #selector(followAction), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let gradientColors = [UIColor(hex: "#FF8BB7").cgColor, UIColor(hex: "#FF465D").cgColor]
        let followGradientLayer = followButton.gradient(colors: gradientColors)
        followGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        followGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        followButton.layer.cornerRadius = followButton.bounds.height * 0.5
        followGradientLayer.isHidden = roomInfo.isFollow
    }
    
    /// 刷新关注状态
    private func updateFollowState(isFollow: Bool) {
        followButton.isSelected = isFollow
        followButton.gradientLayer?.isHidden = isFollow
    }
}

// MARK: - UIButton Touch Event
extension ShowLiveRoomInfoAlert {
    
    /// 关注按钮点击事件
    @objc
    private func followAction() {
        let willFollow = !roomInfo.isFollow
        let userId = roomInfo.ownerId
        RoomService.shared.requestFollow(userId: userId,
                                         isFollow: willFollow) { [weak self] in
            guard let self = self else { return }
            if willFollow {
                self.view.makeToast(.followedText)
            }
            if willFollow {
                self.followCount += 1
            } else if self.followCount > 1 {
                self.followCount -= 1
            }
            self.roomInfo.isFollow = willFollow
            self.updateFollowState(isFollow: willFollow)
            self.followCountLabel.text = .followText + " \(self.followCount)"
            self.followBlock?(willFollow)
        } failed: { [weak self] (code, error) in
            guard let self = self else { return }
            self.view.makeToast(error)
        }
    }
}

// MARK: - internationalization string
fileprivate extension String {
    static let followText = ShowLiveLocalize("Scene.ShowLive.Audience.follow")
    static let followedText = ShowLiveLocalize("Scene.ShowLive.Audience.followed")
    static let fansText = ShowLiveLocalize("Scene.ShowLive.Audience.fans")
    
    static let defaultUserAvatar = "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar2.png"
}
