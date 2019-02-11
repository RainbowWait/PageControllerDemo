//
//  CustomViewController.swift
//  PageControllerExample
//
//  Created by 郑小燕 on 2018/3/19.
//  Copyright © 2018年 郑小燕. All rights reserved.
//

import UIKit

class CustomViewController: PageController {
    var menuViewPosition: MenuViewPosition?
    var index = 0
//    lazy var button: UIButton = {
//        let btn = UIButton(type: UIButtonType.custom)
//        btn.backgroundColor = UIColor.red
//        btn.addTarget(self, action: #selector(btnMethod), for: .touchUpInside)
//        return btn
//    }()
    
    
    lazy var redView: UIView = {
        let view = UIView(frame: CGRect.zero)
        view.backgroundColor = UIColor(red: 168.0/255.0, green: 20.0/255.0, blue: 4/255.0, alpha: 1)
        return view
    }()
    
    @objc func btnMethod() {
        index += 1
        self.reloadData()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.menuViewStyle == .triangle {
            self.view.addSubview(self.redView)
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.redView.frame = CGRect(x: 0, y: (self.menuView?.frame.maxY) ?? 0, width: self.view.frame.width, height: 2.0)
//        self.button.frame.size = CGSize(width: 44, height: 44)
//        self.menuView?.leftView = self.button
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numbersOfChildControllersInPageController(_ pageController: PageController) -> Int {
        switch self.menuViewStyle {
        case .flood:
            return 3 + index
        case .segmented:
            return 3 + index
        default:
            return 5 + index
        }
    }
    
    func pageController(_ pageController: PageController, titleAtIndex index: Int) -> String {
        switch index % 3 {
        case 0:return "头条"
        case 1:return "推荐"
        default:return "重庆"
        }
    }
    
    func pageController(_ pageController: PageController, viewControllerAtIndex index: Int) -> UIViewController {
        switch index % 3 {
        case 0:
            return FirstViewController()
        case 1:
            return ViewController()
        case 2:
            return SecondController()
        default:
            return UIViewController()
        }
    }
    
    override func menuView(_ menu: MenuView, widthForItemAtIndex index: Int) -> CGFloat {
        let width = super.menuView(menu, widthForItemAtIndex: index)
        return width + 10
    }
    
    override func pageController(pageController: PageController, preferredFrameForMenuView menuView: MenuView?) -> CGRect {
        if self.menuViewPosition == .bottom {
            menuView?.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
            return CGRect(x: 0, y: self.view.frame.size.height - 44, width: self.view.frame.width, height: 44)
        }
        let leftMargin: CGFloat = self.showOnNavigationBar ? 50 : 0
        let originY = self.showOnNavigationBar ? 0 : self.navigationController?.navigationBar.frame.maxY
        
        
        return CGRect(x: 0, y: originY ?? 0, width: self.view.frame.width - 2 * leftMargin, height: 44)
    }
    
    override func pageController(pageController: PageController, preferredFrameForContentView scrollView: WMScrollView?) -> CGRect {
        if self.menuViewPosition == .bottom {
            return CGRect(x: 0, y: 64, width: self.view.frame.width, height: self.view.frame.height - 64 - 44)
        }
        var originY = self.pageController(pageController: pageController, preferredFrameForMenuView: self.menuView ?? nil).maxY
        if self.menuViewStyle == .triangle {
            originY += self.redView.frame.height
        }
        return CGRect(x: 0, y: originY , width: self.view.frame.width, height: self.view.frame.height - originY)
    }
    
    func pageController(_ pageController: PageController, didEnterViewController viewController: UIViewController, withInfo info: Dictionary<String, String>) {
//        print("info = \(info) ====viewController = \(viewController)")
    }
    
    func pageController(_ pageController: PageController, lazyLoadViewController viewController: UIViewController, withInfo info: Dictionary<String, String>) {
//         print("info = \(info) ====viewController = \(viewController)")
    }
    
    func pageController(_ pageController: PageController, willEnterViewController viewController: UIViewController, withInfo info: Dictionary<String, String>) {
        print("info = \(info) ====viewController = \(viewController)")
    }

    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
