//
//  ShowLiveHotRankingTableCell.swift
//  XiaoZhiBoApp
//
//  Created by jack on 2021/12/21.
//

import UIKit

/// 人气榜View
class ShowLiveHotRankingContentView: UIView {
    /// 榜单序号标签Label
    lazy var orderLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = UIColor(hex: "#999999")
        label.font = UIFont(name: "PingFangSC-Regular", size: 16)
        label.text = "0"
        return label
    }()
    /// 房间图片View
    lazy var coverImageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 24
        view.layer.masksToBounds = true
        return view
    }()
    /// 房间名称Label
    lazy var nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = UIColor(hex: "#333333")
        label.font = UIFont(name: "PingFangSC-Regular", size: 16)
        return label
    }()
    /// 人气数量Label
    lazy var numberLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = UIColor(hex: "#333333")
        label.font = UIFont(name: "PingFangSC-Regular", size: 16)
        return label
    }()
    
    private var isViewReady = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
    }
    
    private func constructViewHierarchy() {
        addSubview(orderLabel)
        addSubview(coverImageView)
        addSubview(nameLabel)
        addSubview(numberLabel)
    }
    
    private func activateConstraints() {
        orderLabel.snp.makeConstraints { make in
            make.leading.equalTo(20)
            make.centerY.equalToSuperview()
        }
        coverImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(48)
            make.leading.equalTo(orderLabel.snp.trailing).offset(20)
        }
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(coverImageView.snp.trailing).offset(16)
            make.trailing.lessThanOrEqualTo(numberLabel.snp.leading).offset(-20)
            make.centerY.equalTo(coverImageView)
        }
        numberLabel.snp.makeConstraints { make in
            make.trailing.equalTo(-20)
            make.width.greaterThanOrEqualTo(1)
            make.centerY.equalTo(coverImageView)
        }
    }
    
    /// 更新UI
    /// - Parameters:
    ///   - order: 排序
    ///   - roomInfo: 房间信息
    func updateUI(order: Int, roomInfo: ShowLiveRoomInfo) {
        if order == 1 {
            orderLabel.textColor = UIColor(hex: "#FF465D")
        } else if order == 2 {
            orderLabel.textColor = UIColor(hex: "#FF8607")
        } else if order == 3 {
            orderLabel.textColor = UIColor(hex: "#FCAF41")
        } else {
            orderLabel.textColor = UIColor(hex: "#999999")
        }
        if order >= 0 {
            orderLabel.text = order.description
        } else {
            orderLabel.text = "-"
        }
        let imageURL = URL(string: roomInfo.coverUrl)
        coverImageView.kf.setImage(with: imageURL, placeholder: nil)
        nameLabel.text = roomInfo.roomName
        if roomInfo.totalJoined >= 10000 {
            numberLabel.text = String(format: "%.1fw", Float(roomInfo.totalJoined)/10000.0)
        } else if roomInfo.totalJoined >= 1000 {
            numberLabel.text = String(format: "%.1fk", Float(roomInfo.totalJoined)/1000.0)
        } else {
            numberLabel.text = roomInfo.totalJoined.description
        }
    }
}

// MARK: - ShowLiveHotRankingTableCell
class ShowLiveHotRankingTableCell: UITableViewCell {
    /// 人气榜View
    lazy var rankingContentView: ShowLiveHotRankingContentView = {
        let view = ShowLiveHotRankingContentView(frame: .zero)
        return view
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.backgroundColor = .white
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
    }
    
    private func constructViewHierarchy() {
        contentView.addSubview(rankingContentView)
    }
    
    private func activateConstraints() {
        rankingContentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}

// MARK: - Public
extension ShowLiveHotRankingTableCell {
    
    /// 更新UI
    /// - Parameters:
    ///   - order: 排序
    ///   - roomInfo: 房间信息
    func updateUI(order: Int, roomInfo: ShowLiveRoomInfo) {
        rankingContentView.updateUI(order: order, roomInfo: roomInfo)
    }
    
}
