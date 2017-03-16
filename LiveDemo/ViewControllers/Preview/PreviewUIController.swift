//
//  PreviewUIController.swift
//  LiveShowSwift
//
//  Created by manajay on 14/03/2017.
//  Copyright © 2017 manajay. All rights reserved.
//

import UIKit

private let kPaddingX: CGFloat = 20
private let kPaddingY: CGFloat = 10

private let kHorizontalMargin: CGFloat = 10

private let kNagigationHeight: CGFloat = 40
private let kStatusViewHeight: CGFloat = 60
private let kControlViewHeight: CGFloat = 40

class PreviewUIController: UIViewController {
  
  var orientation:ScreenOrientation
  var viewModel: PreviewViewModel!

  fileprivate var allowRotate = false

  
  init(orientation:ScreenOrientation = .landscapeRight) {
    self.orientation = orientation
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // 视图容器
  fileprivate lazy var containerView: UIView = {
    let containerView = UIView(frame: .zero)
    containerView.layer.contentsRect = CGRect(x: 0, y: 0, width: 0.8, height: 1)
    
    let image = UIImage(named: "compose_background")?.cgImage
    containerView.layer.contents = image
    containerView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleHeight]
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
    recordTimer?.invalidate()
    recordTimer = nil
  }
  
}

extension PreviewUIController: PreviewControlViewDelegate ,PreviewNavigationViewDelegate {
  
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
    _ = dismiss(animated: false) {
    }
  }
  
  /// 点击直播开关按钮
  private func didTappedStartLiveButton(_ button: UIButton) -> Void {
    
    
    
  }
  
  // 点击美颜按钮
  private func didTappedBeautyButton(_ button: UIButton) -> Void {
  }
  
  /// 点击分享按钮
  private func didTappedShareButton(_ button: UIButton) -> Void {
    
  }
  
  
  // 摄像头
  private func didTappedCameraButton(_ button: UIButton) -> Void {
    
  }
  
  // 关闭 手电筒
  private func didTappedLightButton(_ button: UIButton) -> Void  {
  }
  
}

// MARK: - View Life Circle
extension PreviewUIController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    Log("viewDidLoad ---: \(view.frame)")
    addObservers()
    setupUI()
    preparePreview()
    addRecordTimer()
    
  }
  
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    UIApplication.shared.isIdleTimerDisabled = true
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
extension PreviewUIController {
  
  fileprivate func setupUI() {
    
    view.backgroundColor = .clear
    view.addSubview(containerView)
    
    containerView.addSubview(foucsCursor)
    containerView.addSubview(navigationView)
    containerView.addSubview(statusView)
    containerView.addSubview(controlView)
    
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    containerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
    
    navigationView.frame = CGRect(x: 5, y: kPaddingY + 10 , width: view.frame.width - 15, height: kNagigationHeight)
    let width =  view.frame.width - kPaddingX * 2
    statusView.frame = CGRect(x: kPaddingX, y: navigationView.frame.maxY + kPaddingY, width:  width, height: kStatusViewHeight)
    controlView.frame = CGRect(x: kPaddingX, y: view.frame.height - kControlViewHeight - kPaddingY, width:  width, height: kControlViewHeight)
  }
}


// MARK: - NotificationCenter
extension PreviewUIController {
  
  /// 添加所有的通知操作
  fileprivate func addObservers() {
  }
  
  
  /// 添加监听分享通知
  private func setupShareNotification() -> () {
  }
  
  /// 网络状态的通知 - 收到后的操作
  ///
  /// - Parameter notification: 网络状态的通知
  @objc fileprivate func onNetStateEvent(_ notification:Notification) {
  }
  
  /// 推流状态的通知 后的操作
  ///
  /// - Parameter notification: 推流状态的通知
  @objc fileprivate func onStreamStateChange(_ notification:Notification) {
  }
  
  
  /// 推流重连
  fileprivate func tryReconnect() {
    
  }
  
  @objc fileprivate func enterBg(_ notification:Notification) {
    
  }
  
  @objc fileprivate func becameActive(_ notification:Notification) {
    
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
    Log("onCaptureStateChange--- \(view.frame)")
    onViewRotate()
  }
  
  /// 设备旋转时 更改推流的预览方向
  fileprivate func onViewRotate() {
  }
  
  /// 调整预览是否开启的状态
  fileprivate func preparePreview() {
  }
  
  
}

// MARK: - Update State
extension PreviewUIController {
  
  /// 激活记录推流时间的定时器
  fileprivate func addRecordTimer() {
    recordTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimer(_:)), userInfo: nil, repeats: true)
  }
  
  @objc private func onTimer(_ timer: Timer) {
    recordInterval += 1
  }
  
}

// MARK: - Gesture
extension PreviewUIController {
  
  fileprivate func addPinchGestureRecognizer() {
    let pin = UIPinchGestureRecognizer(target: self, action: #selector(pinchDetected(_:)))
    containerView.addGestureRecognizer(pin)
  }
  
  @objc fileprivate func pinchDetected(_ recognizer: UIPinchGestureRecognizer) {
    if recognizer.state == UIGestureRecognizerState.began {
      
    }
    let _ = currentPinchZoomFactor * recognizer.scale //当前触摸缩放因子*坐标比例
    
  }
  
}

// MARK: - Device Rotation
extension PreviewUIController {
  
  func canRotate() -> Void {}
  
  override var shouldAutorotate: Bool {
    Log("shouldAutorotate--: \(view.frame)")
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
      Log("viewWillTransition-- \(self.view.frame)")
      self.onViewRotate()
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
