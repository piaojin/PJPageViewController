//
//  PJTabBarViewConfiguration.swift
//  PJPageViewController
//
//  Created by piaojin on 2018/1/28.
//  Copyright © 2018年 ywyw.piaojin. All rights reserved.
//

import UIKit

public struct PJTabBarViewConfiguration {
    public var tabBarViewHeigth: CGFloat = 30.0 {
        didSet {
            
        }
    }
    
    public var scrollBarHeigth: CGFloat = 2.0 {
        didSet {
            
        }
    }
    
    public var minimumInteritemSpacing: CGFloat = 60.0 {
        didSet {
            
        }
    }
    
    public var minimumLineSpacing: CGFloat = 60.0 {
        didSet {
            
        }
    }
    
    /// the size of cell
    public var itemSize: CGSize = CGSize.zero {
        didSet {
            
        }
    }
    
    public var sectionInset: UIEdgeInsets = UIEdgeInsets.zero {
        didSet {
            
        }
    }
    
    public var titleSelectedColor: UIColor = .blue {
        didSet {
            
        }
    }
    
    public var titleColor: UIColor = .black {
        didSet {
            
        }
    }
    
    public var titleAlpha: CGFloat = 0.4 {
        didSet {
            
        }
    }
    
    public var titleSelectedAlpha: CGFloat = 1.0 {
        didSet {
            
        }
    }
    
    public var titleFont: UIFont = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.medium) {
        didSet {
            
        }
    }
    
    public var maxItemWidth: CGFloat = 0.0
    
    public var scrollPosition: UICollectionViewScrollPosition = .centeredHorizontally
}
