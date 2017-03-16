//
//  PreviewController.swift
//  LiveShowSwift
//
//  Created by ljduan on 2016/11/15.
//  Copyright © 2016年 manajay. All rights reserved.
//

import UIKit
import CoreImage
import GPUImage
import AVFoundation
import libksygpulive
import libksygpulive.KSYGPUStreamerKit

private let kPaddingY: CGFloat = 10
private let kPaddingX: CGFloat = 20

private let kHorizontalMargin: CGFloat = 10

private let kNagigationHeight: CGFloat = 40
private let kStatusViewHeight: CGFloat = 60
private let kControlViewHeight: CGFloat = 40


class PreviewController: UIViewController {
  
  var orientation:ScreenOrientation
  var viewModel: PreviewViewModel!

  fileprivate var allowRotate = false
  fileprivate var isLiveSelected = false

  var streamQuality:StreamQuality
  var address: String = ""
  
  init(streamQuality:StreamQuality = .normal,
                   orientation:ScreenOrientation = .landscapeRight) {
    self.streamQuality = streamQuality
    self.orientation = orientation
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  fileprivate var streamerKit: KSYGPUStreamerKit?
  
  fileprivate lazy var filter: KSYBeautifyFaceFilter = {
    let filter = KSYBeautifyFaceFilter()
    return filter!
  }()
  
  // 视图容器
  fileprivate lazy var containerView: UIView = {
    let containerView = UIView(frame: .zero)
    containerView.layer.contentsRect = CGRect(x: 0, y: 0, width: 0.8, height: 1)
    
    let image = UIImage(named: "compose_background")?.cgImage
    containerView.layer.contents = image
//    containerView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleHeight]
    return containerView
  }()
  
  /// 记录是否在 直播
  fileprivate var recording: Bool = false
  fileprivate var recordTimer:Timer?
  fileprivate var recordInterval:TimeInterval = 0{
    didSet{
      //处理日期
      let date = Date(timeIntervalSince1970: recordInterval)
      let dateFormat = DateFormatHelp.share
      dateFormat.timeZone = TimeZone(secondsFromGMT: 0)
      dateFormat.dateFormat = "HH:mm:ss"
      let dateString = dateFormat.string(from: date)
      
      // 主线程设置 ui
      DispatchQueue.main.async(execute: {
        self.statusView.recordLabel.text = "REC  " + dateString
      })
    }
  }
  // 手势
  fileprivate var currentPinchZoomFactor: CGFloat = 1.0
  fileprivate lazy var foucsCursor: UIImageView = {
    let imageView = UIImageView()
    imageView.image = #imageLiteral(resourceName: "camera_focus_red")
    imageView.frame = CGRect(x: 80, y: 80, width: 80, height: 80)
    imageView.alpha = 0.0
    return imageView
  }()
  
  fileprivate lazy var navigationView: PreviewNavigationView = {
    let navigationView = PreviewNavigationView(frame: .zero)
    navigationView.delegate = self
    navigationView.titleLabel.text = self.viewModel.shareTitle
    return navigationView
  }()
  
  fileprivate lazy var statusView: PreviewStatusView = {
    let statusView = PreviewStatusView()
    return statusView
  }()
  
  fileprivate lazy var controlView: PreviewControlView = {
    let controlView = PreviewControlView()
    controlView.delegate = self
    return controlView
  }()
  
  deinit {
    streamerKit?.streamerBase.stopStream()
    NotificationCenter.default.removeObserver(self)
    
    recordTimer?.invalidate()
    recordTimer = nil
  }
  
}

extension PreviewController {

  /***= {
   kit.streamerBase.shouldEnableKSYStatModule = true
   kit.vCapDev.interruptCallback = { (interrupt) in
   self.viewModel.writeToLocalFile(with: interrupt ? "被打断, 采集暂停": "恢复采集")
   }
   */
  
