//
//  ShareManager.swift
//  LiveShowSwift
//
//  Created by manajay on 23/02/2017.
//  Copyright © 2017 manajay. All rights reserved.
//

import UIKit

class ShareManager {

  var shareTitle: String?
  var shareImageUrl: String?
  var shareImage: UIImage?
  var shareDetail: String?
  var shareURL: String?
  var type: UInt32 = 0
  
  private static let shareInstance = ShareManager()
  
  class var manager:ShareManager {
    return shareInstance
  }
  
  
}

typealias ShareCallback = (_ isSuccess: Bool) -> ()

extension ShareManager {

  fileprivate func clearInfo( ) -> () {
    self.shareTitle = nil
    self.shareImage = nil
    self.shareImageUrl = nil
    self.shareDetail = nil
    self.shareURL = nil
    self.shareTitle = nil
    self.type = 0
  }
  
  func actionShare(handler: ShareCallback){
    
    if !WXApi.isWXAppInstalled() {
      handler(false)
    }
    
    if let image = shareImage {
      
      let message = WXMediaMessage()
      
      if let title = shareTitle {
        message.title = title
      }
      
      var dataImage: Data? = UIImagePNGRepresentation(image)
      if dataImage == nil {
        dataImage = UIImageJPEGRepresentation(image, 1.0)
      }
      
      if let data = dataImage   {
        let sizeOrigin = data.count
        let sizesizeOriginKB  = sizeOrigin / 1024
        
        if sizesizeOriginKB > 32 {
          let a: CFloat = 32.00000
          let b: CFloat = CFloat(sizesizeOriginKB)
          let q: CFloat = sqrt(a/b)
          let sizeImage: CGSize = image.size
          let iwidthSmall: CGFloat = sizeImage.width * CGFloat(q)
          let iheightSmall: CGFloat = sizeImage.height * CGFloat(q)
          let itemSizeSmall: CGSize = CGSize(width: iwidthSmall, height: iheightSmall)
          UIGraphicsBeginImageContext(itemSizeSmall)
          let imageRectSmall: CGRect = CGRect(x: 0, y: 0, width: iwidthSmall, height: iheightSmall)
          image.draw(in: imageRectSmall)
          let smallImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
          UIGraphicsEndImageContext()
          message.setThumbImage(smallImage)
        } else {
          message.setThumbImage(image)
        }
        
      }
      
      
      //
      if let url = shareURL , let des = shareDetail {
        let web =  WXWebpageObject()
        
        web.webpageUrl = url;
        
        message.description = des;
        
        message.mediaObject = web;
      }
      
      let req = SendMessageToWXReq()
      req.bText = false
      
      req.message = message;
      
      if let title = shareTitle {
        req.text = title
      }
      
      req.scene = Int32(type)
      
      WXApi.send(req)
      
    } else { //
      
      let message = WXMediaMessage()
      
      if let title = shareTitle {
        message.title = title
      }
      
      
      if let url = shareURL , let des = shareDetail {
        let web =  WXWebpageObject()
        
        web.webpageUrl = url;
        message.description = des;
        
        message.mediaObject = web;
      }
      
      
      let req =  SendMessageToWXReq()
      req.bText = true
      req.message = message;
      
      if let title = shareTitle {
        req.text = title
      }
      req.scene = Int32(type)
      WXApi.send(req)
    }
    
    handler(true)
  }
  
}
