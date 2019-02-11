//
//  MenuView.swift
//  PageControllerExample
//
//  Created by 郑小燕 on 2018/3/9.
//  Copyright © 2018年 郑小燕. All rights reserved.
//

import UIKit


open class MenuView: UIView, MenuItemDelegate {
    //自定义进度条宽度
    open var progressWidths: [CGFloat] = [] {
        didSet {
            guard let _ = self.progressView else { return  }
            
            guard self.progressView?.superview != nil else {
                return
            }
            self.resetFramesFromIndex(inde: 0)
        }
    }
    
    var progressView: ProgressView?
    //进度条高度
    var progressHeight: CGFloat = -1
    //样式
    var style: MenuViewStyle = .default
    var layoutMode: MenuViewLayoutMode = .left {
        didSet {
            guard self.superview != nil else {
                return
            }
            self.reload()
        }
    }
    //边距
    var contentMargin: CGFloat = 0.0 {
        didSet {
            guard self.scrollView != nil else {
                return
            }
            self.resetFrames()
        }
    }
    //progressView进度条颜色
    lazy var lineColor: UIColor = self.colorForState(state: .selected, atIndex: 0)
    ///triangle,line有作用
    var progressViewBottomSpace: CGFloat = 0
    var delegate: MenuViewDelegate?
    var dataSource: MenuViewDataSource!
    var leftView: UIView? {
        willSet {
            leftView?.removeFromSuperview()
        }
        didSet {
            if let lView = leftView {
                self.addSubview(lView)
            }
            self.resetFrames()
        }
    }
    
    var rightView: UIView? {
        willSet {
            rightView?.removeFromSuperview()
        }
        didSet {
            if let rView = rightView {
                self.addSubview(rView)
            }
            self.resetFrames()
        }
    }
    var fontName: String?
    var scrollView: UIScrollView?
    /// 进度条的速度因数，默认为 15，越小越快， 大于 0
    public var speedFactor: CGFloat = 15.0 {
        didSet {
            if self.progressView != nil {
                self.progressView?.speedFactor = speedFactor
            }
            for (_, view) in (self.scrollView?.subviews.enumerated())! {
                if view is MenuItem {
                    let itemView = view as? MenuItem
                    itemView?.speedFactor = speedFactor
                }
            }
        }
    }
    
    var progressViewCornerRadius: CGFloat = -1
    var progressViewIsNaughty: Bool = false {
        didSet {
            guard self.progressView != nil else {
                return
            }
            self.progressView?.naughty = progressViewIsNaughty
        }
    }
    var showOnNavigationBar = false
    
