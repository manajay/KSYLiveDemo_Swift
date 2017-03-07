//
//  FileManager+Extension.swift
//  LiveShowSwift
//
//  Created by ljduan on 2016/11/3.
//  Copyright © 2016年 manajay. All rights reserved.
//

import UIKit

typealias ResourcePath = (_ filePath:String ,_ fileName:String) -> ()

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

// sqlite数据库文件目录
let dbPath = documentPath + "juyun.sqlite"

func remakeDbPath() {
    if !FileManager.default.fileExists(atPath:dbPath){
        //获取安装包内数据库路径
        let bundleDBPath:String? = Bundle.main.path(forResource: "juyun", ofType: "sqlite")
        //将安装包内数据库拷贝到Documents目录下
        
        do {
            try FileManager.default.copyItem(atPath: bundleDBPath!, toPath: dbPath)
        } catch let error as NSError {
            debugPrint( error)
        }
        
    }
}


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
  
  
  /// 缓存目录的大小
  public var cachesPathSize:Double {
    return FileManager.fileSize(at: cachesPath) + FileManager.fileSize(at: kVideoPath)
  }
  
  /// 清除指定路径的文件缓存 , 建议子线程操作
  /// 清除 缓存目录下的文件
  class func clearPathFolder(at path:String) -> HandleResultTuples{
    
    let fileArr = FileManager.default.subpaths(atPath: path)
    
    //快速枚举出 所有文件名
    
    guard let files = fileArr else {
      return (true,"操作成功")
    }
    
    for file in files {
      
      //过滤文件 Snapshots(权限问题)
      if file.contain("Snapshots") {
        continue
      }
      
      //把文件名拼接到路径中
      let filePath = path + "/\(file)"
      if FileManager.default.fileExists(atPath: filePath) {
        do {
          try FileManager.default.removeItem(atPath: filePath)
        } catch let error as NSError {
          debugPrint( error)
          return (false,error.description)
        }
      }
    }
    return (true,"操作成功")
  }// end func
  
  /// 清除 缓存目录下的文件
  class func clearCachesPathFolder() -> HandleResultTuples{
    
    _ = FileManager.clearPathFolder(at: kVideoPath)
    
    return FileManager.clearPathFolder(at: cachesPath)
  }// end func
  
  
  
  class func clearImageCache(filePath:String) -> HandleResultTuples {
    do {
      try FileManager.default.removeItem(atPath: filePath)
      return (true,"操作成功")
    } catch _ as NSError {
      return (false,"文件不存在")
    }
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



