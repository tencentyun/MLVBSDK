//
//  ShowLiveListCell.swift
//  XiaoZhiBoApp
//
//  Created by adams on 2021/9/27.
//

import UIKit

class ShowLiveListCell: UICollectionViewCell {
    private var isViewReady: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 10
        clipsToBounds = true
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let coverImageView: UIImageView = {
        let imageView = UIImageView.init(frame: .zero)
        imageView.contentMode = .scaleToFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let anchorNameLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.text = ""
        label.font = UIFont(name: "PingFangSC-Regular", size: 14)
        label.textColor = .white
        return label
    }()
    
    let roomNameLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.text = ""
        label.font = UIFont(name: "PingFangSC-Regular", size: 12)
        label.textColor = .white
        label.textAlignment = .left
        return label
    }()
    
    lazy var memberContainerView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()
    
    lazy var memberBgView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        view.alpha = 0.2
        return view
    }()
    
    lazy var memberCountIcon: UIImageView = {
        let imageV = UIImageView(image: UIImage(named: "audienceCtt"))
        return imageV
    }()
    
    let memberCountLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        label.text = ""
        label.font = UIFont(name: "PingFangSC-Medium", size: 12)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    func setCell(model: ShowLiveRoomInfo) {
        let imageURL = URL.init(string: model.coverUrl)
        let imageName = "showLive_cover1"
        self.coverImageView.kf.setImage(with: imageURL, placeholder: UIImage.init(named: imageName))
        self.anchorNameLabel.text = model.ownerName
        self.roomNameLabel.text = model.roomName.count > 0 ? model.roomName : " "
        self.memberCountLabel.text = localizeReplaceOneCharacter(origin: .onlinexxText, xxx_replace: String(model.memberCount))
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        memberContainerView.layer.cornerRadius = memberContainerView.frame.height * 0.5
    }
    
    // MARK: - 视图生命周期函数
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
    }
    
    func constructViewHierarchy() {
        contentView.addSubview(coverImageView)
        contentView.addSubview(anchorNameLabel)
        contentView.addSubview(roomNameLabel)
        contentView.addSubview(memberContainerView)
        memberContainerView.addSubview(memberBgView)
        memberContainerView.addSubview(memberCountIcon)
        memberContainerView.addSubview(memberCountLabel)
    }
    
    func activateConstraints() {
        coverImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        roomNameLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.trailing.lessThanOrEqualToSuperview().offset(-10)
        }
        anchorNameLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(roomNameLabel)
            make.bottom.equalTo(roomNameLabel.snp.top)
            make.trailing.lessThanOrEqualToSuperview().offset(-10)
        }
        memberContainerView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(10)
        }
        memberBgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        memberCountIcon.snp.makeConstraints { (make) in
            make.centerX.equalTo(memberContainerView.snp.leading).offset(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 16, height: 16))
        }
        memberCountLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(3)
            make.bottom.equalToSuperview().offset(-3)
            make.trailing.equalToSuperview().offset(-8)
            make.leading.equalTo(memberCountIcon.snp.centerX).offset(8)
        }
    }
}

// MARK: - internationalization string
fileprivate extension String {
    static let onlinexxText = ShowLiveLocalize("Scene.ShowLive.List.xxissinging")
}
