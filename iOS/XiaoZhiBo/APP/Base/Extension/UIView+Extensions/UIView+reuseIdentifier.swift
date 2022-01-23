//  
//  UIView+reuseIdentifier.swift
//  XiaoZhiBoApp
//
//  Created by jack on 2021/12/13.
//

import UIKit

// MARK: - UICollectionViewCell 重用标识符
extension UITableViewCell {
    
    /// 获取Cell的重用标识符
    public class var reuseIdentifier: String {
        return "reuseId_\(self.description())"
    }
    
}

// MARK: - UICollectionViewCell 重用标识符
extension UICollectionViewCell {
    
    /// 获取Cell的重用标识符
    public class var reuseIdentifier: String {
        return "reuseId_\(self.description())"
    }
    
}
