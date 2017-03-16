//
//  PreviewNavigationView.swift
//  LiveShowSwift
//
//  Created by manajay on 14/03/2017.
//  Copyright © 2017 manajay. All rights reserved.
//

import UIKit

private let kButtonWidth:  CGFloat = 40
private let kButtonHeight: CGFloat = 40
private let kPaddingX: CGFloat = 0
private let kHorizontalMargin: CGFloat = 15

enum NavigationButtonType {
  case back,quit
}

protocol PreviewNavigationViewDelegate: class {
  func didTappedButton(with type: NavigationButtonType, button: UIButton)
}

class PreviewNavigationView: UIView {

  weak var delegate: PreviewNavigationViewDelegate?

  // 标题Label
  var titleLabel: UILabel = {
    let titleLabel = UILabel(frame: CGRect.zero)
    titleLabel.text = "聚现直播"
    titleLabel.textColor = UIColor.white
    titleLabel.font = UIFont.systemFont(ofSize: 14.0)
    titleLabel.numberOfLines = 1
    return titleLabel
  }()
  
  // 直播标题按钮
  fileprivate var backButton: UIButton = {
    let button = UIButton(frame: .zero)
    button.setImage(#imageLiteral(resourceName: "bleft"), for: .normal)
    button.isExclusiveTouch = true
    return button
  }()
  
  fileprivate var quitButton: UIButton = {
    let button = UIButton(frame: .zero)
    button.setImage(#imageLiteral(resourceName: "dismiss_Black"), for: .normal)
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
extension PreviewNavigationView {
  
  fileprivate func setupUI(){
    addSubview(backButton)
    addSubview(quitButton)
    addSubview(titleLabel)
  }
  
  fileprivate func layout() {
    backButton.frame = CGRect(x: kPaddingX , y: 0, width: kButtonWidth, height: kButtonHeight)
    quitButton.frame = CGRect(x: frame.width - kPaddingX - kButtonWidth, y: 0, width: kButtonWidth, height: kButtonHeight)
    titleLabel.frame = CGRect(x: backButton.frame.maxX , y: 0, width: frame.width - (kButtonWidth + kPaddingX) * 2, height: kButtonHeight)
  }
  
  /// 添加 Target-Actions
  fileprivate func addTargetAction() {
    backButton.addTarget(self, action: #selector(didTappedBackButton(_:)), for:.touchUpInside)
    quitButton.addTarget(self, action: #selector(didTappedQuitButton(_:)), for: .touchUpInside)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
  }
}

// MARK: - Actions
extension PreviewNavigationView {
  
  @objc fileprivate  func didTappedBackButton(_ button: UIButton) {
    delegate?.didTappedButton(with: .back, button: button)
  }
  

  @objc fileprivate func didTappedQuitButton(_ button: UIButton) {
    delegate?.didTappedButton(with: .quit, button: button)
  }
}
