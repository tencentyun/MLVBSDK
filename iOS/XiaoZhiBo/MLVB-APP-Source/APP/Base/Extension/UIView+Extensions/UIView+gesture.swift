//
//  UIView+gesture.swift
//  XiaoZhiBoApp
//
//  Created by jack on 2021/12/15.
//  UIView 手势处理

import UIKit

// MARK: - 手势处理
extension UIView {
    
    /// 增加单击手势
    /// - Parameters:
    ///   - target: 手势响应对象
    ///   - action: 手势响应方法
    ///   - delegate: 手势代理
    public func addTapGesture(target: Any?, action: Selector?, delegate: UIGestureRecognizerDelegate? = nil) {
        let tap = UITapGestureRecognizer(target: target, action: action)
        tap.delegate = delegate
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tap)
    }
    
}
