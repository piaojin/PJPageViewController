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

public protocol PJCoverPageViewProtocol: class {
    func scrollView() -> UIScrollView?
}

open class PJCoverPageViewController: PJPageViewController {

    private var kScrollViewConText = 0
    
    private static let kScrollViewKeyPath = "contentOffset"
    
    open var coverPageViewScrollType: PJCoverPageViewScrollType = .linkageScroll
    
    private var subViewControllerScrollViews: [UIViewController : UIScrollView] = [:]
    
    private var contentOffsetY: [Int : CGFloat] = [:]
    
    private var currentContentOffsetY: CGFloat = 0.0
    
    open var coverViewHeigth: CGFloat = 60.0
    
    private var coverViewY: CGFloat {
        get {
            let statusBarFrame = UIApplication.shared.statusBarFrame
            let Y = statusBarFrame.size.height + (self.navigationController?.navigationBar.frame.size.height ?? 0.0)
            return Y
        }
    }
    
    open var coverView: UIView!
    
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

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.coverView.frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: self.coverView.frame.size.height)
        self.tabBarView.frame = CGRect(x: 0.0, y: self.coverView.frame.maxY, width: size.width, height: self.tabBarView.frame.size.height)
    }
    
    //To smooth, I do not use autolayout. So I need to manually adjust the vertical screen.
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
                //up

            } else {
                //down
                if -scrollView.contentOffset.y >= self.coverView.frame.size.height {
                    height = self.coverView.frame.size.height - newValue.y + oldValue.y
                } else {
                    self.contentOffsetY[index] = scrollView.contentOffset.y
                    self.currentContentOffsetY = newValue.y
                    return
                }
            }
            self.updateCoverViewTarBabFrame(height: height)
            
            if scrollView is UITableView, let tableView = scrollView as? UITableView, tableView.style == .plain {
                self.updateSectionTableViewContentInset(tableView: tableView, coverViewCurrentHeight: height)
            }
            
            self.contentOffsetY[index] = scrollView.contentOffset.y
            self.currentContentOffsetY = newValue.y
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: PJCoverPageViewController.kScrollViewKeyPath)
    }
}

public extension PJCoverPageViewController {
    private func initCoverView() {
        self.topContentViewHeight.constant = self.coverViewHeigth + self.tabBarViewHeigth
        self.coverView.translatesAutoresizingMaskIntoConstraints = true
        self.coverView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.coverViewHeigth)
        self.topContentView.addSubview(self.coverView)
        
        self.tabBarView.frame = CGRect(x: 0.0, y: self.coverView.frame.maxY, width: self.view.frame.size.width, height: self.tabBarViewHeigth)
        self.view.bringSubview(toFront: self.tabBarView)
    }
    
    private func initCoverData() {
        if self.coverPageViewScrollType == .forbiddenScroll {
            if let first = viewControllers.first {
                self.pageViewController.setViewControllers([first], direction: .forward, animated: true, completion: nil)
            }
        }
        self.addSubScrollViewObserver()
        self.currentContentOffsetY = -self.coverView.frame.size.height
    }
    
    private func addSubScrollViewObserver() {
        for index in 0..<self.viewControllers.count {
            let viewController = self.viewControllers[index]
            if viewController is PJCoverPageViewProtocol, let coverPageViewProtocol = viewController as? PJCoverPageViewProtocol, let scrollView = coverPageViewProtocol.scrollView() {
                if #available(iOS 11.0, *) {
                    scrollView.contentInsetAdjustmentBehavior = .never
                } else {
                    self.automaticallyAdjustsScrollViewInsets = false
                }
                scrollView.pj_scrollViewIndex = index
                self.updateScrollViewContentInset(scrollView: scrollView, contentInsetTop: self.coverViewHeigth)
                if self.coverPageViewScrollType == .linkageScroll {
                    scrollView.addObserver(self, forKeyPath: PJCoverPageViewController.kScrollViewKeyPath, options: [.new, .old], context: &self.kScrollViewConText)
                }
            }
        }
    }
    
    private func updateScrollViewContentInset(scrollView: UIScrollView, contentInsetTop: CGFloat) {
        scrollView.contentInset.top = contentInsetTop
        scrollView.contentOffset.y = -scrollView.contentInset.top
    }
    
    private func updateCoverViewTarBabFrame(height: CGFloat) {
        var height = height
        if height < 0.0 {
            height = 0.0
        }
        if self.coverView.frame.size.height != height {
            self.coverView.frame.size.height = height
            self.tabBarView.frame.origin.y = self.coverView.frame.maxY
        }
    }
    
    private func updateSectionTableViewContentInset(tableView: UITableView, coverViewCurrentHeight: CGFloat) {
        var sectionInsetTop: CGFloat = coverViewCurrentHeight
        if sectionInsetTop < 0.0 {
            sectionInsetTop = 0.0
        } else if sectionInsetTop > self.coverViewHeigth {
            sectionInsetTop = self.coverViewHeigth
        }
        
        if tableView.contentInset.top != sectionInsetTop {
            tableView.contentInset.top = sectionInsetTop
        }
    }
}

// MARK: PJTabBarViewDelegate
public extension PJCoverPageViewController {
    override public func pjTabBarWillChange(_ pjTabBarView: PJTabBarView, fromIndex: Int, toIndex: Int) {
        super.pjTabBarWillChange(pjTabBarView, fromIndex: fromIndex, toIndex: toIndex)
        let toViewController = self.viewControllers[toIndex]
        if toViewController is PJCoverPageViewProtocol, let coverPageViewProtocol = toViewController as? PJCoverPageViewProtocol, let scrollView = coverPageViewProtocol.scrollView() {
            if let index = scrollView.pj_scrollViewIndex, let contentOffsetY = self.contentOffsetY[index] {
                if scrollView is UITableView, let tableView = scrollView as? UITableView, tableView.style == .plain {
                    self.updateSectionTableViewContentInset(tableView: tableView, coverViewCurrentHeight: self.coverView.frame.height)
                }
                var contentOffsetY = contentOffsetY
                if contentOffsetY < 0 {
                    if -contentOffsetY > self.coverView.frame.size.height {
                        contentOffsetY = -self.coverView.frame.size.height
                    }
                }
                if scrollView.contentOffset.y > 0 {
                    contentOffsetY = contentOffsetY - self.coverView.frame.size.height
                }
                self.contentOffsetY[toIndex] = contentOffsetY
                scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: contentOffsetY), animated: false)
            } else {
                self.contentOffsetY[toIndex] = -(self.coverView.frame.size.height)
                scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x, y: -self.coverView.frame.size.height), animated: false)
            }
            self.currentContentOffsetY = scrollView.contentOffset.y
        }
    }
}

public extension UIScrollView {
    private struct AssociatedKeys {
        static var pj_scrollViewIndex = "pj_scrollViewIndex"
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
