//
//  PJTopContentView.swift
//  PJPageViewController
//
//  Created by Zoey Weng on 2018/3/22.
//  Copyright © 2018年 ywyw.piaojin. All rights reserved.
//

import UIKit

class PJTopContentView: UIView {
    //make coverView and pjTabBarView and tableView to response event
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view == self {
            return nil
        }
        return view
    }
}
