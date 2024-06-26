//
//  DemoTableViewController.swift
//  PJPageViewController
//
//  Created by Zoey Weng on 2018/2/4.
//  Copyright © 2018年 ywyw.piaojin. All rights reserved.
//

import UIKit
import PJPageViewController

class DemoTableViewController: UIViewController, PJCoverPageViewProtocol {
    
    public lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tableFooterView = UIView()
        view.delegate = self
        view.dataSource = self
        view.alwaysBounceVertical = true
        view.backgroundColor = .black
        if #available(iOS 11.0, *) {
            view.contentInsetAdjustmentBehavior = .never
        }
        return view
    }()
    
    lazy var pageViewController: PJPageViewController = {
        let viewController1 = TestViewController()
        viewController1.title = "viewController1"
        viewController1.view.backgroundColor = .orange
        
        let viewController2 = TestViewController()
        viewController2.title = "viewController2"
        viewController2.view.backgroundColor = .red
        
        let viewController3 = DemoTableViewController()
        viewController3.title = "viewController3"
        viewController3.view.backgroundColor = .yellow
        
        let viewController4 = DemoTableViewController()
        viewController4.title = "viewController4"
        viewController4.view.backgroundColor = .black
        
        let sectionTableViewController = DemoSectionTableViewController()
        sectionTableViewController.title = "sectionTableViewController"
        sectionTableViewController.view.backgroundColor = .green
        
        let coverView = UIView()
        coverView.backgroundColor = .green
        
        var tabBarViewConfiguration = PJPageOptions()
        tabBarViewConfiguration.scrollBarColor = .blue
        tabBarViewConfiguration.maxItemWidth = 100.0
        tabBarViewConfiguration.scrollBarHeigth = 2.0
        tabBarViewConfiguration.titleColor = .red
        tabBarViewConfiguration.titleSelectedColor = .black
        tabBarViewConfiguration.minimumInteritemSpacing = 60.0
        
        let viewController = PJCoverPageViewController(viewControllers: [viewController3, sectionTableViewController, viewController4, viewController2, viewController1], coverView: coverView, coverPageViewScrollType: .linkageScroll, tabBarViewConfiguration: tabBarViewConfiguration)
        viewController.tabBarViewHeigth = 30.0
        viewController.tabBarView.backgroundColor = .green
        viewController.title = "Has coverView"
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initView() {
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.addSubview(self.tableView)
        
        self.tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        if #available(iOS 11.0, *) {
            self.tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
            self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        } else {
            self.tableView.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor).isActive = true
            self.tableView.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor).isActive = true
        }
        
        self.tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "UITableViewCell")
    }
    
    func scrollView() -> UIScrollView? {
        return self.tableView
    }
}

extension DemoTableViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 60
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        cell?.tintColor = .orange
        cell?.textLabel?.text = "\(indexPath.row)"
        cell?.backgroundColor = .yellow
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
}

extension DemoTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        self.navigationController?.pushViewController(self.pageViewController, animated: true)
    }
}
