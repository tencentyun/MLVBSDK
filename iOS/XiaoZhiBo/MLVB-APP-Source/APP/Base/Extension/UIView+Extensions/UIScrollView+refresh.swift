//
//  UIScrollView+refresh.swift
//  XiaoZhiBoApp
//
//  Created by jack on 2021/12/15.
//

import MJRefresh
import UIKit

// MARK: - 上下拉控件
extension UIScrollView {
    
    /// 设置下拉刷新
    /// - Parameters:
    ///   - target: 下拉事件响应对象
    ///   - action: 下拉事件响应的方法
    func setupNormalRefreshHeader(target: Any, action: Selector) {
        
        let header = MJRefreshNormalHeader(refreshingTarget: target, refreshingAction: action)
        header.setTitle(.pullRefreshText, for: .pulling)
        header.setTitle(.refreshingText, for: .refreshing)
        header.setTitle("", for: .idle)
        header.lastUpdatedTimeLabel?.isHidden = true
        
        self.mj_header = header;
    }
    
}

// MARK: - internationalization string
fileprivate extension String {
    static let pullRefreshText = ShowLiveLocalize("Scene.ShowLive.List.pullrefresh")
    static let refreshingText = ShowLiveLocalize("Scene.ShowLive.List.refreshing")
}
