//
//  PreviewStatusView.swift
//  LiveShowSwift
//
//  Created by manajay on 14/03/2017.
//  Copyright © 2017 manajay. All rights reserved.
//

import UIKit


private let kLabelHeight: CGFloat = 25
private let kRecordLabelWidth: CGFloat = 130

private let kPaddingX: CGFloat = 0
private let kHorizontalMargin: CGFloat = 10


class PreviewStatusView: UIView {

  // 状态Label
   var stateLabel: UILabel = {
    let stateLabel = UILabel(frame: CGRect.zero)
    stateLabel.text = "未连接"
    stateLabel.textColor = UIColor.white
    stateLabel.font = UIFont.systemFont(ofSize: 14.0)
    return stateLabel
  }()
  
  // 直播流程百分比Label
   var fluentPercentageLabel: UILabel = {
    let fluentPercentageLabel = UILabel(frame: CGRect.zero)
    fluentPercentageLabel.text = ""
    fluentPercentageLabel.textColor = UIColor.white
    fluentPercentageLabel.font = UIFont.systemFont(ofSize: 14.0)
    fluentPercentageLabel.textAlignment = .left
    return fluentPercentageLabel
  }()
  
  /// 倒计时的label
   var recordLabel: UILabel = {
    let label = UILabel(frame: CGRect.zero)
    label.text = "REC  00:00:00"
    label.textColor = UIColor.white
    label.font = UIFont.systemFont(ofSize: 15.0)
    return label
  }()
  
  fileprivate lazy var recordIcon: UIImageView = {
    let view = UIImageView(image: #imageLiteral(resourceName: "record_red"))
    return view
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
    layout()
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

extension PreviewStatusView {

}

// MARK: - UI
extension PreviewStatusView {
  
  fileprivate func setupUI(){
    addSubview(recordIcon)
    addSubview(recordLabel)
    addSubview(stateLabel)
    addSubview(fluentPercentageLabel)
  }
  
  fileprivate func layout() {
    recordIcon.frame = CGRect(x: kPaddingX, y: (kLabelHeight - 15) * 0.5, width: 15, height: 15)
    let recordLabelX = recordIcon.frame.maxX + kHorizontalMargin
    recordLabel.frame = CGRect(x: recordLabelX, y: 0, width: kRecordLabelWidth, height: kLabelHeight)
    let fluentPercentageLabelX = recordLabel.frame.maxX
    fluentPercentageLabel.frame = CGRect(x: fluentPercentageLabelX, y: recordLabel.frame.minY, width: frame.width - fluentPercentageLabelX, height: kLabelHeight)
    
    stateLabel.frame = CGRect(x: kPaddingX, y: recordLabel.frame.maxY + kHorizontalMargin, width: frame.width - kPaddingX, height: kLabelHeight)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
  }
  
}
