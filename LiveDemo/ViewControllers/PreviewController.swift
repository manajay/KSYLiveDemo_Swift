//
//  PreviewController.swift
//  LiveDemo
//
//  Created by manajay on 2017/1/5.
//  Copyright © 2017年 manajay. All rights reserved.
//

import Foundation

import UIKit
import CoreImage
import GPUImage
import AVFoundation
import libksygpulive
import libksygpulive.KSYGPUStreamerKit
import SnapKit

private let topMargin:CGFloat = 20

private let topBtnMargin:CGFloat = 30
private let topHMargin:CGFloat = 20

private let bottomVMargin:CGFloat = 10

private let closeButtonWidth:CGFloat = 40

class PreviewController: UIViewController {
  
  var orientation:ScreenOrientation = .portrait
  var streamQuality:StreamQuality
  fileprivate var allowRotate = false

  var address: String = "rtmp://xxxxxx/live/mobile"

  init(streamQuality:StreamQuality = .normal,
       orientation:ScreenOrientation = .landscapeRight) {
    self.streamQuality = streamQuality
    self.orientation = orientation
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  fileprivate lazy var kit: KSYGPUStreamerKit = {
    let kit = KSYGPUStreamerKit()
    
    kit.videoFPS = 18
    kit.streamerBase.videoCodec = KSYVideoCodec.AUTO
    kit.streamerBase.videoInitBitrate =  self.streamQuality.rawValue
    kit.streamerBase.videoMaxBitrate  = self.streamQuality.videoMaxBitrate //1000
    kit.streamerBase.videoMinBitrate  = self.streamQuality.videoMinBitrate // 200
    kit.streamerBase.audiokBPS        =   self.streamQuality.audiokBPS // 48
    kit.streamerBase.maxKeyInterval        =   self.streamQuality.maxKeyInterval //  关键帧
    kit.streamerBase.shouldEnableKSYStatModule = true
    kit.setupFilter(self.filter)
    kit.streamDimension = self.streamQuality.streamDimension
    kit.cameraPosition  = .back
    //    kit.maxAutoRetry = 10
    kit.streamerBase.videoFPS = 18
    kit.streamerBase.logBlock  = { (msg) in
      if let msg = msg {
        self.writeToLocalFile(with: msg)
        #if DEBUG
        #endif
      }
    }
    
    
    kit.vCapDev.interruptCallback = { (interrupt) in
      self.writeToLocalFile(with: interrupt ? "被打断, 采集暂停": "恢复采集")
    }
    
    return kit
  }()
  
  fileprivate lazy var filter: KSYBeautifyFaceFilter = {
    let filter = KSYBeautifyFaceFilter()
    return filter!
  }()
  
  // 视图
  fileprivate lazy var containerView: UIView = {
    let containerView = UIView(frame: CGRect.zero)
    containerView.layer.contentsRect = CGRect(x: 0, y: 0, width: 0.8, height: 1)
    let image = UIImage(named: "compose_background")?.cgImage
    containerView.layer.contents = image
    containerView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleHeight]
    return containerView
  }()
  
  // 状态Label
  fileprivate var stateLabel: UILabel = {
    let stateLabel = UILabel(frame: CGRect.zero)
    stateLabel.text = "未连接"
    stateLabel.textColor = UIColor.white
    stateLabel.font = UIFont.systemFont(ofSize: 14.0)
    return stateLabel
  }()
  
  
  // 直播流程百分比Label
  fileprivate var fluentPercentageLabel: UILabel = {
    let fluentPercentageLabel = UILabel(frame: CGRect.zero)
    fluentPercentageLabel.text = ""
    fluentPercentageLabel.textColor = UIColor.white
    fluentPercentageLabel.font = UIFont.systemFont(ofSize: 14.0)
    fluentPercentageLabel.textAlignment = .center
    return fluentPercentageLabel
  }()
  
