//
//  MenuItem.swift
//  PageControllerExample
//
//  Created by 郑小燕 on 2018/3/9.
//  Copyright © 2018年 郑小燕. All rights reserved.
//

import UIKit
class MenuItem: UILabel {
    ///设置rate，并刷新标题状态
    var rate: CGFloat = 0.0 {
        didSet {
            guard rate >= 0.0 && rate <= 1.0 else {
                return
            }
            let r = normalRed + (selectedRed - normalRed) * rate
            let g = normalGreen + (selectedGreen - normalGreen) * rate
            let b = normalBlue + (selectedBlue - normalBlue) * rate
            let a = normalAlpha + (selectedAlpha - normalAlpha) * rate
            self.textColor = UIColor(red: r, green: g, blue: b, alpha: a)
            let minScale: CGFloat = self.normalSize / self.selectedSize
            let trueScale = minScale + (1 - minScale) * rate
            self.transform = CGAffineTransform(scaleX: trueScale, y: trueScale)
        }
    }
    ///Normal状态的字体大小，默认大小为15
    var normalSize: CGFloat = 15
    ///Selected状态的字体大小，默认大小为18
    var selectedSize: CGFloat = 18
    ///Normal状态的字体颜色，默认为黑色
    var normalColor: UIColor = UIColor.black {
        didSet {
            normalColor.getRed(&normalRed, green: &normalGreen, blue: &normalBlue, alpha: &normalAlpha)
        }
    }
    ///Selected状态的字体颜色，默认为红色 (可动画)
    var selectedColor: UIColor = UIColor.black {
        didSet {
        self.selectedColor.getRed(&selectedRed, green: &selectedGreen, blue: &selectedBlue, alpha: &selectedAlpha)
        }
        
    }
    ///进度条的速度因数，默认 15，越小越快, 必须大于0
    lazy var speedFactor: CGFloat = 15.0
    weak var delegate: MenuItemDelegate?
    //选中状态
    var selected: Bool = false
    //MARK: - private var
    fileprivate var selectedRed: CGFloat = 0
    fileprivate var selectedGreen: CGFloat = 0
    fileprivate var selectedBlue: CGFloat = 0
    fileprivate var selectedAlpha: CGFloat = 0
    fileprivate var normalRed: CGFloat = 0
    fileprivate var normalGreen: CGFloat = 0
    fileprivate var normalBlue: CGFloat = 0
    fileprivate var normalAlpha: CGFloat = 0
    fileprivate var sign: Int = 0
    fileprivate var gap: CGFloat = 0
    fileprivate var step: CGFloat = 0
    fileprivate var link: CADisplayLink!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.numberOfLines = 0
        self.setupGestureRecognizer()
    }
    
    func setupGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(touchUpInside(_:)))
        self.addGestureRecognizer(tap)
        
    }
    
    @objc func touchUpInside(_ sender: UITapGestureRecognizer)  {
        self.delegate?.didPressedMenuItem(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSelected(_ selected: Bool, animation: Bool) {
        self.selected = selected
        guard animation else {
            self.rate = selected ? 1.0 : 0.0
            return
        }
        sign = (selected == true) ? 1 : -1
        gap = (selected == true) ? (1.0 - rate) : (rate - 0.0)
        step = gap / speedFactor
        
        if link != nil {
            link.remove(from: .main, forMode: .commonModes)
        }
        let displayLink = CADisplayLink(target: self, selector: #selector(rateChange))
        displayLink.add(to: RunLoop.main, forMode: .commonModes)
        link = displayLink
        
    }
    
    @objc func rateChange() {
        if gap > 0.000001 {
            gap -= step
            guard gap >= 0 else {
                 self.rate = CGFloat(Int(self.rate + CGFloat(sign) * step + 0.5))
                return
            }
            self.rate += CGFloat(sign) * step
        } else {
            self.rate = CGFloat(Int(self.rate + 0.5))
            link.invalidate()
            link = nil
        }
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
