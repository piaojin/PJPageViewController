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
    
    @objc optional func pjTabBarWillChange(_ pjTabBarView: PJTabBarView, fromIndex: Int, toIndex: Int)
    
    func pjTabBarNumberOfItems() -> Int
    
    func pjTabBar(_ pjTabBarView: PJTabBarView, pjTabBarItemAt index: Int) -> String
}

@IBDesignable
open class PJTabBarView: UIView {
    
    private static let kPJTabBarViewWidthKeyPath = "frame"
    
    open var clickCellClosure: ((PJTabBarView, Int) -> ())?
    
    private var lastWidth: CGFloat = 0.0
    
    open var items: [Int : PJTabBarItem] = [:]
    
    open var tabBarOptions: PJPageOptions = PJPageOptions()
    
    @IBInspectable open var scrollBarHeigth: CGFloat = 2.0 {
        didSet {
            if delegate != nil {
                self.tabBarOptions.scrollBarHeigth = scrollBarHeigth
                scrollBar.frame.size = CGSize(width: scrollBar.frame.size.width, height: scrollBarHeigth)
                scrollBar.frame.origin = CGPoint(x: scrollBar.frame.origin.x, y: collectionView.frame.size.height - scrollBarHeigth)
            }
        }
    }
    
    @IBInspectable open var minimumInteritemSpacing: CGFloat = 60.0 {
        didSet {
            flowLayout.minimumInteritemSpacing = minimumInteritemSpacing
            self.tabBarOptions.minimumInteritemSpacing = minimumInteritemSpacing
            setUpScrollBarPosition(atIndex: currentIndex)
        }
    }
    
    @IBInspectable open var minimumLineSpacing: CGFloat = 60.0 {
        didSet {
            flowLayout.minimumLineSpacing = minimumLineSpacing
            self.tabBarOptions.minimumLineSpacing = minimumLineSpacing
            setUpScrollBarPosition(atIndex: currentIndex)
        }
    }
    
    /// the size of cell
    @IBInspectable open var itemSize: CGSize = CGSize.zero {
        didSet {
            flowLayout.itemSize = itemSize
            self.tabBarOptions.itemSize = itemSize
            flowLayout.invalidateLayout()
            setUpScrollBarPosition(atIndex: currentIndex)
        }
    }
    
    /// current select item index
    open var currentIndex: Int = 0 {
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
            } else {
                let newTabBarItem = PJTabBarItem(title: delegate?.pjTabBar(self, pjTabBarItemAt: newIndex))
                newTabBarItem.isSelect = true
                self.items[newIndex] = newTabBarItem
            }
            
            if oldIndex < count, oldIndex >= 0 {
                if let oldTabBarItem = self.items[oldIndex] {
                    oldTabBarItem.isSelect = false
                    collectionView?.reloadItems(at: [IndexPath(row: oldIndex, section: 0)])
                }
            }
            
