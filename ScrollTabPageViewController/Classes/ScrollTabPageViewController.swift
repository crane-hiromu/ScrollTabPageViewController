//
//  ScrollTabPageViewController.swift
//  ScrollTabPageViewController
//
//  Created by h.crane on 2020/4/22.
//  Copyright © 2020年 h.crane. All rights reserved.
//

import UIKit

protocol ScrollTabPageViewControllerProtocol {
    var scrollTabPageViewController: ScrollTabPageViewController { get }
    var scrollView: UIScrollView { get }
}

class ScrollTabPageViewController: UIPageViewController {
    
    private let models = ["","",""]

    private let contentViewHeihgt: CGFloat = 344 // contents + tab = 300 + 44
    
    private var pageViewControllers: [UIViewController] = []
    private lazy var contentsView: ContentsView = {
        let cView = ContentsView(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: contentViewHeihgt))
        cView.configure(models: models)
        cView.tabButtonPressedBlock = { [weak self] (index: Int) in
            guard let self = self else { return }

            self.shouldUpdateLayout = true
            self.updateIndex = index
            let direction: UIPageViewController.NavigationDirection = ((self.currentIndex ?? 0) < index) ? .forward : .reverse
            self.setViewControllers([self.pageViewControllers[index]],
                direction: direction,
                animated: true,
                completion: { completed in
                    if self.shouldUpdateLayout {
                        self.setupContentOffsetY(index: index, scroll: -self.scrollContentOffsetY)
                        self.shouldUpdateLayout = false
                    }
                })
        }

        cView.scrollDidChangedBlock = { [weak self] (scroll: CGFloat, shouldScrollFrame: Bool) in
            self?.shouldScrollFrame = shouldScrollFrame
            self?.updateContentOffsetY(scroll: scroll)
        }
        return cView
    }()
    private var scrollContentOffsetY: CGFloat = 0.0
    private var shouldScrollFrame: Bool = true
    private var shouldUpdateLayout: Bool = false
    private var updateIndex: Int = 0
    private var currentIndex: Int? {
        guard let viewController = viewControllers?.first, let index = pageViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        return index
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        initialize()
    }
}


// MARK: - View

extension ScrollTabPageViewController {
    
    func initialize() {
        models.forEach { _ in
            let sb = UIStoryboard(name: "ViewController", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "ViewController")
            pageViewControllers.append(vc)
        }
        
        view.addSubview(contentsView)
        setupPageViewController()
    }


    private func setupPageViewController() {
        dataSource = self
        delegate = self

        setViewControllers([pageViewControllers[0]],
            direction: .forward,
            animated: false,
            completion: { [weak self] (completed: Bool) in
                self?.setupContentInset()
            })
    }
}


// MARK: - updateScroll

extension ScrollTabPageViewController {

    private func setupContentInset() {
        guard let currentIndex = currentIndex, let vc = pageViewControllers[currentIndex] as? ScrollTabPageViewControllerProtocol else {
            return
        }

        let inset = UIEdgeInsets(top: contentViewHeihgt, left: 0.0, bottom: 0.0, right: 0.0)
        vc.scrollView.contentInset = inset
        vc.scrollView.scrollIndicatorInsets = inset
    }

    private func setupContentOffsetY(index: Int, scroll: CGFloat) {
        guard let  vc = pageViewControllers[index] as? ScrollTabPageViewControllerProtocol else {
            return
        }

        if scroll == 0.0 {
            vc.scrollView.contentOffset.y = -contentViewHeihgt
        } else if (scroll < contentViewHeihgt - contentsView.buttonWrapperView.frame.height) || (vc.scrollView.contentOffset.y <= -contentsView.buttonWrapperView.frame.height) {
            vc.scrollView.contentOffset.y = scroll - contentViewHeihgt
        }
    }

    private func updateContentView(scroll: CGFloat) {
        if shouldScrollFrame {
            contentsView.frame.origin.y = scroll
            scrollContentOffsetY = scroll
        }
        shouldScrollFrame = true
    }

    private func updateContentOffsetY(scroll: CGFloat) {
        if let currentIndex = currentIndex, let vc = pageViewControllers[currentIndex] as? ScrollTabPageViewControllerProtocol {
            vc.scrollView.contentOffset.y += scroll
        }
    }

    func updateContentViewFrame() {
        guard let currentIndex = currentIndex, let vc = pageViewControllers[currentIndex] as? ScrollTabPageViewControllerProtocol else {
            return
        }

        if vc.scrollView.contentOffset.y >= -contentsView.buttonWrapperView.frame.height {
            let scroll = contentViewHeihgt - contentsView.buttonWrapperView.frame.height
            updateContentView(scroll: -scroll)
            vc.scrollView.scrollIndicatorInsets.top = contentsView.buttonWrapperView.frame.height
        } else {
            let scroll = contentViewHeihgt + vc.scrollView.contentOffset.y
            updateContentView(scroll: -scroll)
            vc.scrollView.scrollIndicatorInsets.top = -vc.scrollView.contentOffset.y
        }
    }

    func updateLayoutIfNeeded() {
        if shouldUpdateLayout {
            let vc = pageViewControllers[updateIndex] as? ScrollTabPageViewControllerProtocol
            let shouldSetupContentOffsetY = vc?.scrollView.contentInset.top != contentViewHeihgt
            
            let scroll = scrollContentOffsetY
            setupContentInset()
            setupContentOffsetY(index: updateIndex, scroll: -scroll)
            shouldUpdateLayout = shouldSetupContentOffsetY
        }
    }
}


// MARK: - UIPageViewControllerDateSource

extension ScrollTabPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        
        guard var index = pageViewControllers.firstIndex(of: viewController) else { return nil }
        index += 1

        guard 0 <= index && index < pageViewControllers.count else { return nil }
        return pageViewControllers[index]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        
        guard var index = pageViewControllers.firstIndex(of: viewController) else { return nil }
        index -= 1
        
        guard 0 <= index && index < pageViewControllers.count else { return nil }
        return pageViewControllers[index]
    }
}


// MARK: - UIPageViewControllerDelegate

extension ScrollTabPageViewController: UIPageViewControllerDelegate {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        willTransitionTo pendingViewControllers: [UIViewController]
    ) {
        if let vc = pendingViewControllers.first, let index = pageViewControllers.firstIndex(of: vc) {
            shouldUpdateLayout = true
            updateIndex = index
        }

    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard let _ = previousViewControllers.first, let currentIndex = currentIndex else {
            return
        }

        if shouldUpdateLayout {
            setupContentInset()
            setupContentOffsetY(index: currentIndex, scroll: -scrollContentOffsetY)
        }

        if 0 <= currentIndex && currentIndex < contentsView.buttonWrapperView.subviews.count {
            contentsView.currentIndex.accept(currentIndex)
        }
    }
}
