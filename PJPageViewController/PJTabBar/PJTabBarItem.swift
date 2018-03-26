//
//  RCUIPhoneTabBarItem.swift
//  Glip
//
//  Created by Zoey Weng on 2017/10/26.
//  Copyright © 2017年 RingCentral. All rights reserved.
//

import UIKit

open class PJTabBarItem {

    open var title: String? = ""
    open var titleWidth: CGFloat {
        return cellSize.width - self.tabBarOptions.leftPadding - self.tabBarOptions.rightPadding
    }
    open var cellSize: CGSize = .zero
    open var isSelect: Bool = false
    open var tabBarOptions: PJPageOptions = PJPageOptions()
    public init(title: String?) {
        self.title = title
    }
}
