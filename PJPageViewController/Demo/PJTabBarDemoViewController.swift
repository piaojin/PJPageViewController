//
//  PJTabBarDemoViewController.swift
//  PJPageViewController
//
//  Created by piaojin on 2018/1/26.
//  Copyright © 2018年 ywyw.piaojin. All rights reserved.
//

import UIKit

class PJTabBarDemoViewController: UIViewController {

    lazy var pageViewController: PJPageViewController = {
        let viewController1 = TestViewController()
        viewController1.title = "viewController1"
        viewController1.view.backgroundColor = .orange
        
        let viewController2 = TestViewController()
        viewController2.title = "viewController2"
        viewController2.view.backgroundColor = .red
        
        let viewController3 = DemoTableViewController()
        viewController3.title = "viewController3$"
        viewController3.view.backgroundColor = .yellow
        
        let viewController4 = DemoTableViewController()
        viewController4.title = "viewController4"
        viewController4.view.backgroundColor = .black
        
        let sectionTableViewController = DemoSectionTableViewController()
        sectionTableViewController.title = "se"
        sectionTableViewController.view.backgroundColor = .green
        
        let coverView = UIView()
        coverView.backgroundColor = .green
        
        var tabBarViewConfiguration = PJPageOptions()
//        tabBarViewConfiguration.leftPadding = 30.0
//        tabBarViewConfiguration.rightPadding = 10.0
//        tabBarViewConfiguration.scrollBarExtraWidth = 20.0
//        tabBarViewConfiguration.scrollBarConstWidth = 130.0
        tabBarViewConfiguration.scrollBarColor = .green
//        tabBarViewConfiguration.maxItemWidth = 100.0
        tabBarViewConfiguration.scrollBarHeigth = 6.0
        tabBarViewConfiguration.titleColor = .red
        tabBarViewConfiguration.titleSelectedColor = .blue
        tabBarViewConfiguration.autoSetMinimumInteritemSpacingMaxCount = 3
        tabBarViewConfiguration.isAutoSetMinimumInteritemSpacing = true
//        tabBarViewConfiguration.leftViewAnchors = (left: 0.0, top: 0.0, bottom: 0.0, width: 20.0)
//        tabBarViewConfiguration.rightViewAnchors = (right: 0.0, top: 0.0, bottom: 0.0, width: 20.0)
//        tabBarViewConfiguration.sectionInset = UIEdgeInsets(top: 0.0, left: 100.0, bottom: 0.0, right: 100.0)
//        tabBarViewConfiguration.minimumInteritemSpacing = 200.0
//        tabBarViewConfiguration.itemSize = CGSize(width: 80.0, height: 30.0)
        
        let viewController5 = TestViewController()
        viewController5.title = "viewController5"
        viewController5.view.backgroundColor = .orange
        
        let viewController6 = TestViewController()
        viewController6.title = "viewController6"
        viewController6.view.backgroundColor = .orange
        
        let viewController7 = TestViewController()
        viewController7.title = "viewController7"
        viewController7.view.backgroundColor = .orange
        
        let viewController = PJCoverPageViewController(viewControllers: [viewController3, sectionTableViewController, viewController4, viewController2, viewController1, viewController5, viewController6, viewController7], coverView: coverView, coverPageViewScrollType: .linkageScroll, tabBarViewConfiguration: tabBarViewConfiguration)
        viewController.tabBarViewHeigth = 30.0
//        let leftView = UIView()
//        leftView.backgroundColor = .orange
//        let rightView = UIView()
//        rightView.backgroundColor = .yellow
//        viewController.tabBarLeftView = leftView
//        viewController.tabBarRightView = rightView
        
        //不带coverView
//        let viewController = PJPageViewController(viewControllers: [viewController3, sectionTableViewController, viewController4, viewController2, viewController1], tabBarOptions: tabBarViewConfiguration)
//        viewController.tabBarViewHeigth = 30.0
//        viewController.currentIndex = 3
        
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension PJTabBarDemoViewController {
    func initView() {
        self.title = "piaojin"
        self.view.backgroundColor = .white
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("点击", for: .normal)
        button.backgroundColor = .orange
        self.view.addSubview(button)
        button.widthAnchor.constraint(equalToConstant: 66.0).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        button.addTarget(self, action: #selector(clickAction), for: .touchUpInside)
    }
    
    @objc func clickAction() {
        let nav = UINavigationController(rootViewController: self.pageViewController)
        self.present(nav, animated: true, completion: nil)
    }
}
