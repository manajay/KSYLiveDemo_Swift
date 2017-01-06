
//
//  PreviewAutoController.swift
//  LiveDemo
//
//  Created by manajay on 2017/1/5.
//  Copyright © 2017年 manajay. All rights reserved.
//

//
//  PreviewAutoController.swift
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

class PreviewAutoController: UIViewController {
  
  var orientation:ScreenOrientation = .portrait
  var address: String = "rtmp://115.29.150.217/live/mobile"
  
  fileprivate lazy var kit: KSYGPUStreamerKit = {
    let kit = KSYGPUStreamerKit()
    
    kit.videoFPS = 15
    kit.streamerBase.videoCodec = KSYVideoCodec.AUTO
    kit.streamerBase.videoInitBitrate =  800
    kit.streamerBase.videoMaxBitrate  = 1000
    kit.streamerBase.videoMinBitrate  =  200
    kit.streamerBase.audiokBPS        =   48
    kit.streamerBase.shouldEnableKSYStatModule = true
    kit.setupFilter(self.filter)
    
    kit.cameraPosition  = .back
    kit.streamerBase.videoFPS = 20
    kit.maxAutoRetry  = 10
    kit.streamerBase.logBlock  = { (msg) in
      print(msg)
    }
    
    kit.videoProcessingCallback = {
      (buf) in
      // 在此处添加自定义图像处理, 直接修改buf中的图像数据会传递到观众端
      // 或复制图像数据之后再做其他处理, 则观众端仍然看到处理前的图像
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
    //    containerView.backgroundColor = UIColor.clear
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
  
  
  /// 记录是否在 直播
  fileprivate var recording: Bool = false
  
  // 灯光
  fileprivate lazy var lightButton: UIButton = {
    let lightButton = UIButton(frame: CGRect.zero)
    lightButton.setImage(#imageLiteral(resourceName: "light_black"), for: .normal)
    lightButton.setImage(#imageLiteral(resourceName: "light_open"), for: .selected)
    return lightButton
  }()
  
  // 摄像头
  fileprivate var cameraButton: UIButton = {
    let cameraButton = UIButton(frame: CGRect.zero)
    cameraButton.setImage(#imageLiteral(resourceName: "camera_reverse"), for: .normal)
    return cameraButton
  }()
  
  // 美颜
  fileprivate var beautyButton: UIButton = {
    let beautyButton = UIButton(frame: CGRect.zero)
    beautyButton.setImage(#imageLiteral(resourceName: "beauty_magic_open"), for: UIControlState.selected)
    beautyButton.setImage(#imageLiteral(resourceName: "beauty_magic"), for: .normal)
    return beautyButton
  }()
  
  // 开始直播按钮
  fileprivate var startLiveButton: UIButton = {
    let startLiveButton = UIButton(frame: CGRect.zero)
    startLiveButton.setImage(#imageLiteral(resourceName: "live_start"), for: .normal)
    startLiveButton.setImage(#imageLiteral(resourceName: "live_stop"), for: .selected)
    return startLiveButton
  }()
  
  // 直播标题按钮
  fileprivate var titleButton: UIButton = {
    let button = UIButton(frame: CGRect.zero)
    button.setTitleColor(UIColor.white, for:UIControlState())
    button.setImage(#imageLiteral(resourceName: "leftArrow"), for: .normal)
    button.setTitle(" 在线直播", for: .normal)
    button.titleLabel!.font = UIFont.systemFont(ofSize: 18)
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
}


// MARK: - View Life Circle
extension PreviewAutoController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initObservers()
    
    setupPreview()
    addTargetAction()
    
    kit.videoFPS = 15
    onCapture(orientation)
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
    navigationController?.setNavigationBarHidden(false, animated: false)
    UIApplication.shared.isIdleTimerDisabled = false
    orientationTo(.portrait)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    removeObs()
    kit.stopPreview()
  }
  
}


// MARK: - 屏幕旋转
extension PreviewAutoController {
  
  fileprivate func onCapture(_ orientation: ScreenOrientation) {
    
    if (kit.vCapDev.isRunning == false){
      kit.videoOrientation = UIApplication.shared.statusBarOrientation
      kit.startPreview(containerView)
    }
    else {
      kit.stopPreview()
    }
    
  }
  
  fileprivate func orientationTo(_ orientation: UIInterfaceOrientation) {
    let orientationValue = orientation.rawValue
    UIDevice.current.setValue(orientationValue, forKey: "orientation")
  }
  
  func canRotate() -> Void {
    
  }
  
  override var shouldAutorotate: Bool {
    return true
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return .allButUpsideDown
  }
  
  override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
    return .portrait
  }
  
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    Log(message: "size: \(size) coordinator: \(coordinator)")
    
    kit.rotatePreview(to: UIApplication.shared.statusBarOrientation)
    
    super.viewWillTransition(to: size, with: coordinator)
  }
  
}


// MARK: - Setup UI
extension PreviewAutoController {
  
  fileprivate func setupPreview() {
    
    view.backgroundColor = UIColor.clear
    view.addSubview(containerView)
    
    
    containerView.addSubview(stateLabel)
    containerView.addSubview(beautyButton)
    containerView.addSubview(cameraButton)
    containerView.addSubview(startLiveButton)
    
    containerView.addSubview(titleButton)
    containerView.addSubview(recordIcon)
    containerView.addSubview(recordLabel)
    
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
    
    
    //  美颜按钮 选中状态
    beautyButton.isSelected = true
    
  }
}


// MARK: - 初始化观察者
extension PreviewAutoController {
  
  fileprivate func initObservers() {
    
    NotificationCenter.default.addObserver(self, selector: #selector(onCaptureStateChange(_:)), name: NSNotification.Name.KSYCaptureStateDidChange, object: nil)
    //    NotificationCenter.default.addObserver(self, selector: #selector(onBgmPlayerStateChange(_:)), name: NSNotification.Name.KSYAudioStateDidChange, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(onStreamStateChange(_:)), name: NSNotification.Name.KSYStreamStateDidChange, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(onNetStateEvent(_:)), name: NSNotification.Name.KSYNetStateEvent, object: nil)
    
    
    NotificationCenter.default.addObserver(self, selector: #selector(enterBg(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(becameActive(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    
  }
  
  fileprivate func removeObs() {
    NotificationCenter.default.removeObserver(self)
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
      kit.streamerBase.videoCodec = KSYVideoCodec.X264
      tryReconnect()
    default: break
    }
  }
  
  fileprivate func tryReconnect() {
    
    if kit.maxAutoRetry > 0 {
      return
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
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
  
  @objc fileprivate func onBgmPlayerStateChange(_ notification:Notification) { // 背景播放音乐
    // kit.bgmPlayer
  }
  @objc fileprivate func onCaptureStateChange(_ notification:Notification) {
    Log(message: notification)
    switch orientation {
    case .landscapeRight:
      orientationTo(.landscapeRight)
    default:
      orientationTo(.portrait)
    }
    
    // 解决横屏的时候出现没有画面的bug,本质是preview的size为zero引起的.
    if kit.vCapDev.isRunning {
      kit.preview.snp.makeConstraints({ (make) in
        make.edges.equalToSuperview()
      })
    }
    
  }
  
  
}

// MARK: - Gesture
extension PreviewAutoController {
  
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
extension PreviewAutoController {
  
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
    self.dismiss()
  }
  
  fileprivate func dismiss() {
    
    dismiss(animated: true) {
      self.orientationTo(.portrait)
    }
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
    } else {
      
    }
    
  }
  
}

