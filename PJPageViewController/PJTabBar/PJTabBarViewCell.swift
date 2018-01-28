//
//  PhoneTabBarCell.swift
//  Glip
//
//  Created by Zoey Weng on 2017/10/26.
//  Copyright © 2017年 RingCentral. All rights reserved.
//

import UIKit

open class PJTabBarViewCell: UICollectionViewCell {
    
    private lazy var titleLabel: UILabel! = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var pjTabBarItem: PJTabBarItem? {
        didSet {
            self.updateTitle()
            if pjTabBarItem != nil {
                self.setSelected(selected: pjTabBarItem!.isSelect)
            }
        }
    }
    
    var titleFont: UIFont = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.medium)
    var titleSelectedColor: UIColor = .blue
    var titleColor: UIColor = .black
    var titleAlpha: CGFloat = 0.4
    var titleSelectedAlpha: CGFloat = 1.0
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setSelected(selected: false)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

public extension PJTabBarViewCell {
    
    func initView() {
        self.contentView.addSubview(self.titleLabel)
        
        self.titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        self.titleLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        self.titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        self.titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
    }
    
    func updateTitle() {
        titleLabel.font = titleFont
        titleLabel.text = pjTabBarItem?.title
    }
    
    func setSelected(selected: Bool) {
        if selected {
            titleLabel.textColor = titleSelectedColor
            titleLabel.alpha = titleSelectedAlpha
        }
        else {
            titleLabel.textColor = titleColor
            titleLabel.alpha = titleAlpha
        }
    }
    
    func setCount(count: Int) {
        updateTitle()
    }
    
    func setTitle(title: String) {
        updateTitle()
    }
    
    func setTextAlignment(textAlignment: NSTextAlignment) {
        titleLabel.textAlignment = textAlignment
    }
}

