//
//  PJTabBarViewConfiguration.swift
//  PJPageViewController
//
//  Created by piaojin on 2018/1/28.
//  Copyright © 2018年 ywyw.piaojin. All rights reserved.
//

import UIKit

public struct PJPageOptions {
    
    public var scrollBarColor: UIColor = .blue
    
    public var scrollBarHeigth: CGFloat = 2.0
    
    public var scrollBarConstWidth: CGFloat = 0.0
    
    public var minimumInteritemSpacing: CGFloat = 60.0
    
    public var minimumLineSpacing: CGFloat = 60.0
    
    /// the size of cell
    public var itemSize: CGSize = .zero
    
    public var sectionInset: UIEdgeInsets = .zero
    
    public var leftPadding: CGFloat = 0.0
    
    public var rightPadding: CGFloat = 0.0
    
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
    
    public var isAutoSetMinimumLineSpacing = true
    
    public var autoSetMinimumLineSpacingMaxCount: Int = 3
}