    //filePrivate
    fileprivate var selItem: MenuItem?
    lazy var frames: [CGRect] = [CGRect]()
    fileprivate var selectIndex: Int = 0
    fileprivate var titlesCount: Int {
        return self.dataSource.numbersOfTitlesInMenuView(self)
    }
    fileprivate let WMMENUITEM_TAG_OFFSET = 6250
    fileprivate let WMBADGEVIEW_TAG_OFFSET = 1212
    fileprivate var _progressHeight: CGFloat {
        get {
            switch self.style {
            case .line:
                return getHeight(self.progressHeight)
            case .triangle:
                return getHeight(self.progressHeight)
            case .flood:
                return getHeight(self.progressHeight, CGFloat(ceil(self.frame.height * 0.8)))
            case .segmented:
                return getHeight(self.progressHeight, CGFloat(ceil(self.frame.height * 0.8)))
            case .floodHollow:
                return getHeight(self.progressHeight, CGFloat(ceil(self.frame.height * 0.8)))
            default:
                return self.progressHeight
            }
        }
        set {
            self._progressHeight = self.progressHeight
        }
    }
    fileprivate var _progressViewCornerRadius: CGFloat {
        set {
            if self.progressView != nil {
                self.progressView?.cornerRadius = self.getHeight(self.progressViewCornerRadius, _progressHeight / 2.0)
            }
        }
        get {
            return self.getHeight(self.progressViewCornerRadius, _progressHeight / 2.0)
        }
    }
    open override var frame: CGRect {
        didSet {
            guard self.scrollView != nil else {
                return
            }
            let leftMargin: CGFloat = (rightView == nil) ? contentMargin : contentMargin + rightView!.frame.width
            let rightMargin: CGFloat = (leftView == nil) ? contentMargin : contentMargin + leftView!.frame.width
            let contentWidth: CGFloat = (self.scrollView?.frame.width ?? 0) + leftMargin + rightMargin
            let startX: CGFloat = (self.leftView != nil) ? self.leftView!.frame.origin.x : (self.scrollView?.frame.origin.x ?? 0) - self.contentMargin
            // Make the contentView center, because system will change menuView's frame if it's a titleView.
            if startX + contentWidth / 2 != self.bounds.size.width / 2 {
                let xOffset: CGFloat = (self.bounds.size.width - contentWidth) / 2
                self.leftView?.frame = {
                    var frame = self.leftView?.frame
                    frame?.origin.x = xOffset
                    return frame ?? CGRect.zero
                }()
                
                self.scrollView?.frame = {
                    var frame = self.scrollView?.frame ?? CGRect.zero
                    frame.origin.x = (self.leftView != nil) ? (self.leftView?.frame.maxX)! + self.contentMargin : xOffset
                    return frame
                }()
                self.rightView?.frame = {
                    var frame = self.rightView?.frame
                    frame?.origin.x = (self.scrollView?.frame.maxX ?? 0) + self.contentMargin
                    return frame!
                }()
                
            }
        }
    }
    
    
    //MARK: Init
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Method
    public func slideMenuAtProgress(_ progress: CGFloat) {
        if self.progressView != nil {
            self.progressView?.progress = progress
        }
        let tag = Int(progress) + WMMENUITEM_TAG_OFFSET
        let rate: CGFloat = progress - CGFloat(tag) + CGFloat(WMMENUITEM_TAG_OFFSET)
        let currentItem = self.viewWithTag(tag) as? MenuItem
        let nextItem = self.viewWithTag(tag + 1) as? MenuItem
        if rate == 0.0 {
            self.selItem?.setSelected(false, animation: false)
            self.selItem = currentItem
            selItem?.setSelected(true, animation: false)
            self.refreshContenOffset()
            return
        }
        currentItem?.rate = 1.0 - rate
        nextItem?.rate = rate
        
        
        
        
    }
    
    func selectItemAtIndex(_ index: Int) {
        let tag = index + WMMENUITEM_TAG_OFFSET
        guard let _ = self.selItem else { return  }
        let currentIndex = (self.selItem?.tag)! - WMMENUITEM_TAG_OFFSET
        self.selectIndex = index
        guard index != currentIndex else{
            return
        }
        let item = self.viewWithTag(tag) as? MenuItem
        self.selItem?.setSelected(false, animation: false)
        self.selItem = item
        self.selItem?.setSelected(true, animation: false)
        //        self.progressView?.moveToPostion(index)
        self.progressView?.setProgressWithOutAnimate(CGFloat(index))
        //        delegate?.menuView?(self, didSelectedIndex: index, currentIndex)
        self.refreshContenOffset()
    }
    
    func resetFrames() {
        var frame = self.bounds
        if let rView = rightView {
            var rightFrame = rView.frame
            rightFrame.origin.x = frame.width - rightFrame.width
            rightView?.frame = rightFrame
            frame.size.width -= rightFrame.width
        }
        if let lView = leftView {
            var leftFrame = lView.frame
            leftFrame.origin.x = 0
            leftView?.frame = leftFrame
            frame.origin.x += leftFrame.width
            frame.size.width -= leftFrame.width
        }
        frame.origin.x += self.contentMargin
        frame.size.width -= self.contentMargin * 2
        self.scrollView?.frame = frame
        self.resetFramesFromIndex(inde: 0)
    }
    
    public func reload() {
        self.frames.removeAll()
        self.progressView?.removeFromSuperview()
        for (_, view) in (self.scrollView?.subviews.enumerated())! {
            view.removeFromSuperview()
        }
        self.addItems()
        self.makeStyle()
        self.addBadgeViews()
    }
    
    public func updateTitle(title: String, atIndex index: Int, andWidth update: Bool) {
        guard index < titlesCount && titlesCount > 0 else {
            return
        }
        let item = self.viewWithTag(WMMENUITEM_TAG_OFFSET + index) as? MenuItem
        item?.text = title
        guard update else {
            return
        }
        self.resetFrames()
    }
    
