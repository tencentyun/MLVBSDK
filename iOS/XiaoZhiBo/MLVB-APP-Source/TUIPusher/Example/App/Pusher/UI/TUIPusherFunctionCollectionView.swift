//
//  TUIPusherFunctionCollectionView.swift
//  TUIPusherApp
//
//  Created by gg on 2021/9/17.
//

import UIKit
import SnapKit

typealias ActionBlock = (_ functionView: TUIPusherFunctionCollectionView, _ index: Int) -> ()

class TUIPusherFunctionCollectionView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public var dataSource: [String] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    public var didClickItem: ActionBlock?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TUIPusherFunctionCollectionViewCell.self, forCellWithReuseIdentifier: "TUIPusherFunctionCollectionViewCell")
        return collectionView
    }()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TUIPusherFunctionCollectionViewCell", for: indexPath)
        if let scell = cell as? TUIPusherFunctionCollectionViewCell {
            let title = dataSource[indexPath.item]
            scell.titleLabel.text = title
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let title = dataSource[indexPath.item]
        return CGSize(width: title.width(UIFont.systemFont(ofSize: 20)), height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let action = didClickItem {
            action(self, indexPath.item)
        }
    }
}

extension String {
    func width(_ font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font : font]
        let maxSize = CGSize(width: CGFloat(MAXFLOAT), height: font.lineHeight)
        let str = self as NSString
        let size = str.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size
        return ceil(size.width)
    }
}

class TUIPusherFunctionCollectionViewCell: UICollectionViewCell {
    public lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.center.leading.trailing.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