  // 1.0
  fileprivate func setCaptureConfiguration() {
    streamerKit?.cameraPosition = .back
//    streamerKit?.gpuOutputPixelFormat = 
//    streamerKit?.capturePixelFormat =
    streamerKit?.videoOrientation = orientation.preferredInterfaceOrientationForPresentation

    streamerKit?.videoProcessingCallback = { (buf) -> Void in
      // 在此处添加自定义图像处理, 直接修改buf中的图像数据会传递到观众端
      // 或复制图像数据之后再做其他处理, 则观众端仍然看到处理前的图像
    }
    
    streamerKit?.audioProcessingCallback = { (buf) -> Void in
      // 在此处添加自定义音频处理, 直接修改buf中的pcm数据会传递到观众端
      // 或复制音频数据之后再做其他处理, 则观众端仍然听到原始声音
    }
    streamerKit?.previewDimension = self.streamQuality.streamDimension
    streamerKit?.videoFPS = 18
    
    streamerKit?.interruptCallback = { (bInterrupt) -> Void in
      // 在此处添加自定义图像采集被打断的处理 (比如接听电话等)
      Log(bInterrupt ? "采集被打断" : "采集很顺畅")
      self.viewModel.writeToLocalFile(with: bInterrupt ? "采集被打断" : "采集很顺畅")
    }
    
    if KSYAVAudioSession.isBluetoothInputAvaible() == true {
      AVAudioSession.sharedInstance().currentMicType = .bluetoothMic
    }
  }
  
  // 2.0 推流的参数设置 must set after capture
  fileprivate func setStreamerConfiguration() {
    
    guard let _ = streamerKit?.streamerBase else {
      return
    }
    
    //      streamerKit?.capPreset =

    streamerKit?.streamDimension = self.streamQuality.streamDimension
    streamerKit?.streamerBase.videoCodec = KSYVideoCodec.AUTO
    
    //      streamerKit?.streamerBase.videoInitBitrate =  self.streamQuality.rawValue
    streamerKit?.streamerBase.videoMaxBitrate = self.streamQuality.videoMaxBitrate
    streamerKit?.streamerBase.videoMinBitrate = self.streamQuality.videoMinBitrate
    //      streamerKit?.streamerBase.audioCodec =
    streamerKit?.streamerBase.audiokBPS = self.streamQuality.audiokBPS
    streamerKit?.streamerBase.videoFPS = 18
    streamerKit?.streamerBase.maxKeyInterval        =   self.streamQuality.maxKeyInterval //  关键帧
    //      streamerKit?.streamerBase.bwEstimateMode =
    streamerKit?.streamerBase.logBlock  = { (msg) in
      if let msg = msg {
        Log(msg)
        self.viewModel.writeToLocalFile(with: msg)
        #if DEBUG
        #endif
      }
    }
  }
  
}

// MARK: - View Life Circle
extension PreviewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    if streamerKit == nil {
      streamerKit = KSYGPUStreamerKit(defaultCfg: ())
    }
//    streamerKit?.streamerProfile = KSYStreamerProfile(rawValue: presetCfgView!.curProfileIdx)!

    setupUI()
    addObservers()
    
    // 采集相关设置初始化
    setCaptureConfiguration()
    //推流相关设置初始化
    setStreamerConfiguration()
    // 打印版本号信息
    Log(streamerKit?.getKSYVersion())
    
    layoutSubviews()
    setPreviewFrame()

    addRecordTimer()
    
  }
  
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    UIApplication.shared.isIdleTimerDisabled = true
    Log("\(self.view.frame)")
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    UIApplication.shared.isIdleTimerDisabled = false
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
  }
  
}


// MARK: - Setup UI
extension PreviewController {
  
  fileprivate func setupUI() {
    
    view.backgroundColor = .clear
    view.addSubview(containerView)
    
    containerView.addSubview(foucsCursor)
    containerView.addSubview(navigationView)
    containerView.addSubview(statusView)
    containerView.addSubview(controlView)

  }
  
