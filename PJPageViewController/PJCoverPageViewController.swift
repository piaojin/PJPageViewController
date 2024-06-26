//
//  PJCoverPageViewController.swift
//  PJPageViewController
//
//  Created by Zoey Weng on 2018/1/31.
//  Copyright © 2018年 ywyw.piaojin. All rights reserved.
//

import UIKit

public enum PJCoverPageViewScrollType {
    case forbiddenScroll
    case linkageScroll
}

public protocol PJCoverPageViewProtocol {
    func scrollView() -> UIScrollView?
}

open class PJCoverPageViewController: PJPageViewController {

    private var kScrollViewConText = 0
    
    private static let kScrollViewKeyPath = "contentOffset"
    
    open var coverPageViewScrollType: PJCoverPageViewScrollType = .forbiddenScroll {
        didSet {
            if coverPageViewScrollType == .linkageScroll {
                if !hasAddScrollViewObserver {
                    addSubScrollViewObserver()
                }
            } else {
                removeSubScrollViewObserver()
            }
        }
    }
    
    private var subViewControllerScrollViews: [UIViewController : UIScrollView] = [:]
    
    private var hasAddScrollViewObserver = false;
    
    open var coverViewHeigth: CGFloat = 60.0 {
        didSet {
            topContentViewHeight?.constant = coverViewHeigth + tabBarViewHeigth
        }
    }
    
    private var coverViewY: CGFloat {
        get {
            let statusBarFrame = UIApplication.shared.statusBarFrame
            let Y = statusBarFrame.size.height + (self.navigationController?.navigationBar.frame.size.height ?? 0.0)
            return Y
        }
    }
    
    open var coverView: UIView = UIView()
    
    convenience public init(viewControllers: [UIViewController], coverView: UIView, coverPageViewScrollType: PJCoverPageViewScrollType = .linkageScroll) {
        self.init(viewControllers: viewControllers, coverView: coverView, coverPageViewScrollType: coverPageViewScrollType, tabBarViewConfiguration: PJPageOptions())
    }
    
    convenience public init(titles: [String], coverView: UIView, coverPageViewScrollType: PJCoverPageViewScrollType = .linkageScroll) {
        self.init(titles: titles, coverView: coverView, coverPageViewScrollType: coverPageViewScrollType, tabBarViewConfiguration: PJPageOptions())
    }
    
    convenience public init(viewControllers: [UIViewController], coverView: UIView, coverPageViewScrollType: PJCoverPageViewScrollType = .linkageScroll, tabBarViewConfiguration: PJPageOptions) {
        self.init()
        self.coverView = coverView
        self.coverPageViewScrollType = coverPageViewScrollType
        self.viewControllers = viewControllers
        self.tabBarOptions = tabBarViewConfiguration
    }
    
