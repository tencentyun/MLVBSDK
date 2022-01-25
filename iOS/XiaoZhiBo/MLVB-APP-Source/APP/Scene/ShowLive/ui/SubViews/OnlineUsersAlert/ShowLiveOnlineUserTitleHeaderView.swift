//
//  ShowLiveOnlineUserTitleHeaderView.swift
//  XiaoZhiBoApp
//
//  Created by jack on 2021/12/13.
//  在线用户列表弹框 头部视图 Top 100

import UIKit

class ShowLiveOnlineUserTitleHeaderView: UITableViewHeaderFooterView {

    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = UIColor(hex: "#999999")
        label.font = UIFont(name: "PingFangSC-Regular", size: 14)
        label.text = "TOP 100"
        return label
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        constructViewHierarchy()
        activateConstraints()
    }
    
    private func constructViewHierarchy() {
        contentView.addSubview(titleLabel)
    }
    
    private func activateConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(20)
        }
    }

}
