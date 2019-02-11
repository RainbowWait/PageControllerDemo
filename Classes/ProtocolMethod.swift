//
//  MenuViewProtocol.swift
//  PageControllerExample
//
//  Created by 郑小燕 on 2018/3/23.
//  Copyright © 2018年 郑小燕. All rights reserved.
//

import UIKit

protocol MenuItemDelegate: NSObjectProtocol {
    func didPressedMenuItem(_ menuItem: MenuItem)
}

@objc protocol MenuViewDelegate: NSObjectProtocol {
    
    /// 设置menuItem可选中和不可选中
    ///
    /// - Parameters:
    ///   - menu: menu
    ///   - index: 点击选中menuItem的下标
    /// - Returns:
    @objc optional func menuView(_ menu: MenuView, shouldSelesctedIndex index: Int ) -> Bool
    
    /// 已经选中的menuItem
    ///
    /// - Parameters:
    ///   - menu: menu
    ///   - index: 选中menuItem的下标
    ///   - currentIndex: 当前显示的menuItem的下标
    @objc optional func menuView(_ menu: MenuView, didSelectedIndex index: Int, _ currentIndex: Int)
    
    /// 获取下标为index的menuItem的宽
    ///
    /// - Parameters:
    ///   - menu: menuItem
    ///   - index: menuItem的下标
    /// - Returns: 宽度
    @objc optional func menuView(_ menu: MenuView, widthForItemAtIndex index: Int) -> CGFloat
    ////边距
    @objc optional func menuView(_ menu: MenuView, itemMarginAtIndex index: Int) -> CGFloat
    //menuItem的文字大小
    @objc optional func menuView(_ menu: MenuView, titleSizeForState state: MenuItemState, atIndex index: Int) -> CGFloat
    //menuItem的文字颜色
    @objc optional func menuView(_ menu: MenuView, titleColorForState state: MenuItemState, atIndex index: Int) -> UIColor
    @objc optional func menuView(_ menu: MenuView, didLayoutItemFrame menuItem: MenuItem, atIndex index: Int)
}

@objc protocol MenuViewDataSource: NSObjectProtocol {
    
    /// 标题数量
    ///
    /// - Parameter menuView: menuView
    func numbersOfTitlesInMenuView(_ menuView: MenuView) -> Int
    
    /// 获取标题
    ///
    /// - Parameters:
    ///   - menuView: menuView
    ///   - index: 下标
    func menuView(_ menuView: MenuView, titleAtIndex index: Int) -> String
    
    /// 角标 (例如消息提醒的小红点) 的数据源方法，在 WMPageController 中实现这个方法来为 menuView 提供一个 badgeView  需要在返回的时候同时设置角标的 frame 属性，该 frame 为相对于 menuItem 的位置
    ///
    /// - Parameters:
    ///   - menu: menuView
    ///   - index: 角标的序号
    /// - Returns: 返回一个设置好 frame 的角标视图
    @objc optional func menuView(_ menu: MenuView, badgeViewAtIndex index: Int) -> UIView?
    
    
    /// 用于定制 MenuItem，可以对传出的 initialMenuItem 进行修改定制，也可以返回自己创建的子类，需要注意的是，此时的 item 的 frame 是不确定的，所以请勿根据此时的 frame 做计算！如需根据 frame 修改，请使用代理
    ///
    /// - Parameters:
    ///   - menu: 当前的 menuView,frame 也是不确定的
    ///   - item: 初始化完成的 menuItem
    ///   - index: Item 所属的位置
    /// - Returns: 定制完成的 MenuItem
    @objc optional func menuView(_ menu: MenuView, initialMenuItem item: MenuItem, atIndex index: Int) -> MenuItem?
}

@objc public protocol PageControllerDataSource: NSObjectProtocol {
    @objc optional func numbersOfChildControllersInPageController(_ pageController:PageController) -> Int
    @objc optional func pageController(_ pageController: PageController, viewControllerAtIndex index: Int) -> UIViewController
    @objc optional func pageController(_ pageController: PageController, titleAtIndex index: Int) -> String
    func pageController(pageController: PageController, preferredFrameForContentView scrollView: WMScrollView?) -> CGRect
    func pageController(pageController: PageController, preferredFrameForMenuView menuView: MenuView?) -> CGRect
    
}

@objc public protocol PageControllerDelegate: NSObjectProtocol {
    @objc optional func pageController(_ pageController: PageController, lazyLoadViewController viewController: UIViewController, withInfo info: Dictionary<String, String>)
    @objc optional func pageController(_ pageController: PageController, willCachedViewController viewController: UIViewController, withInfo info: Dictionary<String, String>)
    @objc optional func pageController(_ pageController: PageController, willEnterViewController viewController: UIViewController, withInfo info: Dictionary<String, String>)
    @objc optional func pageController(_ pageController: PageController, didEnterViewController viewController: UIViewController, withInfo info: Dictionary<String, String>)
}
