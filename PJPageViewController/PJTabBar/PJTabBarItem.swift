//
//  RCUIPhoneTabBarItem.swift
//  Glip
//
//  Created by Zoey Weng on 2017/10/26.
//  Copyright © 2017年 RingCentral. All rights reserved.
//

import UIKit

open class PJTabBarItem {

    var title: String?
    var cellSize: CGSize = CGSize.zero
    var isSelect: Bool = false
    var titleTextAlignment: NSTextAlignment = .center
    init(title: String?) {
        self.title = title
    }
}
