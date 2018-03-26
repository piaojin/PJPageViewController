//
//  PJPageViewController.swift
//  PJPageViewController
//
//  Created by piaojin on 2018/1/27.
//  Copyright © 2018年 ywyw.piaojin. All rights reserved.
//

import UIKit

public enum ScrollViewType: Int {
    case pageScrollView
    case coverScrollView
}

public enum ScrollBarScrollType {
    case `default`
    case linkage
}

public enum PJSwipeDirection {
    case left
    case right
}

public typealias PageCompletion = ((Bool, Int) -> Swift.Void)

public typealias SetPageOptionsClosure = ((_ tabBarViewConfiguration: PJPageOptions) -> Swift.Void)

open class PJPageViewController: UIViewController {
    
    open var pageWidth: CGFloat {
        return self.pageScrollView.bounds.width
    }
    
    open var scrollBarScrollType: ScrollBarScrollType = .linkage
    
    open var swipeDirection: PJSwipeDirection {
        if self.pageScrollView.contentOffset.x > self.lastContentOffsetX {
            return .left
        }
        return .right
    }
    
    private var lastContentOffsetX: CGFloat = 0.0
    
    private var didFinishAnimating = false
    
    private var isClickTabBarView = false
    
    public var viewControllerCount: Int {
        return self.viewControllers.count
    }
    
    public var tabBarViewHeigth: CGFloat = 30.0
    
    public var pageAnimated = true
    
    public var pageCompletion: PageCompletion?
    
    public var setPageOptionsClosure: SetPageOptionsClosure?
    
    //pageView tabBarView settings
    public var tabBarOptions: PJPageOptions = PJPageOptions() {
        didSet {
            self.pjTabBarView.tabBarOptions = tabBarOptions
        }
    }
    
    public lazy var pageViewController: UIPageViewController = {
        let viewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.delegate = self
        viewController.dataSource = self
        return viewController
    }()
    
    public lazy var pjTabBarView: PJTabBarView = {
        let bar = PJTabBarView(tabBarOptions: self.tabBarOptions)
        bar.translatesAutoresizingMaskIntoConstraints = true
        bar.isUserInteractionEnabled = true
        bar.delegate = self
//        bar.finishedLayoutClosure = { [weak self] (tabBarView) in
//            if let `self` = self {
//                tabBarView.currentIndex = self.currentIndex
////                tabBarView.reloadData()
////                self.pjTabBarView.delegate = self
//                tabBarView.scrollToItem(at: self.currentIndex)
//            }
//        }
        return bar
    }()
    
    // use topContentView to adapter screen rotation.
    var topContentView: PJTopContentView = {
        let topContentView = PJTopContentView()
        topContentView.translatesAutoresizingMaskIntoConstraints = false
        topContentView.backgroundColor = .clear
        topContentView.isUserInteractionEnabled = true
        return topContentView
    }()
    
    var topContentViewHeight: NSLayoutConstraint!
    
    public weak var pageScrollView: UIScrollView!
    
    public var viewControllers: [UIViewController] = [] {
        didSet {
            if let first = viewControllers.first {
                self.pageViewController.setViewControllers([first], direction: .forward, animated: self.pageAnimated, completion: {
                    [weak self] (finished) in
                    self?.pageCompletion?(finished, 0)
                })
            }
        }
    }
    
    public var titles: [String] = []
    
    public var currentIndex: Int = 0 {
        didSet {
            assert(currentIndex <= self.viewControllers.count - 1 && currentIndex >= 0 , "PJPageViewController: currentIndex out of bounds")
//            if self.pjTabBarView.currentIndex != currentIndex {
//                self.pjTabBarView.currentIndex = currentIndex
//            }
        }
    }
    
    public var currentViewController: UIViewController! {
        return self.viewControllers[self.currentIndex]
    }
    
    public var isPageScrollEnabled: Bool = true
    
    //lock vertical or horizontal scrolling while dragging
    public var pageBounces: Bool = true
    
    convenience public init(viewControllers: [UIViewController]) {
        self.init(viewControllers: viewControllers, tabBarOptions: PJPageOptions())
    }
    
    convenience public init(titles: [String]) {
        self.init(titles: titles, tabBarOptions: PJPageOptions())
    }
    
    convenience public init(viewControllers: [UIViewController], tabBarOptions: PJPageOptions) {
        self.init()
        self.viewControllers = viewControllers
        self.tabBarOptions = tabBarOptions
    }
    
