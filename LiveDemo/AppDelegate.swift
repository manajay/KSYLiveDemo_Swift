//
//  AppDelegate.swift
//  LiveDemo
//
//  Created by manajay on 2017/1/5.
//  Copyright © 2017年 manajay. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    window = UIWindow.init(frame: UIScreen.main.bounds)
    let main =  MainViewController()
    window?.rootViewController = main
    window?.makeKeyAndVisible()
    
    return true
  }

}


// MARK: - 横竖屏旋转
extension AppDelegate {
  
  func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
    
    if let rootViewController = self.currentViewControllerWithRootViewController(rootViewController: window?.rootViewController){
      // 需要横屏的设置能够横屏
      if rootViewController.responds(to: Selector(("canRotate"))){
        return .allButUpsideDown
      }
    }
    // 默认只能显示竖屏
    return .portrait
    
  }
  
  private func currentViewControllerWithRootViewController(rootViewController: UIViewController!)->UIViewController?{
    if nil == rootViewController{
      return nil
    }
    // UITabBarController就接着查找它当前显示的selectedViewController
    if rootViewController.isKind(of: UITabBarController.self){
      return self.currentViewControllerWithRootViewController(rootViewController: (rootViewController as! UITabBarController).selectedViewController)
      // UINavigationController就接着查找它当前显示的visibleViewController
    }else if rootViewController.isKind(of: UINavigationController.self){
      return self.currentViewControllerWithRootViewController(rootViewController: (rootViewController as! UINavigationController).visibleViewController)
      // 如果当前窗口有presentedViewController,就接着查找它的presentedViewController
    }else if nil != rootViewController.presentedViewController{
      return self.currentViewControllerWithRootViewController(rootViewController: rootViewController.presentedViewController)
    }
    // 否则就代表找到了当前显示的控制器
    return rootViewController
  }
  
}

