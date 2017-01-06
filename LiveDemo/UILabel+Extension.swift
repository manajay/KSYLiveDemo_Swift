
//
//  UILabel+Extension.swift
//  LiveDemo
//
//  Created by manajay on 2017/1/5.
//  Copyright © 2017年 manajay. All rights reserved.
//

import UIKit

extension UILabel {

  static func test(content: String) -> UILabel {
    let label = UILabel()
    label.frame = CGRect(origin: .zero, size: CGSize(width: 300, height: 20))
    label.center = CGPoint(x: UIScreen.main.bounds.width * 0.5, y: UIScreen.main.bounds.height * 0.5)
    label.text = content
    label.textAlignment = .center
    label.font = UIFont.boldSystemFont(ofSize: 50)
    return label
  }
  
  
}
