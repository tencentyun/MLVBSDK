//
//  ShowLiveHotRankingView.swift
//  XiaoZhiBoApp
//
//  Created by jack on 2021/12/21.
//  人气榜单直播间展示View

import UIKit

class ShowLiveHotRankingView: UIView {

    private lazy var iconImageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.image = UIImage(named: "top_hot")
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = .titleText
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
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
        backgroundColor = UIColor.black.withAlphaComponent(0.3)
        layer.masksToBounds = true
    }
    
    private func constructViewHierarchy() {
        addSubview(iconImageView)
        addSubview(titleLabel)
    }
    
    private func activateConstraints() {
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(16)
            make.leading.equalTo(8)
            make.centerY.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(2)
            make.trailing.equalTo(-8)
            make.centerY.equalToSuperview()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.cornerRadius = bounds.height * 0.5
    }
}

// MARK: - internationalization string
fileprivate extension String {
    static let titleText = ShowLiveLocalize("Scene.ShowLive.Ranking.hot")
}