    public func updateAttributeTitle(title: NSAttributedString, atIndex index: Int, andWidth update: Bool) {
        guard index < self.titlesCount && index > 0 else {
            return
        }
        let item = self.viewWithTag(WMMENUITEM_TAG_OFFSET + index) as? MenuItem
        item?.attributedText = title
        guard update else {
            return
        }
        self.resetFrames()
        
    }
    
    func itemAtIndex(index: Int) -> MenuItem? {
        let view = self.viewWithTag(index + WMMENUITEM_TAG_OFFSET)
        return view as? MenuItem
    }
    
    /// 立即刷新 menuView 的 contentOffset，使 title 居中
    ///让选中的item位于中间
    func refreshContenOffset() {
        let frame = self.selItem?.frame
        let itemX = frame?.origin.x ?? 0
        let width = self.scrollView?.frame.size.width ?? 0
        let contentSize = self.scrollView?.contentSize ?? CGSize.zero
        if itemX > width / 2 {
            var targetX : CGFloat = 0
            if (contentSize.width - itemX) <= width / 2 {
                targetX = contentSize.width - width
            } else {
                targetX = (frame?.origin.x)! - width / 2 + (frame?.size.width)! / 2
            }
            //应该有更好的解决办法
            if targetX + width > contentSize.width {
                targetX = contentSize.width - width
            }
            self.scrollView?.setContentOffset(CGPoint(x: targetX, y: 0), animated: true)
            
        } else {
            self.scrollView?.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
    
    public func deselectedItemsIfNeeded() {
        for (_, view) in (self.scrollView?.subviews.enumerated())! {
            guard view is MenuItem, view != self.selItem else {
                return
            }
            let subView = view as? MenuItem
            subView?.setSelected(false, animation: false)
        }
        
    }
    
    public func updateBadgeViewAtIndex(index: Int) {
        let oldBadgeView = self.scrollView?.viewWithTag(WMBADGEVIEW_TAG_OFFSET + index)
        if oldBadgeView != nil {
            oldBadgeView?.removeFromSuperview()
        }
        self.addBadgeViewAtIndex(index)
        self.resetBadgeFrame(index)
    }
    
    //MARK: - filePrivateMethod
    func getHeight(_ newHeight: CGFloat? = 2.0, _ defaultHeight: CGFloat = 2) -> CGFloat {
        return (newHeight != -1) ? newHeight! : defaultHeight
    }
    fileprivate func colorForState(state: MenuItemState, atIndex index: Int) -> UIColor {
        if let color = self.delegate?.menuView?(self, titleColorForState: state, atIndex: index) {
            return color
        }
        return UIColor.black
    }
    
    fileprivate func resetFramesFromIndex(inde: Int) {
        self.frames.removeAll()
        self.calculateItemFrames()
        for i in 0..<self.titlesCount {
            self.resetItemFrame(i)
            self.resetBadgeFrame(i)
        }
        guard let _ = self.progressView  else {
            return
        }
        
        guard self.progressView?.superview != nil else {
            return
        }
        self.progressView?.frame = self.calculateProgressViewFrame()
        self.progressView?.cornerRadius = _progressViewCornerRadius
        self.progressView?.itemFrames = self.convertProgressWidthsToFrames()
        self.progressView?.setNeedsDisplay()
        
    }
    
    func convertProgressWidthsToFrames() -> [CGRect] {
        if self.frames.count == 0  {
            assert(false, "BUUUUUUUG...SHOULDN'T COME HERE!!")
        }
        if self.progressWidths.count < self.titlesCount {
            return self.frames
        }
        
        var progressFrames: [CGRect] = [CGRect]()
        let count = (self.frames.count <= self.progressWidths.count) ? self.frames.count : self.progressWidths.count
        for i in 0..<count {
            let itemFrame = self.frames[i]
            let progressWidth = self.progressWidths[i]
            let x = itemFrame.origin.x + (itemFrame.size.width - progressWidth) / 2
            let progressFrame = CGRect(x: x, y: itemFrame.origin.y, width: progressWidth, height: 0)
            progressFrames.append(progressFrame)
            
        }
        return progressFrames
    }
    
    fileprivate func calculateProgressViewFrame() -> CGRect {
        switch self.style {
        case .triangle:
            fallthrough
        case .line:
            return CGRect(x: 0, y: self.frame.height - _progressHeight - self.progressViewBottomSpace, width: (self.scrollView?.contentSize.width ?? 0), height: _progressHeight)
        case .floodHollow:
            fallthrough
        case .flood:
            fallthrough
        case .segmented:
            return CGRect(x:0, y:(self.frame.size.height - _progressHeight) / 2, width:(self.scrollView?.contentSize.width ?? 0), height:_progressHeight )
        default:
            return CGRect.zero
        }
    }
    
    /// 计算所有item的frame值，主要是为了适配所有item的宽度之和小于屏幕宽的情况
    fileprivate func calculateItemFrames() {
        var contentWidth: CGFloat = self.itemMarginAtIndex(0)
        for i in 0..<self.titlesCount {
            var itemW: CGFloat = 60.0
            itemW = (self.delegate?.menuView?(self, widthForItemAtIndex: i)) ?? 0
            let frame = CGRect(x: contentWidth, y: 0, width: itemW, height: self.frame.size.height)
            //记录frame
            self.frames.append(frame)
            contentWidth += itemW + self.itemMarginAtIndex(i + 1)
        }
        // 如果总宽度小于屏幕宽,重新计算frame,为item间添加间距
        if contentWidth < (self.scrollView?.frame.width ?? 0) {
            let distance = (self.scrollView?.frame.width ?? 0) - contentWidth
            var shiftDis: (_ index: Int) -> CGFloat
            switch self.layoutMode {
            case .scatter:
                let gap = distance / CGFloat(self.titlesCount + 1)
                shiftDis = {(index: Int) in
                    return gap * CGFloat(index + 1)
                }
            case .left:
                shiftDis = {(index: Int) in
                    return 0.0
                }
            case .right:
                shiftDis = {(index: Int) in
                    return distance
                }
            case .center:
                shiftDis = {(index: Int) in
                    return distance / 2
                }
            }
            for i in 0..<self.frames.count {
                var frame = self.frames[i]
                frame.origin.x += shiftDis(i)
                self.frames[i] = frame
            }
            contentWidth = self.scrollView?.frame.width ?? 0
        }
        self.scrollView?.contentSize = CGSize(width: contentWidth, height: self.frame.height)
        
    }
    
    fileprivate func itemMarginAtIndex(_ index: Int) -> CGFloat {
        if let itemMargin = self.delegate?.menuView?(self, itemMarginAtIndex: index) {
            return itemMargin
        }
        return 0.0
        
    }
    
    fileprivate func resetBadgeFrame(_ index: Int) {
        let frame = self.frames[index]
        let view = self.scrollView?.viewWithTag(WMBADGEVIEW_TAG_OFFSET + index)
        if let badgeView = view {
            var badgeFrame = self.badgeViewAtIndex(index)?.frame
            badgeFrame?.origin.x += frame.origin.x
            badgeView.frame = badgeFrame ?? CGRect.zero
        }
    }
    
    fileprivate func badgeViewAtIndex(_ index: Int) -> UIView? {
        
        if let badgeView = self.dataSource.menuView?(self, badgeViewAtIndex: index) {
            badgeView.tag = index + WMBADGEVIEW_TAG_OFFSET
            return badgeView
        } else {
            return nil
        }
        
    }
    
    fileprivate func resetItemFrame(_ index: Int) {
        let item = self.viewWithTag(WMMENUITEM_TAG_OFFSET + index)
        if let menuItem = item as? MenuItem {
            let frame = self.frames[index]
            menuItem.frame = frame
            self.delegate?.menuView?(self, didLayoutItemFrame: menuItem, atIndex: index)
        }
    }
    
    fileprivate func sizeForState(_ state: MenuItemState, atIndex index: Int) -> CGFloat {
        
        if let size = self.delegate?.menuView?(self, titleSizeForState: state, atIndex: index) {
            return size
        }
        return 15.0
    }
    
    func updateAttributeTitle(_ title: NSAttributedString, _ index: Int, _ update: Bool) {
        guard index < self.titlesCount && index > 0 else {
            return
        }
        let item = self.viewWithTag(WMMENUITEM_TAG_OFFSET + index) as? MenuItem
        item?.attributedText = title
        guard update else {
            return
        }
        self.resetFrames()
        
        
        
    }
    
    func addItems() {
        self.calculateItemFrames()
        for i in 0..<self.titlesCount {
            let frame = self.frames[i]
            var item = MenuItem(frame: frame)
            item.tag = i + WMMENUITEM_TAG_OFFSET
            item.delegate = self
            item.text = self.dataSource.menuView(self, titleAtIndex: i)
            item.textAlignment = .center
            item.isUserInteractionEnabled = true
            item.backgroundColor = UIColor.clear
            item.normalSize = self.sizeForState(.normal, atIndex: i)
            item.selectedSize = self.sizeForState(.selected, atIndex: i)
            item.normalColor = self.colorForState(state: .normal, atIndex: i)
            item.selectedColor = self.colorForState(state: .selected, atIndex: i)
            item.speedFactor = self.speedFactor
            if let fontNameValue = self.fontName {
                item.font = UIFont(name: fontNameValue, size: item.selectedSize)
            } else {
                item.font = UIFont.systemFont(ofSize: item.selectedSize)
            }
            
            if let newItem = self.dataSource.menuView?(self, initialMenuItem: item, atIndex: i) {
                item = newItem
            }
            
            if i == 0 {
                item.setSelected(true, animation: false)
                self.selItem = item
            } else {
                item.setSelected(false, animation: false)
            }
            self.scrollView?.addSubview(item)
            
        }
    }
    
    fileprivate func makeStyle(){
        let frame = self.calculateProgressViewFrame()
        guard frame != CGRect.zero else {
            return
        }
        self.addProgressViewWithFrame(frame, self.style == .triangle, self.style == .segmented, self.style == .floodHollow, _progressViewCornerRadius )
        
    }
    
    fileprivate func addBadgeViews() {
        for i in 0..<titlesCount {
            self.addBadgeViewAtIndex(i)
        }
    }
    
    fileprivate func addBadgeViewAtIndex(_ index: Int) {
        
        if let badgeView = self.badgeViewAtIndex(index) {
            self.scrollView?.addSubview(badgeView)
        }
        
    }
    
    
    
    //MARK: - Progress View
    fileprivate func addProgressViewWithFrame(_ frame: CGRect, _ isTriangle: Bool = false, _ hasBorder: Bool = false, _ isHollow: Bool = false, _ cornerRadius: CGFloat = 0.0) {
        let pView = ProgressView(frame: frame)
        pView.itemFrames = self.convertProgressWidthsToFrames()
        pView.color = self.lineColor.cgColor
        pView.isTriangle = isTriangle
        pView.hasBorder = hasBorder
        pView.hollow = isHollow
        pView.cornerRadius = cornerRadius
        pView.naughty = self.progressViewIsNaughty
        pView.speedFactor = self.speedFactor
        pView.backgroundColor = UIColor.clear
        self.progressView = pView
        self.scrollView?.insertSubview(self.progressView!, at: 0)
        
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        guard self.scrollView == nil else {
            return
        }
        self.addScrollView()
        self.addItems()
        self.makeStyle()
        self.addBadgeViews()
        self.resetSelectionIfNeeded()
        
    }
    
    fileprivate func addScrollView() {
        let width = self.frame.width - (self.contentMargin ) * 2
        let height = self.frame.height
        let frameS = CGRect(x: self.contentMargin , y: 0, width: width, height: height)
        let scrollView = UIScrollView(frame: frameS)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = UIColor.clear
        scrollView.scrollsToTop = false
        self.addSubview(scrollView)
        self.scrollView = scrollView
    }
    
    fileprivate func resetSelectionIfNeeded() {
        guard self.selectIndex != 0 else {
            return
        }
        self.selectItemAtIndex(self.selectIndex)
    }
    
    //MARK: - MenuItemDelegate
    func didPressedMenuItem(_ menuItem: MenuItem) {
        if let should = self.delegate?.menuView?(self, shouldSelesctedIndex: menuItem.tag - WMMENUITEM_TAG_OFFSET) {
            guard should else {
                return
            }
        }
        let progress = menuItem.tag - WMMENUITEM_TAG_OFFSET
        guard let _ = self.selItem else { return }
        let currentIndex = (self.selItem?.tag)! - WMMENUITEM_TAG_OFFSET
        self.progressView?.moveToPostion(progress)
        self.delegate?.menuView?(self, didSelectedIndex: progress, currentIndex)
        self.selItem?.setSelected(false, animation: true)
        menuItem.setSelected(true, animation: true)
        self.selItem = menuItem
        self.refreshContenOffset()
    }
    
    
    
    
    
    
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
