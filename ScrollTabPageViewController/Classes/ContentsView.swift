//
//  ContentsView.swift
//  ScrollTabPageViewController
//
//  Created by h.crane on 2020/04/22.
//  Copyright © 2020年 h.crane. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

// MARK: - View

final class ContentsView: UIView {

    var currentIndex: Int = 0
    var tabButtonPressedBlock: ((_ index: Int) -> Void)?
    var scrollDidChangedBlock: ((_ scroll: CGFloat, _ shouldScroll: Bool) -> Void)?

    private var scrollStart: CGFloat = 0.0

    @IBOutlet private weak var scrollView: UIScrollView! {
        didSet {
            scrollView.scrollsToTop = false
            scrollView.rx.contentOffset.subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                if 0.0 < $0.y || self.frame.minY < 0.0 {
                    self.scrollDidChangedBlock?($0.y, true)
                    self.scrollView.contentOffset.y = 0.0
                } else {
                    self.scrollDidChangedBlock?(($0.y - self.scrollStart), false)
                    self.scrollStart = $0.y
                }
            }).disposed(by: rx.disposeBag)
        }
    }
    @IBOutlet var tabButtons: [UIButton]! {
        didSet {
            tabButtons.forEach { btn in
                btn.rx.tap.subscribe(onNext: { [weak self] in
                    self?.tabButtonPressedBlock?(btn.tag)
                    self?.updateCurrentIndex(index: btn.tag, animated: true)
                }).disposed(by: rx.disposeBag)
            }
        }
    }

    // MARK: Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }
}


// MARK: - Private

private extension ContentsView {
    
    func initialize() {
        let onwer = self.instantiate()
        equalToParentConstraint(for: onwer)
        
        
    }
}

// MARK: - Internal

extension ContentsView {

    func updateCurrentIndex(index: Int, animated: Bool) {
        tabButtons[currentIndex].backgroundColor = UIColor.white
        tabButtons[index].backgroundColor = UIColor(red: 0.88, green: 1.0, blue: 0.87, alpha: 1.0)
        currentIndex = index
    }
}
