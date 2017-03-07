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
  
  fileprivate let group = DispatchGroup()
  fileprivate var isVideoGranted: Bool = false
  fileprivate var isAudioGranted: Bool = false
  
  fileprivate lazy var streamURLStringTextField: UITextField = {
    let textField = UITextField(frame: .zero)
    let leftLabel = UILabel()
    leftLabel.text = "请输入推流地址"
    leftLabel.frame = CGRect(origin: .zero, size: CGSize(width: 60, height: 40))
    textField.leftView = leftLabel
    return textField
  }()
  
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

  @objc fileprivate func dismissController() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      DispatchQueue.main.async {
        self.dismiss(animated: true, completion: {
          if let delegate = UIApplication.shared.delegate as? AppDelegate ,let main = delegate.window?.rootViewController as? MainViewController {
            main.modalNavigationController = nil
          }
        })
      }
    }
  }//end func
  
}

// MARK: - Modal StreamViewController
extension PostAffairController: AVCaptureAccessProtocal {
  
  @objc fileprivate func portraitLive() {
    submit(with: .portrait)
  }
  
  @objc fileprivate func landscapeLive() {
    submit(with: .landscapeRight)
  }
  
  
  fileprivate func submit(with orientation: ScreenOrientation) {
    
    group.enter()
    requestAccessForAudio()
    group.enter()
    requestAccessForVideo()
    group.notify(queue: DispatchQueue.main) {
      guard self.isAudioGranted && self.isVideoGranted else {
        return
      }
      //完成回调
      let previewController         = PreviewController(orientation: orientation)
      let streamURLString = self.streamURLStringTextField.text
      previewController.address = streamURLString ?? ""
      self.present(previewController, animated: true, completion: nil)
    }
    
  }
  
  func requestAccessForAudio(authorizationStatus: CaptureAccessStatus, statusMesasge: String) {
    isAudioGranted = (authorizationStatus == .authorized)
    group.leave()
    guard authorizationStatus == .authorized else {
//      MSProgressView.show(message: "请获取音频的授权后再次尝试")
      return
    }
  }
  
  func requestAccessForVideo(authorizationStatus: CaptureAccessStatus, statusMesasge: String) {
    isVideoGranted = (authorizationStatus == .authorized)
    group.leave()
    guard authorizationStatus == .authorized else {
      
      return
    }
  }
  
}


// MARK: - Orientation
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
  
}

extension PostAffairController {
  
  fileprivate func setupUI() {
    
    view.layer.contentsRect = CGRect(x: 0, y: 0, width: 0.8, height: 1)
    let image = UIImage(named: "compose_background")?.cgImage
    view.layer.contents = image
    
    view.addSubview(portraitButton)
    view.addSubview(landscapeButton)
    view.addSubview(dismissPostButton)
    view.addSubview(streamURLStringTextField)
    
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
    
    streamURLStringTextField.snp.makeConstraints { (make) in
      make.centerY.equalTo(self.view).offset( -buttonMargin - buttonHeight * 1.5 )
      make.centerX.equalToSuperview()
      make.width.equalTo(buttonWidth)
      make.height.equalTo(buttonHeight)
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
