//
//  ViewController.swift
//  PJPageViewController
//
//  Created by piaojin on 2018/1/24.
//  Copyright © 2018年 ywyw.piaojin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var pageScrollView: UIScrollView!
    
    var viewControllers: [UIViewController] = []
    
    var currentIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
