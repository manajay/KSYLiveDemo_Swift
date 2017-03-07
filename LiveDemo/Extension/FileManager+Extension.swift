//
//  FileManager+Extension.swift
//  LiveShowSwift
//
//  Created by ljduan on 2016/11/3.
//  Copyright © 2016年 manajay. All rights reserved.
//

import UIKit

typealias ResourcePath = (_ filePath:String ,_ fileName:String) -> ()
/// 处理结果的回调, 成功与否, 返回信息
typealias HandleResultTuples = (isSuccess:Bool, message:String)

// MARK: - 路径相关
//
// App沙盒路径
let appBoxPath = NSHomeDirectory()

// Documents路径
let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!

// Library目录 路径 () 包括 Caches牡蛎 和 Preferences目录 平时使用的偏好设置目录
let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!

// Caches目录
let cachesPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!

let kVideoPath = (documentPath as NSString).appendingPathComponent("UpLoadVideoFolder")

let kStreamInfoFolder = (documentPath as NSString).appendingPathComponent("StreamInfoFolder")


// tmp目录  ./tmp
let tmpPath = NSTemporaryDirectory()

// 程序打包安装的目录 Bundle.main
/**
 工程打包安装后会在Bundle.main路径下，该路径是只读的，不允许修改。
 所以当我们工程中有一个SQLite数据库要使用，在程序启动时，我们可以把该路径下的数据库拷贝一份到Documents路径下，以后整个工程都将操作Documents路径下的数据库。
 */
let bundlePath = Bundle.main

extension FileManager {

  /// 根据路径 获取 文件的大小
  ///
  /// - parameter filePath: 文件路径
  ///
  /// - returns: 文件大小
  class func fileSizeAtPath(filePath:String) -> UInt64 {
    let manager = FileManager.default
    var fileSize:UInt64?
    if manager.fileExists(atPath: filePath) {
      do {
        if let attr: NSDictionary = try manager.attributesOfItem(atPath: filePath) as NSDictionary? {
          fileSize = UInt64(attr.fileSize())
        }
      } catch let error as NSError {
        debugPrint(error)
        return 0
      }
    }
    
    return fileSize ?? 0;
  }
  
  class func fileSize(at path: String) -> Double {
    
    //取出文件夹下面的所有目录
    let fileArray = FileManager.default.subpaths(atPath: path)
    
    guard let fileArr = fileArray else {
      return 0.0
    }
    
    //快速枚举出 所有文件名, 计算出文件大小
    var size = 0.0
    for file in fileArr {
      //把文件名拼接到路径中
      let filePath = path + "/\(file)"
      // 取出文件属性
      let folder = try! FileManager.default.attributesOfItem(atPath: filePath)
      for (attributeKey , value) in folder { //bytes
        // 累计文件大小
        if attributeKey == FileAttributeKey.size{
          size += value as! Double
        }
      }
    }
    
    let mm = size / 1024.0 / 1024.0
    debugPrint( "目录:\(path) -> 大小:\(mm)M")
    return mm
  }
  
    class func valid(filePath: String) {
    
    var isDir:ObjCBool = ObjCBool(false)
    let manager = FileManager.default
    
    let isExist = manager.fileExists(atPath: filePath, isDirectory: &isDir)
    
    if !isExist || (isExist && !(isDir.boolValue)) {
      let error: Error? = nil
      //可以建立多级目录
      do {
        try manager.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
      }
      catch {
      }
      if error == nil {
        debugPrint( "目录创建成功")
      }
      else {
        debugPrint( "目录创建失败")
      }
    }
  }
  
  class func fileExists(at filePath: String) {
    if !FileManager.default.fileExists(atPath: filePath)  {
      FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
    }
  }
  
  
}



