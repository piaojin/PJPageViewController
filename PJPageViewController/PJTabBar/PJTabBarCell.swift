//
//  PhoneTabBarCell.swift
//  Glip
//
//  Created by Zoey Weng on 2017/10/26.
//  Copyright © 2017年 RingCentral. All rights reserved.
//

import UIKit

open class PJTabBarCell: UICollectionViewCell, PJTabBarViewCellProtocol {
    
    private var titleLeadingAnchor: NSLayoutConstraint?
    
    private var titleTrailingAnchor: NSLayoutConstraint?
    
    open lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.backgroundColor = .black
        return label
    }()
    
    open var pjTabBarItem: PJTabBarItem = PJTabBarItem(title: "") {
        didSet {
            self.updateTitle()
            self.setSelected(selected: pjTabBarItem.isSelect)
        }
    }
    
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

public extension PJTabBarCell {
    
    private func initView() {
        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        self.titleLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        self.titleLeadingAnchor = self.titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: self.pjTabBarItem.tabBarOptions.leftPadding)
        self.titleLeadingAnchor?.isActive = true
        self.titleTrailingAnchor = self.titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -self.pjTabBarItem.tabBarOptions.rightPadding)
        self.titleTrailingAnchor?.isActive = true
    }
    
    public func updateTitle() {
        titleLabel.font = self.pjTabBarItem.tabBarOptions.titleFont
        titleLabel.text = pjTabBarItem.title
        self.titleLeadingAnchor?.constant = self.pjTabBarItem.tabBarOptions.leftPadding
        self.titleTrailingAnchor?.constant = -self.pjTabBarItem.tabBarOptions.rightPadding
        self.layoutIfNeeded()
    }
    
    public func setSelected(selected: Bool) {
        if selected {
            titleLabel.textColor = self.pjTabBarItem.tabBarOptions.titleSelectedColor
            titleLabel.alpha = self.pjTabBarItem.tabBarOptions.titleSelectedAlpha
            if self.pjTabBarItem.tabBarOptions.cellSelectedColor != .clear {
                self.backgroundColor = self.pjTabBarItem.tabBarOptions.cellSelectedColor
            }
        }
        else {
            titleLabel.textColor = self.pjTabBarItem.tabBarOptions.titleColor
            titleLabel.alpha = self.pjTabBarItem.tabBarOptions.titleAlpha
            if self.pjTabBarItem.tabBarOptions.cellColor != .clear {
                self.backgroundColor = self.pjTabBarItem.tabBarOptions.cellColor
            }
        }
    }
}

