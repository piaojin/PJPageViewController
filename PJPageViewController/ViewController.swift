//
//  ViewController.swift
//  PJPageViewController
//
//  Created by piaojin on 2018/1/24.
//  Copyright © 2018年 ywyw.piaojin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    lazy var pageViewController: UIPageViewController! = {
        let viewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        viewController.view.frame = self.view.bounds
        viewController.delegate = self
        viewController.dataSource = self
        return viewController
    }()
    
    var pageScrollView: UIScrollView!
    
    var viewControllers: [UIViewController] = []
    
    var currentIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewController1 = UIViewController()
        viewController1.view.backgroundColor = .orange
        
        let viewController2 = UIViewController()
        viewController2.view.backgroundColor = .red
        
        let viewController3 = UIViewController()
        viewController3.view.backgroundColor = .yellow
        
        viewControllers.append(viewController1)
        viewControllers.append(viewController2)
        viewControllers.append(viewController3)
        
        self.pageViewController.setViewControllers([viewController1], direction: .forward, animated: true, completion: nil)
        
        self.addChildViewController(self.pageViewController)
        self.pageViewController.didMove(toParentViewController: self)
        self.view.addSubview(self.pageViewController.view)
        
        self.syncScrollView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController {
    func syncScrollView() {
        for view in self.pageViewController.view.subviews {
            if view is UIScrollView, let tempView = view as? UIScrollView {
                self.pageScrollView = tempView
                self.pageScrollView.delegate = self
            }
        }
    }
}

extension ViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("scrollViewDidScroll")
    }
}

extension ViewController: UIPageViewControllerDataSource {
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.viewControllers.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let index =  self.viewControllers.index(of: viewController), index > 0, index != NSNotFound else {
            return nil
        }
        
        var beforeIndex = index
        
        beforeIndex = beforeIndex - 1
        
        return self.viewControllers[beforeIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index =  self.viewControllers.index(of: viewController), index < self.viewControllers.count - 1, index != NSNotFound else {
            return nil
        }
        
        var afterIndex = index
        
        afterIndex = afterIndex + 1
        
        return self.viewControllers[afterIndex]
    }
}

extension ViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
    }
    
    
}

