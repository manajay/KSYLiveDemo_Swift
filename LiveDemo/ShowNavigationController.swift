//
//  ShowNavigationController.swift
//  LiveShowSwift
//
//  Created by ljduan on 2016/11/7.
//  Copyright © 2016年 manajay. All rights reserved.
//

import UIKit

class ShowNavigationController: BaseNavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

      addPanGesture()
    }
  
  fileprivate func addPanGesture() {
    // 1.使用运行时, 打印手势中所有属性
    guard let targets = interactivePopGestureRecognizer!.value(forKey:  "_targets") as? [NSObject] else { return }
    let targetObjc = targets[0]
    let target = targetObjc.value(forKey: "target")
    let action = Selector(("handleNavigationTransition:"))
    
    let panGes = UIPanGestureRecognizer(target: target, action: action)
    view.addGestureRecognizer(panGes)
  }

}
