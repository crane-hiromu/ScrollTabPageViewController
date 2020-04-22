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

    var currentIndex: BehaviorRelay<Int> = .init(value: 0)
    
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
                    self?.currentIndex.accept(btn.tag)
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
        
        currentIndex
            .subscribe(onNext: { [weak self] in
                // todo underbar color
                
                /// reset
                self?.tabButtons.forEach { $0.backgroundColor = .white }
                
                /// set
                self?.tabButtons[$0].backgroundColor = .lightGray
            })
            .disposed(by: rx.disposeBag)
    }
}
