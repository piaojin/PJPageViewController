//
//  PhoneTabBar.swift
//  Glip
//
//  Created by Zoey Weng on 2017/10/26.
//  Copyright © 2017年 RingCentral. All rights reserved.
//

import UIKit

@objc public protocol PJTabBarViewDelegate: NSObjectProtocol {
    @objc optional func pjTabBarDidChange(_ pjTabBarView: PJTabBarView, fromIndex: Int, toIndex: Int)
    
    func pjTabBarNumberOfItems() -> Int
    
    func pjTabBar(_ pjTabBarView: PJTabBarView, pjTabBarItemAt index: Int) -> String
}

@IBDesignable
open class PJTabBarView: UIView {
    
    var items: [Int : PJTabBarItem] = [:]
    
    @IBInspectable var scrollBarHeigth: CGFloat = 2.0 {
        didSet {
            if delegate != nil {
                scrollBar.frame.size = CGSize(width: scrollBar.frame.size.width, height: scrollBarHeigth)
                scrollBar.frame.origin = CGPoint(x: scrollBar.frame.origin.x, y: collectionView.frame.size.height - scrollBarHeigth)
            }
        }
    }
    
    @IBInspectable var minimumInteritemSpacing: CGFloat = 60.0 {
        didSet {
            flowLayout.minimumInteritemSpacing = minimumInteritemSpacing
            setUpScrollBarPosition(atIndex: currentIndex)
        }
    }
    
    @IBInspectable var minimumLineSpacing: CGFloat = 60.0 {
        didSet {
            flowLayout.minimumLineSpacing = minimumLineSpacing
            setUpScrollBarPosition(atIndex: currentIndex)
        }
    }
    
    /// the size of cell
    @IBInspectable var itemSize: CGSize = CGSize.zero {
        didSet {
            flowLayout.itemSize = itemSize
            flowLayout.invalidateLayout()
            setUpScrollBarPosition(atIndex: currentIndex)
        }
    }
    
    /// current select item index
    var currentIndex: Int = 0 {
        didSet {
            guard delegate != nil, let count = delegate?.pjTabBarNumberOfItems(), currentIndex < count, currentIndex >= 0 else {
                return
            }
            
            let oldIndex = oldValue
            let newIndex = currentIndex
            
            if oldIndex == newIndex {
                return
            }
            
            if let newTabBarItem = self.items[newIndex]  {
                newTabBarItem.isSelect = true
            }
            
            if oldIndex < count, oldIndex >= 0 {
                if let oldTabBarItem = self.items[oldIndex] {
                    oldTabBarItem.isSelect = false
                    collectionView?.reloadItems(at: [IndexPath(row: oldIndex, section: 0)])
                }
            }
            
            collectionView?.reloadItems(at: [IndexPath(row: newIndex, section: 0)])
            collectionView?.scrollToItem(at: IndexPath(row: newIndex, section: 0), at: scrollPosition, animated: true)
            self.setUpScrollBarPosition(atIndex: newIndex)
        }
    }
    
    @IBInspectable var sectionInset: UIEdgeInsets = UIEdgeInsets.zero {
        didSet {
            flowLayout.sectionInset = sectionInset
            setUpScrollBarPosition(atIndex: currentIndex)
        }
    }
    
