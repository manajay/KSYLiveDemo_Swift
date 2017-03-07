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
  
  /**
   This method returns the total set of interface orientations supported by the app. When determining whether to rotate a particular view controller, the orientations returned by this method are intersected with the orientations supported by the root view controller or topmost presented view controller. The app and view controller must agree before the rotation is allowed.
   
   If you do not implement this method, the app uses the values in the UIInterfaceOrientation key of the app’s Info.plist as the default interface orientations.
   */
  func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
    
    
    if let rootViewController = self.currentViewController(with: window?.rootViewController){
      // 需要横屏的设置能够横屏
      if rootViewController.responds(to: NSSelectorFromString("canRotate")) {
        return .allButUpsideDown
      }
    }
    // 默认只能显示竖屏
    return .portrait
  }
  
}
