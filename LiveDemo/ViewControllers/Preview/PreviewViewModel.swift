//
//  PreviewViewModel.swift
//  LiveShowSwift
//
//  Created by ljduan on 2016/11/8.
//  Copyright © 2016年 manajay. All rights reserved.
//

import UIKit

/// 直播状态改变
class PreviewViewModel {
  
  /// 推流的地址
  var streamURL: URL?
  
  var liveID: Int {
  
    return 0
  }

  // MARK: - Share
  
  fileprivate var privateShareImage: UIImage?{
    return nil
  }
  
  var shareImage: UIImage {
    return #imageLiteral(resourceName: "shareImage")
  }
  
  var shareURLString: String {
    
    return "http://juyun.tv"
  }
  
  
  var shareTitle: String {
    
    return "聚现-直播现场"
  }
  
  var shareSummary: String {
    return "聚现-直播现场"
  }
  
  

}


// MARK: - Update state
extension PreviewViewModel {

  
  /// 更新直播的地理位置
  func uploadLiveLocation() {
   
  }
  
}


// MARK: - 分享
extension PreviewViewModel {
  
  /// 获取分享数据中的图片对象
  fileprivate  func fetchShareImage() {
  }
}

extension PreviewViewModel {
  
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
    } catch let error {
    }
  }
  
  func writeToLocalFile(with streamInfo: String) {
    let dateFormat = DateFormatHelp.share
    dateFormat.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let dateString = "推流时间:" + dateFormat.string(from: Date()) + "      \n 推流内容: "
    let composeString = (dateString + streamInfo + "\n                                                                       \n")
    if let data = composeString.data(using: .utf8) {
      writeToLocalFile(with: data)
    }
  }
  
}


