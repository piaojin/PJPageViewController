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
        let viewController1 = UIViewController()
        viewController1.view.backgroundColor = .orange
        
        let viewController2 = UIViewController()
        viewController2.view.backgroundColor = .red
        
        let viewController3 = UIViewController()
        viewController3.view.backgroundColor = .yellow
        
        let viewController = PJPageViewController(viewControllers: [viewController1, viewController2, viewController3], tabBarViewConfiguration: PJTabBarViewConfiguration())
        
//        viewController.viewControllers = [viewController1, viewController2, viewController3]
        viewController.tabBarViewConfiguration.tabBarViewHeigth = 60.0
        return viewController
    }()
    
    lazy var pjTabBarView: PJTabBarView! = {
        let view = PJTabBarView()
        view.backgroundColor = .orange
        view.translatesAutoresizingMaskIntoConstraints = false
//        view.currentIndex = 6
        view.delegate = self
        view.currentIndex = 6
        return view
    }()
    
    var items: [String] = ["piaojin1", "piaojin2", "piaojin100", "piaojin100", "piaojin100", "piaojin100", "piaojin100", "piaojin100", "piaojin100", "piaojin100", "piaojin100", "piaojin100", "piaojin100", "piaojin100"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let nav = UINavigationController(rootViewController: self.pageViewController)
        self.present(nav, animated: true, completion: nil)
    }
}

extension PJTabBarDemoViewController {
    func initView() {
        self.title = "piaojin"
        self.view.backgroundColor = .white
//        self.view.addSubview(self.pjTabBarView)
//        self.pjTabBarView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
//        self.pjTabBarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
//        self.pjTabBarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
//        self.pjTabBarView.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
    }
}

extension PJTabBarDemoViewController: PJTabBarViewDelegate {
    func pjTabBarNumberOfItems() -> Int {
        return items.count
    }
    
    func pjTabBar(_ pjTabBarView: PJTabBarView, pjTabBarItemAt index: Int) -> String {
        return items[index]
    }
}
