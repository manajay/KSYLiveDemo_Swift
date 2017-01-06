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