    convenience public init(titles: [String], tabBarOptions: PJPageOptions) {
        self.init()
        self.titles = titles
        self.tabBarOptions = tabBarOptions
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.setPageOptionsClosure?(self.tabBarOptions)
        self.initView()
        self.syncScrollView()
        self.initData()
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.pjTabBarView.frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: self.pjTabBarView.frame.size.height)
    }
}

public extension PJPageViewController {
    
    private func initView() {
        self.view.backgroundColor = .white
        self.pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChildViewController(self.pageViewController)
        self.pageViewController.didMove(toParentViewController: self)
        self.view.addSubview(self.pageViewController.view)
        
        self.pageViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.pageViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        if #available(iOS 11.0, *) {
            self.pageViewController.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: self.tabBarViewHeigth).isActive = true
            self.pageViewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        } else {
            self.pageViewController.view.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: self.tabBarViewHeigth).isActive = true
            self.pageViewController.view.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.bottomAnchor).isActive = true
        }
        
        self.view.addSubview(self.topContentView)
        self.topContentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.topContentView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.topContentViewHeight = self.topContentView.heightAnchor.constraint(equalToConstant: self.tabBarViewHeigth)
        self.topContentViewHeight.isActive = true
        if #available(iOS 11.0, *) {
            self.topContentView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            self.topContentView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
        }
        
        //Use frame layout for smooth frames.
        self.pjTabBarView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.tabBarViewHeigth)
        self.topContentView.addSubview(self.pjTabBarView)
    }
    
    private func initData() {
        let firstShowViewController = viewControllers[self.currentIndex]
        self.pageViewController.setViewControllers([firstShowViewController], direction: .forward, animated: self.pageAnimated, completion: {
            [weak self] (finished) in
            if let `self` = self {
                self.pageCompletion?(finished, 0)
            }
        })

        self.pjTabBarView.currentIndex = self.currentIndex
    }
    
    public func syncScrollView() {
        for view in self.pageViewController.view.subviews {
            if view is UIScrollView, let tempView = view as? UIScrollView {
                self.pageScrollView = tempView
                self.pageScrollView.delegate = self
                self.pageScrollView.bounces = self.pageBounces
                self.pageScrollView.isScrollEnabled = self.isPageScrollEnabled
                self.pageScrollView.tag = ScrollViewType.pageScrollView.rawValue
                self.pageScrollView.isPagingEnabled = true
            }
        }
    }
}

extension PJPageViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("isClickTabBarView: \(isClickTabBarView)")
        
        if self.scrollBarScrollType != .linkage {
            return
        }
        
        if self.isClickTabBarView {
            return
        }
        
        if self.pjTabBarView.frame == .zero {
            return
        }
        
        let direction: PJSwipeDirection = scrollView.contentOffset.x >= self.lastContentOffsetX ? .left : .right
        
        let (fromIndex, toIndex, scrollPercentage) = self.caculateIndexProgress(offsetX: scrollView.contentOffset.x, direction: direction)
        
        print("fromIndex: \(fromIndex), toIndex: \(toIndex), progressPercentage: \(scrollPercentage), offsetX: \(scrollView.contentOffset.x), swipeDirection: \(swipeDirection), currentIndex: \(currentIndex)")
        
        if fromIndex == -1, toIndex == fromIndex {
//            self.lastContentOffsetX = scrollView.contentOffset.x
            return
        }
        
        if (self.currentIndex == self.viewControllers.count - 1 && scrollView.contentOffset.x >= scrollView.frame.size.width) || (self.currentIndex == 0 && scrollView.contentOffset.x < scrollView.frame.size.width) {
//            self.lastContentOffsetX = scrollView.contentOffset.x
            return
        }
        
        if toIndex < self.viewControllerCount, toIndex >= 0, fromIndex < self.viewControllerCount, fromIndex >= 0 {
            if !self.didFinishAnimating {
                self.pjTabBarView.moveScrollBar(fromIndex: fromIndex, toIndex: toIndex, progressPercentage: scrollPercentage)
            } else {
                self.didFinishAnimating = false
            }
        }