  fileprivate func layoutSubviews() {
    containerView.frame = CGRect(x: 0, y: 0, width: orientation.fullScreenWidth, height: orientation.fullScreenHeight)
    let width =  orientation.fullScreenWidth - kPaddingX * 2
    navigationView.frame = CGRect(x: 5, y: kPaddingY + 10 , width: orientation.fullScreenWidth - 15, height: kNagigationHeight)
    statusView.frame = CGRect(x: kPaddingX, y: navigationView.frame.maxY + kPaddingY, width: width, height: kStatusViewHeight)
    controlView.frame = CGRect(x: kPaddingX, y: orientation.fullScreenHeight - kControlViewHeight - kPaddingY, width: width, height: kControlViewHeight)
  }
  
  fileprivate func setPreviewFrame() { //
    
    ///@warning: 开始推流前必须先启动预览
    ///@see videoDimension, cameraPosition, videoOrientation, videoFPS
    if streamerKit != nil {
//      streamerKit?.preview.frame =  CGRect(x: 0, y: 0, width: orientation.fullScreenWidth, height: orientation.fullScreenHeight)
      streamerKit?.setupFilter(filter)
      streamerKit?.startPreview(containerView)
//      streamerKit?.preview.frame =  CGRect(x: 0, y: 0, width: orientation.fullScreenWidth, height: orientation.fullScreenHeight)
    }
  }

}


// MARK: - NotificationCenter
extension PreviewController {
  
  /// 添加所有的通知操作
  fileprivate func addObservers() {
    NotificationCenter.default.addObserver(self, selector: #selector(onCaptureStateChange(_:)), name: NSNotification.Name.KSYCaptureStateDidChange, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(onStreamStateChange(_:)), name: NSNotification.Name.KSYStreamStateDidChange, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(onNetStateEvent(_:)), name: NSNotification.Name.KSYNetStateEvent, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(enterBg(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(becameActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    
    setupShareNotification()
  }
  
  
  /// 添加监听分享通知
  private func setupShareNotification() -> () {
    
    NotificationCenter.default.addObserver(forName: AppNotification.kShareLiveInfoEvent,// 通知名称，通知中心用来识别通知的
      object: nil,// 发送通知的对象，如果为nil，监听任何对象
      queue: nil,// nil，主线程
      using: { //防止循环引用 [weak self]
        (notification) in
        
        guard let resp = notification.userInfo?["resp"] as? BaseResp else {
          return
        }
        
        ShareHelper.manager.dismiss()
        let code = resp.errCode
        if code == WXSuccess.rawValue {
        } else if code == WXErrCodeUserCancel.rawValue {
        }
        
    })
    
  }
  
  /// 网络状态的通知 - 收到后的操作
  ///
  /// - Parameter notification: 网络状态的通知
  @objc fileprivate func onNetStateEvent(_ notification:Notification) {
    guard let streamerKit = streamerKit else { return }
    
    let netStatus = streamerKit.streamerBase.getCurKSYStreamErrorCodeName() ?? "网络错误日志"
    self.viewModel.writeToLocalFile(with: netStatus)

    switch streamerKit.streamerBase.netStateCode {
    case .SEND_PACKET_SLOW:
      Log("单次发送包时间过长")
    case .EST_BW_RAISE:
      Log("估计带宽调整,上调")
    case .EST_BW_DROP:
      Log("估计带宽调整,下调")
    default: break
    }
    
  }
  
  /// 推流状态的通知 后的操作
  ///
  /// - Parameter notification: 推流状态的通知
  @objc fileprivate func onStreamStateChange(_ notification:Notification) {
    guard let streamerKit = streamerKit else { return }
    
    let netStatus = streamerKit.streamerBase.getCurStreamStateName() ?? "网络状态"
    self.viewModel.writeToLocalFile(with: netStatus)
    
    switch streamerKit.streamerBase.streamState {
    case .error:
      statusView.stateLabel.text = "连接错误"
      recording = false
      Log("连接错误: \(streamerKit.streamerBase.streamErrorCode.rawValue)")
      //处理错误
      onStream(error: streamerKit.streamerBase.streamErrorCode)
    case .connecting:
      statusView.stateLabel.text = "连接中"
      recording = false
    case .connected:
      statusView.stateLabel.text = "已连接"
      recording = true
    case .disconnecting:
      statusView.stateLabel.text = "断开连接中"
      recording = false
    case .idle:
      statusView.stateLabel.text = "未连接"
      recording = false
    }
    
  }
  
  
  /// 处理网络推流错误
  ///
  /// - Parameter error: 网络推流错误
  fileprivate func onStream(error: KSYStreamErrorCode) {
    switch error {
      case .CONNECT_BREAK:
        tryReconnect()
      case .AV_SYNC_ERROR:
        tryReconnect()
      case .CODEC_OPEN_FAILED:
        streamerKit?.streamerBase.videoCodec = KSYVideoCodec.X264
        tryReconnect()
      default: break
    }
    Log("网络推流错误码: \(error.rawValue)")
    self.viewModel.writeToLocalFile(with: "网络推流错误码: \(error.rawValue)")
    #if DEBUG
    #endif
  }
  
  
  /// 推流重连
  fileprivate func tryReconnect() {
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
      if let url = self.viewModel.streamURL {
        self.streamerKit?.streamerBase.startStream(url)
      }
    }
  }
  
