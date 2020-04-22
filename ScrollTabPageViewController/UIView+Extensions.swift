//
//  UIView+Extensions.swift
//  ScrollTabPageViewController
//
//  Created by h.crane on 2020/04/22.
//  Copyright © 2020 h.crane. All rights reserved.
//

import UIKit

// MARK: - Extensions

extension UIView {

    /// **Owner**から画面を生成
    /// - returns: UIViewで返す
    func instantiate() -> UIView {
        return UINib(nibName: className, bundle: Bundle(for: type(of: self)))
            .instantiate(withOwner: self, options: nil)
            .first as! UIView
    }

    /// **View**から画面を生成
    /// -　T: 画面のクラス
    /// - returns: 指定したTクラスにキャストして返す
    static func instantiate<T: UIView>() -> T {
        return UINib(nibName: className, bundle: nil)
            .instantiate(withOwner: self, options: nil)
            .first as! T
    }

    /// 親画面(呼び出し元画面)の制約に合わせる
    /// - parameter target: 呼び出し元のクラス
    func equalToParentConstraint(for target: UIView) {
        addSubview(target)
        target.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            target.topAnchor.constraint(equalTo: topAnchor),
            target.leftAnchor.constraint(equalTo: leftAnchor),
            target.bottomAnchor.constraint(equalTo: bottomAnchor),
            target.rightAnchor.constraint(equalTo: rightAnchor)
        ])
    }
}
