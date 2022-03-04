//
//  TUIBeautyViewController.swift
//  TUIBeautyApp
//
//  Created by gg on 2021/9/22.
//

import Foundation
import TUIBeauty
import SnapKit
import TUICore

class TUIBeautyViewController: UIViewController {
    
    var beautyView: TUIBeautyView?
    
    var beautyBtn: UIButton?
    
    lazy var pusher: V2TXLivePusher = {
        let pusher = V2TXLivePusher(liveMode: .RTC)
        return pusher!
    }()
    
    lazy var switchCameraBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("切换摄像头", for: .normal)
        btn.addTarget(self, action: #selector(switchCameraBtnClick), for: .touchUpInside)
        return btn
    }()
    
    var isFrontCamera = true
    
    @objc func beautyBtnClick() {
        // step 3. 在需要的地方调这句即可弹出美颜面板
        beautyView?.isHidden = false
    }
    
    @objc func switchCameraBtnClick() {
        isFrontCamera = !isFrontCamera
        pusher.getDeviceManager().switchCamera(isFrontCamera)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pusher.setRenderView(view)
        pusher.startCamera(isFrontCamera)
        
        view.addSubview(switchCameraBtn)
        switchCameraBtn.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        // 加载美颜组件
        
        // step 1. 获取美颜入口按钮
        beautyBtn = TUIBeautyExtensionView.getExtensionView() as? UIButton
        guard let beautyBtn = beautyBtn else {
            return
        }
        beautyBtn.addTarget(self, action: #selector(beautyBtnClick), for: .touchUpInside)
        view.addSubview(beautyBtn)
        beautyBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(switchCameraBtn.snp.bottom).offset(20)
        }
        
        // step 2. 创建并添加美颜面板视图
        guard let beautyManager = pusher.getBeautyManager() else {
            return
        }
        beautyView = TUIBeautyView(frame: .zero, beautyManager: beautyManager)
        guard let beautyView = beautyView else {
            return
        }
        view.addSubview(beautyView)
        beautyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}