    @IBInspectable var titleSelectedColor: UIColor = .blue {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    @IBInspectable var titleColor: UIColor = .black {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    @IBInspectable var titleAlpha: CGFloat = 0.4 {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    @IBInspectable var titleSelectedAlpha: CGFloat = 1.0 {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    @IBInspectable var titleFont: UIFont = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.medium) {
        didSet {
            for pjTabBarItem in self.items.values {
                pjTabBarItem.cellSize = CGSize.zero
            }
            collectionView?.reloadData()
            setUpScrollBarPosition(atIndex: currentIndex)
        }
    }
    
    var maxItemWidth: CGFloat = 0.0
    var scrollPosition: UICollectionViewScrollPosition = .centeredHorizontally
    
    weak var delegate: PJTabBarViewDelegate? {
        didSet {
            if delegate != nil {
                assert(delegate?.pjTabBarNumberOfItems() != nil && currentIndex <= (delegate?.pjTabBarNumberOfItems())! && currentIndex >= 0, "currentIndex out of bounds")
                collectionView?.reloadData()
            }
        }
    }
    
    private static let kPJTabBarIdentifier = "PJTabBarViewCell"
    public var flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout() {
        didSet {
            self.collectionView.collectionViewLayout = flowLayout
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.reloadData()
        }
    }
    @IBInspectable var collectionView: UICollectionView!
    @IBInspectable var scrollBar: UIView!
    
    /// current select item source
    var currentPhoneTabBarItem: PJTabBarItem?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpSubViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setUpSubViews()
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /// init subViews
    private func setUpSubViews() {
        self.backgroundColor = .white
        flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        flowLayout.minimumLineSpacing = minimumLineSpacing
        flowLayout.sectionInset = sectionInset
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        
        collectionView.register(PJTabBarViewCell.classForCoder(), forCellWithReuseIdentifier: PJTabBarView.kPJTabBarIdentifier)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
        self.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        scrollBar = UIView()
        scrollBar.backgroundColor = .blue
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.addSubview(scrollBar)
        collectionView.accessibilityIdentifier = "tabs"
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    /// The number of calls is relatively small and acceptable.
    open override func layoutSubviews() {
        super.layoutSubviews()
        collectionView?.reloadItems(at: [IndexPath(row: currentIndex, section: 0)])
        collectionView?.scrollToItem(at: IndexPath(row: currentIndex, section: 0), at: scrollPosition, animated: true)
        self.setUpScrollBarPosition(atIndex: currentIndex)
    }
}

//MARK: UICollectionView UICollectionViewDataSource
extension PJTabBarView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = delegate?.pjTabBarNumberOfItems() {
            return count
        }
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PJTabBarView.kPJTabBarIdentifier, for: indexPath) as? PJTabBarViewCell
        configCell(cell: cell!, indexPath: indexPath)
        return cell!
    }
    
    public func configCell(cell: PJTabBarViewCell, indexPath: IndexPath) {
        cell.titleFont = titleFont
        cell.titleSelectedColor = titleSelectedColor
        cell.titleColor = titleColor
        cell.titleAlpha = titleAlpha
        cell.titleSelectedAlpha = titleSelectedAlpha
        let pjTabBarItem = self.items[indexPath.row]
        cell.pjTabBarItem = pjTabBarItem
        cell.backgroundColor = .orange
        if let textAlignment = pjTabBarItem?.titleTextAlignment {
            cell.setTextAlignment(textAlignment: textAlignment)
        } else {
            cell.setTextAlignment(textAlignment: .center)
        }
        
        if indexPath.row == currentIndex {
            self.setUpScrollBarPosition(atIndex: currentIndex)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt sizeForItemAtIndexPath: IndexPath) -> CGSize {
        if itemSize != CGSize.zero {
            return itemSize
        }
        
        guard let title = delegate?.pjTabBar(self, pjTabBarItemAt: sizeForItemAtIndexPath.row) else {
            return CGSize.zero
        }
        
        if let pjTabBarItem = self.items[sizeForItemAtIndexPath.row] {
            if pjTabBarItem.cellSize == .zero || maxItemWidth > 0 {
                pjTabBarItem.cellSize = sizeForItem(title: title)
            }
            return pjTabBarItem.cellSize
        } else {
            // first time load sizeForItem
            let pjTabBarItem = PJTabBarItem(title: title)
            if currentIndex == sizeForItemAtIndexPath.row {
                pjTabBarItem.isSelect = true
            }
            pjTabBarItem.cellSize = sizeForItem(title: title)
            self.items[sizeForItemAtIndexPath.row] = pjTabBarItem
            return pjTabBarItem.cellSize
        }
    }
}

//MARK: UICollectionView UICollectionViewDelegate
extension PJTabBarView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.scrollToItem(at: indexPath.row, at: scrollPosition)
    }
}

//MARK: PhoneTabBar action(select,scrollTo)
public extension PJTabBarView {
    
    /// if cell is not visible,set reload `true` to reload and get visible cell
    ///
    /// - Parameters:
    ///   - indexPaths: get cells by indexPaths
    ///   - reload: if cell is not visible,set reload `true` to reload and get visible cell
    /// - Returns: cells for indexPaths
    private func cellForItems(at indexPaths: [IndexPath], reloadIfNotVisible reload: Bool = true) -> [PJTabBarViewCell?] {
        let cells = indexPaths.map { collectionView.cellForItem(at: $0) as? PJTabBarViewCell }
        
        if reload {
            let indexPathsToReload = cells.enumerated()
                .flatMap { (arg) -> IndexPath? in
                    let (index, cell) = arg
                    return cell == nil ? indexPaths[index] : nil
                }
                .flatMap { (indexPath: IndexPath) -> IndexPath? in
                    return (indexPath.item >= 0 && indexPath.item < collectionView.numberOfItems(inSection: indexPath.section)) ? indexPath : nil
            }
            
            if !indexPathsToReload.isEmpty {
                collectionView.reloadItems(at: indexPathsToReload)
            }
        }
        return cells
    }
    
    /// scroll to the item at index
    ///
    /// - Parameters:
    ///   - index: the index which you want scroll to
    ///   - isSendChange: Whether to tell the caller, current select item has been changed
    func scrollToItem(at index: Int, at position: UICollectionViewScrollPosition = .centeredHorizontally) {
        assert(delegate?.pjTabBarNumberOfItems() != nil && index < (delegate?.pjTabBarNumberOfItems())!, "index out of bounds ")
        
        if index == currentIndex {
            return
        }
        
        UIView.animate(withDuration: 0.3) {
            self.setUpScrollBarPosition(atIndex: index)
        }
        
        collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: position, animated: true)
        
