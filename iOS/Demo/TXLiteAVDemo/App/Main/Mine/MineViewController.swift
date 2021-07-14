//
//  MineViewController.swift
//  TXLiteAVDemo
//
//  Created by gg on 2021/4/6.
//  Copyright © 2021 Tencent. All rights reserved.
//

import Foundation

@objc class MineViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        super.loadView()
        let viewModel = MineViewModel()
        let rootView = MineRootView(viewModel: viewModel)
        rootView.rootVC = self
        view = rootView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.navigationBar.isTranslucent = true;
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor : UIColor.white,
             NSAttributedString.Key.font : UIFont(name: "PingFangSC-Semibold", size: 18) ?? UIFont.systemFont(ofSize: 18)
            ]
        
        let colors = [UIColor(red: 19.0 / 255.0, green: 41.0 / 255.0,
                              blue: 75.0 / 255.0, alpha: 1).cgColor,
                      UIColor(red: 5.0 / 255.0, green: 12.0 / 255.0,
                              blue: 23.0 / 255.0, alpha: 1).cgColor]
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.compactMap { $0 }
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
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
}
