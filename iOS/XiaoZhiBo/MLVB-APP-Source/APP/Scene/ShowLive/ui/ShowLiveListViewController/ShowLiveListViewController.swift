//
//  ShowLiveListViewController.swift
//  XiaoZhiBoApp
//
//  Created by adams on 2021/9/27.
//

import UIKit

class ShowLiveListViewController: UIViewController {
    let viewModel: ShowLiveListViewModel
    
    init(viewModel: ShowLiveListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.viewNavigator = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        TRTCLog.out("deinit \(type(of: self))")
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            if #available(iOS 13.0, *) {
                return .darkContent
            } else {
                return .default
            }
        }
    }
    
    public override var prefersStatusBarHidden: Bool {
        get {
            return false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        title = .controllerTitle
        
        let backBtn = UIButton(type: .custom)
        backBtn.setImage(UIImage(named: "navigationbar_back"), for: .normal)
        backBtn.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        backBtn.sizeToFit()
        let backItem = UIBarButtonItem(customView: backBtn)
        backItem.tintColor = .black
        self.navigationItem.leftBarButtonItem = backItem
        
        let helpBtn = UIButton(type: .custom)
        helpBtn.setImage(UIImage(named: "help_small"), for: .normal)
        helpBtn.addTarget(self, action: #selector(connectWeb), for: .touchUpInside)
        helpBtn.sizeToFit()
        let rightItem = UIBarButtonItem(customView: helpBtn)
        rightItem.tintColor = .black
        self.navigationItem.rightBarButtonItem = rightItem
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.getRoomList() // 调整房间列表的刷新时机
        guard let rootView = self.view as? ShowLiveListRootView else {
            return
        }
        rootView.updateBaseCollectionOffsetY()
    }
    
    public override func loadView() {
        let rootView = ShowLiveListRootView.init(viewModel: viewModel)
        viewModel.viewResponder = rootView
        view = rootView
    }
    
    /// 取消
    @objc func cancel() {
        navigationController?.popViewController(animated: true)
    }
    
    /// 连接官方文档
    @objc public func connectWeb() {
        if let url = URL(string: "https://cloud.tencent.com/document/product/647/35429") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
}

// MARK: - ShowLiveListViewNavigator
extension ShowLiveListViewController: ShowLiveListViewNavigator {
    func pushRoomView(viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func pushCreateRoom(viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: false)
    }
    
    func showFloatFloatingWindow() {
        
    }
}

// MARK: - internationalization string
private extension String {
    static let controllerTitle = ShowLiveLocalize("Scene.ShowLive.List.title")
}
