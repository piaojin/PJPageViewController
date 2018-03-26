//
//  TestViewController.swift
//  PJPageViewController
//
//  Created by Zoey Weng on 2018/1/30.
//  Copyright © 2018年 ywyw.piaojin. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear:" + (self.title ?? ""))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear:" + (self.title ?? ""))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("viewWillDisappear:" + (self.title ?? ""))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDidDisappear:" + (self.title ?? ""))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad:" + (self.title ?? ""))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        print("deinit:" + (self.title ?? ""))
    }
}