  @objc fileprivate func enterBg(_ notification:Notification) {
    streamerKit?.appEnterBackground()
  }
  
  @objc fileprivate func becameActive(_ notification:Notification) {
    streamerKit?.appBecomeActive()
  }

  
  /**
   KSYCaptureStateIdle	设备空闲中
   KSYCaptureStateCapturing	设备工作中
   KSYCaptureStateDevAuthDenied	设备授权被拒绝
   KSYCaptureStateClosingCapture	关闭采集设备中
   KSYCaptureStateParameterError	参数错误，无法打开（比如设置的分辨率，码率当前设备不支持）
   */
  /// 采集摄像头状态改变的通知
  ///
  /// - Parameter notification: 像头状态改变的通知
  @objc fileprivate func onCaptureStateChange(_ notification:Notification) {
    Log(notification)
    self.viewModel.writeToLocalFile(with: "网络推流onCaptureStateChange: \(notification)")
    Log("\(view.frame)")
  }
  
}

// MARK: - Update State
extension PreviewController {
  
  /// 激活记录推流时间的定时器
  fileprivate func addRecordTimer() {
    recordTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimer(_:)), userInfo: nil, repeats: true)
  }
  
  @objc private func onTimer(_ timer: Timer) {
    guard let streamerKit = streamerKit else { return }
    guard streamerKit.streamerBase.streamState == .connected, recording == true ,isLiveSelected == true else { return }
    guard streamerKit.streamerBase.encodedFrames > 0 else {
      statusView.fluentPercentageLabel.text =  "| 流畅度: 0%"
      return
    }
    /// 防崩溃处理
    statusView.fluentPercentageLabel.text = viewModel.updateStreamState(droppedVideoFrames: Double(streamerKit.streamerBase.droppedVideoFrames), encodedFrames: Double(streamerKit.streamerBase.encodedFrames))
    recordInterval += 1
  }
  
}


extension PreviewController: PreviewControlViewDelegate,PreviewNavigationViewDelegate{
  func didTappedButton(with type: ControlButtonType, button: UIButton) {
    switch type {
    case .light:
      didTappedLightButton(button)
    case .camera:
      didTappedCameraButton(button)
    case .beauty:
      didTappedBeautyButton(button)
    case .share:
      didTappedShareButton(button)
    case .start:
      didTappedStartLiveButton(button)
    }
  }
  
  func didTappedButton(with type: NavigationButtonType, button: UIButton) {
    switch type {
    case .back:
      didTappedBackButton(button)
    case .quit:
      didTappedQuitButton(button)
    }
  }
  
  /// 点击返回按钮
  private func didTappedBackButton(_ button: UIButton) -> Void {
    dismiss(animated: true)
  }
  
  /// 点击退出
  private func didTappedQuitButton(_ button: UIButton) {
    dismiss(animated: false) {
      self.quitAfterNextStep()
    }
  }
  
  private func quitAfterNextStep() {
   
  }
  