            collectionView?.reloadItems(at: [IndexPath(row: newIndex, section: 0)])
            collectionView?.scrollToItem(at: IndexPath(row: newIndex, section: 0), at: self.tabBarOptions.scrollPosition, animated: true)
            self.setUpScrollBarPosition(atIndex: newIndex)
        }
    }
    
    @IBInspectable open var sectionInset: UIEdgeInsets = UIEdgeInsets.zero {
        didSet {
            flowLayout.sectionInset = sectionInset
            self.tabBarOptions.sectionInset = sectionInset
            setUpScrollBarPosition(atIndex: currentIndex)
        }
    }
    
    @IBInspectable open var titleSelectedColor: UIColor = .blue {
        didSet {
            self.tabBarOptions.titleSelectedColor = titleSelectedColor
            collectionView?.reloadData()
        }
    }
    
    @IBInspectable open var titleColor: UIColor = .black {
        didSet {
            self.tabBarOptions.titleColor = titleColor
            collectionView?.reloadData()
        }
    }
    
    @IBInspectable open var titleAlpha: CGFloat = 0.4 {
        didSet {
            self.tabBarOptions.titleAlpha = titleAlpha
            collectionView?.reloadData()
        }
    }
    
    @IBInspectable open var titleSelectedAlpha: CGFloat = 1.0 {
        didSet {
            self.tabBarOptions.titleSelectedAlpha = titleSelectedAlpha
            collectionView?.reloadData()
        }
    }
    
    @IBInspectable open var titleFont: UIFont = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.medium) {
        didSet {
            for pjTabBarItem in self.items.values {
                pjTabBarItem.cellSize = .zero
            }
            self.tabBarOptions.titleFont = titleFont
            collectionView?.reloadData()
            setUpScrollBarPosition(atIndex: currentIndex)
        }
    }
    
    open weak var delegate: PJTabBarViewDelegate? {
        didSet {
            if delegate != nil {
                assert(delegate?.pjTabBarNumberOfItems() != nil && currentIndex <= (delegate?.pjTabBarNumberOfItems())! && currentIndex >= 0, "PJTabBar: currentIndex out of bounds")
                if let tabBarItem = self.items[currentIndex] {
                    tabBarItem.isSelect = true
                } else {
                    let tabBarItem = PJTabBarItem(title: delegate?.pjTabBar(self, pjTabBarItemAt: currentIndex))
                    tabBarItem.isSelect = true
                    self.items[currentIndex] = tabBarItem
                }
                
                for i in 0..<delegate!.pjTabBarNumberOfItems() {
                    let tabBarItem = PJTabBarItem(title: delegate?.pjTabBar(self, pjTabBarItemAt: i))
                    tabBarItem.isSelect = i == currentIndex
                    self.items[i] = tabBarItem
                }
                
                collectionView?.reloadData()
            }
        }
    }
    
    private static let kPJTabBarIdentifier = "PJTabBarViewCell"
    open var flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout() {
        didSet {
            self.collectionView.collectionViewLayout = flowLayout
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.reloadData()
        }
    }
    @IBInspectable open var collectionView: UICollectionView!
    @IBInspectable open var scrollBar: UIView!
    
    /// current select item source
    open var currentPhoneTabBarItem: PJTabBarItem?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initSubViews()
        self.initData()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initSubViews()
        self.initData()
    }
    
    public convenience init(frame: CGRect, tabBarOptions: PJPageOptions) {
        self.init(frame: frame)
        self.tabBarOptions = tabBarOptions
        self.flowLayout.minimumLineSpacing = tabBarOptions.minimumLineSpacing
        self.flowLayout.minimumInteritemSpacing = tabBarOptions.minimumInteritemSpacing
    }
    
    public convenience init(tabBarOptions: PJPageOptions) {
        self.init(frame: .zero)
        self.tabBarOptions = tabBarOptions
        self.flowLayout.minimumLineSpacing = tabBarOptions.minimumLineSpacing
        self.flowLayout.minimumInteritemSpacing = tabBarOptions.minimumInteritemSpacing
    }
    
    public convenience init() {
        self.init(frame: .zero)
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.initSubViews()
        self.initData()
    }
    
    /// init subViews
    private func initSubViews() {
        self.backgroundColor = .white
        flowLayout.scrollDirection = .horizontal
        flowLayout.sectionInset = self.tabBarOptions.sectionInset
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(PJTabBarCell.classForCoder(), forCellWithReuseIdentifier: PJTabBarView.kPJTabBarIdentifier)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = self.backgroundColor
        self.addSubview(collectionView)
        
        collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        if self.tabBarOptions.isNeedScrollBar {
            scrollBar = UIView()
            scrollBar.backgroundColor = self.tabBarOptions.scrollBarColor
            collectionView.addSubview(scrollBar)
        }
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func initData() {
        self.addObserver(self, forKeyPath: PJTabBarView.kPJTabBarViewWidthKeyPath, options: [.new, .old], context: nil)
    }
    
    private func setMinimumLineSpacing() {
        if self.tabBarOptions.isAutoSetMinimumLineSpacing {
            var totalWidth: CGFloat = 0.0
            var autoSetMinimumLineSpacingMaxCount = self.tabBarOptions.autoSetMinimumLineSpacingMaxCount
            if autoSetMinimumLineSpacingMaxCount <= 0 {
                self.tabBarOptions.autoSetMinimumLineSpacingMaxCount = 0
                flowLayout.minimumLineSpacing = self.tabBarOptions.minimumLineSpacing
            } else if let count = delegate?.pjTabBarNumberOfItems() {
                if autoSetMinimumLineSpacingMaxCount > count {
                    autoSetMinimumLineSpacingMaxCount = count
                }
                for i in 0..<autoSetMinimumLineSpacingMaxCount {
                    if let title = delegate?.pjTabBar(self, pjTabBarItemAt: i) {
                        var titleWidth = self.sizeForItem(title: title).width
                        if self.tabBarOptions.maxItemWidth > 0.0 {
                            if titleWidth > self.tabBarOptions.maxItemWidth {
                                titleWidth = self.tabBarOptions.maxItemWidth
                            }
                        }
                        totalWidth += titleWidth
                    }
                }
                
                var minimumLineSpacing = (self.frame.size.width - totalWidth - self.tabBarOptions.sectionInset.left - self.tabBarOptions.sectionInset.right) / CGFloat(autoSetMinimumLineSpacingMaxCount)
                if minimumLineSpacing < 0 {
                    print("⚠️: minimumLineSpacing is less than 0")
                    minimumLineSpacing = 0
                }
                self.tabBarOptions.minimumLineSpacing = minimumLineSpacing
                flowLayout.minimumLineSpacing = minimumLineSpacing
            } else {
                flowLayout.minimumLineSpacing = self.tabBarOptions.minimumLineSpacing
            }
        } else {
            flowLayout.minimumLineSpacing = self.tabBarOptions.minimumLineSpacing
        }
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: PJTabBarView.kPJTabBarViewWidthKeyPath)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == PJTabBarView.kPJTabBarViewWidthKeyPath {
            if self.lastWidth != self.frame.size.width {
                self.setMinimumLineSpacing()
                self.lastWidth = self.frame.size.width
            }
        }
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PJTabBarView.kPJTabBarIdentifier, for: indexPath) as? PJTabBarCell
        configCell(cell: cell!, indexPath: indexPath)
        return cell!
    }
    
    public func configCell(cell: PJTabBarCell, indexPath: IndexPath) {
        let pjTabBarItem = self.items[indexPath.row]
        pjTabBarItem?.tabBarOptions = self.tabBarOptions
        if let tabBarItem = pjTabBarItem {
            cell.pjTabBarItem = tabBarItem
        }
        
        if indexPath.row == currentIndex {
            self.setUpScrollBarPosition(atIndex: currentIndex)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt sizeForItemAtIndexPath: IndexPath) -> CGSize {
        if self.tabBarOptions.itemSize != CGSize.zero {
//            guard let title = delegate?.pjTabBar(self, pjTabBarItemAt: sizeForItemAtIndexPath.row) else {
//                return self.tabBarOptions.itemSize
//            }
//            // first time load sizeForItem
//            let pjTabBarItem = PJTabBarItem(title: title)
//            if currentIndex == sizeForItemAtIndexPath.row {
//                pjTabBarItem.isSelect = true
//            }
//            pjTabBarItem.cellSize = self.tabBarOptions.itemSize
//            self.items[sizeForItemAtIndexPath.row] = pjTabBarItem
            return self.tabBarOptions.itemSize
        }
        
        guard let title = delegate?.pjTabBar(self, pjTabBarItemAt: sizeForItemAtIndexPath.row) else {
            return .zero
        }
        
        if let pjTabBarItem = self.items[sizeForItemAtIndexPath.row] {
            if pjTabBarItem.cellSize == .zero || self.tabBarOptions.maxItemWidth > 0 {
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
        self.clickCellClosure?(self, indexPath.row)
        self.delegate?.pjTabBarWillChange?(self, fromIndex: currentIndex, toIndex: indexPath.row)
        self.scrollToItem(at: indexPath.row, at: self.tabBarOptions.scrollPosition)
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
    private func cellForItems(at indexPaths: [IndexPath], reloadIfNotVisible reload: Bool = true) -> [PJTabBarCell?] {
        let cells = indexPaths.map { collectionView.cellForItem(at: $0) as? PJTabBarCell }
        
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
    public func scrollToItem(at index: Int, at position: UICollectionViewScrollPosition = .centeredHorizontally) {
        assert(delegate?.pjTabBarNumberOfItems() != nil && index < (delegate?.pjTabBarNumberOfItems())!, "PJTabBar: index out of bounds ")
        
        if index == currentIndex {
            return
        }
        
        UIView.animate(withDuration: self.tabBarOptions.animationDuration) {
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
        
        if let oldSelectCell = cells.first as? PJTabBarCell {
            oldSelectCell.setSelected(selected: false)
        }
        
        //select new cell
        if let newTabBarItem = self.items[newIndexPath.row] {
            newTabBarItem.isSelect = true
            currentPhoneTabBarItem = newTabBarItem
        }
        
        if let newSelectCell = cells.last as? PJTabBarCell {
            newSelectCell.setSelected(selected: true)
        }
    }
    
    private func sizeForItem(title: String) -> CGSize {
        let width = title.boundingSizeBySize(CGSize(width: self.tabBarOptions.maxItemWidth == 0.0 ? CGFloat.greatestFiniteMagnitude : self.tabBarOptions.maxItemWidth, height: collectionView.frame.size.height), font: self.tabBarOptions.titleFont).width
        return CGSize(width: width + self.tabBarOptions.leftPadding + self.tabBarOptions.rightPadding, height: collectionView.frame.size.height)
    }
}

//MARK: PhoneTabBar set
public extension PJTabBarView {
    
    /// reload all Items
    public func reloadData() {
        collectionView.reloadData()
    }
    
    /// reload Items at index
    public func reloadItems(at indexPaths: [IndexPath]) {
        collectionView.reloadItems(at: indexPaths)
    }
    
    /// set item title at index
    ///
    /// - Parameters:
    ///   - title: new title for item at index
    ///   - atIndex: at index
    public func setTitle(title: String, atIndex: Int) {
        assert(delegate?.pjTabBarNumberOfItems() != nil && atIndex < (delegate?.pjTabBarNumberOfItems())!, "PJTabBar: atIndex out of bounds")
        let pjTabBarItem = self.items[atIndex]
        pjTabBarItem?.title = title
        pjTabBarItem?.cellSize = self.sizeForItem(title: title)
        collectionView?.reloadItems(at: [IndexPath(row: atIndex, section: 0)])
        if currentIndex == atIndex {
            setUpScrollBarPosition(atIndex: atIndex)
        }
    }
    
    private func setUpScrollBarPosition(atIndex: Int) {
        if !self.tabBarOptions.isNeedScrollBar {
            return
        }
        if let attr = collectionView?.layoutAttributesForItem(at: IndexPath(row: atIndex, section: 0)), let title = delegate?.pjTabBar(self, pjTabBarItemAt: atIndex), let pjTabBarItem = self.items[atIndex] {
            
            var scrollBarWidth: CGFloat = pjTabBarItem.cellSize.width
            if scrollBarWidth == 0.0 {
                pjTabBarItem.cellSize = sizeForItem(title: title)
                scrollBarWidth = pjTabBarItem.cellSize.width
            }
            if self.tabBarOptions.scrollBarConstWidth != 0.0 {
                scrollBarWidth = self.tabBarOptions.scrollBarConstWidth
            }
            scrollBarWidth = scrollBarWidth - self.tabBarOptions.leftPadding - self.tabBarOptions.rightPadding
            if scrollBarWidth > attr.frame.size.width {
                scrollBarWidth = attr.frame.size.width
            }
            self.scrollBar.frame.size = CGSize(width: scrollBarWidth, height: self.tabBarOptions.scrollBarHeigth)
            let scrollBarY = collectionView.frame.size.height - self.scrollBar.frame.size.height
            let scrollBarCenterX = self.tabBarOptions.leftPadding + (attr.bounds.size.width - self.tabBarOptions.leftPadding - self.tabBarOptions.rightPadding) / 2.0
            self.scrollBar.center = CGPoint(x: attr.frame.origin.x + scrollBarCenterX, y: scrollBarY)
        }
    }
    
    /// rolling scrollBar when switching
    public func moveScrollBar(fromIndex: Int, toIndex: Int, progressPercentage: CGFloat) {
        
        if !self.tabBarOptions.isNeedScrollBar {
            return
        }
//        self.currentIndex = progressPercentage > 0.5 ? toIndex : fromIndex

        let cells = cellForItems(at: [IndexPath(row: fromIndex, section: 0), IndexPath(row: toIndex, section: 0)], reloadIfNotVisible: true)
        
        guard let numberOfItems = self.collectionView.dataSource?.collectionView(self.collectionView, numberOfItemsInSection: 0), let fromFrame = self.collectionView.layoutAttributesForItem(at: IndexPath(item: fromIndex, section: 0))?.frame, cells.count == 2, let fromCell = cells.first as? PJTabBarCell, let toCell = cells.last as? PJTabBarCell else {
            return
        }

        ///change title color by progressPercentage
        var narR: CGFloat = 0, narG: CGFloat = 0, narB: CGFloat = 0, narA: CGFloat = 1
        self.tabBarOptions.titleColor.getRed(&narR, green: &narG, blue: &narB, alpha: &narA)
        var selR: CGFloat = 0, selG: CGFloat = 0, selB: CGFloat = 0, selA: CGFloat = 1
        self.tabBarOptions.titleSelectedColor.getRed(&selR, green: &selG, blue: &selB, alpha: &selA)
        let detalR = narR - selR , detalG = narG - selG, detalB = narB - selB, detalA = narA - selA
        fromCell.titleLabel.textColor = UIColor(red: selR + detalR * progressPercentage, green: selG + detalG * progressPercentage, blue: selB + detalB * progressPercentage, alpha: selA + detalA * progressPercentage)
        toCell.titleLabel.textColor = UIColor(red: narR - detalR * progressPercentage, green: narG - detalG * progressPercentage, blue: narB - detalB * progressPercentage, alpha: narA - detalA * progressPercentage)
        
        var toFrame: CGRect

        if toIndex < 0 || toIndex > numberOfItems - 1 {
            if toIndex < 0 {
                if let tempcellAtts = self.collectionView.layoutAttributesForItem(at: IndexPath(item: 0, section: 0)) {
                    toFrame = tempcellAtts.frame.offsetBy(dx: -tempcellAtts.frame.size.width, dy: 0)
                } else {
                    return
                }
            } else {
                if let tempcellAtts = self.collectionView.layoutAttributesForItem(at: IndexPath(item: (numberOfItems - 1), section: 0)) {
                    toFrame = tempcellAtts.frame.offsetBy(dx: tempcellAtts.frame.size.width, dy: 0)
                } else {
                    return
                }
            }
        } else {
            if let tempFrame = self.collectionView.layoutAttributesForItem(at: IndexPath(item: toIndex, section: 0))?.frame {
                toFrame = tempFrame
            } else {
                return
            }
        }

        var targetFrame = fromFrame
        targetFrame.size.height = self.scrollBar.frame.size.height
        targetFrame.size.width += (toFrame.size.width - fromFrame.size.width) * progressPercentage
        
        if self.tabBarOptions.scrollBarConstWidth != 0.0 {
            targetFrame.size.width = self.tabBarOptions.scrollBarConstWidth
        } else if self.tabBarOptions.maxItemWidth > 0, targetFrame.size.width > self.tabBarOptions.maxItemWidth {
            targetFrame.size.width = self.tabBarOptions.maxItemWidth
        } else if targetFrame.size.width > toFrame.size.width {
            targetFrame.size.width = toFrame.size.width
        }
        
        let toFrameCenterX = toFrame.origin.x + self.tabBarOptions.leftPadding + (toFrame.size.width - self.tabBarOptions.leftPadding - self.tabBarOptions.rightPadding) / 2.0
        
        let fromFrameCenterX = fromFrame.origin.x + self.tabBarOptions.leftPadding + (fromFrame.size.width - self.tabBarOptions.leftPadding - self.tabBarOptions.rightPadding) / 2.0
        
        self.scrollBar.center = CGPoint(x: fromFrameCenterX + (toFrameCenterX - fromFrameCenterX) * progressPercentage, y: self.scrollBar.center.y)
        self.scrollBar.frame.size.width = targetFrame.size.width
        
//        targetFrame.origin.x += (toFrame.origin.x - fromFrame.origin.x) * progressPercentage

//        self.scrollBar.frame = CGRect(x: targetFrame.origin.x, y: self.scrollBar.frame.origin.y, width: targetFrame.size.width, height: self.scrollBar.frame.size.height)

        var targetContentOffset: CGFloat = 0.0
        if self.collectionView.contentSize.width > self.frame.size.width {
            let toContentOffset = contentOffsetForCell(withFrame: toFrame, andIndex: toIndex)
            let fromContentOffset = contentOffsetForCell(withFrame: fromFrame, andIndex: fromIndex)

            targetContentOffset = fromContentOffset + ((toContentOffset - fromContentOffset) * progressPercentage)
        }

        self.collectionView.setContentOffset(CGPoint(x: targetContentOffset, y: 0), animated: false)
    }
    
    private func contentOffsetForCell(withFrame cellFrame: CGRect, andIndex index: Int) -> CGFloat {
        let alignmentOffset = (frame.size.width - cellFrame.size.width) * 0.5
        var contentOffset = cellFrame.origin.x - alignmentOffset
        contentOffset = max(0, contentOffset)
        contentOffset = min(self.collectionView.contentSize.width - frame.size.width, contentOffset)
        return contentOffset
    }
}
