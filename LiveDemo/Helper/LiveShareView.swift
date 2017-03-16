//
//  LiveShareView.swift
//  LiveShowSwift
//
//  Created by ljduan on 2016/11/3.
//  Copyright © 2016年 manajay. All rights reserved.
//

private let ITEM_WIDTH:CGFloat  = 80
private let ITEM_HEIGHT:CGFloat = 80

private let MARGIN:CGFloat = ITEM_HEIGHT * 0.5 + 5
private let LabelFontSize:CGFloat = 17
private let LabelImageMargin:CGFloat = 30
private let IconFontSize:CGFloat = 58


class LiveShareView:UIView {
  
  public var delegate:ShareProtocal?
  
  //    button.setTitleColor(UIColor(hex:0x4EB029), for: .normal)
  fileprivate lazy var friendButton: UIButton = {
    let button = UIButton(type: UIButtonType.custom)
    button.setImage(#imageLiteral(resourceName: "friend"), for: .normal)
    button.setTitle("微信朋友", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: LabelFontSize)
    button.addTarget(self, action: #selector(friendClick), for: .touchUpInside)
    return button
  }()
  
  fileprivate lazy var friendCircleButton: UIButton = {
    let button = UIButton(type: UIButtonType.custom)
    button.setImage(#imageLiteral(resourceName: "friend_circle"), for: .normal)
    button.setTitle("朋友圈", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: LabelFontSize)
    button.addTarget(self, action: #selector(friendCircleClick), for: .touchUpInside)
    return button
  }()
  
  fileprivate lazy var copyLinkButton: UIButton = {
    let button = UIButton(type: UIButtonType.custom)
    button.setImage(#imageLiteral(resourceName: "copyLink"), for: .normal)
    button.setTitle("复制链接", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: LabelFontSize)
    button.addTarget(self, action: #selector(copyLinkClick), for: .touchUpInside)
    return button
  }()
  
  fileprivate lazy var friendLabel: UILabel = {
    let label = UILabel()
    label.text = "微信朋友"
    label.textColor = .white
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: LabelFontSize)
    return label
  }()
  
  fileprivate lazy var friendCircleLabel: UILabel = {
    let label = UILabel()
    label.text = "朋友圈"
    label.textColor = .white
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: LabelFontSize)
    return label
  }()
  
  fileprivate lazy var copyLinkLabel: UILabel = {
    let label = UILabel()
    label.text = "复制链接"
    label.textColor = .white
    label.textAlignment = .center
    label.font = UIFont.systemFont(ofSize: LabelFontSize)
    return label
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
    addDissmissAction()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

}


// MARK: - UI
extension LiveShareView {
  
  fileprivate func setupUI() -> () {
    
    backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.75)
    addSubview(friendButton)
    addSubview(friendCircleButton)
    addSubview(copyLinkButton)
    
    // snp
    friendButton.snp.makeConstraints { (make) in
      make.centerX.equalTo(self).offset(-2 * MARGIN)
      make.centerY.equalTo(self)
      make.width.height.equalTo(ITEM_WIDTH)
    }
    
    friendCircleButton.snp.makeConstraints { (make) in
      make.centerX.equalTo(self)
      make.centerY.equalTo(self)
      make.width.height.equalTo(ITEM_WIDTH)
    }
    
    copyLinkButton.snp.makeConstraints { (make) in
      make.centerX.equalTo(self).offset( 2 * MARGIN)
      make.centerY.equalTo(self)
      make.width.height.equalTo(ITEM_WIDTH)
    }
    
  }
  
  fileprivate func addDissmissAction() -> () {
    let dismissTap =  UITapGestureRecognizer(target: self, action: #selector(dismissAction))
    self.addGestureRecognizer(dismissTap)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    friendButton.layoutButton(with: .top, imageTitleSpace: LabelImageMargin)
    friendCircleButton.layoutButton(with: .top, imageTitleSpace: LabelImageMargin)
    copyLinkButton.layoutButton(with: .top, imageTitleSpace: LabelImageMargin)
  }
  
}


// MARK: - PUBLIC
extension LiveShareView {

  func dismissAction() -> () {
    UIView.animate(withDuration: 0.3, animations: {
      self.frame.origin.y = self.frame.size.height
    }, completion: {(isDone) in
      self.removeFromSuperview()
    })
  }
  
}


// MARK: - ACTION
extension LiveShareView {
  
  @objc fileprivate func friendCircleClick() -> () {
    self.delegate?.share(to: .frendCircle)
  }
  
  @objc fileprivate func friendClick() -> () {
    self.delegate?.share(to: .friend)
  }
  
  
  @objc fileprivate func copyLinkClick() -> () {
    self.delegate?.share(to: .pasteBoard)
  }
}