//        self.lastContentOffsetX = scrollView.contentOffset.x
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffsetX = scrollView.contentOffset.x
    }
    
    func caculateIndexProgress(offsetX: CGFloat, direction: PJSwipeDirection) -> (Int, Int, CGFloat) {
        if self.pageScrollView.frame == .zero {
            return (-1, -1, 0.0)
        }
        
        if self.viewControllerCount <= 0 {
            self.currentIndex = -1
            return (-1, -1, 0.0)
        }
        
        let floadIndex = offsetX / self.pageWidth
        let floorIndex = floor(floadIndex)
        if floorIndex < 0 || floorIndex >= CGFloat(self.viewControllerCount) || floadIndex > CGFloat(self.viewControllerCount - 1) {
            return (-1, -1, 0.0)
        }
        var progress = offsetX / self.pageWidth - floorIndex
        var fromIndex: CGFloat = 0, toIndex: CGFloat = 0
        if direction == .left {
            progress = floadIndex - 1
            if floadIndex < 0 {
                progress = 1 - floadIndex
            }
            fromIndex = CGFloat(self.currentIndex)
            toIndex = CGFloat(min(self.viewControllerCount - 1, Int(fromIndex + 1)))
            if fromIndex == toIndex, toIndex == CGFloat(self.viewControllerCount - 1 ) {
                fromIndex = CGFloat(self.viewControllerCount - 2)
                progress = 1.0
            }
        } else {
            toIndex = floorIndex - 1 + CGFloat(self.currentIndex)
            fromIndex = CGFloat(min(self.viewControllerCount - 1, Int(toIndex + 1)))
            progress = 1.0 - progress
        }
        return (Int(fromIndex), Int(toIndex), progress)
    }
}

extension PJPageViewController: UIPageViewControllerDataSource {
    
    public func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.viewControllers.count
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let index =  self.viewControllers.index(of: viewController), index > 0, index != NSNotFound else {
            return nil
        }
        
        var beforeIndex = index
        beforeIndex = beforeIndex - 1
        return self.viewControllers[beforeIndex]
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index =  self.viewControllers.index(of: viewController), index < self.viewControllers.count - 1, index != NSNotFound else {
            return nil
        }
        
        var afterIndex = index
        afterIndex = afterIndex + 1
        return self.viewControllers[afterIndex]
    }
}

extension PJPageViewController: UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            let index = Int(self.pageScrollView.contentOffset.x / self.pageScrollView.frame.size.width) - 1
            if index != 0 {
                self.currentIndex = self.currentIndex + index
                if self.pjTabBarView.currentIndex != self.currentIndex {
                    self.pjTabBarView.currentIndex = self.currentIndex
                }
                if !self.tabBarOptions.isNeedScrollBar {
                    self.pjTabBarView.scrollToItem(at: self.currentIndex)
                } else if self.scrollBarScrollType != .linkage {
                    self.pjTabBarView.scrollToItem(at: self.currentIndex)
                }
            }
        }
        self.didFinishAnimating = finished
        self.lastContentOffsetX = self.pageScrollView.contentOffset.x
    }
}

extension PJPageViewController: PJTabBarViewDelegate {
    public func pjTabBarNumberOfItems() -> Int {
        return self.titles.count > 0 ? self.titles.count : self.viewControllers.count
    }
    
    public func pjTabBar(_ pjTabBarView: PJTabBarView, pjTabBarItemAt index: Int) -> String {
        if self.titles.count > 0 {
            return self.titles[index]
        } else {
            if let title = self.viewControllers[index].title {
                return title
            }
            return "⚠️ no title"
        }
    }
    
    public func pjTabBarWillChange(_ pjTabBarView: PJTabBarView, fromIndex: Int, toIndex: Int) {
        self.isClickTabBarView = fromIndex != toIndex
    }
    
    public func pjTabBarDidChange(_ pjTabBarView: PJTabBarView, fromIndex: Int, toIndex: Int) {
        self.currentIndex = toIndex
        let viewController = viewControllers[toIndex]
        var pageViewControllerNavigationDirection: UIPageViewControllerNavigationDirection = .forward
        if fromIndex > toIndex {
            pageViewControllerNavigationDirection = .reverse
        }
        self.pageViewController.setViewControllers([viewController], direction: pageViewControllerNavigationDirection, animated: self.pageAnimated, completion: {
            [weak self] (finished) in
            self?.pageCompletion?(finished, 0)
            self?.isClickTabBarView = false
        })
    }
}

