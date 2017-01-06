//
//  PostAffairController.swift
//  LiveDemo
//
//  Created by manajay on 2017/1/5.
//  Copyright © 2017年 manajay. All rights reserved.
//

import UIKit
import SnapKit

private let paddingX: CGFloat = 40
private let buttonHeight: CGFloat = 70 //按钮高度
private let buttonWidth: CGFloat = 200 //按钮宽度
private let buttonMargin: CGFloat = 50 //按钮间距

class PostAffairController: UIViewController {
  
  /// 按钮
  fileprivate lazy var portraitButton: UIButton = {
    let button = UIButton(type: UIButtonType.custom)
    button.addTarget(self, action: #selector(portraitLive), for: .touchUpInside)
    button.setTitle("竖屏直播",for:.normal)
    
    button.setImage(UIImage(named: "live_blue"), for: .normal)
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, -20)
    button.adjustsImageWhenHighlighted = false
    
    return button
  }()
  
  fileprivate lazy var landscapeButton: UIButton = {
    let button = UIButton(type: UIButtonType.custom)
    button.addTarget(self, action: #selector(landscapeLive), for: .touchUpInside)
    button.setImage(UIImage(named: "photo_blue"), for: .normal)
    button.setTitle("横屏直播",for:.normal)
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, -20)
    button.adjustsImageWhenHighlighted = false
    
    return button
  }()

  /// 按钮
  fileprivate lazy var dismissPostButton: UIButton = {
    let button = UIButton(type: UIButtonType.custom)
    button.addTarget(self, action: #selector(dismissController), for: .touchUpInside)
    button.setImage(#imageLiteral(resourceName: "dismissButton_compose"), for: .normal)
    return button
  }()
  
}

extension PostAffairController {

  
  @objc fileprivate func portraitLive() {
    
    DeviceHelper.requestAccessForAudio { (isGranted, msg) in
      guard isGranted else {
        return
      }
    }
    
    DeviceHelper.requestAccessForVideo { (isGranted, msg) in
      guard isGranted else {
        return
      }
    }
    
    let preVC = PreviewController()
    preVC.orientation = .portrait
    self.present(preVC, animated: true, completion: nil)
  }
  
  
  @objc fileprivate func landscapeLive() {
    
    DeviceHelper.requestAccessForAudio { (isGranted, msg) in
      guard isGranted else {
        return
      }
    }
    
    DeviceHelper.requestAccessForVideo { (isGranted, msg) in
      guard isGranted else {
        return
      }
    }
    
    let preVC = PreviewController()
    preVC.orientation = .landscapeRight
    self.present(preVC, animated: true, completion: nil)
  }
  
  @objc fileprivate func dismissController() {
    
   self.dismiss(animated: true, completion: nil)
    
  }//
  
}

extension PostAffairController {

  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  override var shouldAutorotate: Bool {
    return false
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .portrait
  }
  
  override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
    return .portrait
  }
  
  fileprivate func orientationTo(_ orientation: UIInterfaceOrientation) {
    let orientationValue = orientation.rawValue
    UIDevice.current.setValue(orientationValue, forKey: "orientation")
  }
}

extension PostAffairController {
  
  fileprivate func setupUI() {
    
    view.layer.contentsRect = CGRect(x: 0, y: 0, width: 0.8, height: 1)
    let image = UIImage(named: "compose_background")?.cgImage
    view.layer.contents = image
    
    view.addSubview(portraitButton)
    view.addSubview(landscapeButton)
    view.addSubview(dismissPostButton)

    portraitButton.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.view).offset(-buttonMargin - buttonHeight * 0.5)
      make.centerX.equalToSuperview()
      make.width.equalTo(buttonWidth)
      make.height.equalTo(buttonHeight)
    }
    
    landscapeButton.snp.makeConstraints { (make) in
      make.center.equalToSuperview()
      make.height.width.equalTo(portraitButton)
    }
    
    dismissPostButton.snp.makeConstraints { (make) in
      make.bottom.equalTo(self.view.snp.bottom).offset(-8)
      make.centerX.equalTo(self.view)
      make.height.width.equalTo(30)
    }

  }
}

extension PostAffairController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.random
    title = "配置直播"
    setupUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController!.isNavigationBarHidden = true
  }
  
}
