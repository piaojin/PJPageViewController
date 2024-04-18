//
//  PurchasePageViewController.swift
//  PJPageViewControllerExample
//
//  Created by piaojin on 2024/4/18.
//  Copyright © 2024 ywyw.piaojin. All rights reserved.
//

import UIKit
import PJPageViewController

class PurchasePageViewController: PJCoverPageViewController {
    private let supplierLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.text = "*供应商：江西通药集採医药有限公司-通药-通药一部"
        return label
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "请输入商品编码 / 名称", attributes: [NSAttributedString.Key.foregroundColor : UIColor.black])
            searchBar.searchTextField.backgroundColor = .systemGreen
            searchBar.searchTextField.layer.cornerRadius = 18
            searchBar.searchTextField.layer.masksToBounds = true
        } else {
            // Fallback on earlier versions
        }
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor.white.cgColor
        return searchBar
    }()
    
    private let searchButton: UIButton = {
        let button = UIButton()
        button.setTitle("搜索", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .regular)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func initCoverView() {
        self.coverViewHeigth = 90
        self.tabBarViewHeigth = 44
        self.topContentViewHeight?.constant = self.coverViewHeigth + self.tabBarViewHeigth
        self.coverView.translatesAutoresizingMaskIntoConstraints = true
        self.coverView.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.coverViewHeigth)
        self.topContentView.addSubview(self.coverView)
        
        self.tabBarView.frame = CGRect(x: 0.0, y: self.coverView.frame.maxY, width: self.view.frame.size.width, height: self.tabBarViewHeigth)
        self.view.bringSubview(toFront: self.tabBarView)
        
        self.coverView.addSubview(supplierLabel)
        self.coverView.addSubview(searchBar)
        self.coverView.addSubview(searchButton)
        NSLayoutConstraint.activate([
            supplierLabel.topAnchor.constraint(equalTo: coverView.topAnchor, constant: 10),
            supplierLabel.leadingAnchor.constraint(equalTo: coverView.leadingAnchor, constant: 15),
            supplierLabel.trailingAnchor.constraint(equalTo: coverView.trailingAnchor, constant: -15),
            
            searchBar.topAnchor.constraint(equalTo: supplierLabel.bottomAnchor, constant: 5),
            searchBar.bottomAnchor.constraint(equalTo: coverView.bottomAnchor),
            searchBar.leadingAnchor.constraint(equalTo: coverView.leadingAnchor, constant: 15),
            searchBar.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: -15),
            
            searchButton.trailingAnchor.constraint(equalTo: coverView.trailingAnchor, constant: -15),
            searchButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            searchButton.widthAnchor.constraint(equalToConstant: 45),
            searchButton.heightAnchor.constraint(equalToConstant: 24),
        ])
    }
}
