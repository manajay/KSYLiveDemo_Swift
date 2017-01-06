//
//  HomeController.swift
//  LiveDemo
//
//  Created by manajay on 2017/1/5.
//  Copyright © 2017年 manajay. All rights reserved.
//

import UIKit

class HomeController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

      view.backgroundColor = UIColor.random
      view.addSubview(UILabel.test(content: "首页"))
      title = "首页"

    }

}
