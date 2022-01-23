//
//  ShowLiveAlertViewController.swift
//  XiaoZhiBoApp
//
//  Created by jack on 2021/12/13.
//

import UIKit

class ShowLiveAlertViewController: UIViewController {

    /// 标题
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .black
        label.font = UIFont(name: "PingFangSC-Medium", size: 24)
        return label
    }()
    
    /// 内容布局视图
    lazy var contentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        return view
    }()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.modalPresentationStyle = .custom
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .custom
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .clear
        navigationController?.navigationBar.isHidden = true
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc
    func constructViewHierarchy() {
        view.addSubview(contentView)
        contentView.addSubview(titleLabel)
    }
    
    @objc
    func activateConstraints() {
        contentView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(24)
            make.height.equalTo(36)
        }
    }
    
    @objc
    func bindInteraction() {
        // 添加点击空白处dismiss手势
        addTapDismissGesture()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let roundingCorners: UIRectCorner = [.topLeft, .topRight]
        let cornerRadii = CGSize(width: 20, height: 20)
        contentView.roundedRect(rect: contentView.bounds, byRoundingCorners: roundingCorners, cornerRadii: cornerRadii)
    }
    
}

// MARK: - Private - 手势
extension ShowLiveAlertViewController {
    
    /// 添加点击手势
    private func addTapDismissGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapDismiss))
        tap.delegate = self
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)
    }
    
    /// 视图dismiss
    @objc
    private func tapDismiss() {
        dismiss(animated: false, completion: nil)
    }
}


// MARK: - UIGestureRecognizerDelegate
extension ShowLiveAlertViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let point = gestureRecognizer.location(in: contentView)
        return point.y <= 0
    }
    
}
