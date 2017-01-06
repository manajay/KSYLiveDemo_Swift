
//
//  UIColor+Extension.swift
//  LiveDemo
//
//  Created by manajay on 2017/1/5.
//  Copyright © 2017年 manajay. All rights reserved.
//


import UIKit

public extension UIColor {
  /// Return hexadecimal value string.
  public var hexString: String {
    var r:CGFloat = 0
    var g:CGFloat = 0
    var b:CGFloat = 0
    var a:CGFloat = 0
    
    getRed(&r, green: &g, blue: &b, alpha: &a)
    let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
    return NSString(format:"#%06x", rgb).uppercased as String
  }
  
  /// Create UIColor from hexadecimal value with optional transparency.
  public convenience init(hex: Int, transparency: CGFloat = 1) {
    
    var trans: CGFloat {
      if transparency > 1 {
        return 1
      } else if transparency < 0 {
        return 0
      } else {
        return transparency
      }
    }
    
    self.init(red:(hex >> 16) & 0xff, green:(hex >> 8) & 0xff, blue:hex & 0xff, transparency: trans)
  }
  
  /// Create UIColor from RGB values with optioanl transparency.
  public convenience init(red: Int, green: Int, blue: Int, transparency: CGFloat = 1) {
    assert(red >= 0 && red <= 255, "Invalid red component")
    assert(green >= 0 && green <= 255, "Invalid green component")
    assert(blue >= 0 && blue <= 255, "Invalid blue component")
    
    var trans: CGFloat {
      if transparency > 1 {
        return 1
      } else if transparency < 0 {
        return 0
      } else {
        return transparency
      }
    }
    
    self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: trans)
  }
  
  /// Return random color.
  public static var random: UIColor {
    let r = Int(arc4random_uniform(255))
    let g = Int(arc4random_uniform(255))
    let b = Int(arc4random_uniform(255))
    return UIColor(red: r, green: g, blue: b)
  }
  
}
