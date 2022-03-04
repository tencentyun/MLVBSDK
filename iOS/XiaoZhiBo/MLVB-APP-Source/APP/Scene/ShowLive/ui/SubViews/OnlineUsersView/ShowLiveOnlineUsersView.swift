//
//  ShowLiveOnlineUsersView.swift
//  XiaoZhiBoApp
//
//  Created by jack on 2021/12/13.
//  直播间在线用户列表视图

import UIKit

class ShowLiveOnlineUserCell: UICollectionViewCell {
    
    lazy var avatarImageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        constructViewHierarchy()
        activateConstraints()
        contentView.backgroundColor = .clear
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.kf.cancelDownloadTask()
        avatarImageView.image = nil
    }
    
    private func constructViewHierarchy() {
        contentView.addSubview(avatarImageView)
    }
    
    private func activateConstraints() {
        avatarImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
}

class ShowLiveOnlineUserCountCell: UICollectionViewCell {
    
    lazy var countLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        label.font = UIFont(name: "PingFangSC-Regular", size: 12)
        label.textAlignment = .center
        label.layer.cornerRadius = 16
        label.layer.masksToBounds = true
        label.backgroundColor = .black
        label.alpha = 0.3
        return label
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        constructViewHierarchy()
        activateConstraints()
        contentView.backgroundColor = .clear
    }
    
    private func constructViewHierarchy() {
        contentView.addSubview(countLabel)
    }
    
    private func activateConstraints() {
        countLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
}

// MARK: - 在线用户列表事件Delegate
protocol ShowLiveOnlineUsersDelegate: NSObjectProtocol {
    
    /// 查看更多在线用户
    func showLiveOnlineUsersDidClickMore()
    
    /// 点击某个用户
    func showLiveOnlineUsersDidClickUser(_ userInfo: ShowLiveUserInfo)
    
}

// MARK: - 为ShowLiveOnlineUsersDelegate可选方法提供默认实现
extension ShowLiveOnlineUsersDelegate {
    
    func showLiveOnlineUsersDidClickMore() {
        TRTCLog.out("在线用户列表: 点击更多")
    }
    
    func showLiveOnlineUsersDidClickUser(_ userInfo: ShowLiveUserInfo) {
        TRTCLog.out("在线用户列表: 点击了用户 userId: \(userInfo.userId)")
    }
}


class ShowLiveOnlineUsersView: UIView {

    private lazy var collectionLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 32, height: 32)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = .zero
        return layout
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
        view.backgroundColor = .clear
        view.register(ShowLiveOnlineUserCell.self, forCellWithReuseIdentifier: ShowLiveOnlineUserCell.reuseIdentifier)
        view.register(ShowLiveOnlineUserCountCell.self, forCellWithReuseIdentifier: ShowLiveOnlineUserCountCell.reuseIdentifier)
        view.delegate = self
        view.dataSource = self
        view.isScrollEnabled = false
        view.clipsToBounds = true
        return view
    }()

    private var userDataSource: [ShowLiveUserInfo] = [ShowLiveUserInfo]()
    private var onlineUserCount: Int = 0
    /// 最多显示用户头像数量
    private var maxShowCount: Int = 4
    weak var delegate: ShowLiveOnlineUsersDelegate? = nil
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        constructViewHierarchy()
        activateConstraints()
        backgroundColor = .clear
    }
    
    convenience init(delegate: ShowLiveOnlineUsersDelegate?) {
        self.init(frame: .zero)
        self.delegate = delegate
    }
    
    private func constructViewHierarchy() {
        addSubview(collectionView)
    }
    
    private func activateConstraints() {
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.width.equalTo(32)
            make.height.equalTo(32)
        }
    }

    
    func updateUI(userDataSource: [ShowLiveUserInfo], userCount: Int) {
        self.userDataSource = userDataSource
        self.onlineUserCount = userCount
        var showCount = maxShowCount + 1
        if self.userDataSource.count < maxShowCount {
            showCount = self.userDataSource.count % maxShowCount + 1
        }
        let collectionWidth = CGFloat(showCount) * collectionLayout.itemSize.width + collectionLayout.minimumLineSpacing * CGFloat(showCount - 1)
        collectionView.snp.updateConstraints { make in
            make.width.equalTo(collectionWidth)
        }
        self.layoutIfNeeded()
        self.collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension ShowLiveOnlineUsersView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if userDataSource.count >= maxShowCount {
            return maxShowCount + 1
        }
        return userDataSource.count % maxShowCount + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item < userDataSource.count && indexPath.item < maxShowCount {
            let reuseId =  ShowLiveOnlineUserCell.reuseIdentifier
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as! ShowLiveOnlineUserCell
            var userAvatar = userDataSource[indexPath.item].avatar
            if userAvatar.isEmpty {
                userAvatar = "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar1.png"
            }
            let avatarURL = URL(string: userAvatar)
            cell.avatarImageView.kf.setImage(with: avatarURL, placeholder: nil)
            return cell
        } else {
            let reuseId = ShowLiveOnlineUserCountCell.reuseIdentifier
            let userCountCell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as! ShowLiveOnlineUserCountCell
            userCountCell.countLabel.text = onlineUserCountString(onlineUserCount)
            return userCountCell
        }
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ShowLiveOnlineUsersView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.showLiveOnlineUsersDidClickMore()
    }
}


// MARK: - Private
extension ShowLiveOnlineUsersView {
    // 在线用户数字转换
    private func onlineUserCountString(_ count: Int) -> String {
        if count <= 999 {
            return count.description
        } else {
            return String(format: "%.2fK", Double(count)/1000.0)
        }
    }
    
}