  /// 点击直播开关按钮
  private func didTappedStartLiveButton(_ button: UIButton) -> Void {
    
    guard let url = self.viewModel.streamURL  else {
//      MSProgressView.show(message: "无效直播地址")
      return
    }
    
    button.isSelected = !button.isSelected;
    isLiveSelected = button.isSelected
    
    if button.isSelected  == false  { //关闭推流
      streamerKit?.streamerBase.stopStream()
      return
    }
    
    if button.isSelected { // 推流
      streamerKit?.streamerBase.startStream(url);
      viewModel.uploadLiveLocation()
      return
    }
    
  }
  
  // 点击美颜按钮
  private func didTappedBeautyButton(_ button: UIButton) -> Void {
    if button.isSelected {
      streamerKit?.setupFilter(nil)
    } else {
      streamerKit?.setupFilter(filter)
    }
    
    button.isSelected = !button.isSelected
  }
  
  /// 点击分享按钮
  private func didTappedShareButton(_ button: UIButton) -> Void {
    ShareHelper.manager.showIn(view: self.view, delegate: self)
  }
  
  
  // 摄像头
  private func didTappedCameraButton(_ button: UIButton) -> Void {
    streamerKit?.switchCamera()
  }
  
  // 关闭 手电筒
  private func didTappedLightButton(_ button: UIButton) -> Void  {
    guard let streamerKit = streamerKit else { return }
    guard let vCapDev = streamerKit.vCapDev, streamerKit.isTorchSupported() else { return }
    if vCapDev.cameraPosition() == AVCaptureDevicePosition.back {
      streamerKit.toggleTorch()
    } else {
      
    }
    button.isSelected = !button.isSelected
  }
  
}


// MARK: - Share
extension PreviewController:ShareProtocal {
  
  func share(to place: SharePlace) {
    
    let manager = ShareManager.manager
    manager.shareTitle = viewModel.shareTitle
    manager.shareURL = viewModel.shareURLString
    manager.shareDetail = viewModel.shareSummary
    manager.shareImage = viewModel.shareImage
    
    
    switch place {
    case .frendCircle:
      manager.type =  WXSceneTimeline.rawValue
      manager.actionShare { (isSuccess) in
        if isSuccess == false {
//          MSProgressView.show(message: "未安装微信客户端")
        }
      }
    case .friend:
      manager.type = WXSceneSession.rawValue
      manager.actionShare { (isSuccess) in
        if isSuccess == false {
//          MSProgressView.show(message: "未安装微信客户端")
        }
      }
    case .pasteBoard:
      let pasteBoard = UIPasteboard.general
      pasteBoard.string = viewModel.shareURLString
//      MSProgressView.show(message: "直播链接已复制到剪切板")
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
    //当前触摸点再view上的点
    let current = touch.location(in: self.view);
    //    触摸点再view上之前的位置
    //    let pointOfBefor = touch?.previousLocation(in: self.view);
    //触摸点，是否在当前视图上
    //    let isInView = self.view.point(inside: pointInView!, with: event);
    //点，再某个视图上的坐标
    //    let viewPoint = self.view.convert(pointOfBefor!, to: self.view);
    let point = convertToPointOfInterest(from: current)
    
    streamerKit?.exposure(at: point)
    streamerKit?.focus(at: point)
    
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
    let frameSize = view.frame.size
    let apertureSize = streamerKit?.captureDimension() ?? .zero
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
    guard let streamerKit = streamerKit else { return }
    if recognizer.state == UIGestureRecognizerState.began {
      currentPinchZoomFactor = streamerKit.pinchZoomFactor
    }
    let zoomFactor = currentPinchZoomFactor * recognizer.scale //当前触摸缩放因子*坐标比例
    streamerKit.pinchZoomFactor = zoomFactor
  }
  
}

// MARK: - Device Rotation
extension PreviewController {
  
  func canRotate() -> Void {}
  
  override var shouldAutorotate: Bool {
    Log("\(view.frame)")
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
    
    coordinator.animate(alongsideTransition: nil) { (_) in
      Log("\(self.view.frame)")
    }
    super.viewWillTransition(to: size, with: coordinator)
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

