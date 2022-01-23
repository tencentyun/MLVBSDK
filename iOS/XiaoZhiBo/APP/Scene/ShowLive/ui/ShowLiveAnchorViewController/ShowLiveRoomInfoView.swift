//
//  ShowLiveRoomInfoView.swift
//  XiaoZhiBoApp
//
//  Created by gg on 2021/10/8.
//

import UIKit

class ShowLiveRoomInfoView: UIView {
    
    public enum ShowLiveRoomType {
        case audience
        case anchor
    }
    
    lazy var bgView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        return view
    }()
    
    lazy var headImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var redPointView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .red
        return view
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 10)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    /// 关注按钮
    lazy var followButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .lightGray
        button.setTitle(.followText, for: .normal)
        button.setTitle(.followedText, for: .selected)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitleColor(.white, for: .normal)
        button.layer.masksToBounds = true
        button.adjustsImageWhenHighlighted = false
        return button
    }()
    
    var timer: Timer?
    
    var beganTime: Date?
    
    public func setRoomInfo(_ roomInfo: ShowLiveRoomInfo) {
        if let url = URL(string: roomInfo.coverUrl) {
            headImageView.kf.setImage(with: .network(url))
        }
        titleLabel.text = "房间号：" + roomInfo.roomID
        if type == .audience {
            timeLabel.text = roomInfo.roomName
        }
    }
    /// follow按钮点击回调
    var followBlock: (()->())?
    /// 刷新关注状态
    public func updateFollowState(isFollow: Bool) {
        followButton.isSelected = isFollow
        followButton.gradientLayer?.isHidden = isFollow
        let followWidth = (isFollow ? String.followedText : String.followText).widthWith(font: UIFont.systemFont(ofSize: 12)) + 9*2
        followButton.snp.updateConstraints { make in
            make.width.equalTo(followWidth)
        }
        followButton.layoutIfNeeded()
    }
    
    private let type: ShowLiveRoomType
    
    init(type: ShowLiveRoomType, frame: CGRect = .zero) {
        self.type = type
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func start() {
        if type == .audience {
            return
        }
        beganTime = Date()
        if let timer = timer {
            timer.invalidate()
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let `self` = self else { return }
            guard let beganTime = self.beganTime else { return }
            let currentTime = Date()
            let duration = Int(currentTime.timeIntervalSince(beganTime))
            UIView.animate(withDuration: 0.5) {
                self.redPointView.alpha = 0
            } completion: { finish in
                UIView.animate(withDuration: 0.5, delay: 0.0) {
                    self.redPointView.alpha = 1
                }
            }
            self.setTime(duration)
        }
    }
    
    public func stop() {
        if type == .audience {
            return
        }
        if let timer = timer {
            timer.invalidate()
        }
        timer = nil
        beganTime = nil
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        headImageView.layer.cornerRadius = headImageView.bounds.height * 0.5
        bgView.layer.cornerRadius = bgView.bounds.height * 0.5
        if type == .anchor {
            redPointView.layer.cornerRadius = redPointView.bounds.height * 0.5
        }
        // follow背景处理
        let gradientColors = [UIColor(hex: "#FF8BB7").cgColor, UIColor(hex: "#FF465D").cgColor]
        let followGradientLayer = followButton.gradient(colors: gradientColors)
        followGradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        followGradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        followButton.layer.cornerRadius = followButton.bounds.height * 0.5
    }
    
    private func setTime(_ second: Int) {
        timeLabel.text = convertTime2Str(second)
    }
    
    private func convertTime2Str(_ second: Int) -> String {
        var sec = 0
        var min = 0
        var hor = 0
        sec = second % 60
        min = second / 60 % 60
        hor = second / 3600
        return "\(convertInt2Str(hor)):\(convertInt2Str(min)):\(convertInt2Str(sec))"
    }
    
    private func convertInt2Str(_ num: Int) -> String {
        if num < 10 {
            return "0\(num)"
        }
        else {
            return "\(num)"
        }
    }
    
    private var isViewReady = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady {
            return
        }
        isViewReady = true
        
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
    }
    
    private func constructViewHierarchy() {
        addSubview(bgView)
        switch type {
        case .audience:
            bgView.addSubview(timeLabel)
            bgView.addSubview(followButton)
        case .anchor:
            bgView.addSubview(redPointView)
            bgView.addSubview(timeLabel)
        }
        bgView.addSubview(headImageView)
        bgView.addSubview(titleLabel)
    }
    private func activateConstraints() {
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        headImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(2)
            make.top.equalToSuperview().offset(2)
            make.bottom.equalToSuperview().offset(-2)
            make.width.equalTo(headImageView.snp.height)
        }
        switch type {
        case .audience:
            timeLabel.snp.makeConstraints { make in
                make.bottom.equalTo(bgView.snp.centerY)
                make.leading.equalTo(headImageView.snp.trailing).offset(6)
                make.trailing.lessThanOrEqualTo(followButton.snp.leading).offset(-6)
            }
            titleLabel.snp.makeConstraints { make in
                make.top.equalTo(bgView.snp.centerY)
                make.leading.equalTo(headImageView.snp.trailing).offset(6)
                make.width.lessThanOrEqualTo(100)
            }
            let followWidth = String.followText.widthWith(font: UIFont.systemFont(ofSize: 12)) + 9*2
            followButton.snp.makeConstraints { make in
                make.leading.equalTo(titleLabel.snp.trailing).offset(6)
                make.trailing.equalTo(-6)
                make.width.equalTo(followWidth)
                make.height.equalTo(28)
                make.centerY.equalToSuperview()
            }
        case .anchor:
            redPointView.snp.makeConstraints { make in
                make.leading.equalTo(headImageView.snp.trailing).offset(6)
                make.centerY.equalTo(timeLabel)
                make.size.equalTo(CGSize(width: 6, height: 6))
            }
            timeLabel.snp.makeConstraints { make in
                make.bottom.equalTo(bgView.snp.centerY)
                make.leading.equalTo(redPointView.snp.trailing).offset(4)
                make.trailing.lessThanOrEqualToSuperview().offset(-6)
            }
            titleLabel.snp.makeConstraints { make in
                make.top.equalTo(bgView.snp.centerY)
                make.leading.equalTo(headImageView.snp.trailing).offset(6)
                make.width.lessThanOrEqualTo(100)
                make.trailing.equalTo(-6)
            }
        }
    }
    private func bindInteraction() {
        if type == .anchor {
            setTime(0)
        }
        followButton.addTarget(self, action: #selector(followAction), for: .touchUpInside)
    }
}

// MARK: - UIButton Touch Event
extension ShowLiveRoomInfoView {
    
    /// 关注事件
    @objc
    private func followAction() {
        followBlock?()
    }
}

// MARK: - internationalization string
fileprivate extension String {
    static let followText = ShowLiveLocalize("Scene.ShowLive.Audience.follow")
    static let followedText = ShowLiveLocalize("Scene.ShowLive.Audience.followed")
}

// MARK: - 计算文字宽度
fileprivate extension String {
    func widthWith(font: UIFont) -> CGFloat {
        let str = self as NSString
        return str.size(withAttributes: [NSAttributedString.Key.font:font]).width
    }
}
