//
//  ShowLiveMoreLiveView.swift
//  XiaoZhiBoApp
//
//  Created by jack on 2021/12/15.
//

import UIKit

class ShowLiveMoreLiveView: UIView {

    private lazy var moreIconImageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "more_live")
        return view
    }()
    
    private lazy var moreLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .white
        label.font = UIFont(name: "PingFangSC-Regular", size: 12)
        label.text = ShowLiveLocalize("Scene.ShowLive.MoreLiveRoom.title")
        return label
    }()
    
    private lazy var moreArrowImageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "more_live_arrow")
        return view
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
        layer.masksToBounds = true
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        roundedRect(rect: bounds, byRoundingCorners: [.topLeft, .bottomLeft], cornerRadii: CGSize(width: 12, height: 12))
    }
    
    private func constructViewHierarchy() {
        addSubview(moreIconImageView)
        addSubview(moreLabel)
        addSubview(moreArrowImageView)
    }
    
    private func activateConstraints() {
        moreIconImageView.snp.makeConstraints { make in
            make.leading.equalTo(10)
            make.width.height.equalTo(16)
            make.centerY.equalToSuperview()
        }
        moreLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(moreIconImageView.snp.trailing).offset(4)
        }
        moreArrowImageView.snp.makeConstraints { make in
            make.leading.equalTo(moreLabel.snp.trailing).offset(4)
            make.trailing.equalTo(-4)
            make.width.height.equalTo(6)
            make.centerY.equalToSuperview()
        }
    }
}
