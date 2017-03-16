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
    
    setupWeChatSDK()
    
    window = UIWindow.init(frame: UIScreen.main.bounds)
    let main =  MainViewController()
    window?.rootViewController = main
    window?.makeKeyAndVisible()
    
    return true
  }

}


// MARK: -  分享初始化
extension AppDelegate {
  
  //************************* 分享 ***********************//
  fileprivate func setupWeChatSDK() -> () {
    WXApi.registerApp("wx8611177d8458e91c")
  }
  
}


// MARK: - 处理应用跳转
extension AppDelegate :WXApiDelegate{
  
  private func handleURL(url:URL) -> Bool {
    return WXApi.handleOpen(url, delegate: self)
  }
  
  @objc(application:handleOpenURL:) func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
    return handleURL(url: url)
  }
  
  @objc(application:openURL:options:) func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    return handleURL(url: url)
  }
  
  @objc(application:openURL:sourceApplication:annotation:) func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    return handleURL(url: url)
  }
  
  
  func onResp(_ resp: BaseResp!) {
    
    debugPrint("开始APP之间的回调")
    
    switch currentViewController(with: window?.rootViewController).self {
    case is PreviewController:
      NotificationCenter.default.post(name: AppNotification.kShareLiveInfoEvent, object: PreviewController.self, userInfo: ["resp": resp])
    default: break
      
    }
    
    debugPrint("结束APP之间的回调")
    
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
