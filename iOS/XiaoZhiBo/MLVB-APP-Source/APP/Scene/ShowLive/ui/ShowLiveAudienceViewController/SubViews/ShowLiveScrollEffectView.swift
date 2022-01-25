//
//  ShowLiveScrollEffectView.swift
//  XiaoZhiBoApp
//
//  Created by jack on 2021/12/30.
//  滑动播放遮罩视图

import UIKit
import Kingfisher

// MARK: - ShowLiveScrollEffectView 滑动播放遮罩视图
class ShowLiveScrollEffectView: UIView {

    lazy var imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    lazy var contentLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private var effectView: UIVisualEffectView = {
        let effect = UIBlurEffect(style: .dark)
        let view = UIVisualEffectView(effect: effect)
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
    
    private func constructViewHierarchy() {
        addSubview(imageView)
        imageView.addSubview(effectView)
        addSubview(contentLabel)
    }
    
    private func activateConstraints() {
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        effectView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
}

// MARK: - Public
extension ShowLiveScrollEffectView {
    
    /// 设置模糊效果底部图片
    /// - note: 拉流预加载模糊背景视图
    func setImage(urlString: String) {
        if let url = URL(string: urlString) {
            imageView.kf.setImage(with: .network(url))
        }
    }
    
    /// 设置提示文字
    /// - note: 房主已退房等提示
    func setTipText(text: String) {
        contentLabel.text = text
    }
}
