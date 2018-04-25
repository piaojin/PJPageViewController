//
//  PhoneTabBar.swift
//  Glip
//
//  Created by Zoey Weng on 2017/10/26.
//  Copyright © 2017年 RingCentral. All rights reserved.
//

import UIKit

//custom cell protocol
public protocol PJTabBarViewCellProtocol: NSObjectProtocol {
    ///this is important for PJTabBarView to set data to each cell
    var pjTabBarItem: PJTabBarItem {set get}
}

@objc public protocol PJTabBarViewDelegate: NSObjectProtocol {
    @objc optional func pjTabBarDidChange(_ pjTabBarView: PJTabBarView, fromIndex: Int, toIndex: Int)
    
    @objc optional func pjTabBarWillChange(_ pjTabBarView: PJTabBarView, fromIndex: Int, toIndex: Int)
    
    func pjTabBarNumberOfItems() -> Int
    
    func pjTabBar(_ pjTabBarView: PJTabBarView, pjTabBarItemAt index: Int) -> String
    
    ///this is important for PJTabBarView to create a new cell, if you want set custom cell.
    @objc optional func tabBarCellIdentifier() -> String
    ///this is important for PJTabBarView to register a new type of cell, if you want set custom cell. Remember to implement PJTabBarViewCellProtocol for yoor custom cell.
    @objc optional func customCellClass() -> UICollectionViewCell.Type
}

@IBDesignable
open class PJTabBarView: UIView {
    
    private static let kPJTabBarIdentifier = "PJTabBarViewCell"
    
    open var clickCellClosure: ((PJTabBarView, Int) -> ())?
    
    open var items: [Int : PJTabBarItem] = [:]
    
    open var tabBarOptions: PJPageOptions = PJPageOptions()
    
    open override var backgroundColor: UIColor? {
        get {
            return super.backgroundColor
        }
        set {
            super.backgroundColor = newValue
            if self.collectionView != nil {
                self.collectionView.backgroundColor = newValue
            }
        }
    }
    
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
    