        self.delegate?.pjTabBarDidChange?(self, fromIndex: currentIndex, toIndex: index)
        self.updateSelectItem(newIndex: index)
        //update current select index (currentIndex)
        currentIndex = index
    }
    
    /// update current select item UI and currentIndex
    ///
    /// - Parameter newIndex: the new select item index
    private func updateSelectItem(newIndex: Int) {
        if currentIndex == newIndex {
            return
        }
        
        //unSelect old cell
        let oldIndexPath = IndexPath(row: currentIndex, section: 0)
        let newIndexPath = IndexPath(row: newIndex, section: 0)
        
        let cells = cellForItems(at: [oldIndexPath, newIndexPath], reloadIfNotVisible: true)
        
        if let oldTabBarItem = self.items[oldIndexPath.row] {
            oldTabBarItem.isSelect = false
        }
        
        if let oldSelectCell = cells.first as? PJTabBarViewCell {
            oldSelectCell.setSelected(selected: false)
        }
        
        //select new cell
        if let newTabBarItem = self.items[newIndexPath.row] {
            newTabBarItem.isSelect = true
            currentPhoneTabBarItem = newTabBarItem
        }
        
        if let newSelectCell = cells.last as? PJTabBarViewCell {
            newSelectCell.setSelected(selected: true)
        }
    }
    
    func sizeForItem(title: String) -> CGSize {
        let width = title.boundingSizeBySize(CGSize(width: maxItemWidth == 0.0 ? CGFloat.greatestFiniteMagnitude : maxItemWidth, height: collectionView.frame.size.height), font: titleFont).width
        return CGSize(width: width, height: collectionView.frame.size.height)
    }
}

//MARK: PhoneTabBar set
public extension PJTabBarView {
    
    /// reload Items at index
    public func reloadItems(at indexPaths: [IndexPath]) {
        collectionView.reloadItems(at: indexPaths)
    }
    
    /// set item title at index
    ///
    /// - Parameters:
    ///   - title: new title for item at index
    ///   - atIndex: at index
    func setTitle(title: String, atIndex: Int) {
        assert(delegate?.pjTabBarNumberOfItems() != nil && atIndex < (delegate?.pjTabBarNumberOfItems())!, "index out of bounds")
        let pjTabBarItem = self.items[atIndex]
        pjTabBarItem?.title = title
        pjTabBarItem?.cellSize = self.sizeForItem(title: title)
        collectionView?.reloadItems(at: [IndexPath(row: atIndex, section: 0)])
        if currentIndex == atIndex {
            setUpScrollBarPosition(atIndex: atIndex)
        }
    }
    
    func setTextAlignment(textAlignment: NSTextAlignment, atIndex: Int) {
        assert(delegate?.pjTabBarNumberOfItems() != nil && atIndex < (delegate?.pjTabBarNumberOfItems())!, "index out of bounds")
        if let pjtarBarItem = self.items[atIndex] {
            pjtarBarItem.titleTextAlignment = textAlignment
            collectionView.reloadItems(at: [IndexPath(row: atIndex, section: 0)])
            if currentIndex == atIndex {
                setUpScrollBarPosition(atIndex: atIndex)
            }
        }
    }
    
    private func setUpScrollBarPosition(atIndex: Int) {
        if let attr = collectionView?.layoutAttributesForItem(at: IndexPath(row: atIndex, section: 0)), let title = delegate?.pjTabBar(self, pjTabBarItemAt: atIndex), let pjTabBarItem = self.items[atIndex] {
            
            var scrollBarWidth: CGFloat = pjTabBarItem.cellSize.width
            if scrollBarWidth == 0.0 {
                pjTabBarItem.cellSize = sizeForItem(title: title)
                scrollBarWidth = pjTabBarItem.cellSize.width
            }
            if maxItemWidth > 0, scrollBarWidth > maxItemWidth { scrollBarWidth = maxItemWidth }
            scrollBar.frame.size = CGSize(width: scrollBarWidth, height: scrollBarHeigth)
            let scrollBarY = collectionView.frame.maxY - scrollBarHeigth
            if let pjtarBarItem = self.items[atIndex] {
                switch pjtarBarItem.titleTextAlignment {
                case .left :
                    scrollBar.frame.origin = CGPoint(x: attr.frame.origin.x, y: scrollBarY)
                    break
                case .right :
                    scrollBar.frame.origin = CGPoint(x: attr.frame.maxX - scrollBar.frame.size.width, y: scrollBarY)
                    break
                default :
                    scrollBar.center = CGPoint(x: attr.center.x, y: scrollBarY)
                    scrollBar.frame.origin = CGPoint(x: scrollBar.frame.origin.x, y: scrollBarY)
                    break
                }
            } else {
                scrollBar.center = CGPoint(x: attr.center.x, y: scrollBarY)
                scrollBar.frame.origin = CGPoint(x: scrollBar.frame.origin.x, y: scrollBarY)
            }
        }
    }
}
