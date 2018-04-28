//
//  PJNavBarPageViewController.swift
//  PJPageViewController
//
//  Created by Zoey Weng on 2018/4/28.
//  Copyright © 2018年 ywyw.piaojin. All rights reserved.
//

import UIKit

open class PJNavBarPageViewController: PJPageViewController {

    open var isTabBarHeightEqualToNavBar = true
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.initNavBarView()
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

public extension PJNavBarPageViewController {
    private func initNavBarView() {
        self.tabBarView.removeFromSuperview()
        if let navigationBar = self.navigationController?.navigationBar {
            if self.isTabBarHeightEqualToNavBar {
                self.tabBarView.frame = CGRect(x: 0.0, y: 0.0, width: navigationBar.bounds.size.width, height: navigationBar.bounds.size.height)
            } else {
                self.tabBarView.frame = CGRect(x: 0.0, y: (navigationBar.bounds.size.height - self.tabBarViewHeigth) / 2.0, width: navigationBar.bounds.size.width, height: self.tabBarViewHeigth)
            }
            navigationBar.addSubview(self.tabBarView)
        } else {
            assertionFailure("⚠️: There is not have navigationBar!")
        }
        self.topContentViewHeight.constant = 0.0
        self.pageViewTopConstraint?.constant = 0.0
    }
}