  /// 倒计时的label
  fileprivate var recordLabel: UILabel = {
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
  
  fileprivate var recordTimer:Timer?
 
  fileprivate var recordInterval:TimeInterval = 0{
    didSet{
      //处理日期
      Log(message: "记录的时间:\(recordInterval)")
      let date = Date(timeIntervalSince1970: recordInterval)
      let dateFormat = DateFormatHelp.share
      dateFormat.timeZone = TimeZone(secondsFromGMT: 0)
      dateFormat.dateFormat = "HH:mm:ss"
      
      let dateString = dateFormat.string(from: date)
      
      // 主线程设置 ui
      DispatchQueue.main.async(execute: {
        self.recordLabel.text = "REC  " + dateString
      })
      
    }
  }
  
  
  
  /// 记录是否在 直播
  fileprivate var recording: Bool = false
  
  // 灯光
  fileprivate lazy var lightButton: UIButton = {
    let lightButton = UIButton(frame: CGRect.zero)
    lightButton.setImage(#imageLiteral(resourceName: "light_black"), for: .normal)
    lightButton.setImage(#imageLiteral(resourceName: "light_open"), for: .selected)
    lightButton.isExclusiveTouch = true
    return lightButton
  }()
  
  // 摄像头
  fileprivate var cameraButton: UIButton = {
    let cameraButton = UIButton(frame: CGRect.zero)
    cameraButton.setImage(#imageLiteral(resourceName: "camera_reverse"), for: .normal)
    cameraButton.isExclusiveTouch = true
    return cameraButton
  }()
  
  // 美颜
  fileprivate var beautyButton: UIButton = {
    let beautyButton = UIButton(frame: CGRect.zero)
    beautyButton.setImage(#imageLiteral(resourceName: "beauty_magic_open"), for: UIControlState.selected)
    beautyButton.setImage(#imageLiteral(resourceName: "beauty_magic"), for: .normal)
    //  美颜按钮 选中状态
    beautyButton.isSelected = true
    beautyButton.isExclusiveTouch = true
    return beautyButton
  }()
  
  // 开始直播按钮
  fileprivate var startLiveButton: UIButton = {
    let startLiveButton = UIButton(frame: CGRect.zero)
    startLiveButton.setImage(#imageLiteral(resourceName: "live_start"), for: .normal)
    startLiveButton.setImage(#imageLiteral(resourceName: "live_stop"), for: .selected)
    startLiveButton.isExclusiveTouch = true
    return startLiveButton
  }()
  
  // 直播标题按钮
  fileprivate var titleButton: UIButton = {
    let button = UIButton(frame: CGRect.zero)
    button.setTitleColor(UIColor.white, for:UIControlState())
    button.setImage(#imageLiteral(resourceName: "bleft"), for: .normal)
    button.setTitle(" 在线直播", for: .normal)
    button.titleLabel!.font = UIFont.systemFont(ofSize: 18)
    button.isExclusiveTouch = true
    return button
  }()
  
  // 手势
  fileprivate var currentPinchZoomFactor: CGFloat = 1.0
  
  fileprivate lazy var foucsCursor: UIImageView = {
    let imageView = UIImageView()
    imageView.image = #imageLiteral(resourceName: "camera_focus_red")
    imageView.frame = CGRect(x: 80, y: 80, width: 80, height: 80)
    imageView.alpha = 0.0
    return imageView
  }()
  
  deinit {
    kit.streamerBase.stopStream()
    NotificationCenter.default.removeObserver(self)
    recordTimer?.invalidate()
    recordTimer = nil
  }
}


// MARK: - View Life Circle
extension PreviewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    addObservers()
    setupPreview()
    preparePreview()
    addTargetAction()
    addRecordTimer()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: false)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    UIApplication.shared.isIdleTimerDisabled = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    UIApplication.shared.isIdleTimerDisabled = false
  }
  
}


// MARK: - Setup UI
extension PreviewController {
  
  fileprivate func setupPreview() {
    
    view.backgroundColor = .clear
    view.addSubview(containerView)
    
    containerView.addSubview(stateLabel)
    containerView.addSubview(beautyButton)
    containerView.addSubview(cameraButton)
    containerView.addSubview(startLiveButton)
    
    containerView.addSubview(titleButton)
    containerView.addSubview(recordIcon)
    containerView.addSubview(recordLabel)
    containerView.addSubview(fluentPercentageLabel)

    containerView.addSubview(lightButton)
    containerView.addSubview(foucsCursor)
    
    // 布局
    containerView.snp.makeConstraints { (make) in
      make.edges.equalToSuperview()
    }
    
    titleButton.snp.makeConstraints { (make) in
      make.top.equalTo(containerView.snp.top).offset(topMargin)
      make.left.equalTo(containerView).offset(bottomVMargin)
    }
    
    recordIcon.snp.makeConstraints { (make) in
      make.top.equalTo(titleButton.snp.bottom).offset(topMargin);
      make.left.equalTo(titleButton).offset(bottomVMargin)
    }
    
    recordLabel.snp.makeConstraints { (make) in
      make.centerY.equalTo(recordIcon)
      make.left.equalTo(recordIcon.snp.right).offset(bottomVMargin)
    }
    
    stateLabel.snp.makeConstraints { (make) in
      make.top.equalTo(recordIcon.snp.bottom).offset(topMargin)
      make.left.equalTo(recordIcon)
      make.height.equalTo(40)
      make.width.equalTo(80)
    }
    
    fluentPercentageLabel.snp.makeConstraints { (make) in
      make.centerY.equalTo(recordLabel)
      make.left.equalTo(recordLabel.snp.right).offset(5)
    }
    
    startLiveButton.snp.makeConstraints { (make) in
      make.bottom.equalTo(containerView.snp.bottom).offset(-bottomVMargin)
      make.right.equalTo(containerView.snp.right).offset(-topBtnMargin)
      make.height.equalTo(40);
      make.width.equalTo(40);
    }
    
    lightButton.snp.makeConstraints { (make) in
      make.bottom.equalTo(containerView.snp.bottom).offset(-bottomVMargin)
      make.left.equalTo(containerView.snp.left).offset(topBtnMargin)
      
      make.height.equalTo(40)
      make.width.equalTo(40)
    }
    
    cameraButton.snp.makeConstraints { (make) in
      make.bottom.equalTo(containerView.snp.bottom).offset(-bottomVMargin)
      make.left.equalTo(lightButton.snp.right).offset(topBtnMargin * 0.5)
      
      make.height.equalTo(40)
      make.width.equalTo(40)
    }
    
    
    beautyButton.snp.makeConstraints { (make) in
      make.bottom.equalTo(containerView.snp.bottom).offset(-bottomVMargin)
      make.left.equalTo(cameraButton.snp.right).offset(topBtnMargin * 0.5)
      make.height.equalTo(40)
      make.width.equalTo(40)
    }
    
  }
}


// MARK: - 初始化观察者
extension PreviewController {
  
  fileprivate func addObservers() {
    
    NotificationCenter.default.addObserver(self, selector: #selector(onCaptureStateChange(_:)), name: NSNotification.Name.KSYCaptureStateDidChange, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(onStreamStateChange(_:)), name: NSNotification.Name.KSYStreamStateDidChange, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(onNetStateEvent(_:)), name: NSNotification.Name.KSYNetStateEvent, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(enterBg(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(becameActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    
  }
  
  @objc fileprivate func onNetStateEvent(_ notification:Notification) {
    switch kit.streamerBase.netStateCode {
    case .SEND_PACKET_SLOW:
      Log(message: "单次发送包时间过长")
    case .EST_BW_RAISE:
      Log(message: "估计带宽调整,上调")
    case .EST_BW_DROP:
      Log(message: "估计带宽调整,下调")
    default: break
    }
  }
  
  
  @objc fileprivate func onStreamStateChange(_ notification:Notification) {
    
    switch kit.streamerBase.streamState {
    case .error:
      stateLabel.text = "连接错误"
      recording = false
      Log(message: "连接错误: \(kit.streamerBase.streamErrorCode.rawValue)")
      //处理错误
      onStream(error: kit.streamerBase.streamErrorCode)
      
    case .connecting:
      stateLabel.text = "连接中"
      recording = false
    case .connected:
      stateLabel.text = "已连接"
      recording = true
    case .disconnecting:
      stateLabel.text = "断开连接中"
      recording = false
    case .idle:
      stateLabel.text = "未连接"
      recording = false
    }
    
  }
  
  fileprivate func onStream(error: KSYStreamErrorCode) {
    switch error {
    case .CONNECT_BREAK:
      tryReconnect()
    case .AV_SYNC_ERROR:
      tryReconnect()
    case .CODEC_OPEN_FAILED:
      tryReconnect()
    default: break
    }
    self.writeToLocalFile(with: "网络推流错误码: \(error.rawValue)")
  }
  
//WARNING: 这里的 kit.maxAutoRetry 是不是处理错了
  fileprivate func tryReconnect() {
    
//    if kit.maxAutoRetry > 0 {
//      return
//    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
      if let url = URL(string: self.address) {
        self.kit.streamerBase.startStream(url)
      }
    }
    
    
  }
  
  
  @objc fileprivate func enterBg(_ notification:Notification) {
    kit.appEnterBackground()
  }
  
  @objc fileprivate func becameActive(_ notification:Notification) {
    kit.appBecomeActive()
  }
  
  @objc fileprivate func onCaptureStateChange(_ notification:Notification) {
    onViewRotate()
  }
  
  /// 设备旋转时 更改推流的预览方向
  fileprivate func onViewRotate() {
    
    if kit.vCapDev.isRunning  {
      guard let _ = kit.preview.superview  else { return }
      kit.preview.snp.remakeConstraints({ (make) in
        make.edges.equalToSuperview()
      })
    }
    kit.rotatePreview(to: orientation.preferredInterfaceOrientationForPresentation)
  }
  
  fileprivate func preparePreview() {
    if (kit.vCapDev.isRunning == false){ //没有开始直播
      kit.videoOrientation = orientation.preferredInterfaceOrientationForPresentation
      kit.rotatePreview(to: orientation.preferredInterfaceOrientationForPresentation)
      kit.startPreview(containerView)
    }
    else {
      kit.stopPreview()
    }
  }
  
  
}

// MARK: - Gesture
extension PreviewController {
  
  //设置摄像头对焦位置
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    guard let touch = touches.first else {
      return
    }
    
    let current = touch.location(in: self.view);
    let point = convertToPointOfInterest(from: current)
    
    kit.exposure(at: point)
    kit.focus(at: point)
    
    //对焦框
    foucsCursor.center = current
    foucsCursor.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
    foucsCursor.alpha = 1.0
    UIView.animate(withDuration: 1.0, animations: {
      self.foucsCursor.transform = CGAffineTransform.identity
    }, completion: { (_) in
      self.foucsCursor.alpha = 0.0
    })
    
  }
  
  
  // 将UI的坐标转换成相机坐标
  func convertToPointOfInterest(from viewCoordinates: CGPoint) -> CGPoint {
    var pointOfInterest = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
    let frameSize = self.view.frame.size
    let apertureSize = kit.captureDimension()
    let point = viewCoordinates
    let apertureRatio: CGFloat = apertureSize.height / apertureSize.width
    let viewRatio: CGFloat = frameSize.width / frameSize.height
    
    var xc: CGFloat = 0.5
    var yc: CGFloat = 0.5
    if viewRatio > apertureRatio {
      let y2: CGFloat = frameSize.height
      let x2: CGFloat = frameSize.height * apertureRatio
      let x1: CGFloat = frameSize.width
      let blackBar: CGFloat = (x1 - x2) / 2
      if point.x >= blackBar && point.x <= blackBar + x2 {
        xc = point.y / y2
        yc = 1.0 - ((point.x - blackBar) / x2)
      }
    }
    else {
      let y2: CGFloat = frameSize.width / apertureRatio
      let y1: CGFloat = frameSize.height
      let x2: CGFloat = frameSize.width
      let blackBar: CGFloat = (y1 - y2) / 2
      if point.y >= blackBar && point.y <= blackBar + y2 {
        xc = ((point.y - blackBar) / y2)
        yc = 1.0 - (point.x / x2)
      }
    }
    pointOfInterest = CGPoint(x: xc, y: yc)
    return pointOfInterest
  }
  
  
  fileprivate func addPinchGestureRecognizer() {
    let pin = UIPinchGestureRecognizer(target: self, action: #selector(pinchDetected(_:)))
    containerView.addGestureRecognizer(pin)
  }
  
  @objc fileprivate func pinchDetected(_ recognizer: UIPinchGestureRecognizer) {
    if recognizer.state == UIGestureRecognizerState.began {
      currentPinchZoomFactor = kit.pinchZoomFactor
    }
    
    let zoomFactor = currentPinchZoomFactor * recognizer.scale //当前触摸缩放因子*坐标比例
    kit.pinchZoomFactor = zoomFactor
    
  }
  
}

// MARK: - Action
extension PreviewController {
  
  fileprivate func addTargetAction() {
    // action buttons
    
    cameraButton.addTarget(self, action: #selector(didTappedCameraButton(_:)), for:.touchUpInside)
    beautyButton.addTarget(self, action: #selector(didTappedBeautyButton(_:)), for: .touchUpInside)
    startLiveButton.addTarget(self, action: #selector(didTappedStartLiveButton(_:)), for: .touchUpInside)
    lightButton.addTarget(self, action: #selector(didTappedLightButton(_:)), for: .touchUpInside)
    
    addPinchGestureRecognizer()
    titleButton.addTarget(self, action: #selector(didTappedTitleLiveButton(_:)), for: .touchUpInside)
    
  }
  
  @objc fileprivate func didTappedTitleLiveButton(_ button: UIButton) -> Void {
    recordTimer?.invalidate()
    dismiss(animated: true)
  }
  
  // 开始直播
  @objc fileprivate  func didTappedStartLiveButton(_ button: UIButton) -> Void {
    startLiveButton.isSelected = !startLiveButton.isSelected;
    
    guard startLiveButton.isSelected else {
      kit.streamerBase.stopStream()
      return
    }
    
    if let url = URL(string: address) {
      kit.streamerBase.startStream(url);
    } else {
        self.stateLabel.text = "无效的链接地址"
    }
    
  }
  
  // 美颜
  @objc fileprivate func didTappedBeautyButton(_ button: UIButton) -> Void {
    
    if beautyButton.isSelected {
      kit.setupFilter(nil)
    } else {
      kit.setupFilter(filter)
    }
    
    beautyButton.isSelected = !beautyButton.isSelected
    
  }
  
  // 摄像头
  @objc fileprivate func didTappedCameraButton(_ button: UIButton) -> Void {
    kit.switchCamera()
  }
  
  // 关闭 手电筒
  @objc fileprivate func didTappedLightButton(_ button: UIButton) -> Void  {
    
    guard let vCapDev = kit.vCapDev, kit.isTorchSupported() else { return }
    if vCapDev.cameraPosition() == AVCaptureDevicePosition.back {
      kit.toggleTorch()
    } else {}
  }
  
}


// MARK: - 计算与写入
extension PreviewController {

  func updateStreamState(droppedVideoFrames: Double , encodedFrames: Double) -> String {
    
    if encodedFrames == 0 {
      return "| 流畅度: \(0)%"
    }
    
    var percentage = 1 - droppedVideoFrames / encodedFrames
    
    if percentage == Double.nan {
      percentage = 0.0
    } else if percentage == Double.infinity {
      percentage = 1.0
    }
    
    if percentage <= 0.0 {
      percentage = 0.0
    } else if percentage >= 1.0 {
      percentage = 1.0
    }
    
    
    ////Double value cannot be converted to Int because it is either infinite or NaN
    // 崩溃在这里
    let percentageInt =  Int(percentage * 100)
    return "| 流畅度: \(percentageInt)%"
  }

  
  fileprivate func writeToLocalFile(with data: Data) {
    FileManager.valid(filePath: kStreamInfoFolder)
    let streamInfoPath = (kStreamInfoFolder as NSString).appendingPathComponent("streamInfo.txt")
    FileManager.fileExists(at: streamInfoPath)
    do {
      let writeHandler = try FileHandle(forWritingTo: URL(fileURLWithPath: streamInfoPath))
      writeHandler.seekToEndOfFile()
      writeHandler.write(data)
    } catch let _ {
      
    }
  }
  
  fileprivate func writeToLocalFile(with streamInfo: String) {
    let dateFormat = DateFormatHelp.share
    dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let dateString = "推流时间:" + dateFormat.string(from: Date()) + "      \n 推流内容: "
    let composeString = (dateString + streamInfo + "\n                                                                       \n")
    if let data = composeString.data(using: .utf8) {
      writeToLocalFile(with: data)
    }
  }

  /// 激活记录推流时间的定时器
  fileprivate func addRecordTimer() {
    recordTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimer(_:)), userInfo: nil, repeats: true)
  }
  
  @objc private func onTimer(_ timer: Timer) {
    guard kit.streamerBase.streamState == .connected, recording == true ,startLiveButton.isSelected == true else { return }
    /// 防崩溃处理
    
    fluentPercentageLabel.text = updateStreamState(droppedVideoFrames: Double(kit.streamerBase.droppedVideoFrames), encodedFrames: Double(kit.streamerBase.encodedFrames))
    recordInterval += 1
  }
  
}

// MARK: - Device Rotation
extension PreviewController {
  
  func canRotate() -> Void {}
  
  override var shouldAutorotate: Bool {
    return allowRotate
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return orientation.supportedInterfaceOrientations
  }
  
  override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
    return orientation.preferredInterfaceOrientationForPresentation
  }
  
  // 横屏还是有点问题
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    kit.rotatePreview(to: orientation.preferredInterfaceOrientationForPresentation)
  }
  
  override var prefersStatusBarHidden: Bool{
    return false
  }
  
  // 当调用 rotate(to: UIInterfaceOrientation.landscapeLeft) 时，先允许自动旋转，然后进行屏幕旋转。再设置为不允许自动旋转。
  fileprivate func rotate(to orientation: UIInterfaceOrientation) {
    UIDevice.rotationDevice(before: {
      allowRotate = true
    }, after: {
      allowRotate = false
    }, to: orientation)
  }
}


/// 单例 DateFormatter
class DateFormatHelp:DateFormatter {
  
  private static let shareInstance = DateFormatHelp()
  
  class var share:DateFormatHelp {
    
    shareInstance.timeZone = TimeZone.current
    shareInstance.locale = Locale.current
    
    return shareInstance
  }
}

func Log<T>(message : T, file : String = #file, lineNumber : Int = #line) {
  
  #if DEBUG
    let fileName = (file as NSString).lastPathComponent
    let printMessage = "[\(fileName):line:\(lineNumber)]- \(message)"
    print(printMessage)
  #endif
}

