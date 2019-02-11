//
//  ProgressView.swift
//  PageControllerExample
//
//  Created by 郑小燕 on 2018/3/9.
//  Copyright © 2018年 郑小燕. All rights reserved.
//

import UIKit

class ProgressView: UIView {
     var itemFrames: [CGRect] = [CGRect]()
     var color: CGColor = UIColor.black.cgColor
     var progress: CGFloat = 0.0 {
        didSet {
            guard progress != oldValue else {
                return
            }
          setNeedsDisplay()
        }
    }
    ///进度条的速度因数，默认为 15，越小越快， 大于 0
    var speedFactor: CGFloat = 15.0
     var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    ///调皮属性，用于实现新腾讯视频效果
     var naughty: Bool = false {
        didSet {
            self.setNeedsDisplay()
        }
    }
     var isTriangle: Bool = false
     var hollow: Bool = false
     var hasBorder: Bool = false
    
    
    fileprivate var sign: Int = 1
    fileprivate var gap: CGFloat = 0
    fileprivate var step: CGFloat = 0
    weak fileprivate var link: CADisplayLink!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required  init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setProgressWithOutAnimate(_ progress: CGFloat) {
        guard self.progress != progress else {
            return
        }
        self.progress = progress
        self.setNeedsDisplay()
    }
    
    func moveToPostion(_ pos: Int) {
        gap = CGFloat(fabs(Double(self.progress - CGFloat(pos))))
        sign = self.progress > CGFloat(pos) ? -1 : 1
        step = gap / self.speedFactor
        if link != nil {
            link.remove(from: .main, forMode: .commonModes)
        }
        let displayLink = CADisplayLink(target: self, selector: #selector(progressChanged))
        displayLink.add(to: RunLoop.main, forMode: .commonModes)
        link = displayLink
    }
    
    @objc func progressChanged() {
        if gap > 0.000001 {
            gap -= step
            if gap < 0.0 {
                self.progress = CGFloat(Int(self.progress + CGFloat(sign) * step + 0.5))
                return
            }
            self.progress += CGFloat(sign) * step
        } else {
            self.progress = CGFloat(Int(self.progress + 0.5))
            link.invalidate()
            link = nil
        }
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        let ctx = UIGraphicsGetCurrentContext()
        let height = self.frame.height
        var index = Int(self.progress)
        index = (index <= self.itemFrames.count - 1) ? index : self.itemFrames.count - 1
        let rate = self.progress - CGFloat(index)
        let currentFrame = self.itemFrames[index]
        let currentWidth = currentFrame.width
        let nextIndex: Int = index + 1 < self.itemFrames.count ? index + 1 : index
        let nextWidth = self.itemFrames[nextIndex].width
        let currentX = currentFrame.origin.x
        let nextX = self.itemFrames[nextIndex].origin.x
        var startX = currentX + (nextX - currentX) * rate
        var width = currentWidth + (nextWidth - currentWidth)*rate
        var endX = startX + width
        if self.naughty {
            let currentMidX = currentX + currentWidth / 2.0
            let nextMidX = nextX + nextWidth / 2.0
            if rate <= 0.5 {
                startX = currentX + (currentMidX - currentX) * rate * 2.0
                let currentMaxX = currentX + currentWidth
                endX = currentMaxX + (nextMidX - currentMaxX) * rate * 2.0
            } else {
                startX = currentMidX + (nextX - currentMidX) * (rate - 0.5) * 2.0;
                let nextMaxX = nextX + nextWidth;
                endX = nextMidX + (nextMaxX - nextMidX) * (rate - 0.5) * 2.0;
            }
            width = endX - startX
        }
        let lineWidth: CGFloat = (self.hollow || self.hasBorder) ? 1.0 : 0.0
        if self.isTriangle {
            ctx?.move(to: CGPoint(x: startX, y: height))
            ctx?.addLine(to: CGPoint(x: endX, y: height))
            ctx?.addLine(to: CGPoint(x: startX + width / 2.0, y: 0))
            ctx?.closePath()
            ctx?.setFillColor(self.color)
            ctx?.fillPath()
            return
        }
        
        let path = UIBezierPath(roundedRect: CGRect(x: startX, y: lineWidth / 2.0, width: width, height: height - lineWidth), cornerRadius: self.cornerRadius)
        ctx?.addPath(path.cgPath)
        if self.hollow {
            ctx?.setStrokeColor(self.color)
            ctx?.strokePath()
            return
        }
        ctx?.setFillColor(self.color)
        ctx?.fillPath()
        if self.hasBorder {
            let startX = self.itemFrames.first?.minX ?? 0
            let endX = self.itemFrames.last?.maxX ?? 0
            let path = UIBezierPath(roundedRect: CGRect(x: startX, y: lineWidth / 2.0, width: (endX - startX), height: height - lineWidth), cornerRadius: self.cornerRadius)
            ctx?.setLineWidth(lineWidth)
            ctx?.addPath(path.cgPath)
            ctx?.setStrokeColor(self.color)
            ctx?.strokePath()
        }
    }
}
