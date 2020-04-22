//
//  ClassNameProtocol.swift
//  ScrollTabPageViewController
//
//  Created by h.crane on 2020/04/22.
//  Copyright © 2020 h.crane. All rights reserved.
//

import Foundation

// MARK: - Protocol

protocol ClassNameProtocol {

    static var className: String { get }
    var className: String { get }
}

extension ClassNameProtocol {

    static var className: String {
        return String(describing: self)
    }

    var className: String {
        return type(of: self).className
    }
}

extension NSObject: ClassNameProtocol {}
