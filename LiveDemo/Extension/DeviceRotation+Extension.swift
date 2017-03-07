//
//  NSObject+Extension.swift
//  LiveShowSwift
//
//  Created by Manajay on 23/10/2016.
//  Copyright © 2016 manajay. All rights reserved.
//
import UIKit

// MARK: - 获取当前显示的控制器
extension UIApplicationDelegate {

  func currentViewController(with rootViewController: UIViewController? ) -> UIViewController? {
    
    // UITabBarController就接着查找它当前显示的selectedViewController
    guard let  rootViewController = rootViewController else  {
      return nil
    }
    
    if rootViewController.isKind(of: UITabBarController.self){
      return currentViewController(with: (rootViewController as! UITabBarController).selectedViewController)
      // UINavigationController就接着查找它当前显示的visibleViewController
    }else if rootViewController.isKind(of: UINavigationController.self){
      return currentViewController(with: (rootViewController as! UINavigationController).visibleViewController)
      // 如果当前窗口有presentedViewController,就接着查找它的presentedViewController
    } else if nil != rootViewController.presentedViewController{
      return currentViewController(with: rootViewController.presentedViewController)
    }
    
    // 跳出循环 (当前控制器不是导航控制器,不是 TabBar控制器,不是Modal的控制器)  就代表找到了当前显示的控制器
    return rootViewController
  }
  
}

