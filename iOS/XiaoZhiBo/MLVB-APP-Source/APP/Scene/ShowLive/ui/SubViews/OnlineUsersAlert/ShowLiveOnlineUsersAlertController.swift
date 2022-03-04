//
//  ShowLiveOnlineUsersAlertController.swift
//  XiaoZhiBoApp
//
//  Created by jack on 2021/12/13.
//  直播间在线用户列表弹框

import UIKit

class ShowLiveOnlineUsersAlertController: ShowLiveAlertViewController {
    
    private var roomId: String = ""
    /// 用户数据源
    private var userDataSource: [ShowLiveUserInfo] = [ShowLiveUserInfo]()
    /// 事件回调
    private var delegate: ShowLiveOnlineUsersDelegate? = nil
    
    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.backgroundColor = .white
        view.separatorStyle = .none
        view.contentInset = .zero
        view.automaticallyAdjustsScrollIndicatorInsets = false
        view.delegate = self
        view.dataSource = self
        view.register(ShowLiveOnlineUserTitleHeaderView.self, forHeaderFooterViewReuseIdentifier: "titleHeader")
        view.register(ShowLiveOnlineUserTableCell.self, forCellReuseIdentifier: ShowLiveOnlineUserTableCell.reuseIdentifier)
        return view
    }()
    
    convenience init(roomId: String, userDataSource: [ShowLiveUserInfo], delegate: ShowLiveOnlineUsersDelegate? = nil) {
        self.init()
        self.roomId = roomId
        self.userDataSource = userDataSource
        self.delegate = delegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = .titleText
        registerNotification()
    }
    
    override func constructViewHierarchy() {
        super.constructViewHierarchy()
        self.contentView.addSubview(self.tableView)
    }
    
    override func activateConstraints() {
        super.activateConstraints()
        self.tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(14)
            make.height.equalTo(380)
            make.bottom.equalTo(-kDeviceSafeBottomHeight)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - IMListenerNotification 用户进入、离开直播间监听
extension ShowLiveOnlineUsersAlertController {
    
    /// 注册IM监听
    private func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(onUserEnterLiveRoom(_:)), name: .IMGroupUserEnterLiveRoom, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onUserLeaveLiveRoom(_:)), name: .IMGroupUserLeaveLiveRoom, object: nil)
    }
    
    /// 用户加入直播间
    @objc
    private func onUserEnterLiveRoom(_ notification: Notification) {
        guard let enterInfo = notification.userInfo as? [String: Any], let groupID = enterInfo["groupID"] as? String, groupID == roomId else {
            return
        }
        guard let enterUsers = enterInfo["memberList"] as? [ShowLiveUserInfo] else {
            return
        }
        for user in enterUsers {
            if userDataSource.contains(where: {$0.userId == user.userId}) == false {
                userDataSource.append(user)
            }
        }
        tableView.reloadData()
    }
    
    /// 用户离开直播间
    @objc
    private func onUserLeaveLiveRoom(_ notification: Notification) {
        guard let leaveInfo = notification.userInfo as? [String: Any], let groupID = leaveInfo["groupID"] as? String, groupID == roomId else {
            return
        }
        guard let leaveUser = leaveInfo["member"] as? ShowLiveUserInfo else {
            return
        }
        userDataSource.removeAll(where: {$0.userId == leaveUser.userId})
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension ShowLiveOnlineUsersAlertController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseId = ShowLiveOnlineUserTableCell.reuseIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath) as! ShowLiveOnlineUserTableCell
        let userInfo = userDataSource[indexPath.row]
        cell.updateUI(order: indexPath.row + 1, userInfo: userInfo)
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension ShowLiveOnlineUsersAlertController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let titleView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "titleHeader") as? ShowLiveOnlineUserTitleHeaderView {
            return titleView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = userDataSource[indexPath.row]
        delegate?.showLiveOnlineUsersDidClickUser(user)
    }
    
}

// MARK: - internationalization string
fileprivate extension String {
    static let titleText = ShowLiveLocalize("Scene.ShowLive.OnlineUsers.title")
}
 
