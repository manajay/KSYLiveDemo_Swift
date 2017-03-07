//
//  DeviceHelper.swift
//  LiveShowSwift
//
//  Created by ljduan on 2016/11/16.
//  Copyright © 2016年 manajay. All rights reserved.
//

import AVFoundation
import UIKit

//MARK: block
typealias HandleMessageBlock =
  (_ isSuccess:Bool ,
  _ message:String
  ) -> ()

class DeviceHelper {

}

typealias TorchCallBack = (_ isSuccess:Bool) -> ()

// MARK: - 手电筒
extension DeviceHelper {
    
    class func lockDeviceTorch(callback:TorchCallBack) {
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)!
    
    if !device.hasTorch {
        callback(false)
            return
        }
    
        //关闭手电筒
        do {
            try device.lockForConfiguration()
            device.torchMode = .off
            device.unlockForConfiguration()
            callback(true)

        } catch  {
            callback(false)
        }
    }
}


// MARK: - 音视频权限请求
extension DeviceHelper {

    class func requestAccessForVideo(hanler:@escaping HandleMessageBlock) {
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo);
        switch status  {
        // 许可对话没有出现，发起授权许可
        case AVAuthorizationStatus.notDetermined:
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted) in
                if(granted){
                    hanler(true,"已获取采集声音权限")
                }
            })
            break;
        // 已经开启授权，可继续
        case AVAuthorizationStatus.authorized:
            hanler(true,"已获取采集声音权限")
            break;
        // 用户明确地拒绝授权，或者相机设备无法访问
        case AVAuthorizationStatus.denied:
            hanler(false,"采集声音受限")
            break
        case AVAuthorizationStatus.restricted:
            hanler(false,"无权限采集声音")
            break;
        }
    }
    
    class func requestAccessForAudio(hanler:@escaping HandleMessageBlock) -> Void {

        let status = AVCaptureDevice.authorizationStatus(forMediaType:AVMediaTypeAudio)
        switch status  {
        // 许可对话没有出现，发起授权许可
        case AVAuthorizationStatus.notDetermined:
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeAudio, completionHandler: { (granted) in
                if(granted){
                    hanler(true,"已获取录像权限")
                }
            })
            break;
        // 已经开启授权，可继续
        case AVAuthorizationStatus.authorized:
            hanler(true,"已获取录像权限")
            break;
        // 用户明确地拒绝授权，或者相机设备无法访问
        case AVAuthorizationStatus.denied:
            hanler(false,"录像受限")
            break
        case AVAuthorizationStatus.restricted:
            hanler(false,"录像受限")
            break;
        }
    }

    
}



enum CaptureAccessStatus: Int {
  
  case notDetermined
  
  case restricted
  
  case denied
  
  case authorized
  
}

protocol AVCaptureAccessProtocal {
  
  // 默认实现
  func requestAccessForVideo()
  func requestAccessForAudio()
  
  //  需要实现
  func requestAccessForVideo(authorizationStatus: CaptureAccessStatus , statusMesasge: String)
  func requestAccessForAudio(authorizationStatus: CaptureAccessStatus , statusMesasge: String)
}

extension AVCaptureAccessProtocal {
  
  /// 请求设备的相机权限
  func requestAccessForVideo() {
    let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo);
    switch status  {
    // 许可对话没有出现，发起授权许可
    case AVAuthorizationStatus.notDetermined:
      AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted) in
        if(granted){
          self.requestAccessForAudio(authorizationStatus: .authorized, statusMesasge: "已获取采集声音权限")
        } else {
          self.requestAccessForAudio(authorizationStatus: .notDetermined, statusMesasge: "采集声音权限未知")
        }
      })
      break;
    // 已经开启授权，可继续
    case AVAuthorizationStatus.authorized:
      self.requestAccessForAudio(authorizationStatus: .authorized, statusMesasge: "已获取采集声音权限")
      break;
    // 用户明确地拒绝授权，或者设备无法访问
    case AVAuthorizationStatus.denied:
      self.requestAccessForAudio(authorizationStatus: .denied, statusMesasge: "无权限采集声音")
      break
    case AVAuthorizationStatus.restricted:
      self.requestAccessForAudio(authorizationStatus: .restricted, statusMesasge: "采集声音权限受限")
      break;
    }
  }
  
  
  /// 请求设备的声音权限
  func requestAccessForAudio() {
    let status = AVCaptureDevice.authorizationStatus(forMediaType:AVMediaTypeAudio)
    switch status  {
    // 许可对话没有出现，发起授权许可
    case AVAuthorizationStatus.notDetermined:
      AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeAudio, completionHandler: { (granted) in
        if(granted){
          self.requestAccessForVideo(authorizationStatus: .authorized, statusMesasge: "已获取录像权限")
        } else {
          self.requestAccessForVideo(authorizationStatus: .notDetermined, statusMesasge: "录像权限未知")
        }
      })
      break;
    // 已经开启授权，可继续
    case AVAuthorizationStatus.authorized:
      requestAccessForVideo(authorizationStatus: .authorized, statusMesasge: "已获取录像权限")
      break;
    // 用户明确地拒绝授权，或者相机设备无法访问
    case AVAuthorizationStatus.denied:
      requestAccessForVideo(authorizationStatus: .denied, statusMesasge: "没有录像权限")
      break
    case AVAuthorizationStatus.restricted:
      requestAccessForVideo(authorizationStatus: .restricted, statusMesasge: "录像受限")
      break;
    }
  }
}
