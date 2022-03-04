//
//  ShowLiveHotRankingAlert.swift
//  XiaoZhiBoApp
//
//  Created by jack on 2021/12/21.
//  人气榜单弹框视图

import UIKit
import TUICore

class ShowLiveHotRankingAlert: ShowLiveAlertViewController {

    /// 当前房间信息
    private var roomInfo: ShowLiveRoomInfo? = nil
    /// 数据源
    private var roomDataSource: [ShowLiveRoomInfo] = [ShowLiveRoomInfo]()
    
    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.backgroundColor = .white
        view.separatorStyle = .none
        view.contentInset = .zero
        view.automaticallyAdjustsScrollIndicatorInsets = false
        view.delegate = self
        view.dataSource = self
        view.tableFooterView = UIView()
        view.register(ShowLiveHotRankingTableCell.self, forCellReuseIdentifier: ShowLiveHotRankingTableCell.reuseIdentifier)
        return view
    }()
    
    /// 当前房间信息View
    private lazy var currentRoomInfoView: ShowLiveHotRankingContentView = {
        let view = ShowLiveHotRankingContentView(frame: .zero)
        view.backgroundColor = .white
        view.layer.shadowOpacity = 0.8
        view.layer.shadowColor = UIColor(hex: "#F7F7F7").cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        return view
    }()
    
    /// 便利构造人气榜Alert视图
    /// - Parameters:
    ///   - roomInfo: 当前房间信息
    ///   - hotDataSource: 人气榜数据源
    convenience init(roomInfo: ShowLiveRoomInfo) {
        self.init()
        self.roomInfo = roomInfo
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        titleLabel.text = .titleText
        if let roomInfo = self.roomInfo {
            currentRoomInfoView.updateUI(order: -1, roomInfo: roomInfo)
        }
        requestHotRooms()
    }
    
    override func constructViewHierarchy() {
        super.constructViewHierarchy()
        contentView.addSubview(tableView)
        contentView.addSubview(currentRoomInfoView)
    }
    
    override func activateConstraints() {
        super.activateConstraints()
        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(14)
            make.height.equalTo(380)
        }
        currentRoomInfoView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(96)
            make.top.equalTo(tableView.snp.bottom)
            make.bottom.equalTo(-kDeviceSafeBottomHeight)
        }
    }

    override func bindInteraction() {
        super.bindInteraction()
        tableView.setupNormalRefreshHeader(target: self, action: #selector(requestHotRooms))
    }
}

// MARK: - 请求人气榜单数据
extension ShowLiveHotRankingAlert {
    
    /// 获取房间榜单
    @objc
    private func requestHotRooms() {
        let sdkAppId = HttpLogicRequest.sdkAppId
        RoomService.shared.getRoomList(sdkAppID: sdkAppId,
                                       roomType: .showLive,
                                       orderType: .totalJoined) { [weak self] (roomInfos) in
            guard let self = self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.roomDataSource = roomInfos
                self.tableView.reloadData()
                self.tableView.mj_header?.endRefreshing()
                // 获取当前房间信息
                guard let roomInfo = self.roomInfo else { return }
                // 获取当前直播间排名
                guard let index = roomInfos.firstIndex(where: {$0.roomID == roomInfo.roomID}) else { return }
                // 更新当前房间排名
                self.currentRoomInfoView.updateUI(order: index + 1, roomInfo: roomInfos[index])
            }
        } failed: { [weak self] (code, message) in
            guard let self = self else { return }
            TRTCLog.out("error: get room list fail. code: \(code), message:\(message)")
            self.view.makeToast(.listFailedText)
            self.tableView.mj_header?.endRefreshing()
        }
    }
    
}

// MARK: - UITableViewDataSource
extension ShowLiveHotRankingAlert: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseId = ShowLiveHotRankingTableCell.reuseIdentifier
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath) as! ShowLiveHotRankingTableCell
        let roomInfo = roomDataSource[indexPath.row]
        cell.updateUI(order: indexPath.row + 1, roomInfo: roomInfo)
        return cell
    }
    
}

// MARK: - UITableViewDelegate
extension ShowLiveHotRankingAlert: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
}

// MARK: - internationalization string
fileprivate extension String {
    static let titleText = ShowLiveLocalize("Scene.ShowLive.Ranking.hot")
    static let listFailedText = ShowLiveLocalize("Scene.ShowLive.List.getlistfailed")
}