    /// the size of cell
    @IBInspectable open var itemSize: CGSize = .zero {
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
    
    @IBInspectable open var sectionInset: UIEdgeInsets = .zero {
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
                assert(delegate?.pjTabBarNumberOfItems() != nil && (delegate?.pjTabBarNumberOfItems())! > 0 && currentIndex <= (delegate?.pjTabBarNumberOfItems())! && currentIndex >= 0, "PJTabBar: currentIndex out of bounds")
                if let tabBarItem = self.items[currentIndex] {
                    tabBarItem.isSelect = true
                } else {
                    let tabBarItem = PJTabBarItem(title: delegate?.pjTabBar(self, pjTabBarItemAt: currentIndex))
                    tabBarItem.isSelect = true
                    self.items[currentIndex] = tabBarItem
                }
                
                collectionView?.reloadData()
            }
        }
    }
    
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
    
    public init(tabBarOptions: PJPageOptions) {
        super.init(frame: .zero)
        self.tabBarOptions = tabBarOptions
        self.initSubViews()
        self.initData()
    }
    
    public init(frame: CGRect, tabBarOptions: PJPageOptions) {
        super.init(frame: frame)
        self.tabBarOptions = tabBarOptions
        self.initSubViews()
        self.initData()
    }
    
    public convenience init() {
        self.init(tabBarOptions: PJPageOptions())
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
        
        if self.tabBarOptions.isAutoSetMinimumInteritemSpacing {
            self.setMinimumInteritemSpacing()
        } else {
            self.flowLayout.minimumInteritemSpacing = self.tabBarOptions.minimumInteritemSpacing
        }
    }
    
    private func initData() {
        //register custom cell if has
        if let cellClass = self.delegate?.customCellClass?(), let tabBarCellIdentifier = self.delegate?.tabBarCellIdentifier?() {
            self.collectionView.register(cellClass, forCellWithReuseIdentifier: tabBarCellIdentifier)
        } else {
            self.collectionView.register(PJTabBarCell.classForCoder(), forCellWithReuseIdentifier: PJTabBarView.kPJTabBarIdentifier)
        }
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    private func setMinimumInteritemSpacing() {
        if self.tabBarOptions.isAutoSetMinimumInteritemSpacing {
            var totalWidth: CGFloat = 0.0
            var autoSetMinimumInteritemSpacingMaxCount = self.tabBarOptions.autoSetMinimumInteritemSpacingMaxCount
            if autoSetMinimumInteritemSpacingMaxCount <= 0 {
                self.tabBarOptions.autoSetMinimumInteritemSpacingMaxCount = 0
                flowLayout.minimumInteritemSpacing = self.minimumInteritemSpacing
            } else if let count = delegate?.pjTabBarNumberOfItems() {
                if autoSetMinimumInteritemSpacingMaxCount > count {
                    autoSetMinimumInteritemSpacingMaxCount = count
                }
                for i in 0..<autoSetMinimumInteritemSpacingMaxCount {
                    if let title = delegate?.pjTabBar(self, pjTabBarItemAt: i) {
                        var titleWidth = self.sizeForItem(title: title).width
                        if self.tabBarOptions.maxItemWidth > 0.0 {
                            if titleWidth > self.tabBarOptions.maxItemWidth {
                                titleWidth = self.tabBarOptions.maxItemWidth
                            }
                        }
                        totalWidth += titleWidth + self.tabBarOptions.leftPadding + self.tabBarOptions.rightPadding
                    }
                }
                
                assert(autoSetMinimumInteritemSpacingMaxCount - 1 >= 0, "autoSetMinimumInteritemSpacingMaxCount must > 0")
                
                if autoSetMinimumInteritemSpacingMaxCount > 1 {
                    var minimumInteritemSpacing = (self.frame.size.width - totalWidth - self.tabBarOptions.sectionInset.left - self.tabBarOptions.sectionInset.right) / CGFloat(autoSetMinimumInteritemSpacingMaxCount - 1)
                    if minimumInteritemSpacing < 0 {
                        print("⚠️: minimumInteritemSpacing is less than 0")
                        minimumInteritemSpacing = 0
                    }
                    self.tabBarOptions.minimumInteritemSpacing = minimumInteritemSpacing
                    flowLayout.minimumInteritemSpacing = self.tabBarOptions.minimumInteritemSpacing
                } else {
                    print("⚠️: autoSetMinimumInteritemSpacingMaxCount is less than 2")
                }
            } else {
                flowLayout.minimumInteritemSpacing = self.tabBarOptions.minimumInteritemSpacing
            }
        } else {
            flowLayout.minimumInteritemSpacing = self.tabBarOptions.minimumInteritemSpacing
        }
    }
    
    ///auto set minimumLineSpacing(Rotating screen). The number of calls is acceptable.
    open override func layoutSubviews() {
        super.layoutSubviews()
        ///set some default value
        self.setMinimumInteritemSpacing()
        self.collectionView.scrollToItem(at: IndexPath(row: self.currentIndex, section: 0), at: self.tabBarOptions.scrollPosition, animated: true)
        self.setUpScrollBarPosition(atIndex: self.currentIndex)
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
        if let delegate = self.delegate {
            var identifier = PJTabBarView.kPJTabBarIdentifier
            if let tabBarCellIdentifier = delegate.tabBarCellIdentifier?() {
                identifier = tabBarCellIdentifier
            }
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
            configCell(cell: cell, indexPath: indexPath)
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    public func configCell(cell: UICollectionViewCell, indexPath: IndexPath) {
        let pjTabBarItem = self.itemAt(index: indexPath.row)
        pjTabBarItem.tabBarOptions = self.tabBarOptions
        if let tempCell = cell as? PJTabBarViewCellProtocol {
             tempCell.pjTabBarItem = pjTabBarItem
        }
        self.items[indexPath.row] = pjTabBarItem
        
        if indexPath.row == currentIndex {
            self.setUpScrollBarPosition(atIndex: currentIndex)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt sizeForItemAtIndexPath: IndexPath) -> CGSize {
        if self.tabBarOptions.itemSize != CGSize.zero {
            guard let title = delegate?.pjTabBar(self, pjTabBarItemAt: sizeForItemAtIndexPath.row) else {
                return self.tabBarOptions.itemSize
            }
            // first time load sizeForItem
            let pjTabBarItem = PJTabBarItem(title: title)
            if currentIndex == sizeForItemAtIndexPath.row {
                pjTabBarItem.isSelect = true
            }
            pjTabBarItem.cellSize = self.tabBarOptions.itemSize
            self.items[sizeForItemAtIndexPath.row] = pjTabBarItem
            return self.tabBarOptions.itemSize
        }
        
        guard let title = delegate?.pjTabBar(self, pjTabBarItemAt: sizeForItemAtIndexPath.row) else {
            return .zero
        }
        
        if let pjTabBarItem = self.items[sizeForItemAtIndexPath.row] {
            if pjTabBarItem.cellSize.width == 0.0 || pjTabBarItem.cellSize.height == 0.0 || self.tabBarOptions.maxItemWidth > 0.0 {
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
    
    private func itemAt(index: Int) -> PJTabBarItem {
        if let pjTabBarItem = self.items[index] {
            return pjTabBarItem
        } else {
            // first time load PJTabBarItem
            let title = self.delegate?.pjTabBar(self, pjTabBarItemAt: index)
            let pjTabBarItem = PJTabBarItem(title: title)
            if currentIndex == index {
                pjTabBarItem.isSelect = true
            }
            return pjTabBarItem
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
                .compactMap { (arg) -> IndexPath? in
                    let (index, cell) = arg
                    return cell == nil ? indexPaths[index] : nil
                }
                .compactMap { (indexPath: IndexPath) -> IndexPath? in
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
            let scrollBarY = collectionView.frame.size.height - self.scrollBar.frame.size.height / 2.0
            let scrollBarCenterX = self.tabBarOptions.leftPadding + (attr.bounds.size.width - self.tabBarOptions.leftPadding - self.tabBarOptions.rightPadding) / 2.0
            self.scrollBar.center = CGPoint(x: attr.frame.origin.x + scrollBarCenterX, y: scrollBarY)
        }
    }
    
    /// rolling scrollBar when switching
    public func moveScrollBar(fromIndex: Int, toIndex: Int, progressPercentage: CGFloat) {
        
        if !self.tabBarOptions.isNeedScrollBar {
            return
        }
        
        if !self.tabBarOptions.isScrollBarLinkScrollWhenMovePage {
            if progressPercentage >= 1.0 {
                UIView.animate(withDuration: self.tabBarOptions.animationDuration) {
                    self.setUpScrollBarPosition(atIndex: toIndex)
                }
            }
            return
        }
        
        let cells = cellForItems(at: [IndexPath(row: fromIndex, section: 0), IndexPath(row: toIndex, section: 0)], reloadIfNotVisible: true)
        
        guard let numberOfItems = self.collectionView.dataSource?.collectionView(self.collectionView, numberOfItemsInSection: 0), let fromFrame = self.collectionView.layoutAttributesForItem(at: IndexPath(item: fromIndex, section: 0))?.frame, cells.count == 2, let fromCell = cells.first as? PJTabBarCell, let toCell = cells.last as? PJTabBarCell else {
            return
        }

        if self.tabBarOptions.isTitleGradient {
            //change title color by progressPercentage
            var narR: CGFloat = 0, narG: CGFloat = 0, narB: CGFloat = 0, narA: CGFloat = 1
            self.tabBarOptions.titleColor.getRed(&narR, green: &narG, blue: &narB, alpha: &narA)
            var selR: CGFloat = 0, selG: CGFloat = 0, selB: CGFloat = 0, selA: CGFloat = 1
            self.tabBarOptions.titleSelectedColor.getRed(&selR, green: &selG, blue: &selB, alpha: &selA)
            let detalR = narR - selR , detalG = narG - selG, detalB = narB - selB, detalA = narA - selA
            fromCell.titleLabel.textColor = UIColor(red: selR + detalR * progressPercentage, green: selG + detalG * progressPercentage, blue: selB + detalB * progressPercentage, alpha: selA + detalA * progressPercentage)
            toCell.titleLabel.textColor = UIColor(red: narR - detalR * progressPercentage, green: narG - detalG * progressPercentage, blue: narB - detalB * progressPercentage, alpha: narA - detalA * progressPercentage)
        }
        
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
        
        if self.tabBarOptions.isScrollBarConstWidth {
            let toFrameCenterX = toFrame.origin.x + self.tabBarOptions.leftPadding + (toFrame.size.width - self.tabBarOptions.leftPadding - self.tabBarOptions.rightPadding) / 2.0
            
            let fromFrameCenterX = fromFrame.origin.x + self.tabBarOptions.leftPadding + (fromFrame.size.width - self.tabBarOptions.leftPadding - self.tabBarOptions.rightPadding) / 2.0
            
            self.scrollBar.center = CGPoint(x: fromFrameCenterX + (toFrameCenterX - fromFrameCenterX) * progressPercentage, y: self.scrollBar.center.y)
        } else {
            let maxScrollBarWidth = fromFrame.size.width - self.tabBarOptions.rightPadding + self.tabBarOptions.minimumInteritemSpacing - self.tabBarOptions.leftPadding + toFrame.size.width
            let maxSubScrollBarWidth = maxScrollBarWidth - toFrame.size.width + self.tabBarOptions.rightPadding + self.tabBarOptions.leftPadding
            switch self.tabBarOptions.moveScrollBarStyle {
            case .bounce:
                var progressX: CGFloat = 0.0
                var scrollBarWidth: CGFloat = self.scrollBar.frame.size.width
                if fromFrame.origin.x < toFrame.origin.x {
                    if progressPercentage <= 0.5 {
                        progressX = fromFrame.origin.x + self.tabBarOptions.leftPadding
                        scrollBarWidth = fromFrame.size.width - self.tabBarOptions.leftPadding - self.tabBarOptions.rightPadding + (self.tabBarOptions.minimumInteritemSpacing + toFrame.size.width) * 2 * progressPercentage
                    } else {
                        let subScrollBarWidth = maxScrollBarWidth - maxSubScrollBarWidth * (progressPercentage - 0.5) * 2
                        progressX = fromFrame.origin.x + maxScrollBarWidth - subScrollBarWidth + self.tabBarOptions.leftPadding
                        scrollBarWidth = subScrollBarWidth
                    }
                } else {
                    if progressPercentage <= 0.5 {
                        let subScrollBarWidth = (self.tabBarOptions.minimumInteritemSpacing + toFrame.size.width) * 2 * progressPercentage
                        scrollBarWidth = fromFrame.size.width + subScrollBarWidth - self.tabBarOptions.leftPadding - self.tabBarOptions.rightPadding
                        progressX = fromFrame.origin.x - (scrollBarWidth - fromFrame.size.width + self.tabBarOptions.rightPadding)
                    } else {
                        progressX = toFrame.origin.x + self.tabBarOptions.leftPadding
                        scrollBarWidth = maxScrollBarWidth - (maxScrollBarWidth - toFrame.size.width + self.tabBarOptions.leftPadding + self.tabBarOptions.rightPadding) * (progressPercentage - 0.5) * 2
                    }
                }
                
                self.scrollBar.frame = CGRect(x: progressX, y: self.scrollBar.frame.origin.y, width: scrollBarWidth, height: targetFrame.size.height)
                break
            case .elastic:                
                let toFrameCenterX = toFrame.origin.x + self.tabBarOptions.leftPadding + (toFrame.size.width - self.tabBarOptions.leftPadding - self.tabBarOptions.rightPadding) / 2.0
                
                let fromFrameCenterX = fromFrame.origin.x + self.tabBarOptions.leftPadding + (fromFrame.size.width - self.tabBarOptions.leftPadding - self.tabBarOptions.rightPadding) / 2.0
                
                self.scrollBar.center = CGPoint(x: fromFrameCenterX + (toFrameCenterX - fromFrameCenterX) * progressPercentage, y: self.scrollBar.center.y)
                
                var scrollBarWidth = fromCell.pjTabBarItem.titleWidth + (toCell.pjTabBarItem.titleWidth - fromCell.pjTabBarItem.titleWidth) * progressPercentage
                
                if self.tabBarOptions.maxItemWidth > 0, scrollBarWidth > self.tabBarOptions.maxItemWidth {
                    scrollBarWidth = self.tabBarOptions.maxItemWidth
                }
                
                self.scrollBar.frame.size.width = scrollBarWidth
                break
            }
        }
        
        if self.tabBarOptions.isTabBarCellLinkScrollWhenMoveScrollBar {
            var targetContentOffset: CGFloat = 0.0
            if self.collectionView.contentSize.width > self.frame.size.width {
                let toContentOffset = contentOffsetForCell(withFrame: toFrame, andIndex: toIndex)
                let fromContentOffset = contentOffsetForCell(withFrame: fromFrame, andIndex: fromIndex)
                
                targetContentOffset = fromContentOffset + ((toContentOffset - fromContentOffset) * progressPercentage)
            }
            
            self.collectionView.setContentOffset(CGPoint(x: targetContentOffset, y: 0), animated: false)
        }
    }
    
    private func contentOffsetForCell(withFrame cellFrame: CGRect, andIndex index: Int) -> CGFloat {
        let alignmentOffset = (frame.size.width - cellFrame.size.width) * 0.5
        var contentOffset = cellFrame.origin.x - alignmentOffset
        contentOffset = max(0, contentOffset)
        contentOffset = min(self.collectionView.contentSize.width - frame.size.width, contentOffset)
        return contentOffset
    }
}
