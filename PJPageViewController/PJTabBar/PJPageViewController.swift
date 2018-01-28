//
//  PJPageViewController.swift
//  PJPageViewController
//
//  Created by piaojin on 2018/1/27.
//  Copyright © 2018年 ywyw.piaojin. All rights reserved.
//

import UIKit

open class PJPageViewController: UIViewController {
    
    public var tabBarViewHeigth: CGFloat = 30.0 {
        didSet {
            self.tabBarViewConfiguration.tabBarViewHeigth = tabBarViewHeigth
        }
    }
    
    public var flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout() {
        didSet {
            self.pjTabBarView.flowLayout = flowLayout
        }
    }
    
    public var tabBarViewConfiguration: PJTabBarViewConfiguration = PJTabBarViewConfiguration() {
        didSet {
            
            self.pjTabBarView.scrollBarHeigth = tabBarViewConfiguration.scrollBarHeigth
            
            self.pjTabBarView.minimumInteritemSpacing = tabBarViewConfiguration.minimumInteritemSpacing
            
            self.pjTabBarView.minimumLineSpacing = tabBarViewConfiguration.minimumLineSpacing
            
            self.pjTabBarView.itemSize = tabBarViewConfiguration.itemSize
            
            self.pjTabBarView.sectionInset = tabBarViewConfiguration.sectionInset
            
            self.pjTabBarView.titleSelectedColor = tabBarViewConfiguration.titleSelectedColor
            
            self.pjTabBarView.titleColor = tabBarViewConfiguration.titleColor
            
            self.pjTabBarView.titleAlpha = tabBarViewConfiguration.titleAlpha
            
            self.pjTabBarView.titleSelectedAlpha = tabBarViewConfiguration.titleSelectedAlpha
            
            self.pjTabBarView.titleFont = tabBarViewConfiguration.titleFont
            
            self.pjTabBarView.maxItemWidth = tabBarViewConfiguration.maxItemWidth
            
            self.pjTabBarView.scrollPosition = tabBarViewConfiguration.scrollPosition
        }
    }
    
    public lazy var pageViewController: UIPageViewController! = {
        let viewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.delegate = self
        viewController.dataSource = self
        return viewController
    }()
    
    public lazy var pjTabBarView: PJTabBarView! = {
        let bar = PJTabBarView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()
    
    public weak var pageScrollView: UIScrollView!
    
    public var viewControllers: [UIViewController] = [] {
        didSet {
            if let first = viewControllers.first {
                self.pageViewController.setViewControllers([first], direction: .forward, animated: true, completion: nil)
            }
        }
    }
    
    public var titles: [String] = []
    
    public var currentIndex: Int = 0
    
    convenience public init(viewControllers: [UIViewController]) {
        self.init(viewControllers: viewControllers, tabBarViewConfiguration: PJTabBarViewConfiguration())
    }
    
    convenience public init(titles: [String]) {
        self.init(titles: titles, tabBarViewConfiguration: PJTabBarViewConfiguration())
    }
    
    convenience public init(viewControllers: [UIViewController], tabBarViewConfiguration: PJTabBarViewConfiguration) {
        self.init()
        self.viewControllers = viewControllers
        self.tabBarViewConfiguration = tabBarViewConfiguration
    }
    
    convenience public init(titles: [String], tabBarViewConfiguration: PJTabBarViewConfiguration) {
        self.init()
        self.titles = titles
        self.tabBarViewConfiguration = tabBarViewConfiguration
    }
    
//    override public init() {
//        super.init()
//        print("⚠️you should use 'init(viewControllers: [UIViewController], tabBarViewConfiguration: PJTabBarViewConfiguration)' or 'init(titles: [String], tabBarViewConfiguration: PJTabBarViewConfiguration)' or 'init(viewControllers: [UIViewController])' or 'init(titles: [String])' to do initialize")
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
        self.initData()
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

public extension PJPageViewController {
    
    private func initView() {
        
        self.view.addSubview(self.pjTabBarView)
        
        pjTabBarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        pjTabBarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        pjTabBarView.heightAnchor.constraint(equalToConstant: self.tabBarViewConfiguration.tabBarViewHeigth).isActive = true
        if #available(iOS 11.0, *) {
            pjTabBarView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            pjTabBarView.topAnchor.constraint(equalTo: self.topLayoutGuide.topAnchor).isActive = true
        }
        
        self.addChildViewController(self.pageViewController)
        self.pageViewController.didMove(toParentViewController: self)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.view.topAnchor.constraint(equalTo: self.pjTabBarView.bottomAnchor).isActive = true
        self.pageViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.pageViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        if #available(iOS 11.0, *) {
            self.pageViewController.view.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        } else {
            self.pageViewController.view.bottomAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
        }
        self.syncScrollView()
    }
    
    private func initData() {
        self.pjTabBarView.delegate = self
        if let first = viewControllers.first {
            self.pageViewController.setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
    }
    
    private func syncScrollView() {
        for view in self.pageViewController.view.subviews {
            if view is UIScrollView, let tempView = view as? UIScrollView {
                self.pageScrollView = tempView
                self.pageScrollView.delegate = self
            }
        }
    }
}

extension PJPageViewController: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
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
        let index = Int(self.pageScrollView.contentOffset.x / self.pageScrollView.frame.size.width) - 1
        if index != 0 {
            self.currentIndex = self.currentIndex + index
            self.pjTabBarView.scrollToItem(at: self.currentIndex)
        }
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
    
    public func pjTabBarDidChange(_ pjTabBarView: PJTabBarView, fromIndex: Int, toIndex: Int) {
        let viewController = viewControllers[toIndex]
        var pageViewControllerNavigationDirection: UIPageViewControllerNavigationDirection = .forward
        if fromIndex > toIndex {
            pageViewControllerNavigationDirection = .reverse
        }
        self.pageViewController.setViewControllers([viewController], direction: pageViewControllerNavigationDirection, animated: true, completion: nil)
        self.currentIndex = toIndex
    }
}

