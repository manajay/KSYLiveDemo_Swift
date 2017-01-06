//
//  MainViewController.swift
//  LiveShowSwift
//
//  Created by ljduan on 2016/11/7.
//  Copyright © 2016年 manajay. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController ,UITabBarControllerDelegate{

    
    /// 加号按钮 model 出来的视图
    var modalNavigationController:BaseNavigationController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        //初始化子控制器
        self.initSubVC()
        // 添加加号按钮
        self.setupComposedButton()
        
        // 解决 横屏的 selectedViewController 解包失败的问题
        self.selectedIndex = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 将撰写按钮弄到最前面
        self.tabBar.bringSubview(toFront: self.composedButton)
    }
    // MARK: - setupView
    
    func initSubVC() {
        /**此处的控制器换成自己的**/
        // 1.
        let latestTrendsVC = HomeController()
        self.setupChildVC(latestTrendsVC, title: "最新动态", imageName: "lastestTrend")
        
        // 2.
        self.addChildViewController(UIViewController())
        
        // 3.
        let mapVC = MapController()
        self.setupChildVC(mapVC, title: "地图定位", imageName: "map_location")
    }
    //初始化所有子控制器
    
    func setupChildVC(_ childVC: UIViewController, title: String, imageName: String) {
        //1.设置 item
        let item = self.setupItem(withImageName: imageName, title: title)
        childVC.tabBarItem = item
        //2.添加导航控制器
        
        let Nav = BaseNavigationController(rootViewController: childVC)
        //3.
        self.addChildViewController(Nav)
    }
    // MARK: - private
    
    func setupItem(withImageName imageName: String, title: String) -> UITabBarItem {
        let item = UITabBarItem(title: title, image: UIImage(named: imageName)!.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: imageName.appending("_selected"))!.withRenderingMode(.alwaysOriginal))
        var textAttr: [String: Any]
        var selectedAttr: [String: Any]
        textAttr = [
            NSForegroundColorAttributeName : UIColor(red: 113 / 255.0, green: 113 / 255.0, blue: 113 / 255.0, alpha: 1.0),
            NSFontAttributeName : UIFont.systemFont(ofSize: 11)
        ]
        
        selectedAttr = [
            NSForegroundColorAttributeName :  UIColor(hex: 0x1A9BD2),
            NSFontAttributeName : UIFont.systemFont(ofSize: 11)
        ]
        
        item.setTitleTextAttributes(selectedAttr, for: .selected)
        item.setTitleTextAttributes(textAttr, for: .normal)
        return item
    }
    // MARK: - 特殊控制器
    
    func setupComposedButton() {
        self.tabBar.addSubview(self.composedButton)
       
        
        let count = self.childViewControllers.count
        // 让按钮宽一点点，能够解决手指触摸的容错问题
        let width: CGFloat = self.tabBar.bounds.size.width / CGFloat(count) - 1
        self.composedButton.frame = self.tabBar.bounds.insetBy(dx: width, dy: 0)
        self.composedButton.addTarget(self, action: #selector(self.clickComposedButton), for: .touchUpInside)
    }
    
    lazy var composedButton: UIButton = {
        let button = UIButton(type: UIButtonType.custom)
        button.frame = CGRect.zero
        button.setImage(UIImage(named: "new_live")!, for: .normal)

        return button
    }()
   
    
    // MARK: - ACTION
    /**
     *  转场出 加号 视图控制器
     */
    func clickComposedButton() {
        //
        let composeViewController = PostAffairController()
        let navi = ShowNavigationController(rootViewController: composeViewController)
        navi.modalPresentationStyle = .custom
        weak var weakSelf = self
        self.present(navi, animated: true, completion: {() -> Void in
            weakSelf?.modalNavigationController = navi
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //调整frame。你可以使用任何其它布局方式保证播放视图是你期望的大小
        let count = self.childViewControllers.count
        // 让按钮宽一点点，能够解决手指触摸的容错问题
        let width: CGFloat = self.tabBar.bounds.size.width / CGFloat(count) - 1
        if self.traitCollection.verticalSizeClass == .compact {
            self.composedButton.frame = self.tabBar.bounds.insetBy(dx: width, dy: 0)
        }
        else {
            self.composedButton.frame = self.tabBar.bounds.insetBy(dx: width, dy: 0)
        }
    }

    
    //MARK: 转屏
    override var shouldAutorotate: Bool{
        return false
    }
    
    func tabBarControllerSupportedInterfaceOrientations(_ tabBarController: UITabBarController) -> UIInterfaceOrientationMask {
        return self.selectedViewController!.supportedInterfaceOrientations
    }
    
    func tabBarControllerPreferredInterfaceOrientationForPresentation(_ tabBarController: UITabBarController) -> UIInterfaceOrientation {
        return self.selectedViewController!.preferredInterfaceOrientationForPresentation
    }
    
}