    convenience public init(titles: [String], coverView: UIView, coverPageViewScrollType: PJCoverPageViewScrollType = .linkageScroll, tabBarViewConfiguration: PJPageOptions) {
        self.init()
        self.coverView = coverView
        self.coverPageViewScrollType = coverPageViewScrollType
        self.titles = titles
        self.tabBarOptions = tabBarViewConfiguration
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.initCoverView()
        self.initCoverData()
    }
    
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.coverView.frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: self.coverView.frame.size.height)
        self.tabBarView.frame = CGRect(x: 0.0, y: self.coverView.frame.maxY, width: size.width, height: self.tabBarView.frame.size.height)
    }
    
    /// Used for PJTopContentView stretch effect in the vertical direction.
    // To smooth, I do not use autolayout. So I need to manually adjust the vertical screen.
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == PJCoverPageViewController.kScrollViewKeyPath, context == &self.kScrollViewConText, let scrollView = object as? UIScrollView, let newValue = change?[NSKeyValueChangeKey.newKey] as? CGPoint, let oldValue = change?[NSKeyValueChangeKey.oldKey] as? CGPoint {
            guard let index = scrollView.pj_scrollViewIndex else {
                return
            }
            
            if newValue == oldValue || self.currentIndex != index {
                return
            }
            
            var height = self.coverView.frame.size.height - newValue.y + oldValue.y
            if newValue.y > oldValue.y {
                // Direction Up
                height = max(coverViewHeigth, height)
                if coverView.frame.height > height {
                    self.updateCoverViewTarBabFrame(height: height)
                }
            } else {
                // Direction Down
                if -scrollView.contentOffset.y >= self.coverView.frame.size.height {
                    height = self.coverView.frame.size.height - newValue.y + oldValue.y
                } else {
                    return
                }
                self.updateCoverViewTarBabFrame(height: height)
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    open func initCoverView() {
        self.topContentViewHeight?.constant = self.coverViewHeigth + self.tabBarViewHeigth
        self.coverView.translatesAutoresizingMaskIntoConstraints = true
        self.coverView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.coverViewHeigth)
        self.topContentView.addSubview(self.coverView)
        self.tabBarView.frame = CGRect(x: 0.0, y: self.coverView.frame.maxY, width: self.view.frame.size.width, height: self.tabBarViewHeigth)
        self.view.bringSubviewToFront(self.tabBarView)
    }
    
    open func initCoverData() {
        if self.coverPageViewScrollType == .forbiddenScroll {
            if let first = viewControllers.first {
                self.pageViewController.setViewControllers([first], direction: .forward, animated: true, completion: nil)
            }
        } else {
            addSubScrollViewObserver()
        }
    }
    
    deinit {
        removeSubScrollViewObserver()
    }
}

public extension PJCoverPageViewController {
    private func addSubScrollViewObserver() {
        if hasAddScrollViewObserver {
            return
        }
        
        for index in 0..<self.viewControllers.count {
            let viewController = self.viewControllers[index]
            if viewController is PJCoverPageViewProtocol, let coverPageViewProtocol = viewController as? PJCoverPageViewProtocol, let scrollView = coverPageViewProtocol.scrollView() {
                if #available(iOS 11.0, *) {
                    scrollView.contentInsetAdjustmentBehavior = .never
                } else {
                    self.automaticallyAdjustsScrollViewInsets = false
                }
                scrollView.pj_scrollViewIndex = index
                if self.coverPageViewScrollType == .linkageScroll {
                    scrollView.addObserver(self, forKeyPath: PJCoverPageViewController.kScrollViewKeyPath, options: [.new, .old], context: &self.kScrollViewConText)
                    hasAddScrollViewObserver = true
                }
            }
        }
    }
    
    private func removeSubScrollViewObserver() {
        if hasAddScrollViewObserver {
            for index in 0..<self.viewControllers.count {
                let viewController = self.viewControllers[index]
                if viewController is PJCoverPageViewProtocol, let coverPageViewProtocol = viewController as? PJCoverPageViewProtocol, let scrollView = coverPageViewProtocol.scrollView() {
                    scrollView.removeObserver(self, forKeyPath: PJCoverPageViewController.kScrollViewKeyPath)
                }
            }
        }
    }
    
    private func updateCoverViewTarBabFrame(height: CGFloat) {
        let height = max(height, 0)
        if self.coverView.frame.size.height != height {
            self.coverView.frame.size.height = height
            self.tabBarView.frame.origin.y = self.coverView.frame.maxY
        }
    }
}

// MARK: PJTabBarViewDelegate
public extension PJCoverPageViewController {
    override func pjTabBarWillChange(_ pjTabBarView: PJTabBarView, fromIndex: Int, toIndex: Int) {
        super.pjTabBarWillChange(pjTabBarView, fromIndex: fromIndex, toIndex: toIndex)
    }
}

private extension UIScrollView {
    private struct AssociatedKeys {
        static var pj_scrollViewIndex: UInt8 = 0
    }
    
    var pj_scrollViewIndex: Int? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.pj_scrollViewIndex) as? Int
        }
        set (new) {
            objc_setAssociatedObject(self, &AssociatedKeys.pj_scrollViewIndex, new, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
