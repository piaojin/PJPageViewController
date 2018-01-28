//
//  PJTabBarViewConfiguration.swift
//  PJPageViewController
//
//  Created by piaojin on 2018/1/28.
//  Copyright © 2018年 ywyw.piaojin. All rights reserved.
//

import UIKit

public struct PJTabBarViewConfiguration {
    
    public var tabBarViewHeigth: CGFloat = 30.0
    
    public var scrollBarColor: UIColor = .blue
    
    public var scrollBarHeigth: CGFloat = 2.0
    
    public var minimumInteritemSpacing: CGFloat = 60.0
    
    public var minimumLineSpacing: CGFloat = 60.0
    
    /// the size of cell
    public var itemSize: CGSize = CGSize.zero
    
    public var sectionInset: UIEdgeInsets = UIEdgeInsets.zero
    
    public var titleSelectedColor: UIColor = .blue
    
    public var titleColor: UIColor = .black
    
    public var titleAlpha: CGFloat = 0.4
    
    public var titleSelectedAlpha: CGFloat = 1.0
    
    public var titleFont: UIFont = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.medium)
    
    public var maxItemWidth: CGFloat = 0.0
    
    public var scrollPosition: UICollectionViewScrollPosition = .centeredHorizontally
}
