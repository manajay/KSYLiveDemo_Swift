//
//  ShareHelper.swift
//  LiveShowSwift
//
//  Created by manajay on 2016/11/4.
//  Copyright © 2016年 manajay. All rights reserved.
//

import UIKit


enum SharePlace {
  case friend ,frendCircle , pasteBoard
}

protocol ShareProtocal {
  func share(to place: SharePlace)
}

class ShareHelper: NSObject{
    
    var shareTitle:String?
    var shareImageUrl:String?
    var shareImage:UIImage?
    var shareDetail:String?
    var shareURL:String?
    var type:UInt32 = 0
    
    var shareView:LiveShareView?
    
    private static let shareInstance = ShareHelper()
    
    class var manager:ShareHelper {
        return shareInstance
    }
    
    func showIn(view:UIView ,delegate :ShareProtocal) {
        self.shareView =  LiveShareView(frame: view.frame)
        self.shareView?.frame.origin.y = view.frame.size.height
        view.addSubview(self.shareView!)
        self.shareView?.delegate = delegate
        
        UIView.animate(withDuration: 0.3, animations: {
            self.shareView?.frame.origin.y = 0
        })
    }
    
    func dismiss() {
        self.clearInfo()
        self.shareView?.dismissAction()
        self.shareView = nil
    }
    
   fileprivate func clearInfo( ) -> () {
        self.shareTitle = nil
        self.shareImage = nil
        self.shareImageUrl = nil
        self.shareDetail = nil
        self.shareURL = nil
        self.shareTitle = nil
        self.type = 0
    }
    
    func actionShare() -> Bool {
        
        if !WXApi.isWXAppInstalled() {
//            MSProgressView.show(message: "抱歉,您未安装微信客户端")
            return false
        }
        let manager = ShareHelper.manager
      
      
        if let image = manager.shareImage {
            
            let message = WXMediaMessage()
            
            if let title = manager.shareTitle {
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
            if let url = manager.shareURL , let des = manager.shareDetail {
                let web =  WXWebpageObject()
                
                web.webpageUrl = url;
                
                message.description = des;
                
                message.mediaObject = web;
            }
            
            let req = SendMessageToWXReq()
            req.bText = false
            
            req.message = message;
            
            if let title = manager.shareTitle {
                req.text = title
            }
            
            req.scene = Int32(type)
            
            WXApi.send(req)

        } else { //
            
            let message = WXMediaMessage()
            
            if let title = manager.shareTitle {
                message.title = title
            }
            
            
            if let url = manager.shareURL , let des = manager.shareDetail {
                let web =  WXWebpageObject()
                
                web.webpageUrl = url;
                message.description = des;
                
                message.mediaObject = web;
            }

            
            let req =  SendMessageToWXReq()
            req.bText = true
            req.message = message;

            if let title = manager.shareTitle {
                req.text = title
            }
            req.scene = Int32(type)
            WXApi.send(req)
        }
        
        return true
    }
}
