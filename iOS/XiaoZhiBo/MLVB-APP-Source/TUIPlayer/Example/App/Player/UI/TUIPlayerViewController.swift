//
//  TUIPlayerViewController.swift
//  TUIPlayerApp
//
//  Created by gg on 2021/9/14.
//

import Foundation
import TUIPlayer
import SnapKit
import TUICore

class TUIPlayerViewController: UIViewController {
    lazy var pusherView: TUIPlayerView = {
        let view = TUIPlayerView()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(pusherView)
        pusherView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        /// user id 为测试代码
        pusherView.startPlay(URLUtils.generatePlayUrl("688", type: .WEBRTC))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}


