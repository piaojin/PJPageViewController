//
//  PJTabBarViewConfiguration.swift
//  PJPageViewController
//
//  Created by piaojin on 2018/1/28.
//  Copyright © 2018年 ywyw.piaojin. All rights reserved.
//

import UIKit

public enum MoveScrollBarStyle {
    case elastic, bounce
}

public struct PJPageOptions {
    
    public var scrollBarColor: UIColor = .orange
    
    public var scrollBarHeigth: CGFloat = 4.0
    
    // Set the fixed width of scrollBar
    public var scrollBarConstWidth: CGFloat = 0.0
    
    // scrollBar Width is the same as tabBar title width by default. If you want to increase on the basis of title width, set it up.
    public var scrollBarExtraWidth: CGFloat = 0.0
    
    public var isScrollBarConstWidth: Bool {
        return self.scrollBarConstWidth > 0.0
    }
    
    public var isTabBarCellLinkScrollWhenMoveScrollBar = true
    
    public var minimumInteritemSpacing: CGFloat = 60.0
    
    public var moveScrollBarStyle: MoveScrollBarStyle = .bounce
    
    public var isScrollBarLinkScrollWhenMovePage = true
    
    /// the size of cell
    public var itemSize: CGSize = .zero
    
    public var sectionInset: UIEdgeInsets = .zero
    
    // tabBar left Padding
    public var leftPadding: CGFloat = 0.0
    
    // tabBar right Padding
    public var rightPadding: CGFloat = 0.0
    
    // tabBar left custom view frame
    public var leftViewAnchors: (left: CGFloat, top: CGFloat, bottom: CGFloat, width: CGFloat) = (left: 0.0, top: 0.0, bottom: 0.0, width: 0.0)
    
    // tabBar right custom view frame
    public var rightViewAnchors: (right: CGFloat, top: CGFloat, bottom: CGFloat, width: CGFloat) = (right: 0.0, top: 0.0, bottom: 0.0, width: 0.0)
    
    public var titleSelectedColor: UIColor = .orange
    
    public var titleColor: UIColor = .black
    
    public var cellSelectedColor: UIColor = .clear
    
    public var cellColor: UIColor = .clear
    
    public var titleAlpha: CGFloat = 1.0
    
    public var titleSelectedAlpha: CGFloat = 1.0
    
    public var titleFont: UIFont = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.medium)
    
    //Temporary dissupport
//    public var titleTextAlignment: NSTextAlignment = .center
    
    public var maxItemWidth: CGFloat = 0.0
    
    public var minItemWidth: CGFloat = 0.0
    
    public var scrollPosition: UICollectionViewScrollPosition = .centeredHorizontally
    
    public var animationDuration: TimeInterval = 0.3
    
    public var isNeedScrollBar = true
    
    // set minimumInteritemSpacing automatically
    public var isAutoSetMinimumInteritemSpacing = true
    
    public var autoSetMinimumInteritemSpacingMaxCount: Int = 3
    
    // is set title's gradient when move scrollBar
    public var isTitleGradient = true
}
