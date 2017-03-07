//
//  UIDevice+Extension.swift
//  LiveDemo
//
//  Created by manajay on 07/03/2017.
//  Copyright © 2017 manajay. All rights reserved.
//

import UIKit


extension UIDevice {
  
  public enum Model : String {
    case simulator = "simulator/sandbox",
    iPod1          = "iPod 1",
    iPod2          = "iPod 2",
    iPod3          = "iPod 3",
    iPod4          = "iPod 4",
    iPod5          = "iPod 5",
    iPad2          = "iPad 2",
    iPad3          = "iPad 3",
    iPad4          = "iPad 4",
    iPhone4        = "iPhone 4",
    iPhone4S       = "iPhone 4S",
    iPhone5        = "iPhone 5",
    iPhone5S       = "iPhone 5S",
    iPhone5C       = "iPhone 5C",
    iPadMini1      = "iPad Mini 1",
    iPadMini2      = "iPad Mini 2",
    iPadMini3      = "iPad Mini 3",
    iPadAir1       = "iPad Air 1",
    iPadAir2       = "iPad Air 2",
    iPhone6        = "iPhone 6",
    iPhone6plus    = "iPhone 6 Plus",
    iPhone6S       = "iPhone 6S",
    iPhone6Splus   = "iPhone 6S Plus",
    iPhone7        = "iPhone 7",
    iPhone7plus    = "iPhone 7 Plus",
    unrecognized   = "?unrecognized?"
  }
  
  public var UDID: String {
    return UIDevice.current.identifierForVendor?.uuidString ?? "11111111"
  }
  
  public var type: Model {
    
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
      guard let value = element.value as? Int8 , value != 0 else { return identifier }
      return identifier + String(UnicodeScalar(UInt8(value)))
    }
    
    
    var modelMap : [ String : Model ] = [
      "i386"      : .simulator,
      "x86_64"    : .simulator,
      "iPod1,1"   : .iPod1,
      "iPod2,1"   : .iPod2,
      "iPod3,1"   : .iPod3,
      "iPod4,1"   : .iPod4,
      "iPod5,1"   : .iPod5,
      "iPad2,1"   : .iPad2,
      "iPad2,2"   : .iPad2,
      "iPad2,3"   : .iPad2,
      "iPad2,4"   : .iPad2,
      "iPad2,5"   : .iPadMini1,
      "iPad2,6"   : .iPadMini1,
      "iPad2,7"   : .iPadMini1,
      "iPhone3,1" : .iPhone4,
      "iPhone3,2" : .iPhone4,
      "iPhone3,3" : .iPhone4,
      "iPhone4,1" : .iPhone4S,
      "iPhone5,1" : .iPhone5,
      "iPhone5,2" : .iPhone5,
      "iPhone5,3" : .iPhone5C,
      "iPhone5,4" : .iPhone5C,
      "iPad3,1"   : .iPad3,
      "iPad3,2"   : .iPad3,
      "iPad3,3"   : .iPad3,
      "iPad3,4"   : .iPad4,
      "iPad3,5"   : .iPad4,
      "iPad3,6"   : .iPad4,
      "iPhone6,1" : .iPhone5S,
      "iPhone6,2" : .iPhone5S,
      "iPad4,1"   : .iPadAir1,
      "iPad4,2"   : .iPadAir2,
      "iPad4,4"   : .iPadMini2,
      "iPad4,5"   : .iPadMini2,
      "iPad4,6"   : .iPadMini2,
      "iPad4,7"   : .iPadMini3,
      "iPad4,8"   : .iPadMini3,
      "iPad4,9"   : .iPadMini3,
      "iPhone7,1" : .iPhone6plus,
      "iPhone7,2" : .iPhone6,
      "iPhone8,1" : .iPhone6S,
      "iPhone8,2" : .iPhone6Splus,
      "iPhone9,1" : .iPhone7,
      "iPhone9,2" : .iPhone7plus
      
    ]
    
    if let model = modelMap[identifier] {
      return model
    }
    return Model.unrecognized
  }
  
}

extension UIDevice {
  
  
  /// 强制旋转屏幕
  ///
  /// - Parameters:
  ///   - orientation: 将要旋转的方向
  ///   - before: 旋转之前需要的操作, 一般必须 设置当前控制器 shouldAutorotate 的属性为 true
  ///   - after : 旋转之后需要的操作, 一般必须 设置当前控制器 shouldAutorotate 的属性为 false
  class func rotationDevice(before: (() -> Void), after: (() -> Void) ,to orientation: UIInterfaceOrientation) {
    before()
    // 先自己给一个值0，然后再修改为其他屏幕方向就能顺利调起 KVO 来进入屏幕旋转流程
    UIDevice.current.setValue(UIInterfaceOrientation.unknown.rawValue, forKey: "orientation")
    UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
    after()
  }
  
  /// 当调用 rotate(to: UIInterfaceOrientation.landscapeLeft) 时，先允许自动旋转，然后进行屏幕旋转。再设置为不允许自动旋转 - 手动旋转屏幕的注意点
  ///
  /// - Parameter orientation: 将要改变的屏幕方向
  class func orientation(to orientation: UIInterfaceOrientation) {
    // 先自己给一个值0，然后再修改为其他屏幕方向就能顺利调起 KVO 来进入屏幕旋转流程
    UIDevice.current.setValue(UIInterfaceOrientation.unknown.rawValue, forKey: "orientation")
    UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
  }
  
  /**
   1.当当前设备方向属性 orientation 发生变化时候，会调用 Controller 的 shouldAutorotate 属性。
   2.如果 shouldAutorotate 为 true 则会进一步调用 supportedInterfaceOrientations 来查询支持的屏幕方向。
   3.当 Controller 支持的方向和设备方向一致时候就进行旋转操作。
   
   神 Bug 就出在第一步。UIDevice 的 orientation 属性并不是指的屏幕的方向，而是设备的方向。我们屏幕旋转的实现就是通过手动修改 orientation 属性来欺骗设备告诉他设备方向发生了变化，从而开始屏幕旋转流程。
   
   如果当屏幕 UI 处于横屏且 shouldAutorotate = false 时候，我们旋转手机设备 orientation 属性会持续变化并开始屏幕旋转流程调用 shouldAutorotate。但是因为 shouldAutorotate 为 false 所以不会有任何反应。
   
   当屏幕 UI 处于横屏且我们旋转手机设备至竖屏状态时， orientation 属性已经为 UIInterfaceOrientation.portrait.rawValue 了，所以此时再次设置为 UIInterfaceOrientation.portrait.rawValue 并不会调用被系统认为屏幕方向发生了变化。所以就不会有任何变化。
   
   */
}
