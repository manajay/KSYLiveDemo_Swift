//
//  PreviewControlView.swift
//  LiveShowSwift
//
//  Created by manajay on 14/03/2017.
//  Copyright © 2017 manajay. All rights reserved.
//

import UIKit

enum ControlButtonType {
  case light,camera,beauty,share,start
}

protocol PreviewControlViewDelegate: class {
  func didTappedButton(with type: ControlButtonType, button: UIButton)
}


private let kButtonWidth:  CGFloat = 40
private let kButtonHeight: CGFloat = 40
private let kPaddingX: CGFloat = 0
private let kHorizontalMargin: CGFloat = 15

class PreviewControlView: UIView {

  // 0000     0
  weak var delegate: PreviewControlViewDelegate?
  
  // 灯光
  fileprivate lazy var lightButton: UIButton = {
    let button = UIButton(frame: .zero)
    button.setImage(#imageLiteral(resourceName: "light_black"), for: .normal)
    button.setImage(#imageLiteral(resourceName: "light_open"), for: .selected)
    button.isExclusiveTouch = true
    return button
  }()
  
  // 摄像头
  fileprivate var cameraButton: UIButton = {
    let button = UIButton(frame: CGRect.zero)
    button.setImage(#imageLiteral(resourceName: "camera_reverse"), for: .normal)
    button.isExclusiveTouch = true
    return button
  }()
  
  // 美颜
  fileprivate var beautyButton: UIButton = {
    let button = UIButton(frame: .zero)
    button.setImage(#imageLiteral(resourceName: "beauty_magic_open"), for: .selected)
    button.setImage(#imageLiteral(resourceName: "beauty_magic"), for: .normal)
    button.isExclusiveTouch = true
    button.isSelected = true
    return button
  }()
  
  //分享按钮
  fileprivate var shareButton: UIButton = {
    let button = UIButton(frame: .zero)
    button.setImage(#imageLiteral(resourceName: "live_share"), for: .normal)
    button.isExclusiveTouch = true
    return button
  }()
  
  // 开始直播按钮
  fileprivate var startLiveButton: UIButton = {
    let button = UIButton(frame: CGRect.zero)
    button.setImage(#imageLiteral(resourceName: "live_start"), for: .normal)
    button.setImage(#imageLiteral(resourceName: "live_stop"), for: .selected)
    button.isExclusiveTouch = true
    return button
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
    layout()
    addTargetAction()
  }
  
  override var frame: CGRect {
    didSet {
      layout()
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

// MARK: - UI
extension PreviewControlView {

  fileprivate func setupUI(){
    addSubview(beautyButton)
    addSubview(cameraButton)
    addSubview(lightButton)
    addSubview(shareButton)
    addSubview(startLiveButton)
  }
  
  /// 添加 Target-Actions
  fileprivate func addTargetAction() {
    cameraButton.addTarget(self, action: #selector(didTappedCameraButton(_:)), for:.touchUpInside)
    beautyButton.addTarget(self, action: #selector(didTappedBeautyButton(_:)), for: .touchUpInside)
    startLiveButton.addTarget(self, action: #selector(didTappedStartLiveButton(_:)), for: .touchUpInside)
    lightButton.addTarget(self, action: #selector(didTappedLightButton(_:)), for: .touchUpInside)
    shareButton.addTarget(self, action: #selector(didTappedShareButton(_:)), for: .touchUpInside)
  }
  
  fileprivate func layout() {
    //调整布局
    lightButton.frame = CGRect(x: kPaddingX, y: 0, width: kButtonWidth, height: kButtonHeight)
    cameraButton.frame = CGRect(x: lightButton.frame.maxX + kHorizontalMargin, y: 0, width: kButtonWidth, height: kButtonHeight)
    beautyButton.frame = CGRect(x: cameraButton.frame.maxX + kHorizontalMargin, y: 0, width: kButtonWidth, height: kButtonHeight)
    shareButton.frame = CGRect(x: beautyButton.frame.maxX + kHorizontalMargin, y: 0, width: kButtonWidth, height: kButtonHeight)
    startLiveButton.frame = CGRect(x: frame.width - kPaddingX - kButtonWidth, y: 0, width: kButtonWidth, height: kButtonHeight)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    

  }
}

// MARK: - Actions
extension PreviewControlView {

  /// 点击直播开关按钮
  @objc fileprivate  func didTappedStartLiveButton(_ button: UIButton) {
    delegate?.didTappedButton(with: .start, button: button)
  }
  
  // 点击美颜按钮
  @objc fileprivate func didTappedBeautyButton(_ button: UIButton) {
    delegate?.didTappedButton(with: .beauty, button: button)
  }
  
  /// 点击分享按钮
  @objc fileprivate func didTappedShareButton(_ button: UIButton) {
    delegate?.didTappedButton(with: .share, button: button)
  }
  
  
  // 摄像头
  @objc fileprivate func didTappedCameraButton(_ button: UIButton) {
    delegate?.didTappedButton(with: .camera, button: button)
  }
  
  // 关闭 手电筒
  @objc fileprivate func didTappedLightButton(_ button: UIButton) -> Void  {
    delegate?.didTappedButton(with: .light, button: button)
  }
}

